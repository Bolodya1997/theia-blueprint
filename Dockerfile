FROM node:12.19.0-stretch as setup
RUN apt-get update && apt-get install -y libxkbfile-dev libsecret-1-dev

FROM setup as build
WORKDIR /root/velocity-ide

COPY . .
RUN yarn

FROM build as runtime-dependencies

# Install Python 3 from source
ARG VERSION=3.8.3
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y make build-essential libssl-dev \
    && apt-get install -y libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    && apt-get install -y libncurses5-dev  libncursesw5-dev xz-utils tk-dev \
    && wget https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tgz \
    && tar xvf Python-$VERSION.tgz \
    && cd Python-$VERSION \
    && ./configure \
    && make -j8 \
    && make install \
    && cd .. \
    && rm -rf Python-$VERSION \
    && rm Python-$VERSION.tgz

FROM runtime-dependencies as run
WORKDIR ./applications/electron

# Cleanup apt cache
RUN apt-get clean \
    && apt-get auto-remove -y \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

CMD yarn start
