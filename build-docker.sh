#!/bin/bash
set -euf -o pipefail

export BRANCH='r1.7'

cd src

if [[ ${1:-} == "reset" ]]; then
  git add .
  git reset --hard
fi

git checkout ${BRANCH}
git pull --rebase

export TF_DOCKER_BUILD_TYPE='GPU'
export TF_DOCKER_BUILD_IS_DEVEL='NO'
export TF_DOCKER_BUILD_PYTHON_VERSION='PYTHON3'
export TF_DOCKER_BUILD_OPTIONS='MAVX2_FMA'

export TF_DOCKER_BUILD_IMAGE_NAME='fekle/tensorflow-avx2'
export TF_DOCKER_BUILD_PUSH_CMD='docker push'

export CFLAGS='-march=native -O3 -pipe'
export CXXFLAGS="${CFLAGS}"

tensorflow/tools/docker/parameterized_docker_build.sh
