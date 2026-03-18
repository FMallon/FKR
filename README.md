# Finzell's Unified Linux Kernel Package Management Resolver

A cross-distro compatible Package Manager handler - basically just detects Package Manager and runs the commands in a unified way.... it's not that deep!

# Install
- Install using this command:

```
cd /var/opt && sudo git clone https://github.com/FMallon/FKR && cd FKR && sudo chmod +x ./fkr.sh && sudo ln -s $(pwd)/fkr.sh /usr/local/bin/fkr
```

# Note

This is in testing stage! It's quick & dirty rn.  I am only making it public because I need to begin testing on many other distros!

This stems from an idea I had many years ago because I distro-hop a lot, Arch, Fedora-based distros, Debian-based and so on.  I don't know why a universal command hasn't already been agreed upon to make life easier for people, but whatever!

Anyways, before I was using 'pacman -Syyu' as an alias for 'apt update && apt upgrade' in my .bashrc and it would sometimes clash.  So this has always been an idea.

The reason I am making it now, is for another project I am working on, and I need a tool like this for it.  

As stated above, this is in testing stage, I've only spent a few hours total on this.  I need to make public so I can download and begin hardening/testing/improving the code using other systems.  

So far, it has only been tested in WSL - Arch (and it also seems to work on apt cuz I just tested it the second after uploading).  I don't even know if the other Package Manager commands and flags work - hence why it is public... I refuse to upload privately and use git authentification on a load of systems.

So.... use at your own volition, I can't stop you, and I assume you are a grown adult. 

Thus far, it works to install, query, update and upgrade - but like I said: still needs a lot of work.

The Usage is still copy paste from a different script, so ignore that completely.

I will also consider making Unix package manager's compatible.  I don't know if I will do NixOS cuz it's a different thing, and Snap/Flatpak more than likely won't happen.  I definietly won't be doing it for Portage because it's its own thing.

It has only been tested in Bash - it may not work with zshell at the moment.  And only on more up-to-date versions of Bash.
###########################################################################################################
Usage:
``` 
    - fkr --install | -i <packages> -> install packages
    - fkr --remove | -r <packages> -> remove packages

    - fkr --update -> update the Repo's cache
    - fkr --upgrade -> upgrade the packages/system
    - fkr --update-upgrade | -uu -> update & upgrade the repo's cache and packages/system

    - fkr --query-pkg | -qp <packages> -> query installed packages
    - fkr --query-repo | -qr <packages> -> query the repo database

  Note: there is a --from-file and --dry-run flag, but I need to improve their functionality and handling.

   ```
    
