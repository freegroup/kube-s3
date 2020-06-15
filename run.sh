#!/bin/bash
mkdir -p "${MNT_POINT}"
echo "${AWS_KEY}:${AWS_SECRET_KEY}" > /etc/passwd-s3fs
chmod 0400 /etc/passwd-s3fs
/usr/bin/s3fs $S3_BUCKET $MNT_POINT -f -o endpoint=${S3_REGION},allow_other,use_cache=/tmp,max_stat_cache_size=1000,stat_cache_expire=900,retries=5,connect_timeout=10

