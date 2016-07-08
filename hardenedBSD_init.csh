#!/bin/csh

git clone git@github.com:HardenedBSD/hardenedBSD.git hardenedBSD.git
if ( $? != 0 ) then
	git clone https://github.com/HardenedBSD/hardenedBSD.git hardenedBSD.git
endif

cd hardenedBSD.git

git remote add freebsd https://github.com/freebsd/freebsd.git
git fetch freebsd

# FreeBSD upstream repos
git branch --track freebsd/current/master freebsd/master
git branch --track freebsd/10-stable/master freebsd/stable/10
git branch --track freebsd/11-stable/master freebsd/stable/11
git branch --track freebsd/10.2-releng/master freebsd/releng/10.2
git branch --track freebsd/10.3-releng/master freebsd/releng/10.3

# HardenedBSD 10-STABLE master branches
git branch --track {,origin/}hardened/10-stable/master
git branch --track {,origin/}hardened/10-stable/master-libressl

# HardenedBSD 10-STABLE topic branches
git branch --track {,origin/}hardened/10-stable/unstable

# HardenedBSD 10.2-RELENG master branches
git branch --track {,origin/}hardened/10.2-releng/master

# HardenedBSD 11-STABLE master branches
git branch --track {,origin/}hardened/11-stable/master
git branch --track {,origin/}hardened/11-stable/master-libressl

# HardenedBSD 11-STABLE topic branches
git branch --track {,origin/}hardened/11-stable/unstable

# HardenedBSD master branch
git branch --track {,origin/}hardened/current/master
git branch --track {,origin/}hardened/current/master-libressl
git branch --track {,origin/}hardened/current/unstable

# HardenedBSD CURRENT topic branches
git branch --track {,origin/}hardened/current/intel-smap
git branch --track {,origin/}hardened/current/segvguard-ng
git branch --track {,origin/}hardened/current/log
