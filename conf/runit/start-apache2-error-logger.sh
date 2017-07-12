#!/bin/bash

exec logger -p local0.error -t apache2-error -f /var/log/apache2/error.log
