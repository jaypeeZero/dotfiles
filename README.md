# My Dotfiles

This repo contains my dotfiles along with scripts for programmatically setting up my preferred environment. Right now, I primarily use a macOS machine, so these are geared towards that.

They are, as dotfiles/setup repos are apt to be, under constant construction.

# Bootstrapping

A completely fresh installation of macOS does not come with `git`, making the idea of cloning this repo and running all of the setup scripts a bit difficult. I've created a bootstrap script that will get a fresh box to the point where the setup scripts can be run.

The simplest way to run the bootstrapping script is to `curl` it and pipe it to `bash`. This can be done either in Terminal in a new box, or over SSH. Going the SSH route will help enforce that everything is done by command line only.

```
bash <(curl -s https://raw.githubusercontent.com/kdbertel/macos_setup/master/bootstrap.sh)
```

## Bootstrap contents

The following things are needed for the setup scripts to make any sort of sense. If you are able to do these things sans bootstrap script, then you do not need to run the bootstrap script.

- Generate an SSH key pair; the public key needs to be provided to Github so that Github repositories can be cloned over SSH
- Install Homebrew; as a side effect, this will install the macOS command-line tools, which includes a version of `git`
- Clone this repository into `~/.df`

# Setup Scripts

Someday I will write up what my setup scripts actually do

# Dotfile Linking

To just link dotfiles instead of doing the entire setup:

```
./.df/link_dotfiles.sh
```

# To Do

- [ ] Finish README
- [ ] Rename dotfile linking script
- [ ] Move to `chruby` maybe?
- [ ] Vundle
- [ ] Can I install tmux plugins without manual intervention?
- [ ] Lots of other things
