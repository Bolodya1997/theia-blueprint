FROM rrandom312/web-ide:latest as setup
WORKDIR /root/nginx

RUN apt-get update \
    && apt-get install -y curl gnupg2 ca-certificates lsb-release debian-archive-keyring \
    && curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
       >/usr/share/keyrings/nginx-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/debian `lsb_release -cs` nginx" \
       >/etc/apt/sources.list.d/nginx.list \
    && apt-get update \
    && apt-get install nginx

COPY ./127.0.0.1.* .
COPY ./nginx.conf /etc/nginx/nginx.conf

FROM setup as run
WORKDIR /root/velocity-ide/applications/electron

# Cleanup apt cache
RUN apt-get clean \
    && apt-get auto-remove -y \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

EXPOSE 80 443

CMD bash -c " \
    yarn start & \
    nginx -g 'daemon off;' \
"