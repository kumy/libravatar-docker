#!/bin/bash -x

export WWWSERVERNAME
export WWWSERVERALIAS
export CDNSERVERNAME
export CDNSERVERALIAS
export SECCDNSERVERNAME
export SECCDNSERVERALIAS
export WEBMASTEREMAIL
export VHOSTADDRESS
export DB_HOST
export DB_PORT
export DB_USER
export DB_PASS
export DB_NAME
export SITENAME
export FROMEMAIL
export SUPPORTEMAIL
export ADMINEMAIL
export EMAIL_HOST
export EMAIL_PORT
export EMAIL_HOST_USER
export EMAIL_HOST_PASSWORD
export EMAIL_USE_TLS
export EMAIL_USE_SSL
export SECRETKEY
export APACHE_CERT
export APACHE_KEY
export APACHE_CHAIN
export SLAVE_CERT
export SLAVE_KEY
export SLAVE_CHAIN
export UPLOADED_FILES_ROOT
export READY_FILES_ROOT
export USER_FILES_ROOT
export AVATAR_ROOT
export EXPORT_FILES_ROOT
export AUTH_LDAP_ENABLED
export AUTH_LDAP_BIND_DN
export AUTH_LDAP_BIND_PASSWORD
export AUTH_LDAP_SERVER_URI
export AUTH_LDAP_USER_DN_TEMPLATE
export AUTH_LDAP_USER_SEARCH
export AUTH_LDAP_USER_PHOTO
export AUTH_LDAP_USER_ATTR_MAP


WWWSERVERNAME=${WWWSERVERNAME:-www.libravatar.org}
WWWSERVERALIAS=${WWWSERVERALIAS:-www.libravatar.bit}
CDNSERVERNAME=${CDNSERVERNAME:-cdn.libravatar.org}
CDNSERVERALIAS=${CDNSERVERALIAS:-cdn.libravatar.bit}
SECCDNSERVERNAME=${SECCDNSERVERNAME:-seccdn.libravatar.org}
SECCDNSERVERALIAS=${SECCDNSERVERALIAS:-seccdn.libravatar.bit}
WEBMASTEREMAIL=${WEBMASTEREMAIL:-webmaster@libravatar.org}
VHOSTADDRESS=${VHOSTADDRESS:-*:443}
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_USER=${DB_USER:-djangouser}
DB_PASS=${DB_PASS}
DB_NAME=${DB_NAME:-libravatar}
SITENAME=${SITENAME:-Libravatar.org}
FROMEMAIL=${FROMEMAIL:-accounts@libravatar.org}
SUPPORTEMAIL=${SUPPORTEMAIL:-support@libravatar.org}
ADMINEMAIL=${ADMINEMAIL:-admin@libravatar.org}
EMAIL_HOST=${EMAIL_HOST:-smtp.libravatar.org}
EMAIL_PORT=${EMAIL_PORT:-587}
EMAIL_HOST_USER=${EMAIL_HOST_USER=}
EMAIL_HOST_PASSWORD=${EMAIL_HOST_PASSWORD}
EMAIL_USE_TLS=${EMAIL_USE_TLS:-True}
EMAIL_USE_SSL=${EMAIL_USE_SSL:-False}
SECRETKEY=${SECRETKEY}
UPLOADED_FILES_ROOT=/var/lib/libravatar/uploaded
READY_FILES_ROOT=/var/lib/libravatar/ready
USER_FILES_ROOT=/var/lib/libravatar/user
AVATAR_ROOT=/var/lib/libravatar/avatar
EXPORT_FILES_ROOT=/var/lib/libravatar/export
APACHE_CERT=${APACHE_CERT:-/etc/libravatar/seccdn.crt}
APACHE_KEY=${APACHE_KEY:-/etc/libravatar/seccdn.pem}
APACHE_CHAIN=${APACHE_CHAIN:-/etc/libravatar/seccdn-chain.pem}
SLAVE_CERT=${SLAVE_CERT:-/var/lib/libravatar/slave/cert/seccdn.crt}
SLAVE_KEY=${SLAVE_KEY=:-/var/lib/libravatar/slave/cert/seccdn.pem}
SLAVE_CHAIN=${SLAVE_CHAIN=:-/var/lib/libravatar/slave/cert/seccdn-chain.pem}
RULES_ABE=${RULES_ABE:-/usr/share/libravatar/static/cdn/rules.abe}
APACHE_CDN_COMMON_INCLUDE=${APACHE_CDN_COMMON_INCLUDE:-/etc/libravatar/cdn-common.include}
APACHE_CDN_CONFIG=${APACHE_CDN_CONFIG:-/etc/apache2/sites-available/libravatar-cdn.conf}
APACHE_SECCDN_CONFIG=${APACHE_SECCDN_CONFIG:-/etc/apache2/sites-available/libravatar-seccdn.conf}
APACHE_WWW_CONFIG=${APACHE_WWW_CONFIG:-/etc/apache2/sites-available/libravatar-www.conf}
AWSTATS_CDN_CONFIG=${AWSTATS_CDN_CONFIG:-/etc/awstats/awstats.cdn.conf}
AWSTATS_SECCDN_CONFIG=${AWSTATS_SECCDN_CONFIG:-/etc/awstats/awstats.seccdn.conf}
AWSTATS_WWW_CONFIG=${AWSTATS_WWW_CONFIG:-/etc/awstats/awstats.www.conf}
AWSTATS_CDN_DIR=${AWSTATS_CDN_DIR:-/var/lib/awstats/cdn}
AWSTATS_SECCDN_DIR=${AWSTATS_SECCDN_DIR:-/var/lib/awstats/seccdn}
AWSTATS_WWW_DIR=${AWSTATS_WWW_DIR:-/var/lib/awstats/www}
SETTINGS_PY=/etc/libravatar/settings.py
AUTH_LDAP_ENABLED=${AUTH_LDAP_ENABLED:-false}
AUTH_LDAP_BIND_DN=${AUTH_LDAP_BIND_DN}
AUTH_LDAP_BIND_PASSWORD=${AUTH_LDAP_BIND_PASSWORD}
AUTH_LDAP_SERVER_URI=${AUTH_LDAP_SERVER_URI}
AUTH_LDAP_USER_DN_TEMPLATE=${AUTH_LDAP_USER_DN_TEMPLATE}
AUTH_LDAP_USER_SEARCH=${AUTH_LDAP_USER_SEARCH}
AUTH_LDAP_USER_PHOTO=${AUTH_LDAP_USER_PHOTO:-jpegPhoto}
AUTH_LDAP_USER_ATTR_MAP=${AUTH_LDAP_USER_ATTR_MAP:-"{ 'first_name': 'givenName', 'last_name': 'sn', 'email': 'mail'}"}


