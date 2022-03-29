#! /bin/bash

set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
MAKE_LINUX_EASIER_PATH="$SCRIPT_DIR"

if [[ "$MAKE_LINUX_EASIER_PATH" == "" ]]; then
  printf '\e[31mExpected argument\e[0m [\e[34mtarget path\e[0m]\n'
  exit 1
fi

UPDATER_ARCH="pacman --noconfirm -Syy"
INSTALLER_ARCH="pacman --noconfirm -S"
UPDATER_DEBIAN="apt update -y"
INSTALLER_DEBIAN="apt install -y"

if [[ "$UID" != "0" ]]; then
  UPDATER_ARCH="sudo $UPDATER_ARCH"
  INSTALLER_ARCH="sudo $INSTALLER_ARCH"
  UPDATER_DEBIAN="sudo $UPDATER_DEBIAN"
  INSTALLER_DEBIAN="sudo $INSTALLER_DEBIAN"
fi

OH_MY_ZSH_PATH="$HOME/.oh-my-zsh"
VIM_RUNTIME="$HOME/.vim_runtime"
POWERLEVEL_10K_PATH="$OH_MY_ZSH_PATH/custom/themes/powerlevel10k"
ZSH_SYNTAX_HIGHLIGHT_PATH="$OH_MY_ZSH_PATH/custom/zsh-syntax-highlighting"
OH_MY_TMUX_PATH="$HOME/.local/share/oh-my-tmux"

function commandMustExists() {
  COMMAND="$1"
  if ! command -v "$1" &>/dev/null; then
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
  local ZSH="\e[34m1.  \e[0mInstall Oh My ZSH \e[35m(+powerlevel 10k, +key aliases)\e[0m"
  local VIM="\e[34m2.  \e[0mInstall Ultimate Vim\e[0m"
  local BASH_CONFIGS="\e[34m3.  \e[0mApply bash configs\e[0m"
  local ZSH_CONFIGS="\e[34m4.  \e[0mApply zsh configs\e[0m"
  local TMUX="\e[34m5.  \e[0mInstall Oh My TMUX (\e[31mCurrent TMUX config will be removed\e[0m)\e[0m"
  local PACKAGES_TERM="\e[34m6.  \e[0mInstall zsh, powerline, tmux, vim"
  local PACKAGES_UTIL="\e[34m7.  \e[0mInstall git"
  local UNIFIED_SHORTCUTS="\e[34m8.  \e[0mInstall Unified Shortcuts"


  printf "Select features you would like to install:
"
  if [[ "$OS" == "1" ]]; then
    printf "
$ZSH
$VIM
$BASH_CONFIGS
$ZSH_CONFIGS
$TMUX
$PACKAGES_TERM
$PACKAGES_UTIL
$UNIFIED_SHORTCUTS
"
    FEATURES_AVAILABLE="1234567"
  elif [[ "$OS" == "2" ]]; then
    printf "
$ZSH
$VIM
$BASH_CONFIGS
$ZSH_CONFIGS
$TMUX
$PACKAGES_TERM
$PACKAGES_UTIL
$UNIFIED_SHORTCUTS
"
    FEATURES_AVAILABLE="1234567"
  else
    printf "
$ZSH
$VIM
$BASH_CONFIGS
$ZSH_CONFIGS
$TMUX
$UNIFIED_SHORTCUTS
"
    FEATURES_AVAILABLE="12345"
  fi

  printf "\n"
}

function checkFeature() {
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
  if [[ "$FEATURE_TO_CHECK" == "5" ]]; then
    commandMustExists "git"
    commandMustExists "sed"
    return
  fi
  if [[ "$FEATURE_TO_CHECK" == "6" || "$FEATURE_TO_CHECK" == "7" ]]; then
    if [[ "$OS" == "1" ]]; then
      commandMustExists "apt"
      return
    fi
    if [[ "$OS" == "2" ]]; then
      commandMustExists "pacman"
      return
    fi
  fi
  if [[ "$FEATURE_TO_CHECK" == "8" ]]; then
    commandMustExists "git"
    return
  fi
}

