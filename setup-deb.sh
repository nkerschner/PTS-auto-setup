#!/bin/bash

cd ~/
echo "Please enter your Phoromatic URL: "
read PHOROMATIC_SERVER

apt update && apt upgrade

apt install php php-dom php-xml git

git clone https://github.com/phoronix-test-suite/phoronix-test-suite
cd ~/phoronix-test-suite

./phoronix-test-suite phoromatic.connect "$PHOROMATIC_SERVER"
