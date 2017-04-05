# My Dotfiles

This repo contains my dotfiles along with scripts for programmatically setting up my preferred environment. Right now, I primarily use a macOS machine, so these are geared towards that.

They are, as dotfiles/setup repos are apt to be, under constant construction.

# Before Bootstrapping

There are some manual steps to be done on a fresh macOS installation before bootstrapping. Most of these are things that simply cannot be scripted (as far as I can tell).

- Sign in to iCloud account and App Store

# Bootstrapping

A completely fresh installation of macOS does not come with `git`, making the idea of cloning this repo and running all of the setup scripts a bit difficult. I've created a bootstrap script that will get a fresh box to the point where the setup scripts can be run.

Before bootstrapping, go to `System Preferences -> Sharing` and choose a good computer name. If this is a machine you plan on operating remotely, also turn on `Remote Login` and `Remote Management` with `Observe` and `Control`. For security reasons, setting these is not an automatic part of this setup script. Make sure the machine is up to date with `softwareupdate -l`. If it's not, do `softwareupdate --install --all --verbose`; you may then have to `sudo shutdown -r now` to reboot the machine. Or use the "updates" part of the app store, which doesn't require you to have signed in to the app store, and gives you a somewhat more useful progress indicator.

The simplest way to run the bootstrapping script is to `curl` it and pipe it to `bash`. This can be done either in Terminal in a new box, or over SSH. Going the SSH route will help enforce that everything is done by command line only.

Because this is my personal stuff, and I know what's in the shell script, I'm fine with just running the curl command:

```
bash <(curl -s https://raw.githubusercontent.com/kdbertel/dotfiles/master/bootstrap.sh)
```

## Bootstrap contents

The following things are needed for the setup scripts to make any sort of sense. If you are able to do these things sans bootstrap script, then you do not need to run the bootstrap script.

- Generate an SSH key pair; the public key needs to be provided to Github so that Github repositories can be cloned over SSH
- Install Homebrew; as a side effect, this will install the macOS command-line tools, which includes a version of `git`
- Clone this repository into `~/.df`
- Stow dotfiles
- Other things necessary for setting up my environment

# Setup Scripts

Someday I will write up what my setup scripts actually do

# To Do

- [ ] Finish README

# Manual Steps

## System

Re-map `Caps Lock` to `Escape`. There might be ways of automating this, but they're not good enough for my tastes yet.

- System Preferences -> Keyboard -> Keyboard -> Modifier Keys -> Re-map `Caps Lock` to `Escape`

## Finder

Re-organize sidebar---while this may be possible with `plistBuddy`, I don't want to go through the effort currently, and this is different for each of my computers

## Outlook
- Set up account
- Preferences -> Reading -> Mark mail as read -> When viewed ... `[1]`

## Xcode

Download and install Xcode. You may want to run bootstrap again to make sure settings apply.

## BetterTouchTool

Run it and give it accessibility access.

Import license.