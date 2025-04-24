#!/bin/bash

#######################################################
# PTS-Auto-Setup - setup script for Phoronix-Test-suite
# https://github.com/nkerschner/PTS-auto-setup/setup.sh
# v2.0
#######################################################

DEFAULT_PHOROMATIC_URL=phoromatic:8433/Q1CST9

go_home() {
    cd $HOME
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
    else
        echo "CRITICAL ERROR: UNSUPPORTED OS"
        exit 1
    fi

    echo "OS Detected: $OS_TYPE"
}

detect_arch() {
    if [[ "$(uname -m)" == "arm64" ]]; then
        ARCH="arm64"
    else
        ARCH="x86_64"
    fi
}



#----debian----
install_git_debian() {
    sudo apt install git
}

install_php_debian() {
    sudo apt install php-cli php-xml php-zip php-gd php-curl php-fpdf php-sqlite3 php-ssh2
}

#----alpine----
install_git_alpine() {
    doas apk add git
}

install_php_alpine() {
    doas apk add php-cli php-dom php-simplexml php-zip php-gd php-curl php-sqlite3 php-ssh2 php-posix php-ctype php-fileinfo php-pcntl php-sockets
}


#----macOS----
install_xcode_tools() {
    
    if command -v git &>/dev/null; then
        echo "git installed, moving on"
    else
        echo "Git not found, installing now"
        echo "Installation prompt should pop up"
        xcode-select --install
        read -p "Press enter once xcode install is complete" xcode_complete
    fi
}

install_homebrew() {
    if command -v brew &>/dev/null; then
        echo "homebrew installed, updating instead"
        brew update
    else
        echo "Installing Homebrew"     
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo >> "$HOME"/.zprofile
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME"/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

install_php_macOS() {
    if brew list php &>/dev/null; then
        echo "PHP already installed, updating"
        brew upgrade php
    else
        echo "Installing PHP"
        brew install php
    fi

    brew services restart php

}

install_stats() {
    if [ -f "/Applications/stats.app" &>/dev/null; then
        echo "Stats already installed, updating"
        brew upgrade stats
    else
        echo "Installing Stats"
        brew install stats
    fi

    open -a stats

}

install_osx_cpu_temp() {
    # Remove existing directory if it exists
    if [ -d "osx-cpu-temp" ]; then
        echo "Removing existing osx-cpu-temp folder"
        rm -rf osx-cpu-temp
    fi

    echo "Downloading new OSX-CPU-Temp"
    git clone https://github.com/nkerschner/osx-cpu-temp
    cd osx-cpu-temp
    make
    sudo make install

    go_home
}

#----OS agnostic----
install_pts(){
    # Remove existing directory if it exists
    if [ -d "phoronix-test-suite" ]; then
        echo "Removing existing phoronix-test-suite folder"
        rm -rf phoronix-test-suite
    fi

    echo "Downloading latest Phoronix-Test-Suite"
    git clone https://github.com/phoronix-test-suite/phoronix-test-suite
}


install_all() {
    echo "==============================================" 
    echo "    Installing prerequisite software"
    echo "=============================================="
    
    if [[ "$OS_TYPE" == "macOS" ]]; then
        sudo -v
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

    echo ""
    echo "----------------------------------------------"
    read -p "Press enter to use the default Phoromatic URL ("$DEFAULT_PHOROMATIC_URL"), or press 'n' to input a new Phoromatic URL: " userChoice

    if [[ "$userChoice" == "n" ]]; then
        get_phoromatic_url
    else
        PHOROMATIC_URL="$DEFAULT_PHOROMATIC_URL"
    fi


    echo "=============================================="
    echo "    Connecting to "$PHOROMATIC_URL"           "
    echo "=============================================="
    ./phoronix-test-suite phoromatic.connect "$PHOROMATIC_URL"
}

# display a random message of the day
function message_of_the_day() {
    local messages=(
        "*insert motd here*"
        "It's not a bug, it's an undocumented feature."
        "The 'cloud' is just someone else's computer."
        "I can explain it to you, but I can't understand it for you."
        "Artificial intelligence is no match for natural stupidity."
        "When in doubt, add another if statement."
        "Terminal: Where MacOS users pretend they're Linux users."
        "Macs don't get viruses, they get 'unexpected behaviors.'"
        "MacOS: Because sometimes you just want things to 'just work'... eventually."
        "Please suggest more messages"
    )

  echo "${messages[$RANDOM % ${#messages[@]}]}"
}

welcome_message() {
    echo "=============================================="
    echo "    Welcome to the Phoromatic Setup Script    "
    echo "=============================================="
    message_of_the_day
    sleep 5
}

# Main
go_home
detect_os
detect_arch
welcome_message
install_all
connect_phoromatic
