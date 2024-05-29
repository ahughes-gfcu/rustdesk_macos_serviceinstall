#!/bin/bash

agent_file='https://raw.githubusercontent.com/rustdesk/rustdesk/master/src/platform/privileges_scripts/agent.plist'
daemon_file='https://raw.githubusercontent.com/rustdesk/rustdesk/master/src/platform/privileges_scripts/daemon.plist'
scriptname="RustDesk Service Installer"
logandmetadir="/Library/IntuneScripts/rustdesk"
log="$logandmetadir/rustdeskServiceInstaller.log"
agent_path='/Library/LaunchAgents/com.carriez.RustDesk_server.plist'
daemon_path='/Library/LaunchDaemons/com.carriez.RustDesk_service.plist'

function check_filesize {
    if [ -f $1 ]; then
        filesize=$(stat -f%z $1)
        if [ $filesize -gt 20 ]; then
            echo "File $1 is valid"
        else
            echo "File could not be downloaded properly. Filesize is $filesize."
            exit 1
        fi
    else
        echo "File $1 does not exist"
        exit 1
    fi
}

function install_as_service {
    echo ""
    echo "Downloading files"
    echo "------------------------------------"
    curl -l $agent_file --output $agent_path
    curl -l $daemon_file --output $daemon_path

    echo ""
    echo "Checking file sizes"
    echo "------------------------------------"
    #curl doesnt fail if the URL returns a 404. So we need to check the filesize
    check_filesize $agent_path
    check_filesize $daemon_path

    echo ""
    echo "Setting ownership and file permissions"
    echo "------------------------------------"
    chown root:wheel $agent_path
    chown root:wheel $daemon_path

    echo ""
    echo "Loading LaunchDaemons"
    echo "------------------------------------"
    launchctl load -w $daemon_path && echo "Loaded $daemon_path"
    #attempt to load the agent as well? This seems to fail but the rustdesk client tries this, line 202
    launchctl load -w $agent_path && echo "Loaded $agent_path"

    echo ""
    echo "Resetting RustDesk Application Permissions"
    echo "------------------------------------"
    tccutil reset Accessibility com.carriez.RustDesk
    tccutil reset ScreenCapture com.carriez.RustDesk
}

## Check if the log directory has been created and start logging
if [ -d $logandmetadir ]; then
    ## Already created
    echo "# $(date) | Log directory already exists - $logandmetadir"
else
    ## Creating Metadirectory
    echo "# $(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# start logging
exec 1>> $log 2>&1

# Begin Script Body

echo ""
echo "##############################################################"
echo "# $(date) | Starting $scriptname"
echo "############################################################"
echo ""

while [ ! -d "/Applications/RustDesk.app" ]; do
    echo ""
    echo "RustDesk is not installed"
    echo "Checking again in 30 seconds"
    echo ""
    echo ""
    sleep 30
done

if [ $(launchctl print system/com.carriez.RustDesk_service 2> /dev/null | awk '$1 ~ /^state/ {print$3}') = "running" ] 2>/dev/null; then
    echo ""
    echo "com.carriez.RustDesk_service is already running"
    exit 0
fi

echo "*********** RUSTDESK IS INSTALLED ***********"
echo "******* STARTING SERVICE INSTALLATION *******"
install_as_service