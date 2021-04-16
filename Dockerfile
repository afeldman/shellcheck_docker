FROM mitchty/alpine-ghc:latest AS builder

LABEL MAINTAINER="Anton Feldmann"
LABEL description="shellcheck container builder"

#envs
ENV PATH="/root/.cabal/bin:$PATH"
ARG shellcheckversion="v0.7.1"

# get git
RUN apk add --no-cache build-base git

# build run dir
RUN mkdir -p /usr/src/shellcheck
WORKDIR /usr/src/shellcheck

RUN git clone --branch ${shellcheckversion} --depth 1 https://github.com/koalaman/shellcheck . \
    && cabal update && cabal install

# Get shellcheck binary
RUN mkdir -p /package/bin/ \
    && cp $(which shellcheck) /package/bin/

# Get shared libraries
RUN mkdir -p /package/lib/ \ 
    && ldd $(which shellcheck) | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' /package/lib/

FROM alpine:latest

LABEL MAINTAINER="Anton Feldmann"
LABEL VERSION="0.7.1"
LABEL description="shellcheck container"

RUN apk add --no-cache tini

COPY --from=builder package/bin/shellcheck /usr/local/bin
COPY --from=builder package/lib /usr/local/lib

RUN ldconfig /usr/local/lib

WORKDIR /mnt
ENTRYPOINT ["/sbin/tini","--"]
CMD [ "shellcheck","--version" ]