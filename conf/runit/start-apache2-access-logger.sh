#!/bin/bash

exec logger -p local0.info -t apache2-access -f /var/log/apache2/access.log
