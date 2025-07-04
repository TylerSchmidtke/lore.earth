FROM ghcr.io/nginxinc/nginx-s3-gateway/nginx-oss-s3-gateway:latest
ENV BROTLI_VERSION "v1.0.0rc"

# Build Brotli module from source because there is no repository package
RUN set -eux \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update -qq; \
    apt-get install -y -qq build-essential libpcre3-dev git libbrotli1 libbrotli-dev; \
    curl -o /tmp/nginx.tar.gz --retry 6 -Ls "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"; \
    mkdir /tmp/nginx /tmp/brotli; \
    tar -C /tmp/nginx --strip-components 1 -xzf /tmp/nginx.tar.gz; \
    curl -o /tmp/brotli.tar.gz --retry 6 -Ls "https://github.com/google/ngx_brotli/archive/${BROTLI_VERSION}.tar.gz"; \
    tar -C "/tmp/brotli" --strip-components 1 -xzf /tmp/brotli.tar.gz; \
    cd /tmp/nginx; \
    ./configure --add-dynamic-module=/tmp/brotli \
    --without-http_gzip_module \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx --group=nginx --with-compat --with-file-aio \
    --with-threads \
    --with-compat \
    --with-cc-opt="-g -O2 -fdebug-prefix-map=/data/builder/debuild/nginx-${NGINX_VERSION}/debian/debuild-base/nginx-${NGINX_VERSION}=. -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC" \
    --with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie'; \
    make -j $(nproc) modules; \
    cp /tmp/nginx/objs/ngx_http_brotli_filter_module.so /usr/lib/nginx/modules; \
    cp /tmp/nginx/objs/ngx_http_brotli_static_module.so /usr/lib/nginx/modules; \
    apt-get purge -y --auto-remove build-essential libpcre3-dev git libbrotli-dev; \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# Update configuration to load module
RUN sed -i '1s#^#load_module modules/ngx_http_brotli_filter_module.so;\n\n#' /etc/nginx/nginx.conf

COPY conf /etc/nginx/conf.d

ENV S3_BUCKET_NAME=lore-earth
ENV S3_SERVER=fly.storage.tigris.dev
ENV S3_SERVER_PROTO=https
ENV S3_SERVER_PORT=443
ENV AWS_SIGS_VERSION=4
ENV S3_STYLE=virtual-v2
ENV S3_REGION=auto
ENV ALLOW_DIRECTORY_LIST=false
ENV PROVIDE_INDEX_PAGE=true
ENV PROXY_CACHE_MAX_SIZE=1g
ENV PROXY_CACHE_SLICE_SIZE=1m
ENV PROXY_CACHE_INACTIVE=60m
ENV PROXY_CACHE_VALID_OK=1h
ENV PROXY_CACHE_VALID_NOTFOUND=1m
ENV PROXY_CACHE_VALID_FORBIDDEN=30s
