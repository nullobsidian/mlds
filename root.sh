#!/bin/bash

codenames=('bionic')
cn=$(lsb_release -cs)
userExec="sudo -u ${SUDO_USER}"

validateCn () {
  for i in "${codenames[@]}"; do
    if [[ "${i}" == "${cn}" ]]; then
      return 5
    fi
  done
}

validateCn
cnReturn=$?

# Checking Compatible Linux Distro and Ubuntu Release
if [ "$(lsb_release -is | tr '[:upper:]' '[:lower:]')" == "ubuntu" ] && [[ $cnReturn == 5 ]]; then
    echo -e "[\e[32m+\e[0m] \e[32m\e[1mInitializing\e[0m: Linux User Setup" && sleep 0.5s
    echo -e "[\e[32m+\e[0m] \e[32m\e[1mUpdating\e[0m: Package Management Database" && sleep 0.5s
    until apt-get update -qqy; do sleep 0.1s; done
    
    # Useful utilities
    UTILITIES=(
      zsh
      jq
      npm
      vim
      tree
      htop
      tmux
      snapd
      sakura
      thefuck
      ffmpeg
      gthumb
      xsel 
      mesa-utils
      ruby-full
      exfat-fuse
      exfat-utils
      python3-pip
      python3-distutils
      apt-transport-https
      gnupg-agent
    )
    
    echo -e "[\e[32m+\e[0m] \e[32m\e[1mInstalling\e[0m: Utilities"
    until apt-get install -y ${UTILITIES[@]}; do sleep 0.1s; done
    
    echo -e "[\e[32m+\e[0m] \e[32m\e[1mAdding\e[0m: Keys and Repos"
    # Adding Key and Repo validation
    if [[ $(cat /usr/share/.setup-data) != 0 ]]; then
      # Setting up keys
      until curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -; do sleep 0.1s; done # Docker
      until curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -; do sleep 0.1s; done # Brave
      until apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61; do sleep 0.1s; done  # Etcher
      curl https://packages.microsoft.com/keys/microsoft.asc | $userExec gpg --dearmor > packages.microsoft.gpg && sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/ # Code
      until curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -; do sleep 0.1s; done # K8s
      
      # Adding additional repos
      until add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $cn stable"; do sleep 0.1s; done # Docker
      echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ $cn main" | tee /etc/apt/sources.list.d/brave-browser-release-${cn}.list # Brave
      echo "deb https://deb.etcher.io stable etcher" | sudo tee /etc/apt/sources.list.d/balena-etcher.list # Etcher
      wget -qnc https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb -P /tmp && dpkg -i /tmp/nordvpn-release_1.0.0_all.deb && rm /tmp/nordvpn-release_1.0.0_all.deb # NordVPN
      echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list # Code
      echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list # K8s
      until add-apt-repository ppa:obsproject/obs-studio -y; do sleep 0.1s; done #OBS Studio
      until add-apt-repository ppa:zanchey/asciinema -y; do sleep 0.1s; done #aciinema 
      echo "0" > /usr/share/.setup-data
      else
      echo "Keys and Repos already installed!"
    fi
    
    until apt-get update -qqy; do sleep 0.1s; done
    
    # User Packages
    PACKAGES=(
      code
      kubectl
      nordvpn
      gnome-boxes
      asciinema
      virtualbox
      docker-ce
      docker-ce-cli
      containerd.io
      brave-browser
      balena-etcher-electron
      obs-studio
    )
	  
    echo -e "[\e[32m+\e[0m] \e[32m\e[1mInstalling\e[0m: Packages"
    until apt-get install -y ${PACKAGES[@]}; do sleep 0.1s; done
    if ! which helm; then curl -L https://git.io/get_helm.sh | bash; fi
    gem install colorls
    npm i -g bash-language-server
    chown -R root:root /usr/share/zsh/vendor-completions/_code
    
    echo -e "[\e[32m+\e[0m] \e[32m\e[1mInstalling\e[0m: Additional Drivers"
    until add-apt-repository ppa:eh5/pulseaudio-a2dp -y; do sleep 0.1s; done
    until apt-get install libavcodec-dev libldac pulseaudio-module-bluetooth -y; do sleep 0.1s; done
    
    echo -e "[\e[32m+\e[0m] \e[32m\e[1mInstalling\e[0m: Snappy User Packages"
    snappyClassic () {
      local CLASSIC=(
        slack
      )
      local SNAPPY=(
        spotify
        cacher
        mailspring
        vlc
      )
      for i in "${CLASSIC[@]}"; do
        snap install --classic ${i}
      done
      snap install "${SNAPPY[@]}"
    }
    snappyClassic
    
    echo -e "[\e[32m+\e[0m] \e[32m\e[1mConfiguring\e[0m: Docker"
    if [[ -a "$SUDO_USER" ]]; then
      systemctl enable docker && usermod -aG docker $USER
    else
      systemctl enable docker && usermod -aG docker $SUDO_USER
    fi
	  
    if dpkg --get-selections | grep -E '(^|\s)gnome-shell($|\s)'; then
      gnomeSet () {
        local GNOME=(
          gnome-shell-extensions
          gnome-shell-extension-dashtodock
          gnome-shell-extension-top-icons-plus
          gnome-shell-extension-multi-monitors
          gnome-shell-extension-caffeine
          gnome-shell-extension-log-out-button
          gnome-shell-extension-top-icons-plus
	  gnome-shell-extension-appindicator
        )
        echo -e "[\e[32m+\e[0m] \e[32m\e[1mInstalling\e[0m: GNOME Extensions"
        apt-get install -y "${GNOME[@]}"
        git clone https://github.com/sunwxg/gnome-shell-extension-unblank.git /tmp/gnome-shell-unblank
        $userExec make install -C /tmp/gnome-shell-unblank
      }
      gnomeSet
    fi
    
    echo -e "[\e[32m+\e[0m] \e[32m\e[1mInstalling\e[0m: Installing Extra Fonts and Symbols"
    if [[ $(cat /usr/share/.fonts-rtn) != 0 ]]; then
      wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf -P /tmp
      mv /tmp/PowerlineSymbols.otf /usr/share/fonts/
      mv /tmp/10-powerline-symbols.conf /etc/fonts/conf.d/
      git clone https://github.com/powerline/fonts.git --depth=1 /tmp/fonts && /tmp/fonts/install.sh
      wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/Hack.zip -P /tmp/ && unzip /tmp/Hack.zip -d /usr/share/fonts
      fc-cache -vf
      echo "0" > /usr/share/.fonts-rtn
    fi
    
    echo -e "[\e[32m+\e[0m] \e[32m\e[1mUpdating\e[0m: Setting Default Shell to zsh" && sleep 0.5s
    if [[ -z "$SUDO_USER" ]]; then
      usermod -s /bin/zsh $USER
      else
      usermod -s /bin/zsh $SUDO_USER
    fi
    
    echo -e "[\e[32m+\e[0m] \e[32m\e[1mEnabling Start-Up\e[0m: Docker"
    if [[ -a "$SUDO_USER" ]]; then
      systemctl enable docker && usermod -aG docker $USER
    else
      systemctl enable docker && usermod -aG docker $SUDO_USER
    fi

  else
    echo -e "[\e[31mx\e[0m] \e[31m\e[1mError\e[0m: Unsupported Linux Distrubtion or Ubuntu Release"
    exit 1
fi
