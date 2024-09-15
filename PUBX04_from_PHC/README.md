OpenPMU has traditionally used the ublox PUBX,04 message to transfer time-of-date from a GNSS receiver to the BeagleBone Black ADC.

When synchronising OpenPMU using Precision Time Protocol (PTP) / IEEE 1588, it is necessary to mimic the PUBX,04 message.  

This code operates on by:

* Reading the PHC date/time using the "phc_ctl" command (LinuxPTP) via Python subprocess method.
* Converting the returned time to a Python datetime object.
* Formatting the PUBX,04 message according to spec found in ublox datasheet.
* Sending the message via UART shortly after each second has transitioned.  This is done in SW, so expect some jitter.
