function fetch_apache2_packages() {
  if [ -n "$BUILDPACK_CLEAN_CACHE" ] ; then
    rm -rf $APACHE_CACHE_DIR
  fi

  if [ -z "$GET_PACKAGE_LIST" ] ; then
    get_apt_updates
    GET_PACKAGE_LIST=1
  fi

  if [ ! -d $APACHE_CACHE_DIR ] ; then
    mkdir -p $APACHE_CACHE_DIR
    apt-get --print-uris --yes install apache2 apache2-mpm-prefork libapache2-mod-rpaf | grep ^\' | cut -d\' -f2 > $APACHE_CACHE_DIR/downloads.list
    wget --input-file $APACHE_CACHE_DIR/downloads.list -P $APACHE_CACHE_DIR > /dev/null 2>&1
  else
    echo '(from cache)' | indent
  fi

  dpkg -i $APACHE_CACHE_DIR/*.deb > /dev/null 2>&1

  version=$(dpkg -l | grep apache2 | head -n 1 | awk '{print $3}')
  echo "APACHE2 installed : $version" | indent
}


function install_apache2_configuration() {
  cp "$BP_DIR/conf/apache2/apache2.conf" /etc/apache2/apache2.conf
  cp "$BP_DIR/conf/apache2/security" /etc/apache2/conf.d/security
  cp "$BP_DIR/conf/apache2/ports.conf" /etc/apache2/ports.conf
  cp "$BP_DIR/conf/apache2/rpaf.conf" /etc/apache2/mods-available/rpaf.conf
  a2enmod rewrite > /dev/null 2>&1

  # Add start script
  mkdir -p /etc/service/apache2
  cp "$BP_DIR/conf/runit/start-apache2.sh" /etc/service/apache2/run

  mkdir -p /etc/service/apache2-access-logger
  cp "$BP_DIR/conf/runit/start-apache2-access-logger.sh" /etc/service/apache2-access-logger/run

  mkdir -p /etc/service/apache2-error-logger
  cp "$BP_DIR/conf/runit/start-apache2-error-logger.sh" /etc/service/apache2-error-logger/run
}
