#!/bin/sh

set -e

# Checkout SVN trunc and create upstream GIT tag
git checkout --orphan svn
git rm --cached README.md
rm *
svn checkout svn://svn.code.sf.net/p/scst/svn/trunk .
git add -f * .svn
svn info > info.msg
git commit -F info.msg
git tag upstream/`grep ^Revision: info.msg  | sed 's@.*: @@'`

# Delete temporary branch
git checkout readme
git branch -D svn

# Checkout debian directory
git checkout upstream/`grep ^Revision: info.msg  | sed 's@.*: @@'`
git checkout `git tag -l | grep ^r | tail -n1`
mv debian/changelog debian/changelog.old
cat <<EOF > debian/changelog.new
scst (3.0.0~pre2+svn`grep ^Revision: info.msg  | sed 's@.*: @@'`-ppa1) wheezy; urgency=high

  * Updated to svn`grep ^Revision: info.msg  | sed 's@.*: @@'`

 -- Turbo Fredriksson <turbo@bayour.com>  `date -R`

EOF
cat debian/changelog.new debian/changelog.old > debian/changelog
rm debian/changelog.*
git commit -m "Updated to svn`grep ^Revision: info.msg  | sed 's@.*: @@'`" debian/changelog
git tag r`grep ^Revision: info.msg  | sed 's@.*: @@'`

# Cleanup
rm info.msg
