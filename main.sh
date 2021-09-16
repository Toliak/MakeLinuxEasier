#! /bin/bash

set -e

INSTALLER_ARCH="sudo pacman --noconfirm -S"
INSTALLER_DEBIAN="sudo apt install -y"

function commandMustExists() {
  COMMAND="$1"
  if ! command -v "$1" &> /dev/null
  then
    printf "Command \"\e[34m%s\e[0m\" \e[31mnot found\e[0m\n" "$COMMAND"
    exit 1
  fi
}

function dataAboutOS() {
  printf "Select your OS:

\e[34m1.  \e[0mDebian 11
\e[34m2.  \e[0mArch (latest)
\e[34m3.  \e[0mOther linux

Windows is \e[31mnot supported\e[0m


"
}

# FEATURES: available answers
function features() {
  ZSH="\e[34m1.  \e[0mInstall Oh My ZSH \e[35m(+powerlevel 10k, +key aliases)\e[0m"
  VIM="\e[34m2.  \e[0mInstall Ultimate Vim\e[0m"
  BASH="\e[34m3.  \e[0mApply bash configs\e[0m"
  ALIASES="\e[34m4.  \e[0mApply command aliases (bash and zsh, if installed)\e[0m"
  PACKAGES_TERM="\e[34m5.  \e[0mInstall zsh, powerline, tmux, vim"
  PACKAGES_UTIL="\e[34m6.  \e[0mInstall git"

  printf "Select features you would like to install:
"
  if [[ "$OS" == "1" ]]; then
    printf "
$ZSH
$VIM
$BASH
$ALIASES
$PACKAGES_TERM
$PACKAGES_UTIL
"
    FEATURES_AVAILABLE="123456"
  elif [[ "$OS" == "2" ]]; then
    printf "
$ZSH
$VIM
$BASH
$ALIASES
$PACKAGES_TERM
$PACKAGES_UTIL
"
    FEATURES_AVAILABLE="123456"
  else
    printf "
$ZSH
$VIM
$BASH
$ALIASES
"
    FEATURES_AVAILABLE="1234"
  fi

  printf "\n"
}

function checkFeatures() {
  FEATURE_TO_CHECK="$1"
  if [[ "$FEATURE_TO_CHECK" == "1" ]]; then
    commandMustExists "git"
    return
  fi
  if [[ "$FEATURE_TO_CHECK" == "2" ]]; then
    commandMustExists "git"
    return
  fi
  if [[ "$FEATURE_TO_CHECK" == "3" ]]; then
    commandMustExists "sed"
    return
  fi
  if [[ "$FEATURE_TO_CHECK" == "4" ]]; then
    commandMustExists "sed"
    return
  fi
  if [[ "$FEATURE_TO_CHECK" == "5" || "$FEATURE_TO_CHECK" == "6" ]]; then
      if [[ "$OS" == "1" ]]; then
        commandMustExists "pacman"
        return
      fi
      if [[ "$OS" == "2" ]]; then
        commandMustExists "apt"
        return
      fi
  fi
}

function installFeature() {
  FEATURE_TO_CHECK="$1"
  if [[ "$FEATURE_TO_CHECK" == "1" ]]; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh  --depth 1 || 1
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc || 1
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k || 1
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh-syntax-highlighting" --depth 1 || 1
    sed 's/ZSH_THEME="[^"]\+"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc
    echo "source $HOME/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "~/.zshrc"

    printf 'Installed syntax highlighting and powerlevel10k. Enter\e[34m\n\nzsh\np10k configure\n\n\e[0mTo configure powerlevel10k\e[0m'

    return
  fi
  if [[ "$FEATURE_TO_CHECK" == "2" ]]; then
    return
  fi
  if [[ "$FEATURE_TO_CHECK" == "3" ]]; then
    return
  fi
  if [[ "$FEATURE_TO_CHECK" == "4" ]]; then
    return
  fi
  if [[ "$FEATURE_TO_CHECK" == "5" ]]; then
      if [[ "$OS" == "1" ]]; then
        $INSTALLER_ARCH zsh powerline tmux vim
      fi
      if [[ "$OS" == "2" ]]; then
        $INSTALLER_DEBIAN zsh powerline fonts-powerline tmux vim
        return
      fi
  fi
  if [[ "$FEATURE_TO_CHECK" == "6" ]]; then
      if [[ "$OS" == "1" ]]; then
        $INSTALLER_ARCH git
        return
      fi
      if [[ "$OS" == "2" ]]; then
        $INSTALLER_DEBIAN git
        return
      fi
  fi
}

function ord() {
  printf %x "'$1"
}

# Read data
# Arguments:
#   Available answers
# RETURN_VALUE: answer
function readData() {
  AVAILABLE_ANSWERS="$1"

  printf "> Select one [\e[33m%s\e[0m]: " "$AVAILABLE_ANSWERS"
  while [ 1 ]; do
    read -n1 ANSWER
    if [[ "$AVAILABLE_ANSWERS" == *"$ANSWER"* && "${#ANSWER}" == "1" ]]; then
      printf "\n> Entered: \e[34m$ANSWER\e[0m\n\n"
      RETURN_VALUE="$ANSWER"
      return
    else
      printf '\b \b'
    fi
  done

  printf "\b\e[34mEntered\e[0m: $ANSWER\n\n"
}

# Read data
# Arguments:
#   Available answers
# RETURN_VALUE: answer
function readMultipleData() {
  AVAILABLE_ANSWERS="$1"

  ANSWER=""
  printf "> Select multiple [\e[33m%s\e[0m]: " "$AVAILABLE_ANSWERS"
  while [ 1 ]; do
    read -n1 ANSWER_CHAR
    if [[ "$AVAILABLE_ANSWERS" == *"$ANSWER_CHAR"* && "${#ANSWER_CHAR}" == "1" && "$ANSWER" != *"$ANSWER_CHAR"* ]]; then
      ANSWER="$ANSWER$ANSWER_CHAR"
    elif [[ "$(ord "$ANSWER_CHAR")" == "0" ]]; then
      break
    elif [[ "$(ord "$ANSWER_CHAR")" == "7f" ]]; then
      if [[ "${#ANSWER}" == "0" ]]; then
        printf '\b\b  \b\b'
      else
        ANSWER="${ANSWER:0:${#ANSWER}-1}"
        printf '\b\b\b   \b\b\b'
      fi
    else
      printf '\b \b'
    fi
  done

  RETURN_VALUE="$ANSWER"
  printf "\b> Entered\e[0m: \e[34m$ANSWER\e[0m\n\n"
}

dataAboutOS
readData "123"
OS="$RETURN_VALUE"

features
readMultipleData "$FEATURES_AVAILABLE"
FEATURES="$RETURN_VALUE"

