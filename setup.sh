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

get_priv_cmd() {
    if [[ $(whoami) == "root" ]]; then
        is_root="y"
    elif command -v doas &>/dev/null; then
        priv_cmd="doas"
    elif command -v sudo &>/dev/null; then
        priv_cmd="sudo"
    else
        echo "Neither sudo or doas found, cannot continue"
        exit 1
    fi
}

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macOS"
    elif apt -v &>/dev/null; then
        OS_TYPE="debian"
        get_priv_cmd
    elif apk version &>/dev/null; then
        OS_TYPE="alpine"
        get_priv_cmd
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
update_debian() {
    if [[ "$is_root" == "y" ]]; then
        apt update
        apt upgrade -y
    else
        "$priv_cmd" apt update
        "$priv_cmd" apt upgrade -y
    fi
}

install_git_debian() {
    if [[ "$is_root" == "y" ]]; then
        apt install -y git
    else
        "$priv_cmd" apt install -y git
    fi
}

install_php_debian() {
    if [[ "$is_root" == "y" ]]; then
        apt install -y php-cli php-xml php-zip php-gd php-curl php-fpdf php-sqlite3 php-ssh2
    else
        "$priv_cmd" apt install -y php-cli php-xml php-zip php-gd php-curl php-fpdf php-sqlite3 php-ssh2
    fi
}

#----alpine----
update_alpine() {
    if [[ "$is_root" == "y" ]]; then
        apk update
        apk upgrade
    else
        "$priv_cmd" apk update 
        "$priv_cmd" apk upgrade
    fi
}

install_git_alpine() {
    if [[ "$is_root" == "y" ]]; then
        apk add git
    else
        "$priv_cmd" apk add git
    fi
}

install_php_alpine() {
    if [[ "$is_root" == "y" ]]; then
        apk add php-cli php-dom php-simplexml php-zip php-gd php-curl php-sqlite3 php-ssh2 php-posix php-ctype php-fileinfo php-pcntl php-sockets php-openssl php-bz2
    else
        "$priv_cmd" apk add php-cli php-dom php-simplexml php-zip php-gd php-curl php-sqlite3 php-ssh2 php-posix php-ctype php-fileinfo php-pcntl php-sockets php-openssl php-bz2
    fi
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
    if [ -d "/Applications/stats.app" ]; then
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
        update_debian
        install_git_debian
        install_php_debian
    elif [[ "$OS_TYPE" == "alpine" ]]; then
        update_alpine
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
        "Your refurbished laptop has seen things. Be kind to it."
        "Refurbished laptop: like adopting a pet—it may have a mysterious past, but it still has plenty of love to give."
        "Linux is free only if your time has no value."
        "Linux: making the impossible possible and the simple difficult."
        "Your CPU is not supposed to function as a space heater."
        "The three leading causes of computer failure: dust, dust, and user error."
        "Is your computer running slow? It's probably carrying the weight of all that dust."
        "Touch Bar: Apple's way of asking 'How would you like your function keys to be less functional?'"
        "Apple's idea of repair: 'Have you tried buying a new one?'"
        "Buying refurbished: Saving the planet, one rejected laptop at a time."
        "Bash scripting is like cooking with random ingredients from your fridge—occasionally brilliant, often terrifying."
        "There's a fine line between a working bash script and complete chaos. That line is usually a semicolon."
        "I don't always test my code, but when I do, I do it in production."
        "Turning it off and on again: The IT equivalent of 'Put some ice on it.'"
        "Keyboard not found. Press F1 to continue."
        "There are two hard problems in computer science: cache invalidation, naming things, and off-by-one errors."
        "Cloud computing: Never having to worry where your data is, because it's definitely somewhere."
        "The problem with troubleshooting is that trouble shoots back."
        "We use version control so we know exactly who to blame."
        "My laptop's not overheating, it's trying to achieve nuclear fusion with dust particles."
        "Every Linux distro is the same. Just different enough to break all your scripts."
        "In Windows, viruses do horrible things to your computer. In Linux, your computer does horrible things to you."
        "MacOS is Unix with a fashion degree and a trust fund."
        "MacBook Pro: It's not throttling, it's 'thermal mindfulness.'"
        "We don't do it because it's easy; we do it because we thought it would be easy"
        "Never spend 5 hours on a task that you could spend 5 days failing to automate."
        "There is nothing more permanent than a temporary solution"
        "Everybody has a test environment; some of us are lucky and have a separate production environment, too."
        "Backwards compatibility: Retaining all the mistakes of the previous version."
        "To make an error is human. To spread the error across all servers in an automated way is DevOps."
        "A good man would rotate SSH keys, but I'm not that man."
        "Some days you are the bug, and some days you are the windshield"
        "Next time hit it with a hammer."
        "Never trust a computer you can’t throw out a window. - Steve Wozniak"
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
