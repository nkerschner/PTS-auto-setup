#!/bin/bash

cd ~/
PHOROMATIC_SERVER=$1

#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> /Users/open/.zprofile
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> /Users/open/.zprofile
eval "$(/usr/local/bin/brew shellenv)"


brew install php

cp -R /Volumes/Phoronix/phoronix-test-suite ~/
cd ~/phoronix-test-suite

./phoronix-test-suite phoromatic.connect "$PHOROMATIC_SERVER"
