Getting Started Guide
============

We use CocoaPods.

1) Add the following to your Podfile:

```ruby
pod "Streamlyne-Cocoa-SDK", :git => 'http://git.streamlyne.co/streamlyne/sl-cocoa-sdk.git'
```

2) Copy `Streamlyne.xcdatamodeld` to your project and be sure to check on "Copy items into destination group's folder (if needed)". This is for Core Data, and cannot be installed with CocoaPods.

3) Include `SLSDK.h` to use the Streamlyne SDK.