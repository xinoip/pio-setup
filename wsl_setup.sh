#!/bin/bash
cd "$(dirname "$0")"

### CONFIGURATION
# won't use `source` due to security concerns
conf_home="/home/pio";
conf_ssh_comment="ssh comment foo@foo.com";
conf_zshrc=`cat config/zshrc.conf`;
conf_ohmyzsh_custom_dir="${conf_home}/.oh-my-zsh/custom";

echo "Updating stuff";
sudo apt-get update -y;
sudo apt-get upgrade -y;
echo "Download stuff";
sudo apt-get install clang clang-tidy clang-format zsh xclip;
sudo apt-get install cmake curl zip unzip tar;

# echo "Creating ssh key...";
# ssh-keygen -t ed25519 -C "${conf_ssh_comment}"
# eval "$(ssh-agent -s)"
# ssh-add ${conf_home}/.ssh/id_ed25519
# cat ${conf_home}/.ssh/id_ed25519.pub | xclip -selection clipboard;
# echo "Created ssh key and copied it to clipboard";

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

echo "Setup vcpkg";
mkdir -p ${conf_home}/repo;
git clone https://github.com/Microsoft/vcpkg.git ${conf_home}/repo/vcpkg;
cd ${conf_home}/repo
./vcpkg/bootstrap-vcpkg.sh

echo -e "\n\n\n";
echo "Done!";
