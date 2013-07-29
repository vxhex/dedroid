#!/bin/sh
#
# Runs various tools against an Android apk
# Currently runs apktool, dex2jar, and jad
#
# Works stock on Kali 1.0, should work on any flavor with tools in path
# https://github.com/vxhex/dedroid

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
	echo "Usage: $0 [apk] [dir]"
	echo "[apk] - The Android app to explore"
	echo "[dir] - The output directory (dedroid_out by default)"
	exit;
fi

apkfile=$1
apkout=$2
dir=`pwd`

if [ "$#" -eq 1 ]; then
	apkout="dedroid_out"
fi

echo "[!] Hang on, we're in for some chop!"
echo "[+] Running apktool..."
apktool d $dir/$apkfile $dir/$apkout/apktool_out

echo "[+] Unzipping apk to grab classes.dex..."
unzip -d $dir/$apkout/dex2jar_out $apkfile

echo "[+] Running dex2jar..."
d2j-dex2jar -o $dir/$apkout/dex2jar_out/$apkfile.jar $dir/$apkout/dex2jar_out/classes.dex

echo "[+] Running jad on generated jar file..."
mkdir $dir/$apkout/jad_out
cp $dir/$apkout/dex2jar_out/$apkfile.jar $dir/$apkout/jad_out/$apkfile.jar
unzip -d $dir/$apkout/jad_out $dir/$apkout/jad_out/$apkfile.jar
for f in `find $dir/$apkout/jad_out -name '*.class'`; do
	jad -d $(dirname $f) -s java $f
done
rm $dir/$apkout/jad_out/$apkfile.jar

echo "[+] Dedroid complete!"
