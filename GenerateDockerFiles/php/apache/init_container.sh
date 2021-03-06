#!/bin/bash
cat >/etc/motd <<EOL 
  _____                               
  /  _  \ __________ _________   ____  
 /  /_\  \\___   /  |  \_  __ \_/ __ \ 
/    |    \/    /|  |  /|  | \/\  ___/ 
\____|__  /_____ \____/ |__|    \___  >
        \/      \/                  \/ 
A P P   S E R V I C E   O N   L I N U X

Documentation: http://aka.ms/webapp-linux
PHP quickstart: https://aka.ms/php-qs
PHP version : `php -v | head -n 1 | cut -d ' ' -f 2`
Note: Any data outside '/home' is not persisted
EOL
cat /etc/motd

# Get environment variables to show up in SSH session
eval $(printenv | sed -n "s/^\([^=]\+\)=\(.*\)$/export \1=\2/p" | sed 's/"/\\\"/g' | sed '/=/s//="/' | sed 's/$/"/' >> /etc/profile)

# redirect php custom logs to stderr
if [ "${WEBSITE_ENABLE_PHP_ACCESS_LOGS^^}" = TRUE ] ; then 
	sed -i "s/CustomLog \/dev\/null combined/CustomLog \/dev\/stderr combined/g" /etc/apache2/apache2.conf; 
fi

# starting sshd process
sed -i "s/SSH_PORT/$SSH_PORT/g" /etc/ssh/sshd_config
/usr/sbin/sshd

appPath="/home/site/wwwroot"
runFromPath="/tmp/webapp"
startupCommandPath="/opt/startup/startup.sh"
userStartupCommand="$@"
if [ -z "$userStartupCommand" ]
then
  userStartupCommand="apache2-foreground";
else
  userStartupCommand="$userStartupCommand; apache2-foreground;"
fi

oryxArgs="create-script -appPath $appPath -output $startupCommandPath \
    -bindPort $PORT -startupCommand '$userStartupCommand'"

echo "Running oryx $oryxArgs"
eval oryx $oryxArgs
$startupCommandPath
