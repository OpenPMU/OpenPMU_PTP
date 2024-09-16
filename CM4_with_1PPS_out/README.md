# Configuring the Raspberry Pi CM4 as a PTP Slave Clock with 1PPS output pulse.

Note, for this guide to work, you will need a PTP Master Clock somewhere on your subnet.

* Download and install Raspberry Pi OS to the CM4.
  - _Raspberry Pi OS Lite (64-bit) (Debian Bookworm, Released 2024-07-04) was used to test this setup._
* Install
  - ```screen```
  - ```linuxptp``` (3.1.1)

```
sudo apt-get update
sudo apt-get install screen
sudo apt-get install linuxptp
```

* Obtain testptp.c and compile it.  Place it in ```/pi/home/testptp/```.
* Copy ```Start_PTP.sh``` to your Raspberry Pi at ```/pi/home/```.  
* Run ```./Start_PTP.sh``` as ```root``` (or add ```/dev/ptp0/```) to ```pi``` group.



## LinuxPTP Cheat Sheet

LinuxPTP seems to rely on the driver for the Network Interface Card (NIC) implementing certain features, so sometimes things might yield errors or fail silently.  The tools provided with LinuxPTP offer a great amount of functionality, use the ```-h``` switch to explore their capabilities.  These tools were useful in developing this solution for OpenPMU.

* ```ptp4l```
  - PTP for Linux
  - Use this to operate the clock as a master (server) or a slave (client).
    - As a PTP Slave clock, use ```ptp4l -i eth0 --slaveOnly 1 -m --tx_timestamp_timeout 200 --max_frequency 900000000 --step_threshold 0.1```.  Alternative, create a config file and use ```-f``` to load settings from the file.
* ```ts2phc```
  - Timestamp to Physical Hardware Clock
  - Use this to discipline the PHC to a GNSS receiver's 1PPS
* ```phc_ctl```
  - Physical Hardware Clock control
  - Use this to get, set and adjust the PHC time
* ```phc2sys```
  - Synchronises the system clock to the Physical Hardware Clock.
  - Note: The PHC uses TAI, the system clock uses UTC.  Presently 37 leap seconds, so TAI is 37 seconds ahead of UTC.
* ```testptp```
  - This enables the ```SYNC_IN``` and ```SYNC_OUT``` pin of the CM4's PHC.
    - ```SYNC_IN``` is used on a PTP Master to synchronise the PHC with a reference clock, e.g. GNSS receiver.  Use ```./testptp/testptp -d /dev/ptp0 -L 0,1```.
    - ```SYNC_OUT``` is used on a PTP Slave to provide a 1PPS output (rising edge on transition of second).  Use ```./testptp/testptp -d /dev/ptp0 -L 0,2```.
      - To start the output pulse train, you need to set the period and pulse width in nanoseconds.  Use ```./testptp/testptp -d /dev/ptp0 -p 1000000000 -w 1000```.  Only valid period is 1 second (1000000000 ns), and valid pulse width from 8 ns to 4095 ns.
  - On the CM4, these are the same pin!  So can only do one or the other.
  - Note: This is not installed as part of LinuxPTP, you need to get testptp.c and compile it yourself.
