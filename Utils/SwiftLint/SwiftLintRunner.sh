#!/bin/sh
# Only run for Debug builds
if [ "$CONFIGURATION" != "Debug" ]; then
    exit 0;
fi

# Only run on local machines
if [ "$NODE_NAME" == "" ]
then
    echo "Local build: enable swiftlint"
else
    echo "CI build: disable swiftlint"
    exit 0
fi

# Unsetting the iOS SDK from the path makes Xcode rely on the macOS SDK instead. 
# This SDKROOT gets reset at each build phase, so this only needs to be unset.  
unset SDKROOT

# Triggers the script
"$SRCROOT/../Utils/SwiftLint/SwiftLintRunner.swift" "$PROJECT_DIR"
