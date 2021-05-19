#!/bin/bash
set -euo pipefail
set -o errexit
set -o errtrace
IFS=$'\n\t'

export S3_ACL=${S3_ACL:-private}

mkdir -p ${MNT_POINT}

verbose=$(echo $VERBOSE | tr '[:upper:]' '[:lower:]')

if [ "$IAM_ROLE" == "none" ]; then
  export AWSACCESSKEYID=${AWSACCESSKEYID:-$AWS_KEY}
  export AWSSECRETACCESSKEY=${AWSSECRETACCESSKEY:-$AWS_SECRET_KEY}

  echo "${AWS_KEY}:${AWS_SECRET_KEY}" > /etc/passwd-s3fs
  chmod 0400 /etc/passwd-s3fs

  echo 'IAM_ROLE is not set - mounting S3 with credentials from ENV'
  if [ "$verbose" == "true" ]; then
    /usr/bin/s3fs  ${S3_BUCKET} ${MNT_POINT} -d -d -f -o endpoint=${S3_REGION},allow_other,retries=5 -o nonempty -o umask=0007,uid=${MNT_UID},gid=${MNT_GID}
  else
    /usr/bin/s3fs  ${S3_BUCKET} ${MNT_POINT} -f -o endpoint=${S3_REGION},allow_other,retries=5 -o nonempty -o umask=0007,uid=${MNT_UID},gid=${MNT_GID}
  fi
  echo 'started...'
else
  echo 'IAM_ROLE is set - using it to mount S3'
  if [ "$verbose" == "true" ]; then
    /usr/bin/s3fs ${S3_BUCKET} ${MNT_POINT} -d -d -f -o endpoint=${S3_REGION},iam_role=${IAM_ROLE},allow_other,retries=5 -o umask=0007,uid=${MNT_UID},gid=${MNT_GID}
  else
    /usr/bin/s3fs ${S3_BUCKET} ${MNT_POINT} -f -o endpoint=${S3_REGION},iam_role=${IAM_ROLE},allow_other,retries=5 -o umask=0007,uid=${MNT_UID},gid=${MNT_GID}
  fi
fi
