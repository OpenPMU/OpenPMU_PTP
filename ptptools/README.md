
# Overview of PTP Tools

The `setup_linuxptp_testptp.sh` Bash script is designed for setting up Precision Time Protocol (PTP) tools on a Raspberry Pi environment.  It checks for the existence of the `/dev/ptp0` device, and if found, it installs and configures the necessary tools and permissions for PTP usage.

Other scripts provided in this directory will allow linuxptp to be used in both server and client modes, to synchronise the server to a GNSS receiver (1PPS), and to create a 1PPS output on the client.

### setup_linuxptp_testptp.sh walkthrough

1. **System Update Reminder**  
   - The script prompts the user to update and upgrade the system for an optimal setup.

2. **PTP Device Check**  
   - It verifies the existence of `/dev/ptp0` to ensure PTP-related actions are necessary.

3. **LinuxPTP Installation**  
   - Installs the `linuxptp` package, a toolset required for PTP functionality.

4. **Setup of `testptp.c`**  
   - Creates a dedicated directory, downloads `testptp.c` from a specified URL, compiles it using `gcc`, and sets execute permissions.

5. **User and Permissions Configuration**  
   - Adds the current user to a new `ptpusers` group for PTP access.
   - Creates a `udev` rule that grants the `ptpusers` group access to `/dev/ptp0`.

6. **Reload `udev` Rules**  
   - Reloads the `udev` rules to apply the new permissions.

7. **Capabilities for `ptp4l`**  
   - Sets necessary capabilities for `ptp4l`, allowing it to run without root privileges.

8. **Completion and Usage Instructions**  
   - Provides a summary and suggests a command to test `ptp4l` on the specified network interface, without needing root access.

If `/dev/ptp0` is not found, the script skips all PTP-related configurations.