# FUNCTIONS
# ---------

set_dbconfig () {
    perl -i -e '$field=shift;$value=shift if (scalar(@ARGV)>1);$value||="";while (<>) { s/^\s*("$field"\s*:\s*).*/$1"$value",/; print; }' "$1" "$2" "$3";
}

set_config () {
    perl -i -e '$field=shift;$value=shift if (scalar(@ARGV)>1);$value||="";while (<>) { s/^\s*($field\s*=\s*).*/$1"$value"/; print; }' "$1" "$2" "$3";
}


# URLS
# ----

if [ -z "$VHOSTADDRESS" ]; then
  echo "[ERROR] VHOSTADDRESS is empty $VHOSTADDRESS !"
  exit 1
fi

if [ -z "$WWWSERVERNAME" ]; then
  echo "[ERROR] WWWSERVERNAME is empty $WWWSERVERNAME !"
  exit 1
fi

if [ -z "$WWWSERVERALIAS" ]; then
  echo "[ERROR] WWWSERVERALIAS is empty $WWWSERVERALIAS !"
  exit 1
fi

if [ -z "$CDNSERVERNAME" ]; then
  echo "[ERROR] CDNSERVERNAME is empty $CDNSERVERNAME !"
  exit 1
fi

if [ -z "$CDNSERVERALIAS" ]; then
  echo "[ERROR] CDNSERVERALIAS is empty $CDNSERVERALIAS !"
  exit 1
fi

if [ -z "$SECCDNSERVERNAME" ]; then
  echo "[ERROR] SECCDNSERVERNAME is empty $SECCDNSERVERNAME !"
  exit 1
fi

if [ -z "$SECCDNSERVERALIAS" ]; then
  echo "[ERROR] SECCDNSERVERALIAS is empty $SECCDNSERVERALIAS !"
  exit 1
fi


# EMAILS
# ----

if [ -z "$WEBMASTEREMAIL" ]; then
  echo "[ERROR] WEBMASTEREMAIL is empty $WEBMASTEREMAIL !"
  exit 1
fi

if [ -z "$FROMEMAIL" ]; then
  echo "[ERROR] FROMEMAIL is empty $FROMEMAIL !"
  exit 1
fi

if [ -z "$SUPPORTEMAIL" ]; then
  echo "[ERROR] SUPPORTEMAIL is empty $SUPPORTEMAIL !"
  exit 1
fi

