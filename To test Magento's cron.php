To Test the 5mins Magento cron.php call:

Add to cron.sh:
date >> "$0".log
whoami  >> "$0".log

after the INSTALLDIR variable is set like so:
# absolute path to magento installation
INSTALLDIR=`echo $0 | sed 's/cron\.sh//g'`
date >> "$0".log
whoami  >> "$0".log

And to cron.php 
$log = fopen(__FILE__.'.log', 'a');
fwrite($log, date("Y-m-d H:i:s").PHP_EOL);
fclose($log);

after the dispatchEvent call like so:
Mage::dispatchEvent('default');
$log = fopen(__FILE__.'.log', 'a');
fwrite($log, date("Y-m-d H:i:s").PHP_EOL);
fclose($log);

Additional Steps:

$ chmod +x /path/to/cron.php
$ chmod +x /path/to/cron.sh

Clear cache:
$ magerun cache:flush
Go to admin and manually clear caches

$ sudo service cron restart

After 6 minutes, should see this file in Magento's directory if cron is running.
cron.php.log
cron.sh.log

Delete the addtion two lines at both cron.sh and cron.php (and the log files) after confirming Magento Cron running well
