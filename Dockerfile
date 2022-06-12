FROM alpine:latest as build

# the following ENV need to be present
ENV S3_URL=""
ENV S3_REGION=""
ENV S3_BUCKET=""
ENV IAM_ROLE=""
ARG S3FS_VERSION=v1.89

RUN apk --update add bash fuse libcurl libxml2 libstdc++ libgcc alpine-sdk automake autoconf libxml2-dev fuse-dev curl-dev git; \
    git clone https://github.com/s3fs-fuse/s3fs-fuse.git; \
    cd s3fs-fuse; \
    git checkout tags/${S3FS_VERSION}; \
    ./autogen.sh; \
    ./configure --prefix=/usr ;\
    make ; \
    make install; \
    make clean; \
    rm -rf /var/cache/apk/*; \
    apk del git automake autoconf alpine-sdk libxml2-dev fuse-dev curl-dev;
RUN rm -rvf s3fs-fuse && sed -i s/"#user_allow_other"/"user_allow_other"/g /etc/fuse.conf

VOLUME /var/s3

COPY docker-entrypoint.sh /
CMD /docker-entrypoint.sh
