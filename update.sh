#!/bin/bash
curdir=$(pwd)
srvdir=$curdir/stable
cachedir=$curdir/.cache
rm -rf $cachedir
mkdir -p $cachedir/index
mkdir -p $srvdir/dists/stable/main
mkdir -p $srvdir/pool/main
echo "Begin indexing" >> $srvdir/dists/index.log
date >>  $srvdir/dists/index.log
cd $srvdir
apt-ftparchive --md5 -a amd64 packages pool/main > $cachedir/index/Packages.main64
apt-ftparchive --md5 -a i386 packages pool/main > $cachedir/index/Packages.main32
#Packages oluşturuldu. Packages kopyalanacak
mkdir -p $cachedir/index/dists/stable/main/binary-amd64/
mkdir -p $cachedir/index/dists/stable/main/binary-i386/
#taşı
mv $cachedir/index/Packages.main64 $cachedir/index/dists/stable/main/binary-amd64/Packages
mv $cachedir/index/Packages.main32 $cachedir/index/dists/stable/main/binary-i386/Packages
gzip -k $cachedir/index/dists/stable/main/binary-amd64/Packages
gzip -k $cachedir/index/dists/stable/main/binary-i386/Packages
xz -k $cachedir/index/dists/stable/main/binary-amd64/Packages
xz -k $cachedir/index/dists/stable/main/binary-i386/Packages

cp -rf $cachedir/index/* $srvdir
echo "Finish indexing" >> $srvdir/dists/index.log
date >>  $srvdir/dists/index.log
echo "" >> $srvdir/dists/index.log
rm -rf $cachedir
#create release
cat > $srvdir/dists/stable/Release << EOF
Origin: debian
Label: debian
Suite: debian
Version: 10.0
Codename: stable
Changelogs: https://debjaro.github.io
Date: Sat, 01 Aug 2020 11:04:59 UTC
Architectures: amd64 i386
Components: main
Description: Debjaro repository
MD5Sum:
EOF
cd $srvdir/dists/stable/
prepareLine(){
    while read line ; do
        fname=$(echo $line | sed "s/.* //g")
        fhash=$(echo $line | sed "s/ .*//g")
        echo -e "  $fhash\t$(du -bs $fname| sed 's|\./||g')"
    done
}
echo "MD5Sum:" >>  Release
find . -type f | xargs md5sum | prepareLine >> Release
echo "SHA1:" >>  Release
find . -type f | xargs sha1sum | prepareLine >> Release
echo "SHA256:" >>  Release
find . -type f | xargs sha256sum | prepareLine >> Release
echo "SHA512:" >>  Release
find . -type f | xargs sha512sum | prepareLine  >> Release
gpg --clearsign -o InRelease Release
gpg -abs -o Release.gpg Release
gpg --output Release.key --armor --export 1F7B7D18FBE8F52F90E8F923618AE0AEF8D16C2D

