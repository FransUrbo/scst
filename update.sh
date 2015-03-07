#!/bin/sh

set -e

# Checkout SVN trunc and create upstream GIT tag
git checkout --orphan svn
git rm --cached *
rm *
svn checkout svn://svn.code.sf.net/p/scst/svn/trunk .
git add -f * .svn
svn info > info.msg
git commit -F info.msg
REV=`grep ^Revision: info.msg  | sed 's@.*: @@'`
git tag upstream/$REV

# Delete temporary branch
git checkout readme
git branch -D svn

# Checkout debian directory
git checkout upstream/$REV
git checkout `git tag -l | grep ^r | tail -n1` debian
mv debian/changelog debian/changelog.old
cat <<EOF > debian/changelog.new
scst (3.0.0~pre2+svn$REV-ppa1) wheezy; urgency=high

  * Include debian directory from `git tag -l | grep ^r | tail -n1`
    + Updated to svn$REV

 -- Turbo Fredriksson <turbo@bayour.com>  `date -R`

EOF
cat debian/changelog.new debian/changelog.old > debian/changelog
rm debian/changelog.*
git add debian/changelog
cat <<EOF > debian/gbp.conf
[DEFAULT]
upstream-tag=upstream/$REV
EOF
git add debian/gbp.conf
git commit -m "Import debian dir + updated to svn$REV"
git tag r$REV

# Cleanup
rm info.msg
