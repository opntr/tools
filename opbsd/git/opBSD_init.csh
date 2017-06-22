#!/bin/csh

set BSD_NAME=opBSD
set GIT_USER=opntr
set GIT_PREFIX=opbsd

git clone git@github.com:${GIT_PREFIX}/${BSD_NAME}.git ${BSD_NAME}.git
if ( $? != 0 ) then
	git clone https://github.com/${GIT_USER}/${BSD_NAME}.git ${BSD_NAME}.git
endif

cd ${BSD_NAME}.git

git remote add freebsd "https://github.com/freebsd/freebsd.git"
git config --add remote.freebsd.fetch '+refs/notes/*:refs/notes/*'
git fetch freebsd

git remote add prodevops "git@prodevops.net:opBSD/opBSD.git"
git fetch prodevops

# FreeBSD upstream repos
git branch --track freebsd/10-stable/master freebsd/stable/10
git branch --track freebsd/11-stable/master freebsd/stable/11
git branch --track freebsd/current/master freebsd/master

# opBSD 10-STABLE master branches
git branch --track {,origin/}${GIT_PREFIX}/10-stable/master
