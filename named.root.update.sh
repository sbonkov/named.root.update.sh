#!/bin/sh
#
#Update named hints file
#Make a cron entry and forget about it!

#Check if named is running
echo "Checking if named is running..."

if `rndc status | grep -q "server is up and running"`
then
echo "Named is running!"
else
echo "Named is NOT running!"
echo "Exiting."
exit 0
fi

#Check for internet connection
echo "Checking if we are online..."

if `ping -c 1 8.8.8.8 | grep -q "100.0% packet loss"`;
then
echo "We are not online!"
echo "Could not ping external server!"
echo "Exiting."
exit 1
else
echo "We are online!"
fi

#Create root.hints /named.root/ file

echo "Creating /usr/local/etc/namedb/named.root.new..."
dig @a.root-servers.net . ns > /usr/local/etc/namedb/named.root.new

if `cat /usr/local/etc/namedb/named.root.new | grep -q "NOERROR"`;
then
echo "File creation successful!"
echo "Replacing old file with updated information..."
chmod 644 /usr/local/etc/namedb/named.root.new
cp /usr/local/etc/namedb/named.root /usr/local/etc/namedb/named.root.old
cp /usr/local/etc/namedb/named.root.new /usr/local/etc/namedb/named.root
rm -f /usr/local/etc/namedb/named.root.new
echo "Restarting Named..."
/usr/local/etc/rc.d/named onerestart
else
echo "The named.root file update has FAILED!"
echo "Printing dig output..."
cat /usr/local/etc/namedb/named.root.new
echo "Exiting."
exit 1
fi

echo "Update Complete!"
exit 0
