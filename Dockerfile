
FROM alpine:edge as builder

ARG REQUIRE="cabal git build-base"
RUN apk update && apk upgrade \
      && apk add --no-cache ${REQUIRE}
RUN apk add ca-certificates && update-ca-certificates

RUN mkdir -p /usr/src/shellcheck
WORKDIR /usr/src/shellcheck

RUN git clone https://github.com/koalaman/shellcheck .
RUN cabal update && cabal install

ENV PATH=${PATH}:/root/.local/bin

# Get shellcheck binary
RUN mkdir -p /package/bin/
RUN echo $(which shellcheck)
RUN cp $(which shellcheck) /package/bin/

# Get shared libraries
RUN mkdir -p /package/lib/
RUN ldd $(which shellcheck) | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' /package/lib/

FROM alpine:latest 

LABEL org.opencontainers.image.authors="anton.feldmann@gmail.com"
LABEL version="1.0"
LABEL description="my shell spellchecker"

COPY --from=builder package/bin/shellcheck /usr/local/bin/
COPY --from=builder package/lib/           /usr/local/lib/

RUN ldconfig /usr/local/lib

WORKDIR /mnt
ENTRYPOINT [ "shellcheck" ]
