# My Dotfiles

This repo contains my dotfiles along with scripts for programmatically setting up my preferred environment. Right now, I primarily use a macOS machine, so these are geared towards that.

They are, as dotfiles/setup repos are apt to be, under constant construction.

# Before Bootstrapping

There are some manual steps to be done on a fresh macOS installation before bootstrapping. Most of these are things that simply cannot be scripted (as far as I can tell).

## Logging in

Set up a good password, if you didn't do this on initial account setup.

Set up TouchID, if the computer supports it.

## Keyboard Settings

Re-map `Caps Lock` to `Escape`. There might be ways of automating this, but they're not good enough for my tastes yet. This can be done by System Preferences -> Keyboard -> Keyboard -> Modifier Keys -> Re-map `Caps Lock` to `Escape`.

On the Touch Bar (if it exists), replace Siri with Launchpad.

Turn off "correct spelling automatically". Apparently the `defaults write` command doesn't fully do this.

## Wi-Fi

It should go unstated, but make sure you're on the right Wi-Fi network. Assuming no ethernet connection, of course.

## Accounts and Updates

Sign in to iCloud account and App Store, if you didn't do this on initial account setup.

Then make sure system updates are up-to-date. You can do this either through the App Store or through `softwareupdate -l` and `softwareupdate --install --all --verbose`.

# Bootstrapping

A completely fresh installation of macOS does not come with `git`, making the idea of cloning this repo and running all of the setup scripts a bit difficult. I've created a bootstrap script that will get a fresh box to the point where the setup scripts can be run.

The expectation is that these scripts are being run on the box in question, instead of remotely. This matters mostly for `mas`, which may require a visual prompt.

The simplest way to run the bootstrapping script is to `curl` it and pipe it to `bash` in Terminal. Alternatively, you can save it from Github into a file and run that, especially if you want to see what's in it, first.

Because this is my personal stuff, and I know what's in the shell script, I'm fine with just running the curl command:

```
bash <(curl -s https://raw.githubusercontent.com/kdbertel/dotfiles/master/bootstrap.sh)
```

## Bootstrap contents

The following things are needed for the setup scripts to make any sort of sense. If you are able to do these things sans bootstrap script, then you do not need to run the bootstrap script.

- Generate an SSH key pair; the public key needs to be provided to Github so that Github repositories can be cloned over SSH. My plan is to remove this step and clone over HTTPS, and then later shift it to SSH. This allows for better copy/pasting of the SSH keys.
- Install Homebrew; as a side effect, this will install the macOS command-line tools, which includes a version of `git`
- Clone this repository into `~/.df`
- Stow dotfiles
- Other things necessary for setting up my environment

# After Bootstrapping

These are all steps that need to be taken manually, either because there's no good way of automating them, or I just haven't bothered to sniff out the `defaults write` command to do it.

## Dropbox

Log in to Dropbox and selectively sync the right folders.

## 1Password

Log in to all the right vaults.

Install the Safari extension.

## BetterTouchTool

Run it and give it accessibility access.

Import license.

Make sure the settings load correctly.

## Github

Login to Github. Then run `pubkey` and provide the SSH public key.

Change the `~/.df` repo to point to the SSH version instead of HTTPS.

## Wallpaper

I keep a selection of wallpaper in Dropbox. Selectively sync that and pick a nice one.

## Screensaver

I really wish macOS had a system Blank screensaver.

## Microsoft Office

Download and install Office 365, logging in as appropriate. Run everything to make sure it works.

I prefer the "Classic" theme.

### OneDrive

Get the right folders.

Make sure OneDrive starts up on machine boot.

### Outlook

Set marking mail as read after it's been up for a second: Preferences -> Reading -> Mark mail as read -> When viewed ... `[1]`.

Turn off weather: Preferences -> Calendar -> Weather -> Show current weather on calendar

Turn off reminders: Outlook -> Turn off reminders

### OneNote

Open all the correct notebooks.

## Finder

Re-organize sidebar---while this may be possible with `plistBuddy`, I don't want to go through the effort currently, and this is different for each of my computers.

Toolbar (Icon Only): Back/Forward; Path; (Flexible?) Space; View; Arrange; Action; Share; Edit Tags; Space; Get Infor; (Flexible?) Space; Search

## Mail

Toolbar (Icon Only): Get Mail; New Message; Space; Space; Delete; Reply/Reply All/Forward; Flag; Space; Archive; Move; Flexible Space; Search

## Safari

Plugins: 
- 1Password (done as part of installing 1Password)
- KeySearch
- [uBlock Origin](https://github.com/el1t/uBlock-Safari)
  - Turn off the badge saying how many things have been blocked
- [WhatFont](http://www.chengyinliu.com/whatfont.html)


## Xcode

Download and install Xcode; I use [this Stack Overflow question/answer](http://stackoverflow.com/a/10335943/16633) for my downloads. You may want to run bootstrap again to make sure settings apply.

## Fantastical

Run it and make sure everything is set up.

## Fluid

Run it and create:
URL: https://trello.com
Name: Trello
Location: Applications
Icon: files/Trello.icns (originally from https://dribbble.com/shots/1774232-Freebie-Trello-App-Icon)
