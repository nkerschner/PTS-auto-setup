#!/bin/bash

#######################################################
# PTS-Auto-Setup - removal script for Phoronix-Test-suite
# https://github.com/nkerschner/PTS-auto-setup/remove.sh
# v2.1
#######################################################

DEFAULT_PHOROMATIC_URL=phoromatic:8433/Q1CST9

go_home() {
    cd $HOME
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
remove_git_debian() {
   if [[ "$is_root" == "y" ]]; then
        apt remove -y git
        apt autoremove -y
    else
        "$priv_cmd" apt remove -y git
        "$priv_cmd" apt autoremove -y
    fi
}

remove_php_debian() {
   if [[ "$is_root" == "y" ]]; then
        apt remove -y php-cli php-xml php-zip php-gd php-curl php-fpdf php-sqlite3 php-ssh2
        apt autoremove -y
    else
        "$priv_cmd" apt remove -y php-cli php-xml php-zip php-gd php-curl php-fpdf php-sqlite3 php-ssh2
        "$priv_cmd" apt autoremove -y
    fi
}

#----alpine----
remove_git_alpine() {
    if [[ "$is_root" == "y" ]]; then
        apk del git
    else
        "$priv_cmd" apk del git
    fi
}

remove_php_alpine() {
    if [[ "$is_root" == "y" ]]; then
        apk del php-cli php-dom php-simplexml php-zip php-gd php-curl php-sqlite3 php-ssh2 php-posix php-ctype php-fileinfo php-pcntl php-sockets php-openssl php-bz2
    else
        "$priv_cmd" apk del php-cli php-dom php-simplexml php-zip php-gd php-curl php-sqlite3 php-ssh2 php-posix php-ctype php-fileinfo php-pcntl php-sockets php-openssl php-bz2
    fi
}


#----macOS----


remove_homebrew() {
    if command -v brew &>/dev/null; then
        echo "Uninstalling Homebrew"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
    fi
}

remove_php_macOS() {
    if brew list php &>/dev/null; then
        echo "Removing PHP"
        brew remove php
    else
        echo "PHP not found"
    fi


}

remove_stats() {
    if [ -d "/Applications/stats.app" ]; then
        echo "Removing Stats"
        brew remove stats
    else
        echo "Stats not found"
    fi
}

remove_osx_cpu_temp() {
    # Remove existing directory if it exists
    if [ -d "osx-cpu-temp" ]; then
        echo "Removing existing osx-cpu-temp folder"
        rm -rf osx-cpu-temp
        rm -rf /usr/local/bin/osx-cpu-temp
    fi

    go_home
}

#----OS agnostic----
remove_pts(){
    # Remove existing directory if it exists
    if [ -d "phoronix-test-suite" ]; then
        echo "Removing existing phoronix-test-suite folder"
        rm -rf phoronix-test-suite
    fi
}


remove_all() {

    echo "=============================================="
    echo "    Removing the Phoronix Test Suite"
    echo "=============================================="
    remove_pts

    echo "==============================================" 
    echo "    Removing prerequisite software"
    echo "=============================================="
    
    if [[ "$OS_TYPE" == "macOS" ]]; then
        sudo -v
        remove_php_macOS
        remove_stats
        remove_osx_cpu_temp
        remove_homebrew
    elif [[ "$OS_TYPE" == "debian" ]]; then
        remove_git_debian
        remove_php_debian
    elif [[ "$OS_TYPE" == "alpine" ]]; then
        remove_git_alpine
        remove_php_alpine
    else
        echo "CRITICAL ERROR: UNSUPPORTED OS"
        exit 1
    fi
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
    echo "    Welcome to the Phoromatic Removal Script    "
    echo "=============================================="
    message_of_the_day
    sleep 5
}

# Main
go_home
detect_os
detect_arch
welcome_message
remove_all
