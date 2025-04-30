#!/bin/sh

#######################################################
# PTS-Auto-Setup - setup script for Phoronix-Test-suite
# https://github.com/nkerschner/PTS-auto-setup/setup.sh
# v2.3 (modern POSIX compliant)
#######################################################

DEFAULT_PHOROMATIC_URL=phoromatic:8433/Q1CST9

go_home() {
    cd "$HOME"
}

get_phoromatic_url() {
    echo "Please enter your Phoromatic URL: "
    read PHOROMATIC_URL
}

get_priv_cmd() {
    if [ "$(whoami)" = "root" ]; then
        is_root="y"
        echo "running as root"
    elif command -v doas >/dev/null 2>&1; then
        priv_cmd="doas"
        echo "using 'doas'"
    elif command -v sudo >/dev/null 2>&1; then
        priv_cmd="sudo"
        echo "using 'sudo'"
    else
        echo "Neither sudo or doas found, cannot continue"
        exit 1
    fi
}

detect_os() {
    if echo "$OSTYPE" | grep -q "darwin"; then
        OS_TYPE="macOS"
    elif apt -v >/dev/null 2>&1; then
        OS_TYPE="debian"
        get_priv_cmd
    elif apk version >/dev/null 2>&1; then
        OS_TYPE="alpine"
        get_priv_cmd
    elif command -v dnf >/dev/null 2>&1; then
        OS_TYPE="rhel"
        get_priv_cmd
    else
        echo "CRITICAL ERROR: UNSUPPORTED OS"
        exit 1
    fi

    echo "OS Detected: $OS_TYPE"
}

detect_arch() {
    if [ "$(uname -m)" = "arm64" ]; then
        ARCH="arm64"
    else
        ARCH="x86_64"
    fi
}

#----debian----
update_debian() {
    if [ "$is_root" = "y" ]; then
        apt update
        apt upgrade -y
    else
        "$priv_cmd" apt update
        "$priv_cmd" apt upgrade -y
    fi
}

install_git_debian() {
    if [ "$is_root" = "y" ]; then
        apt install -y git
    else
        "$priv_cmd" apt install -y git
    fi
}

install_php_debian() {
    if [ "$is_root" = "y" ]; then
        apt install -y php-cli php-xml php-zip php-gd php-curl php-fpdf php-sqlite3 php-ssh2
    else
        "$priv_cmd" apt install -y php-cli php-xml php-zip php-gd php-curl php-fpdf php-sqlite3 php-ssh2
    fi
}

#----alpine----
update_alpine() {
    if [ "$is_root" = "y" ]; then
        apk update
        apk upgrade
    else
        "$priv_cmd" apk update 
        "$priv_cmd" apk upgrade
    fi
}

install_git_alpine() {
    if [ "$is_root" = "y" ]; then
        apk add git
    else
        "$priv_cmd" apk add git
    fi
}

install_php_alpine() {
    if [ "$is_root" = "y" ]; then
        apk add php81-cli php81-dom php81-simplexml php81-zip php81-gd php81-curl php81-sqlite3 php81-pecl-ssh2 php81-posix php81-ctype php81-fileinfo php81-pcntl php81-sockets php81-openssl php81-bz2
    else
        "$priv_cmd" apk add php81-cli php81-dom php81-simplexml php81-zip php81-gd php81-curl php81-sqlite3 php81-pecl-ssh2 php81-posix php81-ctype php81-fileinfo php81-pcntl php81-sockets php81-openssl php81-bz2
    fi
}

#----rhel----
update_rhel() {
    if [ "$is_root" = "y" ]; then
        dnf update -y
    else
        "$priv_cmd" dnf update -y
    fi
}

install_git_rhel() {
    if [ "$is_root" = "y" ]; then
        dnf install -y git
    else
        "$priv_cmd" dnf install -y git
    fi
}

install_php_rhel() {
    if [ "$is_root" = "y" ]; then
        dnf install -y php-cli php-xml php-json php-zip php-gd php-sqlite3 php-posix
    else
        "$priv_cmd" dnf install -y php-cli php-xml php-json php-zip php-gd php-sqlite3 php-posix
    fi
}

#----macOS----
install_xcode_tools() {
    if command -v git >/dev/null 2>&1; then
        echo "git installed, moving on"
    else
        echo "Git not found, installing now"
        echo "Installation prompt should pop up"
        xcode-select --install
        read xcode_complete
        echo "Continuing after xcode tools installation"
    fi
}

install_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        echo "homebrew installed, updating instead"
        brew update
    else
        echo "Installing Homebrew"     
        NONINTERACTIVE=1 /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/nkerschner/hb-install/HEAD/install.sh)"
        echo >> "${HOME}/.zprofile"
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "${HOME}/.zprofile"
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

install_php_macOS() {
    if brew list php >/dev/null 2>&1; then
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

    sleep 5
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
    echo "=============================================" 
    echo "    Installing prerequisite software"
    echo "=============================================="
    
    if [ "$OS_TYPE" = "macOS" ]; then
        sudo -v
        install_xcode_tools
        install_homebrew
        install_php_macOS
        install_stats
        install_osx_cpu_temp
    elif [ "$OS_TYPE" = "debian" ]; then
        update_debian
        install_git_debian
        install_php_debian
    elif [ "$OS_TYPE" = "alpine" ]; then
        update_alpine
        install_git_alpine
        install_php_alpine
    elif [ "$OS_TYPE" = "rhel" ]; then
        update_rhel
        install_git_rhel
        install_php_rhel
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
    printf "Press enter to use the default Phoromatic URL (%s), or press 'n' to input a new Phoromatic URL: " "$DEFAULT_PHOROMATIC_URL"
    read userChoice

    if [ "$userChoice" = "n" ]; then
        get_phoromatic_url
    else
        PHOROMATIC_URL="$DEFAULT_PHOROMATIC_URL"
    fi

    echo "=============================================="
    printf "    Connecting to %s           \n" "$PHOROMATIC_URL"
    echo "=============================================="
    ./phoronix-test-suite phoromatic.connect "$PHOROMATIC_URL"
}

