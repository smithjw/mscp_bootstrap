#!/bin/bash

ASDF_DIR="$HOME/.asdf"
mSCP_DIR="$HOME/macos_security"
venv_DIR="$HOME/Documents/py-mscp"

# Install XCode Command Line Tools - https://github.com/eth-its/autopkg-mac-recipes-yaml/blob/main/Scripts_for_Installers/XcodeCLTools-install.zsh
CLTOOLS=$(pkgutil --pkgs=com.apple.pkg.CLTools_Executables)

if [[ -z "$CLTOOLS" ]]; then
    cmd_line_tools_temp_file="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    touch "$cmd_line_tools_temp_file"
    cmd_line_tools=$(/usr/sbin/softwareupdate -l | /usr/bin/awk '/\*\ Label: Command Line Tools/ { $1=$1;print }' | /usr/bin/sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | /usr/bin/cut -c 9- | head -n 1)

    if [[ ${cmd_line_tools} ]]; then
        echo "Download found - installing"
        softwareupdate -i "$cmd_line_tools" --verbose
    else
        "echo Download not found"
    fi

    if [[ -f "$cmd_line_tools_temp_file" ]]; then
        rm "$cmd_line_tools_temp_file"
    fi

else
    echo "Xcode Command Line Tools already installed"
fi

# Install ASDF
if [[ -d "$ASDF_DIR" ]]; then
    echo "asdf is already installed"
else
    echo "asdf wasn't found, installing now"
    git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR"
fi

# Add to path
echo "Add asdf to zsh path"
# shellcheck disable=SC2016
echo '. $HOME/.asdf/asdf.sh' >> ~/.zshrc

# Use asdf to install Ruby and set as global
"$ASDF_DIR"/bin/asdf plugin add ruby
"$ASDF_DIR"/bin/asdf install ruby latest
"$ASDF_DIR"/bin/asdf global ruby latest

# Use asdf to install Python and set as global
"$ASDF_DIR"/bin/asdf plugin add python
"$ASDF_DIR"/bin/asdf install python latest
"$ASDF_DIR"/bin/asdf global python latest

# Clone mSCP Project
git clone https://github.com/usnistgov/macos_security.git "$mSCP_DIR"

# Configure Python Requirements for mSCP
python3 -m venv "$venv_DIR"
# shellcheck disable=SC1091
source "$venv_DIR"/bin/activate
pip3 install -r "$mSCP_DIR"/requirements.txt

# Configure Ruby Requirements for mSCP
bundle install --gemfile "$mSCP_DIR"/Gemfile --binstubs "$mSCP_DIR"/bin --path "$mSCP_DIR"/vendor
