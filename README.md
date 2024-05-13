# RustDesk Service Installer

This bash script is designed to be deployed via Intune to MacOS endpoints. It installs the RustDesk service and server as a system service.

## Script Overview

The script performs the following operations:

1. Downloads the agent and daemon files from the RustDesk repository.
2. Checks the file sizes to ensure the files have been downloaded correctly.
3. Sets the ownership and file permissions for the downloaded files.
4. Loads the LaunchDaemons.
5. Resets the RustDesk application permissions.

## Usage

This script is designed to be deployed via Intune to MacOS endpoints. Here are the steps to deploy it:

1. **Create a shell script in Intune:**
   - Sign in to the Microsoft Endpoint Manager admin center.
   - Select **Devices** > **Scripts** > **macOS shell scripts** > **Add**.
   - Provide a name and description for the script.
   - For **Upload Script**, browse and select this bash script file.
   - Configure Script Options
      - Run script as signed-in user: **No**
      - Hide script notifications on devices: **Not Configured**
      - Script frequency: **Not Configured**
      - Max number of times to retry if script fails: **3 Times**

2. **Assign the script:**
   - On the **Assignments** page, select the **Groups** to which you want to assign the script.
   - Select **Next**.

3. **Review and create the script:**
   - Review your settings. When you're ready, select **Create**.

Once the script is assigned, it will be run on the devices in the assigned groups. The script will automatically download the necessary files, check their integrity, set the appropriate permissions, and load the service.

Please note that the script assumes that RustDesk is already installed on the system. If RustDesk is not installed, the script will pause and check again every 30 seconds until RustDesk is detected.

## Logging

The script logs its operations to a log file located at `/Library/IntuneScripts/rustdesk/rustdeskServiceInstaller.log`. This can be useful for troubleshooting if there are any issues with the script.

## Important Paths

- Agent file: `https://raw.githubusercontent.com/rustdesk/rustdesk/master/src/platform/privileges_scripts/agent.plist`
- Daemon file: `https://raw.githubusercontent.com/rustdesk/rustdesk/master/src/platform/privileges_scripts/daemon.plist`
- Agent path: `/Library/LaunchAgents/com.carriez.RustDesk_service.plist`
- Daemon path: `/Library/LaunchDaemons/com.carriez.RustDesk_server.plist`

## Dependencies

- RustDesk: The script assumes that RustDesk is already installed on the system.
