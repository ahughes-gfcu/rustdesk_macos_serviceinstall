#!/bin/bash

agent_file=$(curl -s 'https://raw.githubusercontent.com/rustdesk/rustdesk/master/src/platform/privileges_scripts/agent.plist')
daemon_file=$(curl -s 'https://raw.githubusercontent.com/rustdesk/rustdesk/master/src/platform/privileges_scripts/daemon.plist')
osascript_body=$(curl - s 'https://raw.githubusercontent.com/rustdesk/rustdesk/master/src/platform/privileges_scripts/install.scpt')
scriptname="RustDesk Service Installer"
logandmetadir="/Library/IntuneScripts/rustdesk"
log="$logandmetadir/rustdeskServiceInstaller.log"
agent_path='/Library/LaunchAgents/com.carriez.RustDesk_server.plist'
daemon_path='/Library/LaunchDaemons/com.carriez.RustDesk_service.plist'
current_user=$(dscacheutil -q user | grep -A 3 -B 2 -e uid:\ 501 | awk '/name: /{print $2}')

function install_as_service {

    osascript -e "$osascript_body" "$daemon_file" "$agent_file" "$current_user"

    if [ -f $agent_path ]; then
        echo "Agent file exists"
        echo "Launching Server"
        launchctl enable gui/501/com.carriez.RustDesk_server
        launchctl kickstart -kp gui/501/com.carriez.RustDesk_server
        fi
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