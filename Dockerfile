FROM alpine:latest as build

ARG S3FS_VERSION=v1.89

RUN apk --update add bash fuse libcurl libxml2 libstdc++ libgcc alpine-sdk automake autoconf libxml2-dev fuse-dev curl-dev curl-static git fuse-static openssl-libs-static openssl-dev nghttp2-dev nghttp2-static ; \
    git clone https://github.com/s3fs-fuse/s3fs-fuse.git; \
    cd s3fs-fuse; \
    git checkout tags/${S3FS_VERSION}; \
    ./autogen.sh; \
    ./configure --prefix=/usr LDFLAGS="-all-static" ; \
    make; \
    make install; \
    make clean; \
    rm -rf /var/cache/apk/*; \
    apk del git automake autoconf;

RUN sed -i s/"#user_allow_other"/"user_allow_other"/g /etc/fuse.conf

# Prod image
FROM alpine:latest as prod

COPY --from=build /etc/fuse.conf /etc/passwd /etc/group /etc/
COPY --from=build /usr/bin/s3fs /usr/bin/

# the following ENV need to be present
ENV S3_URL=""
ENV S3_REGION=""
ENV S3_BUCKET=""
ENV IAM_ROLE=""

VOLUME /var/s3

COPY docker-entrypoint.sh /
CMD /docker-entrypoint.sh
