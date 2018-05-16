# EZNV

EZ backup and restore of your computing NVironment

## Purpose

Backup important config files and program-installed dependency lists to a
private gist automatically, and restore installation easily as well.

## Requirements

- MacOS 10 (only tested on 10.13.4)
- Python 3.6
- [`gist` command line gister](https://github.com/defunkt/gist)
- binaries listed in **GENERATE INSTALL LIST FILES** section of `eznv_backup.sh`
- config files listed in **CONFIG FILES TO SAVE** section of `eznv_backup.sh`

## Setup

1. Download or Fork and Clone the contents of this repo
2. Edit the following in `eznv_backup.sh` to suit your needs:
   - **CONFIG FILES TO SAVE** section: include configuration files you want backed up
     > these will not be re-installed on restore, just backed up
   - **GENERATE INSTALL LIST FILES** section: edit expressions to generate install lists for programs you want backed up
     - expressions must output a file with a `[program_name].install` formatted name
     - items in `[program_name].install` must be on their own line
3. Edit `restore_installers.json` to suit your needs:
    - You can add installer configurations for restoring from `*.install` files saved by `eznv_backup.sh`. The `restore_installers.json` file in root dir is set up in the following format:
    ```json
    {
        "[program_name]": {
            "sh_item_command": "[shell_command]"
        }
    }
    ```
    - program_name =  `*` in `*.install`
    - shell_command = shell comand that would be run on each item in `*.install` list with `{item}` added to command where item from list would normally appear within command
    - **EXAMPLE**:
    ```json
    {
        "brew": {
            "sh_item_command": "brew install {item}"
        }
    }
    ```

## Usage

### Backup

- run `sh eznv_backup.sh`
- once backup is complete, your backup gist will be opened in a new browser window

### Restore

- run `python3 eznv_restore.sh [gist_id]`

## License

GNU GPLv3