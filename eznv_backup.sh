#!/bin/bash

# ----------- #
# EZNV BACKUP #
# ----------- #

# AUTHOR: Arjun Ray
# EMAIL: deconstructionalism@gmail.com
# LICENSE: GNU GPLv3
# MAINTAINER: Arjun Ray
# STATUS: Development
# VERSION: 0.0.1

# PURPOSE: Backup important config files and program 
# installed dependency lists to a private gist 
# automatically.  Allows for easy restore of environment
# using the `eznv_restore.py` script.

# REQUIREMENTS:
# - MacOS 10 (only tested on 10.13.4)
# - binaries listed in "GENERATE INSTALL LIST FILES" section
# - config files listed in "CONFIG FILES TO SAVE" section
# - gist (https://github.com/defunkt/gist)

# IMPORTANT: Do not rename `config_files`

# YOU CAN:
#  - add files you want to backup to `config_files`
#  - add expressions to generate install lists for
#    programs in "GENERATE INSTALL LIST FILES" section
#    - expressions must output a file with a 
#      "[program_name].install" formatted name
#  - add a configuration for a given "*.install" file generated 
#    by this script to `restore_installers.json` to be used
#    by `eznv_restore.py` (see doc for that script 
#    for details)


# GENERATE SYSTEM INFO FILE
cat << EOF > ~/._system.backup
SYSTEM BACKUP
-------------
BACKUP DATE: $(date '+%d-%m-%Y %H:%M:%S')
$(uname -a)
$(sw_vers)
EOF

# CONFIG FILES TO SAVE
config_files=("~/._system.backup" \
              "~/.ga_profile" \
              "~/.gitconfig" \
              "~/.gitignore" \
              "~/.tmux.conf" \
              "~/.bashrc" \
              "~/.profile" \
              "~/.bash_profile" \
              "~/.vimrc" \
              "~/.bashrc")

# GET PATH OF THIS SCRIPT
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
self_path="$dir/`basename $0`"

# MAKE TEMP DIR FOR INSTALL LIST FILES
tmp_dir="/tmp/`date \"+CONFIG_BACKUP.%y-%m-%d.%H-%M-%S\"`"
mkdir $tmp_dir
cd $tmp_dir

# GENERATE INSTALL LIST FILES
## declare array variable
declare -a programs=("apm" "brew" "system_profiler" "tmux" "vim")

## loop through array
for i in "${programs[@]}"
do
  if ! [ -x "$(command -v "$i")" ]; then
    echo "Error: $i is not installed. Edit this file to remove program install file" >&2
    exit 1
  fi
done

#if ! [ -x "$(command -v git)" ]; then
#  echo 'Error: git is not installed.' >&2
#  exit 1
#fi
apm list --installed --bare > apm.install
while true; do
  read -p "Do you wish to save brew programs?" yn
  case $yn in
    [Yy]* ) brew leaves > brew.install && brew cask list --full-name > brew_cask.install; break;;
    [Nn]* ) echo 'skipped brew apps'; break;;
    * ) echo 'Please answer yes or no.';;
  esac
done
echo "Do you wish to save mac OSX apps?"
select yn in "Yes" "No"; do
  case $yn in
    Yes ) system_profiler SPApplicationsDataType -xml > apps.install; break;;
    No ) echo 'skipped mac osx apps'; break;;
  esac
done
ls ~/.tmux/plugins/ > tmux_plugins.install
ls ~/.vim/bundle/ > vim_plugins.install

# GET SPACE-SEPARATED LIST OF INSTALL LIST FILES
install_files=$(find  *.install | tr '\n' ' ')

# MAKE PRIVATE GIST WITH ALL FILES
# includes: config_files, install list files, this script

echo "install files are $install_files"
echo "self path is $self_path"
gist -p -o $self_path $install_files ${config_files[@]} -d "`date` - full config backup"
