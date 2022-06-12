#!/bin/bash
set -euo pipefail
set -o errexit
set -o errtrace
IFS=$'\n\t'

export S3_ACL=${S3_ACL:-private}

mkdir -pv /var/s3


if [ "$IAM_ROLE" == "none" ]; then
  export AWSACCESSKEYID=${AWSACCESSKEYID:-$AWS_ACCESS_KEY_ID}
  export AWSSECRETACCESSKEY=${AWSSECRETACCESSKEY:-$AWS_SECRET_ACCESS_KEY}

  echo 'IAM_ROLE is not set - mounting S3 with credentials from ENV'
  /usr/bin/s3fs ${S3_BUCKET} /var/s3 -d -d -f -o url=${S3_URL},endpoint=${S3_REGION},nonempty,allow_other,retries=5
else
  echo 'IAM_ROLE is set - using it to mount S3'
  /usr/bin/s3fs ${S3_BUCKET} /var/s3 -d -d -f -o url=${S3_URL},endpoint=${S3_REGION},iam_role=${IAM_ROLE},nonempty,allow_other,retries=5
fi

exec "$@"
