# -*- coding: utf-8 -*-
"""
OpenPMU - PUBX04 Timestamp from PHC (Precision Time Protocol - PTP)
Copyright (C) 2024  www.OpenPMU.org

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

import subprocess
import datetime
import time
import serial
import operator
from functools import reduce

# Global settings
LEAP_SECONDS_UTC = 37       # Note: Leap Seconds differ for GPS epoch / UTC epoch
SEND_DELAY_MS = 0.075       # Delay of 75 ms after the second transition
USE_MILLISECONDS = False    # Set to False if you want the millisecond field to be 0 in PUBX04

# UART setup: Change this to match your hardware
UART_PORT = '/dev/serial0'      # Must be enabled in raspi-config
BAUD_RATE = 19200

# Example PUBX,04 from ublox 7M
#          utc_time  date   utc_tow   wno  ls clk_b   clk_d      pg CS
# $PUBX,04,202604.00,150824,419164.00,2327,18,-672045,-11949.632,21*11
# $PUBX,04,202605.00,150824,419165.00,2327,18,-683995,-11949.632,21*1B

def get_phc_time():
    """Gets the PHC time from the network interface, adjusts for UTC by subtracting leap seconds."""
    result = subprocess.run(['phc_ctl', '/dev/ptp0', 'get'], capture_output=True, text=True)
    
    if result.returncode != 0:
        raise RuntimeError(f"phc_ctl command failed with error: {result.stderr}")
    
    for line in result.stdout.splitlines():
        if "clock time is" in line:
            try:
                timestamp_str = line.split("clock time is")[1].split()[0]  # Extract part after 'clock time is'
                timestamp = float(timestamp_str)  # Convert to float
                break
            except (IndexError, ValueError):
                raise RuntimeError("Failed to parse the timestamp from phc_ctl output.")
    else:
        raise RuntimeError("Unable to find 'clock time' in the phc_ctl output")
    
    phc_time_tai = datetime.datetime.utcfromtimestamp(timestamp)
    phc_time_utc = phc_time_tai - datetime.timedelta(seconds=LEAP_SECONDS_UTC)
    
    return phc_time_utc

def calculate_checksum(sentence):
    """Calculate NMEA checksum for the given sentence."""    
    calculated_checksum = reduce(operator.xor, (ord(s) for s in sentence), 0)
    
    return f"{calculated_checksum:02X}"

def calculate_gps_time(utc_now):
    """Calculate the GPS Week Number (UTC_WNO) and Time of Week (UTC_TOW) from a given UTC time."""
    gps_epoch = datetime.datetime(1980, 1, 6, tzinfo=datetime.timezone.utc)
    
    if utc_now.tzinfo is None:
        utc_now = utc_now.replace(tzinfo=datetime.timezone.utc)
    
    delta = utc_now - gps_epoch
    
    utc_wno = delta.days // 7
    utc_tow = (delta.days % 7) * 86400 + delta.seconds + utc_now.microsecond / 1e6
    
    return utc_tow, utc_wno

def create_pubx04_message_from_phc_time(phc_time, clk_b, clk_d, pg, leap_seconds_gps="15D",use_milliseconds=True):
    """Create PUBX04 message using PHC time and provided parameters."""
    utc_tow, utc_wno = calculate_gps_time(phc_time)
    
    if use_milliseconds:
        utc_time = phc_time.strftime("%H%M%S.%f")[:-4]  # hhmmss.ss format with milliseconds
    else:
        utc_time = phc_time.strftime("%H%M%S.00")  # hhmmss.00 format (zero milliseconds)
        utc_tow  = int(utc_tow)
    
    utc_date = phc_time.strftime("%d%m%y")  # ddmmyy format
        
    pubx_message = (
        f"PUBX,04,{utc_time},{utc_date},{utc_tow:.2f},{utc_wno},{leap_seconds_gps},"
        f"{clk_b},{clk_d:.3f},{pg}"
    )
    
    checksum = calculate_checksum(pubx_message)
    full_message = f"${pubx_message}*{checksum}\r\n"
    
    return full_message

def send_pubx04_via_uart(serial_port, pubx_message):
    """Send PUBX04 message via the UART interface."""
    serial_port.write(pubx_message.encode('utf-8'))

def main():
    # Open UART port for communication
    with serial.Serial(UART_PORT, BAUD_RATE, timeout=1) as ser:
        print(f"Opened UART port {UART_PORT} with baud rate {BAUD_RATE}")
        
        # Define fixed values for clk_b, clk_d, pg (not implemented, example values from ublox datasheet)
        clk_b = 1930035  # Receiver clock bias in nanoseconds
        clk_d = -2660.664  # Receiver clock drift in ns/s
        pg = 43  # Timepulse Granularity in nanoseconds

        # Continuous loop
        try:
            while True:
                # Get PHC time (adjusted to UTC)
                phc_time = get_phc_time()
                
                # Calculate GPS epoch leap seconds (UTC epoch 1970-01-01, GPS epoch 1980-01-06, 19 leap seconds)
                leap_seconds_gps = LEAP_SECONDS_UTC - 19
                
                # Generate PUBX04 message
                pubx_message = create_pubx04_message_from_phc_time(phc_time, clk_b, clk_d, pg, leap_seconds_gps, USE_MILLISECONDS)
                print(pubx_message)  # Print the message (optional for debugging)
                
                # Send the PUBX04 message via UART
                send_pubx04_via_uart(ser, pubx_message)

                # Sleep for the remaining time until the next second plus SEND_DELAY_MS
                current_microseconds = phc_time.microsecond
                remaining_time = (1000000 - current_microseconds) / 1e6 + SEND_DELAY_MS
                time.sleep(remaining_time)
        
        except KeyboardInterrupt:
            print("Programme terminated by user.")
            ser.close()

if __name__ == "__main__":
    main()
