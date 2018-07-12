FROM debian:jessie

ARG READY_FILES_ROOT=/var/lib/libravatar/ready
ARG UPLOADED_FILES_ROOT=/var/lib/libravatar/uploaded
ARG USER_FILES_ROOT=/var/lib/libravatar/user
ARG EXPORT_FILES_ROOT=/var/lib/libravatar/export
ARG AVATAR_ROOT=/var/lib/libravatar/avatar
ARG AWSTATS_CDN_DIR=/var/lib/awstats/cdn
ARG AWSTATS_SECCDN_DIR=/var/lib/awstats/seccdn
ARG AWSTATS_WWW_DIR=/var/lib/awstats/www

RUN apt-get update \
 && apt-get install -y \
     advancecomp \
     apache2 \
     ca-certificates \
     gearman-job-server \
     gearman-tools \
     gifsicle \
     git \
     jpegoptim \
     libapache2-mod-wsgi \
     libjs-jquery \
     optipng \
     pngcrush \
     python-bcrypt \
     python-django \
     python-django-auth-openid \
     python-django-auth-ldap \
     python-dns \
     python-gearman \
     python-imaging \
     python-ldap \
     python-openid \
     python-psycopg2 \
     python-requests \
     supervisor \
     vim \
     yui-compressor

ARG LOG_ROOT=/var/log/libravatar
ARG MASTER_ROOT=/var/lib/libravatar/master
ARG SLAVE_ROOT=/var/lib/libravatar/slave

RUN \
    apt-get install -y \
     rssh

COPY files/ /
RUN \
    a2enconf tls \
 && a2enmod \
      alias \
      expires \
      headers \
      proxy \
      proxy_http \
      rewrite \
      ssl \
      wsgi \
 # Create a restricted user to crop/resize images with
 && adduser --system --quiet --disabled-login --shell /bin/false --no-create-home --home ${READY_FILES_ROOT} --gecos 'Libravatar Image Processor,,,' libravatar-img \
 # Install code
 && git clone https://git.launchpad.net/~kumy/libravatar /usr/share/libravatar/ \
 # Create directories
 && mkdir -p /etc/libravatar \
 && mkdir -p /var/lib/libravatar \
 && mkdir ${READY_FILES_ROOT} \
 && mkdir ${UPLOADED_FILES_ROOT} \
 && mkdir ${USER_FILES_ROOT} \
 && mkdir ${EXPORT_FILES_ROOT} \
 && mkdir ${AVATAR_ROOT} \
 && mkdir -p ${LOG_ROOT} \
 && touch ${LOG_ROOT}/workers.log \
 # Change ownership
 && chown -R libravatar-img:www-data ${READY_FILES_ROOT} \
 && chmod 750 ${READY_FILES_ROOT} \
 && chown -R www-data:www-data ${UPLOADED_FILES_ROOT} \
 && chmod 775 ${UPLOADED_FILES_ROOT} \
 && chown -R root:root ${USER_FILES_ROOT} \
 && chown -R root:root ${EXPORT_FILES_ROOT} \
 && chown www-data:www-data ${LOG_ROOT} \
 && chmod 775 ${LOG_ROOT} \
 && chown libravatar-img ${LOG_ROOT}/workers.log \
 # Install abe rules
 && cp /usr/share/libravatar/static/cdn/rules.abe.template /usr/share/libravatar/static/cdn/rules.abe \
 # Install apache configuration
 && cp /usr/share/libravatar/config/cdn-common.apache2.conf /etc/libravatar/cdn-common.include \
 && cp /usr/share/libravatar/config/cdn.apache2.conf /etc/apache2/sites-available/libravatar-cdn.conf \
 && cp /usr/share/libravatar/config/seccdn.apache2.conf /etc/apache2/sites-available/libravatar-seccdn.conf \
 && cp /usr/share/libravatar/config/www.apache2.conf /etc/apache2/sites-available/libravatar-www.conf \
 && a2ensite \
      libravatar-cdn \
      libravatar-seccdn \
      libravatar-www \
 # Create dummy TLS certificates
 && touch /etc/libravatar/seccdn-chain.pem \
 && touch /etc/libravatar/seccdn.pem \
 && touch /etc/libravatar/seccdn.crt \
 # Install awstat
 && mkdir /etc/awstats/ \
 && cp /usr/share/libravatar/config/awstats.cdn.conf /etc/awstats/awstats.cdn.conf \
 && cp /usr/share/libravatar/config/awstats.seccdn.conf /etc/awstats/awstats.seccdn.conf \
 && cp /usr/share/libravatar/config/awstats.www.conf /etc/awstats/awstats.www.conf \
 && mkdir -p ${AWSTATS_CDN_DIR} \
 && chown www-data:www-data ${AWSTATS_CDN_DIR} \
 && mkdir -p ${AWSTATS_SECCDN_DIR} \
 && chown www-data:www-data ${AWSTATS_SECCDN_DIR} \
 && mkdir -p ${AWSTATS_WWW_DIR} \
 && chown www-data:www-data ${AWSTATS_WWW_DIR} \
 # Install wsgi configuration
 && cp /usr/share/libravatar/config/django.wsgi /etc/libravatar/django.wsgi \
 # Install Django settings
 && cp /usr/share/libravatar/libravatar/settings.py.example /etc/libravatar/settings.py \
 && ln -s /etc/libravatar/settings.py usr/share/libravatar/libravatar/settings.py \
 # Install master root
 && adduser --system --quiet --disabled-login --shell /usr/bin/rssh --no-create-home --home ${MASTER_ROOT} --gecos 'Libravatar Mirror Master,,,' libravatar-master || true \
 && mkdir -p ${MASTER_ROOT}/.ssh/ \
 && touch ${MASTER_ROOT}/.ssh/authorized_keys \
 && chown libravatar-master ${MASTER_ROOT}/.ssh/authorized_keys \
 # # Install slave root
 # && adduser --system --quiet --disabled-login --shell /bin/false --no-create-home --home ${SLAVE_ROOT} --gecos 'Libravatar Mirror Slave,,,' libravatar-slave || true \
 # && mkdir -p ${AVATAR_ROOT} \
 # && chown -R libravatar-slave ${AVATAR_ROOT} \
 # && mkdir -p ${SLAVE_ROOT}/cert/ \
 # && chown libravatar-slave ${SLAVE_ROOT}/cert/ \
 # && mkdir -p ${SLAVE_ROOT}/.ssh/ \
 # && if [ ! -e /var/lib/libravatar/slave/.ssh/id_rsa ]; then ssh-keygen -t rsa -N "" -f ${SLAVE_ROOT}/.ssh/id_rsa fi \
 # && chown -R libravatar-slave ${SLAVE_ROOT}/.ssh/ \
 # Image processor
 && echo END

EXPOSE 80 443
VOLUME /var/lib/libravatar

RUN chmod +x /usr/local/bin/run.sh
CMD ["run.sh"]
