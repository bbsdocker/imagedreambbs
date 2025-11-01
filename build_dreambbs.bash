#!/usr/bin/env bash

if [ "${DREAMBBS_SNAP_GIT}" = "" ]; then export DREAMBBS_SNAP_GIT="https://github.com/ccns/dreambbs_snap.git"; fi
if [ "${DREAMBBS_GIT}" = "" ]; then export DREAMBBS_GIT="https://github.com/ccns/dreambbs.git"; fi
if [ "${DREAMBBS_BRANCH}" = "" ]; then export DREAMBBS_BRANCH="master"; fi
if [ "${DREAMBBS_SHA}" = "" ]; then export DREAMBBS_SHA=""; fi

set -e
set -x

source /tmp/env.compile
## clone current repo, build and install it
git clone ${DREAMBBS_SNAP_GIT} ${BBSHOME}
rm -rf ${BBSHOME}/.git*
cp /tmp/env.compile ~/.env.compile

# check environment
env
gcc -v

set -u

git clone -b ${DREAMBBS_BRANCH} --single-branch ${DREAMBBS_GIT} ${BBSHOME}/src
if [ "${DREAMBBS_SHA}" != "" ]; then
    (
        cd "${BBSHOME}/src" \
        && {
            if [ "${DREAMBBS_SHA}" != "$(git rev-parse HEAD)" ]; then
                git checkout "${DREAMBBS_SHA}"
            fi
        }
    )
fi
cd ${BBSHOME}/src
git apply /tmp/try_strl.patch
cp -v /tmp/dreambbs.conf ${BBSHOME}/src/dreambbs.conf
echo 'export BBSHOME=${HOME}' > ${HOME}/.bashrc
echo '. ${HOME}/.bashrc' > ${HOME}/.bash_profile
mkdir ${BBSHOME}/src/build
cd ${BBSHOME}/src/build
cmake "-DUSE_CXX=ON" ..
make install clean
