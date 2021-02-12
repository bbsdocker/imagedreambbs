#!/usr/bin/env bash

set -eux

export BBSHOME=${HOME}
export BBSUID=$(id -u)
export BBSGID=$(id -g)
export BBSUSR=${USER}
export BBSGROUP=$(id -ng)
export BBSHOME=${HOME}
#export WWWGID=$(id -g nginx)
#export WWWGROUP=nginx
export WWWGID=$(id -u)
export WWWGROUP=$(id -ng)
export DREAMBBS_SNAP_GIT="https://github.com/ccns/dreambbs_snap.git"
export DREAMBBS_GIT="https://github.com/ccns/dreambbs.git"

# check environment
env
gcc -v

## clone current repo, build and install it
git clone ${DREAMBBS_SNAP_GIT} ${BBSHOME}
git clone ${DREAMBBS_GIT} ${BBSHOME}/src
cp -v /tmp/dreambbs.conf ${BBSHOME}/src/dreambbs.conf
echo 'export BBSHOME=${HOME}' > ${HOME}/.bashrc
echo '. ${HOME}/.bashrc' > ${HOME}/.bash_profile
mkdir ${BBSHOME}/src/build
cd ${BBSHOME}/src/build
cmake ..
make install clean
