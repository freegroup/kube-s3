#!/bin/bash
set -euo pipefail
set -o errexit
set -o errtrace
IFS=$'\n\t'

export MNT_POINT=${MNT_POINT:-/var/s3}
export IAM_ROLE=${IAM_ROLE:-none}
export DBG_Level=${DBG_Level:-information}
export S3_ACL=${S3_ACL:-private}
export S3_REGION=${S3_REGION:-ap-southeast-1}

mkdir -p ${MNT_POINT}

if [ "$IAM_ROLE" == "none" ]; then
  export AWSACCESSKEYID=${AWSACCESSKEYID:-$AWS_KEY}
  export AWSSECRETACCESSKEY=${AWSSECRETACCESSKEY:-$AWS_SECRET_KEY}

  echo "${AWS_KEY}:${AWS_SECRET_KEY}" > /etc/passwd-s3fs
  chmod 0400 /etc/passwd-s3fs

  echo 'IAM_ROLE is not set - mounting S3 with credentials from ENV'
  /usr/bin/s3fs  ${S3_BUCKET} ${MNT_POINT} -d -f -o endpoint=${S3_REGION},allow_other,use_path_request_style,ssl_verify_hostname=0,dbglevel=${DBG_Level} -o url=http://s3-${S3_REGION}.amazonaws.com
  echo 'started...'
else
  echo 'IAM_ROLE is set - using it to mount S3'
  /usr/bin/s3fs ${S3_BUCKET} ${MNT_POINT} -d -f -o endpoint=${S3_REGION},iam_role=${IAM_ROLE},allow_other,retries=5
fi
