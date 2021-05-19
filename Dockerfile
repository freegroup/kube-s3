###############################################################################
# The FUSE driver needs elevated privileges, run Docker with --privileged=true
###############################################################################

FROM alpine:latest

ENV MNT_POINT /var/s3
ENV IAM_ROLE=none
ENV S3_REGION ''

VOLUME /var/s3


ARG S3FS_VERSION=v1.89

RUN apk --update add bash fuse libcurl libxml2 libstdc++ libgcc alpine-sdk automake autoconf libxml2-dev fuse-dev curl-dev git; \
    git clone https://github.com/s3fs-fuse/s3fs-fuse.git; \
    cd s3fs-fuse; \
    git checkout tags/${S3FS_VERSION}; \
    ./autogen.sh; \
    ./configure --prefix=/usr ; \
    make; \
    make install; \
    make clean; \
    rm -rf /var/cache/apk/*; \
    apk del git automake autoconf;

RUN sed -i s/"#user_allow_other"/"user_allow_other"/g /etc/fuse.conf

COPY docker-entrypoint.sh /
RUN chmod +x docker-entrypoint.sh
CMD /docker-entrypoint.sh
