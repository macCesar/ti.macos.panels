Files in this folder are copied directly into the iOS build directory
when the iOS app is compiled:

    <project-dir>/build/iphone

You can place files such as asset catalog files, .framework files and storyboards in this
directory.

Files in this directory are copied directly on top of whatever files are already
in the build directory, so make sure your files don't overwrite
essential project files or files from other modules.