if [ -z "$ADMINEMAIL" ]; then
  echo "[ERROR] ADMINEMAIL is empty $ADMINEMAIL !"
  exit 1
fi


# DATABASE
# --------

if [ -z "$DB_HOST" ]; then
  echo "[ERROR] DB_HOST is empty $DB_HOST !"
  exit 1
fi

if [ -z "$DB_PORT" ]; then
  echo "[ERROR] DB_PORT is empty $DB_PORT !"
  exit 1
fi

if [ -z "$DB_USER" ]; then
  echo "[ERROR] DB_USER is empty $DB_USER !"
  exit 1
fi

if [ -z "$DB_PASS" ]; then
  echo "[ERROR] DB_PASS is empty $DB_PASS !"
  exit 1
fi

if [ -z "$DB_NAME" ]; then
  echo "[ERROR] DB_NAME is empty $DB_NAME !"
  exit 1
fi


# KEYS
# ----
if [ -z "$SECRETKEY" ]; then
  echo "[ERROR] SECRETKEY is empty $SECRETKEY !"
  exit 1
fi


# DIRECTORIES
# -----------

if [ ! -d "$UPLOADED_FILES_ROOT" ]; then
  echo "[ERROR] Upload directory missing $UPLOADED_FILES_ROOT !"
  exit 1
fi

if [ ! -d "$READY_FILES_ROOT" ]; then
  echo "[ERROR] Ready directory missing $READY_FILES_ROOT !"
  exit 1
fi

if [ ! -d "$USER_FILES_ROOT" ]; then
  echo "[ERROR] User directory missing $USER_FILES_ROOT !"
  exit 1
fi

if [ ! -d "$AVATAR_ROOT" ]; then
  echo "[ERROR] Avatar directory missing $AVATAR_ROOT !"
  exit 1
fi

if [ ! -d "$EXPORT_FILES_ROOT" ]; then
  echo "[ERROR] Export directory missing $EXPORT_FILES_ROOT !"
  exit 1
fi

# Set upload directory permissions
chown -R www-data:www-data $UPLOADED_FILES_ROOT
chmod g+w $UPLOADED_FILES_ROOT

# Set ready and user directories permissions
chown -R libravatar-img:www-data $READY_FILES_ROOT $USER_FILES_ROOT
chmod 775 $READY_FILES_ROOT $USER_FILES_ROOT

# Set avatar and export directories permissions
chown root.root $AVATAR_ROOT $EXPORT_FILES_ROOT
chmod 775 $AVATAR_ROOT $EXPORT_FILES_ROOT


# DNS RESOLVER
# ------------
echo "127.0.0.1 $WWWSERVERNAME $CDNSERVERNAME $SECCDNSERVERNAME" >> /etc/hosts


# CERTIFICATES
# ------------

if [ ! -e $SLAVE_CERT -o ! -e $APACHE_CERT ] ; then
  echo "libravatar-slave: SSL certificate is missing"
  exit 1
fi

if [ ! -e $SLAVE_KEY -o ! -e $APACHE_KEY ] ; then
  echo "libravatar-slave: SSL certificate key is missing"
  exit 2
fi

if [ ! -e $SLAVE_CHAIN -o ! -e $APACHE_CHAIN ] ; then
  echo "libravatar-slave: SSL certificate chain is missing"
  exit 3
fi


# APACHE
# ------