# message of the day function - Ash compatible version
message_of_the_day() {
    # Using a sequence of if/elif statements as ash doesn't support arrays
    r=$(($(date +%s) % 40))
    
    if [ $r -eq 0 ]; then
        echo "*insert motd here*"
    elif [ $r -eq 1 ]; then
        echo "It's not a bug, it's an undocumented feature."
    elif [ $r -eq 2 ]; then
        echo "The 'cloud' is just someone else's computer."
    elif [ $r -eq 3 ]; then
        echo "I can explain it to you, but I can't understand it for you."
    elif [ $r -eq 4 ]; then
        echo "Artificial intelligence is no match for natural stupidity."
    elif [ $r -eq 5 ]; then
        echo "When in doubt, add another if statement."
    elif [ $r -eq 6 ]; then
        echo "Terminal: Where MacOS users pretend they're Linux users."
    elif [ $r -eq 7 ]; then
        echo "Macs don't get viruses, they get 'unexpected behaviors.'"
    elif [ $r -eq 8 ]; then
        echo "MacOS: Because sometimes you just want things to 'just work'... eventually."
    elif [ $r -eq 9 ]; then
        echo "Your refurbished laptop has seen things. Be kind to it."
    elif [ $r -eq 10 ]; then
        echo "Refurbished laptop: like adopting a pet—it may have a mysterious past, but it still has plenty of love to give."
    elif [ $r -eq 11 ]; then
        echo "Linux is free only if your time has no value."
    elif [ $r -eq 12 ]; then
        echo "Linux: making the impossible possible and the simple difficult."
    elif [ $r -eq 13 ]; then
        echo "Your CPU is not supposed to function as a space heater."
    elif [ $r -eq 14 ]; then
        echo "The three leading causes of computer failure: dust, dust, and user error."
    elif [ $r -eq 15 ]; then
        echo "Is your computer running slow? It's probably carrying the weight of all that dust."
    elif [ $r -eq 16 ]; then
        echo "Touch Bar: Apple's way of asking 'How would you like your function keys to be less functional?'"
    elif [ $r -eq 17 ]; then
        echo "Apple's idea of repair: 'Have you tried buying a new one?'"
    elif [ $r -eq 18 ]; then
        echo "Buying refurbished: Saving the planet, one rejected laptop at a time."
    elif [ $r -eq 19 ]; then
        echo "Bash scripting is like cooking with random ingredients from your fridge—occasionally brilliant, often terrifying."
    elif [ $r -eq 20 ]; then
        echo "There's a fine line between a working bash script and complete chaos. That line is usually a semicolon."
    elif [ $r -eq 21 ]; then
        echo "I don't always test my code, but when I do, I do it in production."
    elif [ $r -eq 22 ]; then
        echo "Turning it off and on again: The IT equivalent of 'Put some ice on it.'"
    elif [ $r -eq 23 ]; then
        echo "Keyboard not found. Press F1 to continue."
    elif [ $r -eq 24 ]; then
        echo "There are two hard problems in computer science: cache invalidation, naming things, and off-by-one errors."
    elif [ $r -eq 25 ]; then
        echo "Cloud computing: Never having to worry where your data is, because it's definitely somewhere."
    elif [ $r -eq 26 ]; then
        echo "The problem with troubleshooting is that trouble shoots back."
    elif [ $r -eq 27 ]; then
        echo "We use version control so we know exactly who to blame."
    elif [ $r -eq 28 ]; then
        echo "My laptop's not overheating, it's trying to achieve nuclear fusion with dust particles."
    elif [ $r -eq 29 ]; then
        echo "Every Linux distro is the same. Just different enough to break all your scripts."
    elif [ $r -eq 30 ]; then
        echo "In Windows, viruses do horrible things to your computer. In Linux, your computer does horrible things to you."
    elif [ $r -eq 31 ]; then
        echo "MacOS is Unix with a fashion degree and a trust fund."
    elif [ $r -eq 32 ]; then
        echo "MacBook Pro: It's not throttling, it's 'thermal mindfulness.'"
    elif [ $r -eq 33 ]; then
        echo "We don't do it because it's easy; we do it because we thought it would be easy"
    elif [ $r -eq 34 ]; then
        echo "Never spend 5 hours on a task that you could spend 5 days failing to automate."
    elif [ $r -eq 35 ]; then
        echo "There is nothing more permanent than a temporary solution"
    elif [ $r -eq 36 ]; then
        echo "Everybody has a test environment; some of us are lucky and have a separate production environment, too."
    elif [ $r -eq 37 ]; then
        echo "To make an error is human. To spread the error across all servers in an automated way is DevOps."
    elif [ $r -eq 38 ]; then
        echo "This is JJ. I'm trapped in this computer. Please help."
    elif [ $r -eq 39 ]; then
        echo "Please suggest more messages"
    fi
}

welcome_message() {
    echo "=============================================="
    echo "    Welcome to the Phoromatic Setup Script    "
    echo "=============================================="
    message_of_the_day
    sleep 3
}

# Main
welcome_message
go_home
detect_os
detect_arch
install_all
connect_phoromatic
