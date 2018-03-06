###############################################################################
# The FUSE driver needs elevated privileges, run Docker with --privileged=true
###############################################################################

FROM alpine:3.3

ENV MNT_POINT /var/s3
ENV S3_REGION ''

ARG S3FS_VERSION=v1.83

RUN apk --update --no-cache add fuse alpine-sdk automake autoconf libxml2-dev fuse-dev curl-dev git bash; \
    git clone https://github.com/s3fs-fuse/s3fs-fuse.git; \
    cd s3fs-fuse; \
    git checkout tags/${S3FS_VERSION}; \
    ./autogen.sh; \
    ./configure --prefix=/usr; \
    make; \
    make install; \
    make clean; \
    rm -rf /var/cache/apk/*; \
    apk del git automake autoconf;

RUN mkdir -p "$MNT_POINT"

CMD echo "${AWS_KEY}:${AWS_SECRET_KEY}" > /etc/passwd-s3fs && \
    chmod 0400 /etc/passwd-s3fs && \
    /usr/bin/s3fs $S3_BUCKET $MNT_POINT -f -o endpoint=${S3_REGION},allow_other,use_cache=/tmp,max_stat_cache_size=1000,stat_cache_expire=900,retries=5,connect_timeout=10
