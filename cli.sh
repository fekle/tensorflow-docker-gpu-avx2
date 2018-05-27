#!/bin/bash
set -euf -o pipefail

# tensorflow version to build
export TF_BRANCH='r1.8'
export TF_REPO='https://github.com/tensorflow/tensorflow.git'

# tf-docker configuration
export TF_DOCKER_BUILD_IMAGE_NAME="fekle/tensorflow-avx2"
export TF_DOCKER_BUILD_TYPE="GPU"
export TF_DOCKER_BUILD_IS_DEVEL="NO"
export TF_DOCKER_BUILD_PYTHON_VERSION="PYTHON3"
export TF_DOCKER_BUILD_OPTIONS="MAVX2_FMA"
export TF_DOCKER_BUILD_PUSH_CMD="docker push"
export TF_SKIP_CONTRIB_TESTS=true

case "${1:-}" in
init)
  # initialize src
  git clone -b "${TF_BRANCH}" --single-branch "${TF_REPO}" src
  "${0}" update
  ;;
build)
  # print variables
  env | grep -E '^TF_DOCKER' && echo
  sleep 3

  # build tensorflow docker image
  cd src
  exec ./tensorflow/tools/docker/parameterized_docker_build.sh
  ;;
clean)
  # cleanup dir
  cd src
  git reset --hard
  git clean -fxd
  git prune -v
  git gc --auto
  ;;
update)
  # update src
  cd src
  git fetch --all
  git checkout "${TF_BRANCH}"
  git pull --rebase
  ;;
reset)
  # completely reset src repository if desired
  rm -rf src
  "${0}" init
  ;;
*)
  echo "usage: ${0} <init|build|update|clean|reset>"
  ;;
esac
