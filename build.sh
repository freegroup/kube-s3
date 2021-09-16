#!/usr/bin/env bash

########################################################################################################################
# PREREQUISTITS
########################################################################################################################
#
# - ensure that you have a valid Artifactory or other Docker registry account
# - Create your image pull secret in your namespace
#   kubectl create secret docker-registry artifactory --docker-server=<YOUR-REGISTRY>.docker.repositories.sap.ondemand.com --docker-username=<USERNAME> --docker-password=<PASSWORD> --docker-email=<EMAIL> -n <NAMESPACE>
# - change the settings below arcording your settings
#
# usage:
# Call this script with the version to build and push to the registry. After build/push the
# yaml/* files are deployed into your cluster
#
#  ./build.sh 1.0
#
VERSION=$1
PROJECT=kube-s3
REPOSITORY=dkr.ecr.ap-southeast-1.amazonaws.com


# causes the shell to exit if any subcommand or pipeline returns a non-zero status.
set -e
# set debug mode
#set -x


########################################################################################################################
# build the new docker image
########################################################################################################################
#
#echo '>>> Building new image'
# Due to a bug in Docker we need to analyse the log to find out if build passed (see https://github.com/dotcloud/docker/issues/1875)
#docker build --no-cache=true -t $REPOSITORY/$PROJECT:$VERSION . | tee /tmp/docker_build_result.log

########################################################################################################################
# push the docker image to your registry
########################################################################################################################
#
#echo '>>> Push new image'
#docker push $REPOSITORY/$PROJECT:$VERSION

########################################################################################################################
# deploy your YAML files into your kubernetes cluster
########################################################################################################################
#
# (and replace some placeholder in the yaml files...
# It is recommended to use HELM for bigger projects and more dynamic deployments
#
kubectl apply -f ./yaml/configmap_secrets.yaml
# Apply the YAML passed into stdin and replace the version string first
cat ./yaml/daemonset.yaml | sed "s/container_image/$REPOSITORY\/$PROJECT:$VERSION/g" | kubectl apply -f -
