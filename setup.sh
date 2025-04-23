#!/bin/bash

DEFAULT_PHOROMATIC_URL=phoromatic:8433/Q1CST9

go_home() {
    cd ~/
}

get_phoromatic_url() {
    echo "Please enter your Phoromatic URL: "
    read PHOROMATIC_URL
}

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macOS"
    elif apt -v &>/dev/null; then
        OS_TYPE="debian"
    elif apk version &>/dev/null; then
        OS_TYPE="alpine"
    fi
echo "OS Detected: $OS_TYPE"
}


#----debian----
install_git_debian() {
    apt install git
}

install_php_debian() {
    apt install php-cli php-xml php-zip php-gd php-curl php-fpdf php-sqlite3 php-ssh2
}

#----alpine----
install_git_alpine() {
    apk add git
}

install_php_alpine() {
    apk add php-cli php-dom php-simplexml php-zip php-gd php-curl php-sqlite3 php-ssh2 php-posix php-ctype php-fileinfo php-pcntl php-sockets
}


#----macOS----
install_xcode_tools() {
    xcode-select --install
    
    read -p "Press enter once xcode install is complete" xcode_complete
}

install_homebrew() {
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    echo >> /Users/open/.zprofile
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> /Users/open/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"
}

install_php_macOS() {

    brew install php
    brew services restart php

}

install_stats() {
    brew install stats
}

install_osx_cpu_temp() {
    git clone https://github.com/BourgonLaurent/osx-cpu-temp
    cd osx-cpu-temp
    make
    sudo make install

    go_home
}

install_pts(){
    git clone https://github.com/phoronix-test-suite/phoronix-test-suite
}

#----OS agnostic----
install_all() {
    echo "==============================================" 
    echo "    Installing prerequisite software"
    echo "=============================================="
    
    if [[ "$OS_TYPE" == "macOS" ]]; then
        install_xcode_tools
        install_homebrew
        install_php_macOS
        install_stats
        install_osx_cpu_temp
    elif [[ "$OS_TYPE" == "debian" ]]; then
        install_git_debian
        install_php_debian
    elif [[ "$OS_TYPE" == "alpine" ]]; then
        install_git_alpine
        install_php_alpine
    else
        echo "CRITICAL ERROR: UNSUPPORTED OS"
        exit 1
    fi

    echo "=============================================="
    echo "    Installing the Phoronix Test Suite"
    echo "=============================================="
    install_pts
}

connect_phoromatic() {    
    cd ~/phoronix-test-suite

    read -p "Enter y to use the default Phoromatic URL ("$DEFAULT_PHOROMATIC_URL"), or n to input a new Phoromatic URL: " userChoice

    if [[ "$userChoice" == "y" ]]; then
        PHOROMATIC_URL="$DEFAULT_PHOROMATIC_URL"
    else
        get_phoromatic_url
    fi


    echo "=============================================="
    echo "    Connecting to "$PHOROMATIC_URL"           "
    echo "=============================================="
    ./phoronix-test-suite phoromatic.connect "$PHOROMATIC_URL"
}

welcome_message() {
    echo "=============================================="
    echo "    Welcome to the Phoromatic Setup Script    "
    echo "=============================================="
}

# Main
go_home
detect_os
welcome_message
install_all
connect_phoromatic
