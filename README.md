# My Dotfiles

These dotfiles are intended to be used for quick and easy setup of my environment.
This way, I can have a consistent prompt (&c) on all boxes, both remote and local.
As well, kept public because I might want to reference them on other computers, or point
out features publicly.

## Installation

    git clone https://github.com/kdbertel/dotfiles.git .df
    ./.df/install.sh

Existing dotfiles are backed up. To delete them:

    rm -r .*.dotfiles-*

To update an existing installation:

    ./.df/update.sh

### For Not-Me

Needless to say, if you clone this repo, you probably will want to change references to me
(such as in `.gitconfig`) to your name.