function installFeature() {
  FEATURE_TO_CHECK="$1"

# Oh My ZSH install
  if [[ "$FEATURE_TO_CHECK" == "1" ]]; then
    if [ -e "$OH_MY_ZSH_PATH" ]; then
      printf '\e[34mOh my ZSH\e[0m is \e[32malready installed\e[0m\n'
    else
      git clone https://github.com/robbyrussell/oh-my-zsh.git "$OH_MY_ZSH_PATH" --depth 1
      cp "$OH_MY_ZSH_PATH/templates/zshrc.zsh-template" ~/.zshrc
      printf '\e[34mOh my ZSH\e[0m is \e[32minstalled\e[0m\n'
    fi

    if [ -e "$POWERLEVEL_10K_PATH" ]; then
      printf '\e[34mPowerLevel 10k\e[0m is \e[32malready installed\e[0m\n'
    else
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$POWERLEVEL_10K_PATH" || 1
      sed -i 's/ZSH_THEME="[^"]\+"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc
      printf '\e[34mPowerLevel 10k\e[0m is \e[32minstalled\e[0m\n'
    fi

    if [ -e "$ZSH_SYNTAX_HIGHLIGHT_PATH" ]; then
      printf '\e[34mZSH Syntax Highlighting\e[0m is \e[32malready installed\e[0m\n'
    else
      git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_HIGHLIGHT_PATH" --depth 1 || 1
      echo "source $ZSH_SYNTAX_HIGHLIGHT_PATH/zsh-syntax-highlighting.zsh" >>~/.zshrc
      printf '\e[34mZSH Syntax Highlighting\e[0m is \e[32minstalled\e[0m\n'
    fi

    return
  fi

# Ultimate VIM install
  if [[ "$FEATURE_TO_CHECK" == "2" ]]; then
    if [ -e "$VIM_RUNTIME" ]; then
      printf '\e[34mUltimate VIM\e[0m is \e[32malready installed\e[0m\n'
      return
    fi

    git clone --depth=1 https://github.com/amix/vimrc.git "$VIM_RUNTIME"
    sh "$VIM_RUNTIME/install_awesome_vimrc.sh"

    printf '\e[34mUltimate VIM\e[0m is \e[32minstalled\e[0m\n'
    return
  fi

# BASHRC Configs
  if [[ "$FEATURE_TO_CHECK" == "3" ]]; then
    if grep -Fxq "source $MAKE_LINUX_EASIER_PATH/bash_config" ~/.bashrc; then
      printf '\e[34mBASHRC configs\e[0m is \e[32malready installed\e[0m\n'
    else
      echo "source $MAKE_LINUX_EASIER_PATH/bash_config" >>~/.bashrc
      echo "source $MAKE_LINUX_EASIER_PATH/alias_config" >>~/.bashrc
      if [[ "$OS" == "1" ]]; then
        echo "source $MAKE_LINUX_EASIER_PATH/alias_config_debian" >>~/.bashrc
      elif [[ "$OS" == "2" ]]; then
        echo "source $MAKE_LINUX_EASIER_PATH/alias_config_arch" >>~/.bashrc
      fi
      printf '\e[34mBASHRC configs\e[0m is \e[32minstalled\e[0m\n'
    fi

    return
  fi

# ZSH configs
  if [[ "$FEATURE_TO_CHECK" == "4" ]]; then
    if [ -e "$HOME/.zshrc" ]; then
      if grep -Fxq "source $MAKE_LINUX_EASIER_PATH/zsh_config" ~/.zshrc; then
        printf '\e[34mZSH bind and aliases\e[0m is \e[32malready installed\e[0m\n'
      else
        echo "source $MAKE_LINUX_EASIER_PATH/zsh_config" >>~/.zshrc
        echo "source $MAKE_LINUX_EASIER_PATH/alias_config" >>~/.zshrc
        if [[ "$OS" == "1" ]]; then
          echo "source $MAKE_LINUX_EASIER_PATH/alias_config_debian" >>~/.zshrc
        elif [[ "$OS" == "2" ]]; then
          echo "source $MAKE_LINUX_EASIER_PATH/alias_config_arch" >>~/.zshrc
        fi
        printf '\e[34mZSH bind and aliases\e[0m is \e[32minstalled\e[0m\n'
      fi
    else
      printf '\e[34mZSH bind and aliases\e[0m \e[31mnot found\e[0m\n'
    fi

    return
  fi

# Oh My Tmux
  if [[ "$FEATURE_TO_CHECK" == "5" ]]; then
    if [ -e "$OH_MY_TMUX_PATH" ]; then
        printf '\e[34mOh My TMUX\e[0m is \e[32malready installed\e[0m\n'
    else
        git clone https://github.com/gpakosz/.tmux.git $OH_MY_TMUX_PATH
        rm -f $HOME/.tmux.conf "$HOME/.tmux.conf.local"
        ln -s -f "$OH_MY_TMUX_PATH/.tmux.conf" "$HOME/.tmux.conf"
        cp "$OH_MY_TMUX_PATH/.tmux.conf.local" "$HOME/.tmux.conf.local"

        printf '\e[34mOh My TMUX\e[0m is \e[32minstalled\e[0m\n'
    fi

    if grep -Fxq "source -q $MAKE_LINUX_EASIER_PATH/tmux.conf" ~/.tmux.conf.local; then
        printf '\e[34mAdditional TMUX configs\e[0m is \e[32malready installed\e[0m\n'
    else
      echo "source -q $MAKE_LINUX_EASIER_PATH/tmux.conf" >>~/.tmux.conf.local
      printf '\e[34mAdditional TMUX configs\e[0m is \e[32minstalled\e[0m\n'
    fi

    sed -i 's/#set \-g @plugin '"'"'tmux\-plugins\/tmux-cpu'"'"'/set -g @plugin '"'"'tmux-plugins\/tmux-cpu'"'"'/g' ~/.tmux.conf.local
    printf '\e[34mtmux-plugins/tmux-cpu\e[0m enabled\n'

    sed -i 's/#set \-g @plugin '"'"'tmux\-plugins\/tmux-resurrect'"'"'/set -g @plugin '"'"'tmux-plugins\/tmux-resurrect'"'"'/g' ~/.tmux.conf.local
    printf '\e[34mtmux-plugins/tmux-resurrect\e[0m enabled\n'

    return
  fi

# ZSH, powerline, tmux
  if [[ "$FEATURE_TO_CHECK" == "6" ]]; then
    if [[ "$OS" == "1" ]]; then
      $UPDATER_DEBIAN
      $INSTALLER_DEBIAN zsh powerline fonts-powerline tmux vim
    elif [[ "$OS" == "2" ]]; then
      $UPDATER_ARCH
      $INSTALLER_ARCH zsh powerline tmux vim
    fi

    printf '\e[34mzsh, powerline, tmux, vim\e[0m is \e[32minstalled\e[0m\n'
  fi

# git
  if [[ "$FEATURE_TO_CHECK" == "7" ]]; then
    if [[ "$OS" == "1" ]]; then
      $UPDATER_DEBIAN
      $INSTALLER_DEBIAN git
    elif [[ "$OS" == "2" ]]; then
      $UPDATER_ARCH
      $INSTALLER_ARCH git
    fi 
    printf '\e[34mgit\e[0m is \e[32minstalled\e[0m\n'
    return
  fi

# unified shortcuts
  if [[ "$FEATURE_TO_CHECK" == "8" ]]; then
    printf '\e[34mUnified shortcuts\e[0m is \e[32mcomming soon\e[0m\n'
    return
  fi

}

function installAllFeatures() {
  if [[ "$FEATURES" == *"7"* ]]; then
    checkFeature 7
    installFeature 7
  fi
  if [[ "$FEATURES" == *"6"* ]]; then
    checkFeature 6
    installFeature 6
  fi
  if [[ "$FEATURES" == *"3"* ]]; then
    checkFeature 3
    installFeature 3
  fi
  if [[ "$FEATURES" == *"1"* ]]; then
    checkFeature 1
    installFeature 1
  fi
  if [[ "$FEATURES" == *"5"* ]]; then
    checkFeature 5
    installFeature 5
  fi
  if [[ "$FEATURES" == *"4"* ]]; then
    checkFeature 4
    installFeature 4
  fi
  if [[ "$FEATURES" == *"2"* ]]; then
    checkFeature 2
    installFeature 2
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

#read -n1 char
#ord "$char"

dataAboutOS
readData "123"
OS="$RETURN_VALUE"

features
readMultipleData "$FEATURES_AVAILABLE"
FEATURES="$RETURN_VALUE"

installAllFeatures

printf 'All features has been \e[32minstalled\e[0m\n'
