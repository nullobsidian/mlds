#!/bin/bash

echo -e "[\e[32m+\e[0m] \e[32m\e[1mInstalling\e[0m: oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo -e "[\e[32m+\e[0m] \e[32m\e[1mInstalling\e[0m: User Packages"
pip3 install awscli --upgrade --user

echo -e  "[\e[32m+\e[0m] \e[32m\e[1mInstalling\e[0m: VSCode Extensions"
codeConfig () {
  local EXTENSIONS=(
    redhat.vscode-yaml # YAML
    ms-azuretools.vscode-docker # Docker
    Cacher.cacher-vscode # Cacher
    ms-kubernetes-tools.vscode-kubernetes-tools # K8s
    mauve.terraform # Terraform
    vscoss.vscode-ansible # Ansible 
    ms-python.python # Python
    ms-vscode.Go # Go
    rebornix.Ruby # Ruby
    ms-vscode-remote.vscode-remote-extensionpack # Remote Pack
    davidanson.vscode-markdownlint # Markdown Lint
    bierner.markdown-preview-github-styles # Github Mardown Preview
    github.vscode-pull-request-github # GitHub Pull Request
    christian-kohler.path-intellisense # Path Intellisense
    jonwolfe.language-polymer # THEME
    PKief.material-icon-theme # ICONS
    mads-hartmann.bash-ide-vscode # Bash
    )
  for i in ${EXTENSIONS[@]}; do
    code --install-extension ${i}
  done
}
codeConfig

if dpkg --get-selections | grep -E '(^|\s)gnome-shell($|\s)'; then
  echo -e "[\e[32m+\e[0m] \e[32m\e[1mCustomizing\e[0m: GNOME and Desktop Environment"
  wget https://setup-ubuntu-dt.s3.amazonaws.com/wallpapers/background.jpg -P ~/Pictures/Wallpapers
  wget https://setup-ubuntu-dt.s3.amazonaws.com/wallpapers/screensaver.jpg -P ~/Pictures/Wallpapers
  gsettings set org.gnome.desktop.screensaver picture-uri file:///home/$USER/Pictures/Wallpapers/screensaver.jpg
  gsettings set org.gnome.desktop.background picture-uri file:///home/$USER/Pictures/Wallpapers/background.jpg
fi

echo -e "[\e[32m+\e[0m] \e[32m\e[1mConfiguring\e[0m: shell, terminal, tmux, and vscode"
pip3 install --user powerline-status
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
configZsh () {
  local plDir=$(pip3 show powerline-status | sed -n '/Location:/p' | sed 's/Location: //g')
  if ! grep "source ~/.profile" ~/.zshrc; then echo -e "\nif [ -f ~/.profile ]; then\n    source ~/.profile\nfi" >> ~/.zshrc; fi
  if ! grep "source ${plDir}/powerline/bindings/zsh/powerline.zsh" ~/.zshrc; then echo -e "\nif [ -f ${plDir}/powerline/bindings/zsh/powerline.zsh ]; then\n    . ${plDir}/powerline/bindings/zsh/powerline.zsh\nfi" >> ~/.zshrc; fi
  sed -i 's/ZSH_THEME=".*"/ZSH_THEME="'"powerlevel9k\/powerlevel9k"'"/' ~/.zshrc
  if ! grep colorls ~/.zshrc; then echo -e "\nif which colorls &> /dev/null; then\n    source $(dirname $(gem which colorls))/tab_complete.sh\nfi" >> ~/.zshrc; fi
  echo -e "\nexport TERM=\"xterm-256color\"" >> ~/.zshenv
}
configZsh

if [ -d ~/.config/sakura/ ]; then
  cat config/sakura.conf > ~/.config/sakura/sakura.conf
else
  mkdir -p ~/.config/sakura/
  cat config/sakura.conf > ~/.config/sakura/sakura.conf
fi

if [ -d ~/.config/Code/User/ ]; then
  cat config/settings.json > ~/.config/Code/User/settings.json
else
  mkdir -p ~/.config/Code/User/
  cat config/settings.json > ~/.config/Code/User/settings.json
fi

cat config/tmux.conf > ~/.tmux.conf