for MARKER in $(grep -o -E '__[A-Z0-9_]+__' ${APACHE_CDN_COMMON_INCLUDE}); do
  VAR=${MARKER:2:${#MARKER}-4}
  RET=${!VAR}
  sed -i -e "s/${MARKER}/${RET}/g" ${APACHE_CDN_COMMON_INCLUDE}
  echo sed -i -e "s/${MARKER}/${RET}/g" ${APACHE_CDN_COMMON_INCLUDE}
done

cp ${RULES_ABE}.template ${RULES_ABE}
for MARKER in $(grep -o -E '__[A-Z0-9_]+__' ${RULES_ABE}); do
  VAR=${MARKER:2:${#MARKER}-4}
  RET=${!VAR}
  sed -i -e "s/${MARKER}/${RET}/g" ${RULES_ABE}
  echo sed -i -e "s/${MARKER}/${RET}/g" ${RULES_ABE}
done

# CDN

for MARKER in __WWWSERVERALIAS__ __CDNSERVERALIAS__ __SECCDNSERVERALIAS__ ; do
  VAR=${MARKER:2:${#MARKER}-4}
  RET=${!VAR}
  VALUE=${RET}
  if [ "z${VALUE}" = "z" ] ; then
    sed -i -e "s/${MARKER}//g" ${APACHE_CDN_CONFIG}
  else
    sed -i -e "s/${MARKER}/ServerAlias ${RET}/g" ${APACHE_CDN_CONFIG}
  fi
done

for MARKER in $(grep -o -E '__[A-Z0-9_]+__' ${APACHE_CDN_CONFIG}); do
  VAR=${MARKER:2:${#MARKER}-4}
  RET=${!VAR}
  sed -i -e "s/${MARKER}/${RET}/g" ${APACHE_CDN_CONFIG}
  echo sed -i -e "s/${MARKER}/${RET}/g" ${APACHE_CDN_CONFIG}
done

# SECCDN

for MARKER in __WWWSERVERALIAS__ __CDNSERVERALIAS__ __SECCDNSERVERALIAS__ ; do
  VAR=${MARKER:2:${#MARKER}-4}
  RET=${!VAR}
  VALUE=${RET}
  if [ "z${VALUE}" = "z" ] ; then
    sed -i -e "s/${MARKER}//g" ${APACHE_SECCDN_CONFIG}
  else
    sed -i -e "s/${MARKER}/ServerAlias ${RET}/g" ${APACHE_SECCDN_CONFIG}
  fi
done

for MARKER in $(grep -o -E '__[A-Z0-9_]+__' ${APACHE_SECCDN_CONFIG}); do
  VAR=${MARKER:2:${#MARKER}-4}
  RET=${!VAR}
  sed -i -e "s/${MARKER}/${RET}/g" ${APACHE_SECCDN_CONFIG}
done

# WWW

for MARKER in __WWWSERVERALIAS__ __CDNSERVERALIAS__ __SECCDNSERVERALIAS__ ; do
  VAR=${MARKER:2:${#MARKER}-4}
  RET=${!VAR}
  VALUE=${RET}
  if [ "z${VALUE}" = "z" ] ; then
    sed -i -e "s/${MARKER}//g" ${APACHE_WWW_CONFIG}
  else
    sed -i -e "s/${MARKER}/ServerAlias ${RET}/g" ${APACHE_WWW_CONFIG}
  fi
done

for MARKER in $(grep -o -E '__[A-Z0-9_]+__' ${APACHE_WWW_CONFIG}); do
  VAR=${MARKER:2:${#MARKER}-4}
  RET=${!VAR}
  sed -i -e "s/${MARKER}/${RET}/g" ${APACHE_WWW_CONFIG}
done

# AWSTATS

for MARKER in $(grep -o -E '__[A-Z0-9_]+__' ${AWSTATS_CDN_CONFIG}); do
  VAR=${MARKER:2:${#MARKER}-4}
  RET=${!VAR}
  sed -i -e "s/${MARKER}/${RET}/g" ${AWSTATS_CDN_CONFIG}
done

for MARKER in $(grep -o -E '__[A-Z0-9_]+__' ${AWSTATS_SECCDN_CONFIG}); do
  VAR=${MARKER:2:${#MARKER}-4}
  RET=${!VAR}
  sed -i -e "s/${MARKER}/${RET}/g" ${AWSTATS_SECCDN_CONFIG}
done

for MARKER in $(grep -o -E '__[A-Z0-9_]+__' ${AWSTATS_WWW_CONFIG}); do
  VAR=${MARKER:2:${#MARKER}-4}
  RET=${!VAR}
  sed -i -e "s/${MARKER}/${RET}/g" ${AWSTATS_WWW_CONFIG}
done


# SETTINGS_PY
# -----------

set_dbconfig HOST "${DB_HOST}" ${SETTINGS_PY}
set_dbconfig PORT "${DB_PORT}" ${SETTINGS_PY}
set_dbconfig NAME "${DB_NAME}" ${SETTINGS_PY}
set_dbconfig USER "${DB_USER}" ${SETTINGS_PY}
set_dbconfig PASSWORD "${DB_PASS}" ${SETTINGS_PY}
set_config MEDIA_URL "http://${CDNSERVERNAME}/" ${SETTINGS_PY}

if [ "z${SECCDNSERVERNAME}" = "z" ] ; then
  set_config SECURE_MEDIA_URL "" ${SETTINGS_PY}
else
  set_config SECURE_MEDIA_URL "https://${SECCDNSERVERNAME}/" ${SETTINGS_PY}
fi

set_config SITE_URL "https://${WWWSERVERNAME}" ${SETTINGS_PY}
set_config SITE_NAME "${SITENAME}" ${SETTINGS_PY}
set_config SERVER_EMAIL "${FROMEMAIL}" ${SETTINGS_PY}
set_config SUPPORT_EMAIL "${SUPPORTEMAIL}" ${SETTINGS_PY}
set_config ADMIN_EMAIL "${ADMINEMAIL}" ${SETTINGS_PY}
set_config SECRET_KEY "${SECRETKEY}" ${SETTINGS_PY}

set_config AVATAR_ROOT "${AVATAR_ROOT}/" ${SETTINGS_PY}
set_config READY_FILES_ROOT "${READY_FILES_ROOT}/" ${SETTINGS_PY}
set_config UPLOADED_FILES_ROOT "${UPLOADED_FILES_ROOT}/" ${SETTINGS_PY}
set_config USER_FILES_ROOT "${USER_FILES_ROOT}/" ${SETTINGS_PY}
set_config EXPORT_FILES_ROOT "${EXPORT_FILES_ROOT}/" ${SETTINGS_PY}

set_config DEBUG "True" ${SETTINGS_PY}

# EMAIL
# ----
echo "EMAIL_HOST = '${EMAIL_HOST}'" >> ${SETTINGS_PY}
echo "EMAIL_PORT = ${EMAIL_PORT}" >> ${SETTINGS_PY}
echo "EMAIL_HOST_USER = '${EMAIL_HOST_USER}'" >> ${SETTINGS_PY}
echo "EMAIL_HOST_PASSWORD = '${EMAIL_HOST_PASSWORD}'" >> ${SETTINGS_PY}
echo "EMAIL_USE_TLS = ${EMAIL_USE_TLS}" >> ${SETTINGS_PY}
echo "EMAIL_USE_SSL = ${EMAIL_USE_SSL}" >> ${SETTINGS_PY}


# LDAP
# ----
if $AUTH_LDAP_ENABLED; then
  echo "[LDAP] Ldap auth is enabled"
  echo "import ldap" >> ${SETTINGS_PY}

  sed -i '/django_auth_ldap.backend.LDAPBackend/ s/# //' ${SETTINGS_PY}

  sed -i '/^AUTH_LDAP_BIND_DN/ s/^/#/' ${SETTINGS_PY}
  if [[ ${AUTH_LDAP_BIND_DN} ]]; then
    echo "AUTH_LDAP_BIND_DN = '${AUTH_LDAP_BIND_DN}'" >> ${SETTINGS_PY}
  fi

  sed -i '/^AUTH_LDAP_BIND_PASSWORD/ s/^/#/' ${SETTINGS_PY}
  if [[ ${AUTH_LDAP_BIND_PASSWORD} ]]; then
    echo "AUTH_LDAP_BIND_PASSWORD = '${AUTH_LDAP_BIND_PASSWORD}'" >> ${SETTINGS_PY}
  fi

  sed -i '/^AUTH_LDAP_SERVER_URI/ s/^/#/' ${SETTINGS_PY}
  if [[ ${AUTH_LDAP_SERVER_URI} ]]; then
    echo "AUTH_LDAP_SERVER_URI = '${AUTH_LDAP_SERVER_URI}'" >> ${SETTINGS_PY}
  fi

  sed -i '/^AUTH_LDAP_USER_DN_TEMPLATE/ s/^/#/' ${SETTINGS_PY}
  if [[ ${AUTH_LDAP_USER_DN_TEMPLATE} ]]; then
    echo "AUTH_LDAP_USER_DN_TEMPLATE = '${AUTH_LDAP_USER_DN_TEMPLATE}'" >> ${SETTINGS_PY}
  fi


  if [[ ${AUTH_LDAP_USER_SEARCH} ]]; then
    echo "from django_auth_ldap.config import LDAPSearch" >> ${SETTINGS_PY}
    echo "AUTH_LDAP_USER_SEARCH = ${AUTH_LDAP_USER_SEARCH}" >> ${SETTINGS_PY}
  fi

  sed -i '/^AUTH_LDAP_USER_PHOTO/ s/^/#/' ${SETTINGS_PY}
  echo "AUTH_LDAP_USER_PHOTO = '${AUTH_LDAP_USER_PHOTO}'" >> ${SETTINGS_PY}

  sed -i -e '/AUTH_LDAP_USER_ATTR_MAP/,+5d' ${SETTINGS_PY}
  echo AUTH_LDAP_USER_ATTR_MAP = ${AUTH_LDAP_USER_ATTR_MAP} >> ${SETTINGS_PY}

else
  echo "[LDAP] Ldap auth is disabled."
fi


# DATABASE
# --------

# TODO check database status
cd /usr/share/libravatar
python manage.py migrate


# start main daemon
supervisord -n -c /etc/supervisor/supervisord.conf
