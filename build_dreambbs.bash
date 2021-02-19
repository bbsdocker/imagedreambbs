#!/usr/bin/env bash

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
if [ "${DREAMBBS_SNAP_GIT}" = "" ]; then export DREAMBBS_SNAP_GIT="https://github.com/ccns/dreambbs_snap.git"; fi
if [ "${DREAMBBS_GIT}" = "" ]; then export DREAMBBS_GIT="https://github.com/ccns/dreambbs.git"; fi

set -eux

# check environment
env
gcc -v

## clone current repo, build and install it
git clone ${DREAMBBS_SNAP_GIT} ${BBSHOME}
git clone ${DREAMBBS_GIT} ${BBSHOME}/src
if [ "${DREAMBBS_GIT}" = "https://github.com/IepIweidieng/dreambbs.git" ]; then
    cd ${BBSHOME}/src;
    curl -L -o ipv6_workaround.patch https://gist.github.com/holishing/2d94033592c35b5c7c08572889adabf1/raw/c60179fe85ff3f3995322f9399c32865ed524555/0001-Revert-fix-IPv6-socket-fix-misuse-of-AF_UNSPEC-for-s.patch;
    git config user.name "Docker Script"
    git config user.email "do-not-reply@docker.test"
    git am 0001-Revert-fix-IPv6-socket-fix-misuse-of-AF_UNSPEC-for-s.patch;
    cd -;
fi
cp -v /tmp/dreambbs.conf ${BBSHOME}/src/dreambbs.conf
echo 'export BBSHOME=${HOME}' > ${HOME}/.bashrc
echo '. ${HOME}/.bashrc' > ${HOME}/.bash_profile
mkdir ${BBSHOME}/src/build
cd ${BBSHOME}/src/build
cmake ..
make install clean
