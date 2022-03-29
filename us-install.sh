#! /bin/bash

set -e

VSCODE_CONFIG_DIR="$1"
JETBRAINS_CONFIG_DIR="$2"



function mustAccept() {
    printf "> Continue? [\e[33my/n\e[0m]: "

    read -n1 ANSWER
    if [[ "$ANSWER" == "y" ]]; then
        echo
        return
    fi 
    printf "\b\e[31mStopped\e[0m\n\n"
    exit 1
}

function installJetBrainsConfig() {
    if [ -z "$JETBRAINS_CONFIG_DIR" ]; then
        printf "No JetBrains path provided \t \e[31mSkipped\e[0m\n\n"
        return
    fi

    echo $JETBRAINS_CONFIG_DIR/*.*/
    mustAccept

    for DIR in $JETBRAINS_CONFIG_DIR/*.*/; do 
        echo "$DIR"
        mkdir -p "$DIR/"{keymaps,options}
        cp -r "$TEMP_DIR/idea/"* "$DIR"
    done
    printf 'JetBrains shortucts \e[32minstalled\e[0m\n'

}

function installVSCodeConfig() {
    printf "\b\e[34mProvided path\e[0m: %s\n\n" "$VSCODE_CONFIG_DIR"
    if [ -z "$VSCODE_CONFIG_DIR" ]; then
        printf "No VS Code path provided \t \e[31mSkipped\e[0m\n\n"
        return
    fi
    if [ ! -d "$VSCODE_CONFIG_DIR/User" ]; then
        printf "\e[31mUnable to find path\e[0m\n\n"
        return
    fi 
    mustAccept
    
    cp "$TEMP_DIR/vscode/keybindings.json" "$VSCODE_CONFIG_DIR/User"
    printf 'VSCode shortucts \e[32minstalled\e[0m\n'
}

TEMP_DIR=$(mktemp -d)
git clone https://github.com/Toliak/UnifiedShortcuts --depth 1 $TEMP_DIR 

installVSCodeConfig
installJetBrainsConfig