#!/bin/bash

CLTOOLS=$(pkgutil --pkgs=com.apple.pkg.CLTools_Executables)

if $CLTOOLS; then
    echo "Xcode Command Line Tools already installed"
else
    xcode-select --install
fi

ASDF_DIR=~/.asdf

if [ -d $ASDF_DIR ]; then
    echo "asdf is already installed"
else
    echo "asdf wasn't found, installing now"
    git clone https://github.com/asdf-vm/asdf.git $ASDF_DIR
fi

asdf plugin add ruby
asdf plugin add python

asdf install ruby 3.2.1
asdf install python 3.10.5

bundle install --binstubs --path vendor



