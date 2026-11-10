Files in this folder are copied directly into the compiled product directory
when the iOS app is compiled:

    <project-dir>/build/iphone/build/Products/<Debug-iphonesimulator|Release-iphoneos>/<app name>.app/

Place your module's iOS bundles and localization files in this folder.

Files in this directory are copied directly on top of whatever files are already
in the build directory, so make sure your files don't overwrite
essential project files or files from other modules.
