#!/usr/bin/env bash

# Installation Script for Local Development

if [ -e /etc/os-release ]; then
   . /etc/os-release
else
   . /usr/lib/os-release
fi
if [ "$ID" = "opensuse-leap" ]; then
    echo "Add wiki repository for openSUSE Leap $VERSION"
    sudo zypper addrepo https://download.opensuse.org/repositories/openSUSE:infrastructure:wiki/openSUSE_Leap_$VERSION/openSUSE:infrastructure:wiki.repo
elif [ "$ID" = "opensuse-tumbleweed" ]; then
    echo "Add wiki repository for openSUSE Tumbleweed"
    sudo zypper addrepo https://download.opensuse.org/repositories/openSUSE:infrastructure:wiki/openSUSE_Tumbleweed/openSUSE:infrastructure:wiki.repo
fi

sudo zypper refresh

# Install RPM packages
echo "Install RPM packages"
sudo zypper install mediawiki_1_27-openSUSE

# Link folders and files

echo "Link MediaWiki files and folders"

function link() {
    rm ./$1 -rf
    ln -s /usr/share/mediawiki_1_27/$1 ./$1
}

link api.php
link autoload.php
link img_auth.php
link index.php
link load.php
link opensearch_desc.php
link thumb_handler.php
link thumb.php

link extensions/AbuseFilter
link extensions/Auth_remoteuser
link extensions/CategoryTree
link extensions/CirrusSearch
link extensions/Cite
link extensions/CiteThisPage
link extensions/ConfirmEdit
link extensions/Elastica
link extensions/Gadgets
link extensions/GitHub
link extensions/HitCounters
link extensions/ImageMap
link extensions/InputBox
link extensions/intersection
link extensions/Interwiki
link extensions/LocalisationUpdate
link extensions/Maps
link extensions/maps-vendor
link extensions/MultiBoilerplate
link extensions/Nuke
link extensions/ParamProcessor
link extensions/ParserFunctions
link extensions/PdfHandler
link extensions/Poem
link extensions/Renameuser
link extensions/ReplaceText
link extensions/RSS
link extensions/SpamBlacklist
link extensions/SyntaxHighlight_GeSHi
link extensions/TitleBlacklist
link extensions/UserMerge
link extensions/UserPageEditProtection
link extensions/Validator
link extensions/WikiEditor

link includes
link languages
link maintenance
link resources
link serialized
link vendor

# Copy development settings
echo "Copy development settings"
cp wiki_settings.example.php wiki_settings.php

# Make directories
echo "Make directories"
rm -r cache
mkdir cache
rm -r data
mkdir data # Save SQLite files
rm -r images
mkdir images

# Run installation script
echo "Run installation script"

# Install without extensions
mv LocalSettings.php _LocalSettings.php
php maintenance/install.php --dbuser="" --dbpass="" --dbname=wiki --dbpath=./data \
    --dbtype=sqlite --confpath=./ --scriptpath=/ --pass=evergreen openSUSE Geeko

# Update with extensions
rm LocalSettings.php
mv _LocalSettings.php LocalSettings.php
php maintenance/update.php --conf LocalSettings.php
