#!/bin/bash

export APACHE_USER=$(grep '/app' /etc/passwd | cut -d':' -f 1)

erb /app/.conf/apache2.envvars.erb > /etc/apache2/envvars
erb /app/.conf/apache2.conf.erb > /etc/apache2/sites-available/default
chown -R $APACHE_USER.$APACHE_USER /var/log/php

source /etc/apache2/envvars
exec /usr/sbin/apache2 -D FOREGROUND
