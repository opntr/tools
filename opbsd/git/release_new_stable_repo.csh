#!/usr/bin/env csh

set _date = `date "+%Y%m%d"`
set _Mtag = ""
set _mtag = ""
set _stag = ""
set remotes = "origin prodevops"

if ($#argv < 1 ) then
	echo "$0 (10-stable|current) (-s)"
	echo "	-s	update snapshot version"
	exit 1
endif

if ($#argv == 2 ) then
	set __update_mode = ${argv[2]}
else
	set __update_mode = default
endif

git remote -v

echo

git fetch origin

git remote show hardenedbsd
set _ret = $?
if ( ${_ret} != 0 ) then
		echo "WARNING: 'hardenedbsd' remote have not found in your repo, if you want to add them, continue"
		echo "--"
		echo 'enter "yes" to continue'
		set _ok = $<
		if ( $_ok != "yes" ) then
			exit 1
		endif
	git remote add hardenedbsd git@github.com:HardenedBSD/hardenedBSD.git
endif
git fetch hardenedbsd

echo

set __branch = ${argv[1]}

switch (${__branch})
case "10-stable":
		set _lbranch = "opbsd/10-stable/master"
		set _rbranch = "hardenedbsd/hardened/10-stable/master"
		set _stag_template = "opbsd-10-stable-"
		set _vtag_template = "opBSD-10-STABLE-v"
	breaksw
case "current":
		set _lbranch = "opbsd/current/master"
		set _rbranch = "hardenedbsd/hardened/current/master"
		set _stag_template = "opbsd-master-"
		set _vtag_template = "opBSD-11-CURRENT-v"
	breaksw
default:
	echo "not supported branch"
	exit 1
	breaksw
endsw

git checkout ${_lbranch}
git pull

echo

set _source_version = `git show ${_rbranch}:sys/sys/pax.h | awk '/__HardenedBSD_version/{print $3}' | sed -e 's/UL$//g'`

# find the previous versions
set _last_Mtag = `git tag -l "${_vtag_template}*" | sort --version-sort | grep -v '\.'`
set _last_Mtag = ${_last_Mtag[$#_last_Mtag]}
set _last_mtag = `git tag -l "${_vtag_template}*" | sort --version-sort`
set _last_mtag = ${_last_mtag[$#_last_mtag]}
set _last_stag = `git tag -l "${_stag_template}*" | sort --version-sort`
set _last_stag = ${_last_stag[$#_last_stag]}

switch (${__update_mode})
case	-s:
	set _mode = "snapshot"
	# always create snapshot tags
	# so just break out
	breaksw
default:
	set _last_major = `echo ${_last_Mtag} | cut -d 'v' -f 2`
	if ( ${_last_major} < ${_source_version} ) then
		echo "WARNING: local major version (${_last_major}) differs from remote major version (${_source_version}), are you sure to release new major version?"
		echo "--"
		echo 'enter "yes" to continue'
		set _ok = $<
		if ( $_ok != "yes" ) then
			exit 1
		endif
		set _Mtag = ${_vtag_template}${_source_version}
		set _mode = "major"
		breaksw
	endif

	set _mode = "minor"
	if ( ${_last_Mtag} == ${_last_mtag} ) then
		set _mtag = "${_last_Mtag}.1"
	else
		set _last_minor = `echo ${_last_mtag} | cut -d '.' -f 2`
		@ _new_minor = ${_last_minor} + 1
		set _mtag = "${_last_Mtag}.${_new_minor}"
	endif
	breaksw
endsw

set _stag = "${_stag_template}${_date}-1"
if ( ${_stag} == ${_last_stag} ) then
	set _last_snapshot = `echo ${_last_stag} | sed -e 's/.*-\(.*\)$/\1/g'`
	@ _new_snapshot = ${_last_snapshot} + 1
	set _stag = "${_stag_template}${_date}-${_new_snapshot}"
endif

echo "remote branch:	${_rbranch}"
echo "local branch:	${_lbranch}"
echo "update mode:	${_mode}"
echo "prev Mtag:	${_last_Mtag}	new Mtag:	${_Mtag}"
echo "prev mtag:	${_last_mtag}	new mtag:	${_mtag}"
echo "prev stag:	${_last_stag}	new stag:	${_stag}"
echo "--"
echo 'enter "yes" to continue and check the changes'
set _ok = $<
if ( $_ok != "yes" ) then
	exit 1
endif

git log -p ${_lbranch}..${_rbranch}
git diff --stat ${_lbranch} ${_rbranch}
git diff ${_lbranch} ${_rbranch}
echo "--"
echo 'enter "yes" to continue merge the changes'
set _ok = $<
if ( $_ok != "yes" ) then
	exit 1
endif

git merge ${_rbranch}
echo "--"
echo 'enter "yes" to continue and create the tags'
set _ok = $<
if ( $_ok != "yes" ) then
	exit 1
endif

if ( "X${_Mtag}" != "X" ) then
	git tag ${_Mtag}
	git shortlog ${_last_mtag}..${_Mtag} > /tmp/shortlog.txt
endif

if ( "X${_mtag}" != "X" ) then
	git tag ${_mtag}
	git shortlog ${_last_mtag}..${_mtag} > /tmp/shortlog.txt
endif

if ( "X${_stag}" != "X" ) then
	git tag ${_stag}
	git shortlog ${_last_mtag}..${_stag} > /tmp/shortlog.txt
endif
echo "--"
echo 'enter "yes" to continue and push the tags'
set _ok = $<
if ( $_ok != "yes" ) then
	exit 1
endif

foreach i ( ${remotes} )
	git push ${i}
	git push --tags ${i}
end

echo
echo "done."
