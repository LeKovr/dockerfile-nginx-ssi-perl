# TenderPro modperl Dockerfile
# See https://github.com/TenderPro/dockerfile-modperl

FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No

# apt list nginx 2>/dev/null | awk '{ print $2 }' | awk -F- '{ print $1 }'
ENV NGINX_VERSION 1.14.2

WORKDIR /opt

# Code from
# https://gorails.com/blog/how-to-compile-dynamic-nginx-modules
# https://firstwiki.ru/index.php/Добавление_модулей_nginx_в_Linux_(Debian/Ubuntu/CentOS)

RUN apt-get update \
  && apt-get upgrade -y --no-install-recommends \
  && apt-get -y install \
      build-essential libpcre++-dev libssl-dev libgeoip-dev libxslt1-dev libperl-dev libgd-dev wget unzip

RUN wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
RUN tar zxf nginx-${NGINX_VERSION}.tar.gz

RUN wget https://github.com/fdintino/nginx-upload-module/archive/master.zip
RUN unzip master.zip

RUN cd nginx-${NGINX_VERSION} ; \
./configure --with-cc-opt='-g -O2 -fdebug-prefix-map=/build/nginx-tBUzFN/nginx-${NGINX_VERSION}=. -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-z,relro -Wl,-z,now -fPIC' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_flv_module --with-http_geoip_module=dynamic --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module=dynamic --with-http_mp4_module --with-http_perl_module=dynamic --with-http_random_index_module --with-http_secure_link_module --with-http_sub_module --with-http_xslt_module=dynamic --with-mail=dynamic --with-mail_ssl_module --with-stream=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module --add-dynamic-module=../nginx-upload-module-master ; \
make modules

RUN mv /opt/nginx-1.14.2/objs/ngx_http_upload_module.so /

FROM debian:buster

MAINTAINER Alexey Kovrizhkin <lekovr+docker@gmail.com>

ENV CONSUP_UBUNTU_CODENAME buster

ENV DOCKERFILE_VERSION  190923

# -------------------------------------------------------------------------------
# **** base ****
# -------------------------------------------------------------------------------

ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No

# -------------------------------------------------------------------------------
# Run custom setup scripts

ADD setup_*.sh /tmp/

# Loop does not cache every step
#RUN for f in /tmp/setup_*.sh ; do >&2 echo ">>>> $f" ; . $f ; rm $f ; done

RUN set -x \
  && bash /tmp/setup_0backports.sh \
  && bash /tmp/setup_1pkg.sh \
  && bash /tmp/setup_gosu.sh \
  && bash /tmp/setup_lang.sh \
  && bash /tmp/setup_nginx.sh
  && bash /tmp/setup_perllib_debian.sh \
  && bash /tmp/setup_pg_client.sh

# -------------------------------------------------------------------------------

COPY --from=0 /ngx_http_upload_module.so /usr/lib/nginx/modules/
RUN echo 'load_module /usr/lib/nginx/modules/ngx_http_upload_module.so;' | sudo tee /etc/nginx/modules-enabled/50-mod-http-upload.conf

# -------------------------------------------------------------------------------
# Setup primary lang
ENV LANG en_US.UTF-8

# -------------------------------------------------------------------------------
# user op

RUN useradd -m -r -s /bin/bash -Gwww-data -gusers -gsudo op

# -------------------------------------------------------------------------------
# nginx config files

ADD fastcgi_params /etc/nginx/
ADD proxy_params /etc/nginx/

# -------------------------------------------------------------------------------
# supervisord config files
COPY supervisor.d/*.conf /etc/supervisor/conf.d/

# startup scripts
COPY init.d /init.d

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

# Create user on start, see init.d/user.sh
ENV APP_USER op

# path to init script, see init.d/z-app.sh
ENV APP_ROOT /data

# expose ports for nginx - 80
EXPOSE 80

CMD ["server"]
