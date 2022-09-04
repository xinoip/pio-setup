#!/bin/bash
cd "$(dirname "$0")"

### CONFIGURATION
# won't use `source` due to security concerns
conf_home="/home/pio";
conf_ssh_comment="ssh comment foo@foo.com";
conf_dnf=`cat config/dnf.conf`;
conf_xdg_dirs=`cat config/xdg_dirs.conf`;
conf_zshrc=`cat config/zshrc.conf`;
conf_alacritty=`cat alacritty_settings.yml`;
conf_ohmyzsh_custom_dir="${conf_home}/.oh-my-zsh/custom";

echo "Setup dnf.conf";
sudo sh -c "echo \"${conf_dnf}\" >> /etc/dnf/dnf.conf";

echo "Setup user-dirs.dirs";
echo "${conf_xdg_dirs}" > ${conf_home}/.config/user-dirs.dirs
echo "Remove old user-dirs";
rm -r ${conf_home}/Downloads ${conf_home}/Pictures ${conf_home}/Templates ${conf_home}/Public ${conf_home}/Documents ${conf_home}/Music ${conf_home}/Videos ${conf_home}/Desktop;
echo "Create new user-dirs";
mkdir ${conf_home}/pio-xdg ${conf_home}/download ${conf_home}/picture ${conf_home}/pio-xdg/Templates ${conf_home}/pio-xdg/Public ${conf_home}/pio-xdg/Documents ${conf_home}/pio-xdg/Music ${conf_home}/pio-xdg/Videos ${conf_home}/pio-xdg/Desktop;

echo "Updating stuff";
sudo dnf update --refresh -y;
echo "Download stuff";
sudo dnf install git clang clang-tools-extra zsh xclip alacritty flameshot;
sudo dnf install dnf-plugins-core;

echo "Get vscode";
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc;
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo';
sudo dnf update --refresh -y;
sudo dnf install code;

echo "Get brave";
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/;
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc;
sudo dnf install brave-browser;

echo "Creating ssh key...";
ssh-keygen -t ed25519 -C "${conf_ssh_comment}"
eval "$(ssh-agent -s)"
ssh-add ${conf_home}/.ssh/id_ed25519
cat ${conf_home}/.ssh/id_ed25519.pub | xclip -selection clipboard;
echo "Created ssh key and copied it to clipboard";

echo "= Setup zsh =";
echo "Setup oh-my-zsh";
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mkdir -p "${conf_ohmyzsh_custom_dir}";
echo "Get zsh plugins";
/usr/bin/git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $conf_ohmyzsh_custom_dir/plugins/zsh-syntax-highlighting;
/usr/bin/git clone https://github.com/zsh-users/zsh-autosuggestions.git $conf_ohmyzsh_custom_dir/plugins/zsh-autosuggestions;
/usr/bin/git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $conf_ohmyzsh_custom_dir/themes/powerlevel10k;
echo "Setup .zshrc";
echo "${conf_zshrc}" > ${conf_home}/.zshrc;

echo "Download fonts for p10k";
curl -LJO https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
curl -LJO https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
curl -LJO https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
curl -LJO https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
mkdir -p ${conf_home}/.local/share/fonts;
mv *.ttf ${conf_home}/.local/share/fonts;

echo "Download iosevka font";
sudo dnf copr enable peterwu/iosevka;
sudo dnf search iosevka;
sudo dnf install iosevka-fonts;
fc-cache;

echo "Setup alacritty config";
mkdir -p ${conf_home}/.config/alacritty;
echo ${conf_alacritty} > ${conf_home}/.config/alacritty/alacritty.yml;

echo "Setup vcpkg";
mkdir -p ${conf_home}/repo;
git clone https://github.com/Microsoft/vcpkg.git ${conf_home}/repo/vcpkg;
cd ${conf_home}/repo
./vcpkg/bootstrap-vcpkg.sh

echo -e "\n\n\n";
echo "If we lived through all of it... here are the manual stuff to do!";
echo "Sync programs: vscode, brave";
echo "Setup keybinding for flameshot";
echo "Setup keybindings for workspace management";
echo "Configure desktop environment";
