#!/bin/bash
xcversion update --verbose
xcversion install 7.3.1 --verbose
xcversion install-cli-tools
sudo xcodebuild -license accept

