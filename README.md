#### My Magento Stack ###


VPS Provider:</break>
* Company: Linode
* Virtualization Platform: KVM
* DataCentre: Singapore

Specs:
* 4GB RAM
* 4 x vCPU Core
* 96 GB SSD Storage
* 4 TB Transfer
* 40 Gbit Network In
* 500 Mbit Network Out

* IP Address: <>
* SSH Keys: <> <> <>
* Users: <> <> <>

Stack:
* Linux - Ubuntu 14.04 LTS
* PHP 5.6
* Nginx 1.9.x
* PHP-FPM/FastCGI
* Zend-Opcache
* Mariadb 10.1 with Custom Configured my.cnf
* Database Web Tool: PhpMyAdmin (password protected)
* Opcache GUI

Security:
* Disable Root Access
* Passwordless Log-In / SSH Keys Authentications
* SSH Port Changed to: <>
* Firewall Configuration: UFW & Fail2ban

Emails Infrastructure Set-Up:
* Zoho Mail for Domain Email Addresses (SPF and Domain Keys verified)
* SendGrid for Transactional Emails (SPF, Domain Keys and Whitelissted)

Daily Backup Scripts for:
* Website and Database Auto-Transferred to S3 Bucket

DNS Set-up:
* Staging and Data subdomain
* CNAME - mail

Remote Storage:
* s3cmd installed for AWS S3 Account

Website:
* Magento Framework 1.9.2.1 Installed
* Theme Installed

Dev Tools/Extensions/Optimisations Installed:
* IDE by Koding.com
* Modman
* n98-magerun
* AOE Scheduler
* SMTP Pro Extension by Ashroder

Redis Manager (in sleeping mode for now - to test pre-prodcution)
* Seperate Redis Servers - 2 different ports for:
* System/Data (cm_redis_backend) and
* Sessions (cm_redis_session)
* Third port for FPC maybe?

Snapshots Disks/Stack at Linode

Once the categories and sample products are up:
* Proxy Cache (or maybe Varnish?)
* Browser Caching/Expire Headers
* Activate Google Pagespeed
* Minify js and css
* Merge scripts
* Optimize Images using Kraken, JpegOptim + Optipng or if not at linux level, using GIMP
* SSL Certificate
* Load Balancer
* CDN Set-Up (DIY or maybe Cloundfront or MaxCDN?)
* Load test - Siege and ab testing
* Server Monitoring Tools - New Relic, Munin etc..
