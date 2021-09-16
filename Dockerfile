##############################################################################
# The FUSE driver needs elevated privileges, run Docker with --privileged=true
###############################################################################

FROM alpine:3.13.6
ARG S3FS_VERSION=v1.90
COPY entrypoint.sh /

RUN apk --update add bash fuse libcurl libxml2 libstdc++ libgcc alpine-sdk automake autoconf libxml2-dev fuse-dev curl-dev git mailcap; \
    git clone --branch=${S3FS_VERSION} --depth=1 https://github.com/s3fs-fuse/s3fs-fuse.git; \
    cd s3fs-fuse; \
    ./autogen.sh; \
    ./configure --prefix=/usr ; \
    make; \
    make install; \
    make clean; \
    rm -rf /var/cache/apk/*; \
    apk del git automake autoconf; \
    sed -i s/"#user_allow_other"/"user_allow_other"/g /etc/fuse.conf; \
    chmod +x /entrypoint.sh;

CMD /entrypoint.sh

