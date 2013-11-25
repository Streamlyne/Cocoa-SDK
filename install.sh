#!/bin/bash

# === Dependencies
# CocoaPods
command -v pod >/dev/null 2>&1 || { 
    echo "Installing CocoaPods"
    sudo gem install cocoapods
    pod setup
    echo
}
# Appledoc
command -v appledoc >/dev/null 2>&1 || { 
    echo "Installing Appledoc"
    brew install appledoc
    echo
}

# === Install
echo "===== Cocoa/Objective-C SDK ====="
echo "Installing CocoaPods"
cd Streamlyne-Cocoa-SDK/
pod install
cd ../
echo "Open in Xcode the Streamlyne-Cocoa-SDK/Streamlyne-Cocoa-SDK.xcworkspace"
echo

# === Update
echo "Initializing and Updating Git Submodules"
git submodule update --init --recursive

echo "Installation Completed."
echo
