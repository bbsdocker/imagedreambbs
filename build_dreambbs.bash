#!/usr/bin/env bash

cp /tmp/env.compile ~/.env.compile
. ~/.env.compile
if [ "${DREAMBBS_SNAP_GIT}" = "" ]; then export DREAMBBS_SNAP_GIT="https://github.com/ccns/dreambbs_snap.git"; fi
if [ "${DREAMBBS_GIT}" = "" ]; then export DREAMBBS_GIT="https://github.com/ccns/dreambbs.git"; fi

set -eux

# check environment
env
gcc -v

## clone current repo, build and install it
git clone ${DREAMBBS_SNAP_GIT} ${BBSHOME}
rm -rf ${BBSHOME}/.git*
git clone ${DREAMBBS_GIT} ${BBSHOME}/src
cp -v /tmp/dreambbs.conf ${BBSHOME}/src/dreambbs.conf
echo 'export BBSHOME=${HOME}' > ${HOME}/.bashrc
echo '. ${HOME}/.bashrc' > ${HOME}/.bash_profile
mkdir ${BBSHOME}/src/build
cd ${BBSHOME}/src/build
cmake ..
make install clean
