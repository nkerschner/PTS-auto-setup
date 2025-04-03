#!/bin/bash

cd ~/
echo "Please enter your Phoromatic URL: "
read PHOROMATIC_SERVER

#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> /Users/open/.zprofile
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> /Users/open/.zprofile
eval "$(/usr/local/bin/brew shellenv)"


brew install php
brew install stats

git clone https://github.com/phoronix-test-suite/phoronix-test-suite
cd ~/phoronix-test-suite

./phoronix-test-suite phoromatic.connect "$PHOROMATIC_SERVER"
