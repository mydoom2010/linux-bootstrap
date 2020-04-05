#!/usr/bin/env bash
# ---------------------------------------------
# Artifact:     bootstrap/bootstrap
# Version:      1.0.2
# Date (UTC):   Sun, 05 Apr 2020 12:30:04 +0000
# Generated by: bashing 0.2.2
# ---------------------------------------------
export __BASHING_VERSION='0.2.2'
export __VERSION='1.0.2'
export __ARTIFACT_ID='bootstrap'
export __GROUP_ID='bootstrap'
function install_base_packages() {
    if [ "$(which augtool)" == "" ]; then
        sudo apt update
        sudo apt install -y apt-transport-https curl autojump bash-completion build-essential ca-certificates cifs-utils comprez \
        direnv dselect gawk gdebi git jq mc mysql-client net-tools p7zip-full sshfs tmux tmux-plugin-manager vim-nox virtualenv \
        vpnc-scripts yadm aptitude fonts-powerline libffi-dev augeas-tools
    fi
    set +e
    python --version 2>&1 | grep -q 'Python 2'
    if [ "$?" == "0" ]; then 
        set -e
        sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 20
        sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10
        sudo update-alternatives --set python /usr/bin/python3
    fi
    set -e
    if [ "$(which pip)" == "" ]; then 
        sudo apt install -y python3-pip
    fi
}
ask() {
    local prompt default reply
    if [ "${2:-}" = "Y" ]; then
        prompt="Y/n"
        default=Y
    elif [ "${2:-}" = "N" ]; then
        prompt="y/N"
        default=N
    else
        prompt="y/n"
        default=
    fi
    while true; do
        echo -n "$1 [$prompt] "
        read reply </dev/tty
        if [ -z "$reply" ]; then
            reply=$default
        fi
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
    done
}
function install_deb_from_url {
    FILE="$2"
    URL="$1/$FILE"
    wget $URL -O $FILE
    sudo gdebi $FILE
    rm $FILE
}
function get_download_url {
    wget -q -nv -O- https://api.github.com/repos/$1/releases/latest 2>/dev/null |	jq -r '.assets[] | select(.browser_download_url | contains("linux-amd64")) | .browser_download_url'
}
function setup {
    [ "$RUNFILE" != "" ] && return 
    install_base_packages
    echo " "
    export RUNFILE="$HOME/_todo.sh"
    echo "#!/usr/bin/env bash" >$RUNFILE
    echo "set -x" >>$RUNFILE
    echo "set -e" >>$RUNFILE
    echo 'echo "Staring bootstrap"' >>$RUNFILE
}
function run_todo {
    LINES=$(cat $RUNFILE | wc -l)
    if [ $LINES -gt 4 ]; then 
        cat $RUNFILE
        echo " "
        if ask "Run these commands?" Y; then 
            bash $RUNFILE 
        fi
    else
        echo "All things good..."
    fi
}
function cli_all() {
  export ALL=1
  setup
  echo " "
  echo " "
  if [ -n "$DISPLAY" ]; then
    $0 default_gui_packages
    $0 vscode
    $0 opera
    $0 spotify
    $0 terraform
    $0 peek
    $0 google-chrome
    $0 touchpad_indicator
    $0 copyq
    $0 wavebox
    $0 y_ppa_manager
  fi
  $0 dotfiles
  $0 bash_it
  $0 nodenv
  $0 goenv
  $0 pyenv
  $0 xonsh
  $0 docker
  $0 awscli
  $0 etckeeper
  $0 fix_max_user_watches
  $0 fix_sudo
  run_todo
  return 0;
}
function cli_awscli() {
  setup
  is_awscli_installed() {
      [ "$(which aws)" != "" ]
  }
  install_awscli() {
      echo "Installing awscli now"
      sudo apt install -y awscli s3cmd 
  }
  ask_install_awscli() {
      is_awscli_installed && return
      if ask "Install awscli?"; then 
          type install_awscli | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_awscli
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_bash_it() {
  setup
  is_bash_it_installed() {
      [ -d ~/.bash_it/ ]
  }
  install_bash_it() {
      echo "Installing bash_it now"
      cd "$HOME"
      if [ ! -d ~/.bash_it ]; then
          git clone --depth 1 https://github.com/Bash-it/bash-it.git .bash_it
      fi
      set +e
      if [ -d ~/.dotfiles/bash_it ]; then 
          set -e
          echo "Installing dotfiles too.  Won't modify .bashrc"
          bash ~/.bash_it/install.sh --no-modify-config
          set +e
          grep -q 'dotfiles/bash_it' ~/.bashrc || echo "source ~/.dotfiles/bash_it/bash-it.sh" >> ~/.bashrc
          set +x
          source ~/.dotfiles/bash_it/bash-it.sh
          set -x
          set -e
      else
          set -e
          bash ~/.bash_it/install.sh 
          grep -E '^export|^source' ~/.bashrc > /tmp/setup.sh
          source /tmp/setup.sh 
      fi
      set +x
      bash-it enable alias docker
      bash-it enable alias docker-compose
      bash-it enable alias general
      bash-it enable alias npm
      bash-it enable plugin autojump
      bash-it enable plugin aws
      bash-it enable plugin base
      bash-it enable plugin direnv
      bash-it enable plugin docker
      bash-it enable plugin docker-compose
      bash-it enable plugin git
      bash-it enable plugin history
      bash-it enable plugin ssh
      bash-it enable plugin tmux
      bash-it enable completion awscli
      bash-it enable completion bash-it
      bash-it enable completion docker
      bash-it enable completion docker-compose
      bash-it enable completion git
      bash-it enable completion git_flow
      bash-it enable completion npm
      bash-it enable completion pip
      bash-it enable completion pip3
      bash-it enable completion ssh
      bash-it enable completion system
      bash-it enable completion tmux
      bash-it enable completion vuejs
      set -x    
  }
  ask_install_bash_it() {
      is_bash_it_installed && return
      if ask "Install bash_it?"; then 
          type install_bash_it | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_bash_it
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_copyq() {
  setup
  is_copyq_installed() {
      [ "$(which copyq)" != "" ]
  }
  install_copyq() {
      echo "Installing copyq now"
      sudo add-apt-repository -y  ppa:hluk/copyq
      sudo apt install -y copyq
  }
  ask_install_copyq() {
      is_copyq_installed && return
      if ask "Install copyq?"; then 
          type install_copyq | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_copyq
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_default_gui_packages() {
  is_default_gui_packages_installed() {
      [ "$(which kupfer)" != "" ] 
  }
  install_default_gui_packages() {
      echo "Installing default_gui_packages now"
      sudo apt install -y gtk2-engines-murrine gtk2-engines-pixbuf fonts-roboto ninja-build meson sassc glogg meld synaptic menulibre kupfer remmina vim-gtk3 fonts-firacode
  }
  ask_install_default_gui_packages() {
      is_default_gui_packages_installed && return
      if ask "Install default GUI packages?"; then 
          type install_default_gui_packages | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_default_gui_packages
  return 0;
}
function cli_docker() {
  setup
  is_docker_installed() {
      [ "$(which docker)" != "" ]
  }
  install_docker() {
      echo "Installing docker now"
      sudo snap install docker
      sudo addgroup --system docker
      sudo usermod -aG docker $USER
  }
  ask_install_docker() {
      is_docker_installed && return
      if ask "Install docker?"; then 
          type install_docker | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_docker
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_dotfiles() {
  setup
  is_dotfiles_installed() {
      [ -d ~/.dotfiles/ ]
  }
  install_dotfiles() {
      echo "Installing dotfiles now"
      cd "$HOME"
      if [ ! -d .dotfiles ]; then
          git clone --recursive https://github.com/drmikecrowe/dotphiles.git ~/.dotfiles
      fi
      set +e
      grep -q $HOSTNAME .dotfiles/dotsyncrc
      if [ "$?" == "1" ]; then
          sed -i "/\[hosts\]/ a $HOSTNAME" .dotfiles/dotsyncrc
      fi
      set -e
      ./.dotfiles/dotsync/bin/dotsync -L
      if [ -d $HOME/.bash_it ]; then 
          set +e
          grep -q 'dotfiles/bash_it' ~/.bashrc && echo "source ~/.dotfiles/bash_it/bash-it.sh" >> ~/.bashrc
          set -e
      fi 
  }
  ask_install_dotfiles() {
      is_dotfiles_installed && return
      if ask "Install dotfiles?"; then 
          type install_dotfiles | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_dotfiles
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_etckeeper() {
  setup
  is_etckeeper_installed() {
      [ -d /etc/etckeeper ]
  }
  install_etckeeper() {
      echo "Installing etckeeper now"
      sudo apt install -y etckeeper
      sudo sed -i 's/^VCS=/#VCS/' /etc/etckeeper/etckeeper.conf
      sudo sed -i 's/^#?VCS=.*git.*/VCS="git"/' /etc/etckeeper/etckeeper.conf
      cd /etc
      set +e
      sudo etckeeper init
      set -e
      sudo etckeeper commit "Initial checkin"
  }
  ask_install_etckeeper() {
      is_etckeeper_installed && return
      if ask "Install etckeeper?"; then 
          type install_etckeeper | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_etckeeper
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_fix_max_user_watches() {
  setup
  is_fix_max_user_watches_installed() {
      [ "$(sudo augtool match /files/etc/sysctl.conf/fs.inotify.max_user_watches)" != "" ]
  }
  install_fix_max_user_watches() {
      echo "Setting sysctl.conf fs.inotify.max_user_watches=524288\n"
      cat <<EOF >/tmp/sysctl.aug
  set /files/etc/sysctl.conf/fs.inotify.max_user_watches 524288
  save
EOF
      sudo augtool -f /tmp/sysctl.aug
      sudo sysctl -p
  }
  ask_install_fix_max_user_watches() {
      is_fix_max_user_watches_installed && return
      if ask "Fix max_user_watches by increasing to 524288?"; then 
          type install_fix_max_user_watches | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_fix_max_user_watches
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_fix_sudo() {
  setup
  is_fix_sudo_installed() {
      [ "$(sudo augtool match /files/etc/sudoers/*/user $USER)" != "" ]
  }
  install_fix_sudo() {
      echo "Adding $USER to sudoers with no password\n"
      sudo usermod -aG sudo $USER
      cat <<EOF >/tmp/sudoers.aug
  set /files/etc/sudoers/spec[last()]/user "$USER"
  set /files/etc/sudoers/spec[last()]/host_group/host "ALL"
  set /files/etc/sudoers/spec[last()]/host_group/command "ALL"
  set /files/etc/sudoers/spec[last()]/host_group/command/runas_user "ALL"
  set /files/etc/sudoers/spec[last()]/host_group/command/tag "NOPASSWD"
  save
EOF
      sudo augtool -f /tmp/sudoers.aug
  }
  ask_install_fix_sudo() {
      is_fix_sudo_installed && return
      if ask "Fix sudo so user so password isn't required?"; then 
          type install_fix_sudo | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_fix_sudo
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_goenv() {
  setup
  is_goenv_installed() {
      [ -d ~/.goenv ]
  }
  install_goenv() {
      echo "Installing goenv now"
      cd ~
      wget -q https://github.com/drmikecrowe/goenv-installer/raw/master/bin/goenv-installer -O- | bash
  }
  ask_install_goenv() {
      is_goenv_installed && return
      if ask "Install goenv?"; then 
          type install_goenv | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_goenv
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_google-chrome() {
  setup
  is_google-chrome_installed() {
      [ "$(which google-chrome-beta)" != "" ]
  }
  install_google-chrome() {
      echo "Installing google-chrome now"
      wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
      sudo rm -f /etc/apt/sources.list.d/google-chrome*
      echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
      sudo apt update
      sudo apt install -y google-chrome-beta chrome-gnome-shell
  }
  ask_install_google-chrome() {
      is_google-chrome_installed && return
      if ask "Install google-chrome?"; then 
          type install_google-chrome | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_google-chrome
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_nodenv() {
  setup
  is_nodenv_installed() {
      [ -d ~/.nodenv ]
  }
  install_nodenv() {
      echo "Installing nodenv now"
      cd ~
      wget -q https://raw.githubusercontent.com/nodenv/nodenv-installer/master/bin/nodenv-installer -O- | bash
  }
  ask_install_nodenv() {
      is_nodenv_installed && return
      if ask "Install nodenv?"; then 
          type install_nodenv | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_nodenv
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_opera() {
  setup
  is_opera_installed() {
      [ "$(which opera)" != "" ]
  }
  install_opera() {
      echo "Installing opera now"
      sudo snap install opera
  }
  ask_install_opera() {
      is_opera_installed && return
      if ask "Install opera?"; then 
          type install_opera | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_opera
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_peek() {
  setup
  is_peek_installed() {
      [ "$(which peek)" != "" ]
  }
  install_peek() {
      echo "Installing peek now"
      sudo add-apt-repository -y ppa:peek-developers/stable
      sudo apt install -y peek
  }
  ask_install_peek() {
      is_peek_installed && return
      if ask "Install peek?"; then 
          type install_peek | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_peek
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_pyenv() {
  setup
  is_pyenv_installed() {
      [ -d $HOME/.pyenv ]
  }
  install_pyenv() {
      echo "Installing pyenv now"
      cd ~
      wget -O- https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
  }
  ask_install_pyenv() {
      is_pyenv_installed && return
      if ask "Install pyenv?"; then 
          type install_pyenv | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_pyenv
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_spotify() {
  setup
  is_spotify_installed() {
      [ "$(which spotify)" != "" ]
  }
  install_spotify() {
      echo "Installing spotify now"
      sudo snap install spotify
  }
  ask_install_spotify() {
      is_spotify_installed && return
      if ask "Install spotify?"; then 
          type install_spotify | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_spotify
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_terraform() {
  setup
  is_terraform_installed() {
      [ "$(which terraform)" != "" ]
  }
  install_terraform() {
      echo "Installing terraform now"
      sudo snap install terraform
  }
  ask_install_terraform() {
      is_terraform_installed && return
      if ask "Install terraform?"; then 
          type install_terraform | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_terraform
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_touchpad_indicator() {
  setup
  is_touchpad_indicator_installed() {
      [ "$(which touchpad_indicator)" != "" ]
  }
  install_touchpad_indicator() {
      echo "Installing touchpad-indicator now"
      sudo add-apt-repository -y  ppa:atareao/atareao
      sudo apt install -y touchpad-indicator
  }
  ask_install_touchpad_indicator() {
      is_touchpad_indicator_installed && return
      if ask "Install touchpad-indicator?"; then 
          type install_touchpad_indicator | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_touchpad_indicator
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_vscode() {
  setup
  is_vscode_installed() {
      [ "$(which code)" != "" ]
  }
  install_vscode() {
      echo "Installing vscode now"
      sudo snap install code --classic
  }
  ask_install_vscode() {
      is_vscode_installed && return
      if ask "Install vscode?"; then 
          type install_vscode | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_vscode
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_wavebox() {
  setup
  is_wavebox_installed() {
      [ -f /opt/wavebox/Wavebox ]
  }
  install_wavebox() {
      echo "Installing wavebox now"
      sudo wget -qO - https://wavebox.io/dl/client/repo/archive.key | sudo apt-key add -
      echo "deb https://wavebox.io/dl/client/repo/ x86_64/" | sudo tee /etc/apt/sources.list.d/wavebox.list
      sudo apt update
      sudo apt install -y wavebox ttf-mscorefonts-installer
  }
  ask_install_wavebox() {
      is_wavebox_installed && return
      if ask "Install wavebox?"; then 
          type install_wavebox | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_wavebox
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_xonsh() {
  setup
  is_xonsh_installed() {
      [ "$(which xonsh)" != "" ]
  }
  install_xonsh() {
      echo "Installing xonsh now"
      pip install xonsh
      chsh -s $(which xonsh) $USER
  }
  ask_install_xonsh() {
      is_xonsh_installed && return
      if ask "Install xonsh?"; then 
          type install_xonsh | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_xonsh
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function cli_y_ppa_manager() {
  setup
  is_y_ppa_manager_installed() {
      [ "$(which y-ppa-manager)" != "" ]
  }
  install_y_ppa_manager() {
      echo "Installing y_ppa_manager now"
      sudo add-apt-repository -y ppa:webupd8team/y-ppa-manager
      sudo apt install -y y-ppa-manager
  }
  ask_install_y_ppa_manager() {
      is_y_ppa_manager_installed && return
      if ask "Install y_ppa_manager?"; then 
          type install_y_ppa_manager | sed '1,3d;$d' | sed 's/^\s*//g' >> $RUNFILE
          echo " " >> $RUNFILE
      fi
  }
  ask_install_y_ppa_manager
  [ "$ALL" == "" ] && run_todo
  return 0;
}
function __run() {
  local pid=""
  local status=255
  local cmd="${1-}"
  shift || true
  case "$cmd" in
    "") __run "help"; return $?;;
    "all") cli_all "$@" & local pid="$!";;
    "awscli") cli_awscli "$@" & local pid="$!";;
    "bash_it") cli_bash_it "$@" & local pid="$!";;
    "copyq") cli_copyq "$@" & local pid="$!";;
    "default_gui_packages") cli_default_gui_packages "$@" & local pid="$!";;
    "docker") cli_docker "$@" & local pid="$!";;
    "dotfiles") cli_dotfiles "$@" & local pid="$!";;
    "etckeeper") cli_etckeeper "$@" & local pid="$!";;
    "fix_max_user_watches") cli_fix_max_user_watches "$@" & local pid="$!";;
    "fix_sudo") cli_fix_sudo "$@" & local pid="$!";;
    "goenv") cli_goenv "$@" & local pid="$!";;
    "google-chrome") cli_google-chrome "$@" & local pid="$!";;
    "nodenv") cli_nodenv "$@" & local pid="$!";;
    "opera") cli_opera "$@" & local pid="$!";;
    "peek") cli_peek "$@" & local pid="$!";;
    "pyenv") cli_pyenv "$@" & local pid="$!";;
    "spotify") cli_spotify "$@" & local pid="$!";;
    "terraform") cli_terraform "$@" & local pid="$!";;
    "touchpad_indicator") cli_touchpad_indicator "$@" & local pid="$!";;
    "vscode") cli_vscode "$@" & local pid="$!";;
    "wavebox") cli_wavebox "$@" & local pid="$!";;
    "xonsh") cli_xonsh "$@" & local pid="$!";;
    "y_ppa_manager") cli_y_ppa_manager "$@" & local pid="$!";;
    "help")
      echo "Usage: bootstrap <task> [...]" 1>&2
      cat 1>&2 <<HELP

    all                   :  Install everything (after asking if you want to)
    awscli                :  Install awscli
    bash_it               :  Install bash_it
    copyq                 :  Install copyq
    default_gui_packages  :  Install default gui pages like meld, glogg etc.
    docker                :  Install docker
    dotfiles              :  Install dotfiles
    etckeeper             :  Install etckeeper
    fix_max_user_watches  :  Fix max_user_watches by increasing to 524288?
    fix_sudo              :  Fix sudo so user so password isn't required?
    goenv                 :  Install goenv
    google-chrome         :  Install google-chrome
    help                  :  display this help message
    nodenv                :  Install nodenv
    opera                 :  Install opera
    peek                  :  Install peek
    pyenv                 :  Install pyenv
    spotify               :  Install spotify
    terraform             :  Install terraform
    touchpad_indicator    :  Install touchpad_indicator
    version               :  display version
    vscode                :  Install vscode
    wavebox               :  Install wavebox
    xonsh                 :  Install xonsh
    y_ppa_manager         :  Install y_ppa_manager

HELP
      status=0
      ;;
    "version")
      echo "bootstrap 1.0.2 (bash $BASH_VERSION)"
      status=0
      ;;
    *) echo "Unknown Command: $cmd" 1>&2;;
  esac
  if [ ! -z "$pid" ]; then
      wait "$pid"
      local status=$?
  fi
  return $status
}
__run "$@"
export __STATUS="$?"
exit $__STATUS
