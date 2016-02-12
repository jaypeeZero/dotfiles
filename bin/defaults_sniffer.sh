#!/bin/bash
#
# Simple script to aid sniffing plist file changes

echo "Hit Enter to copy BEFORE"
read -s

[ -d /tmp/before ] && rm -rf /tmp/before
[ -d /tmp/after ] && rm -rf /tmp/after

mkdir /tmp/before
mkdir /tmp/after

cp -r ~/Library/Preferences /tmp/before

find /tmp/before -name "*.plist" | while read file
do
    plutil -convert xml1 "$file"
done

echo ""
echo ""
echo "Hit Enter to copy AFTER"
read -s

cp -r ~/Library/Preferences /tmp/after

find /tmp/after -name "*.plist" | while read file
do
    plutil -convert xml1 "$file"
done

echo ""
echo ""

diff -ur /tmp/before /tmp/after
