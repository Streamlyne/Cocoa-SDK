#!/bin/bash

# CocoaPods
command -v pod >/dev/null 2>&1 || { 
    echo "Installing CocoaPods"
    sudo gem install cocoapods
    pod setup
}

# Appledoc
command -v appledoc >/dev/null 2>&1 || { 
    echo "Installing Appledoc"
    brew install appledoc
}

echo "Installation Completd."

