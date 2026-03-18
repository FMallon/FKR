#!/usr/bin/env bash

############################ Finzell's Unified Linux Kernel Package Management Resolver ############################
#-Or 'fkr' for short.... how it's pronounced is up to the imagination!
#-A way to standardize and make managing packages across multple distros easier
#-Will begin with Pacman, Apt, dnf, apk, brew & Zypper cuz I need them for Containers and my MacOS
#-More can, and maybe will be, added in the future, like Unix Package Managers - I can't think of any more except for NixOS... but that's done through a Config file - will see in the future  
#-I will not be doing this for Portage - that's it's own thing, and using Emerge makes more sense, especially as it pertains to necessary output regarding USE Flags and Masks etc. 

if [ -n "$BASH_VERSION" ]; then
    MAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
elif [ -n "$ZSH_VERSION" ]; then
    MAIN_DIR="$(cd "$(dirname "$0")" && pwd)"
fi


PKGMNGR=()
ROOT=()

INSTALL_PKG=() 
REMOVE_PKG=()
QUERY_PKG=()
QUERY_REPO=()
UPDATE=()
UPGRADE=()

DRYRUN_FLAG=()


check_root(){


    local root=""

    #check for current privilege status
    if [ "$EUID" -eq 0 ]; then 

        ROOT=()
        return 0

    fi

    #test for sudo or doas
    if command -v doas >/dev/null 2>&1; then
        
        root=(doas)
        ROOT=($root)

    elif command -v sudo >/dev/null 2>&1; then

        root=(sudo)
        ROOT=($root)

    else

        printf "\n\nError: You need root privilege to run this!\n\n"
        return 3

    fi 


    # Test if user is Super User!
    sudo -v >/dev/null 2>&1
    if [[ "$?" -eq 0 ]]; then
        
        return 0

    fi

    
    doas true >/dev/null 2>&1
    if [[ "$?" -eq 0 ]]; then
        
        return 0

    fi


    printf "\nError: You are not a Super User!\n"
    clear_space
    return 3


}



clear_space(){


    printf "\n\n"


}



print_line_separater(){


    printf "\n__________________________________________________________________________________________\n"


}



get_pkgmgr(){

    if command -v pacman >/dev/null 2>&1; then 

        PKGMNGR=(pacman)
        INSTALL_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" -S --noconfirm)
        REMOVE_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" -R --noconfirm)
        QUERY_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" -Q)
        QUERY_REPO=("${ROOT[@]}" "${PKGMNGR[@]}" -Si)

        UPDATE=("${ROOT[@]}" "${PKGMNGR[@]}" -Sy)
        UPGRADE=("${ROOT[@]}" "${PKGMNGR[@]}" -Su)

        DRYRUN_FLAG=(--print)

        return 0

    
    elif command -v apt >/dev/null 2>&1; then 

        PKGMNGR=(apt-get)
        INSTALL_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" install -y)
        REMOVE_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" remove -y)
        QUERY_PKG=("${ROOT[@]}" dpkg -s)
        QUERY_REPO=("${ROOT[@]}" apt-cache show)

        UPDATE=("${ROOT[@]}" "${PKGMNGR[@]}" update)
        UPGRADE=("${ROOT[@]}" "${PKGMNGR[@]}" upgrade -y)

        DRYRUN_FLAG=(-s)
        
        return 0

    
    elif command -v dnf >/dev/null 2>&1; then 

        PKGMNGR=(dnf)
        INSTALL_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" install -y)
        REMOVE_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" remove -y)
        QUERY_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" list installed)
        QUERY_REPO=("${ROOT[@]}" "${PKGMNGR[@]}" info)

        UPDATE=("${ROOT[@]}" "${PKGMNGR[@]}" check-update)
        UPGRADE=("${ROOT[@]}" "${PKGMNGR[@]}" upgrade -y)

        DRYRUN_FLAG=(--assumeno)

        return 0


    elif command -v zypper >/dev/null 2>&1; then

        PKGMNGR=(zypper)

        INSTALL_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" install -y)
        REMOVE_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" remove -y)
        QUERY_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" search --installed-only)
        QUERY_REPO=("${ROOT[@]}" "${PKGMNGR[@]}" info)

        UPDATE=("${ROOT[@]}" "${PKGMNGR[@]}" refresh)
        UPGRADE=("${ROOT[@]}" "${PKGMNGR[@]}" update -y)

        DRYRUN_FLAG=(--dry-run)

        return 0

   
    elif command -v brew >/dev/null 2>&1; then

    #Check if brew needs Root, because I don't recall ever using sudo with brew ever!
    #And I think it's --cask for CLI Tools specifically, which is all I care about!

        PKGMNGR=(brew)

        INSTALL_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" install)
        REMOVE_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" uninstall)
        QUERY_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" list)
        QUERY_REPO=("${ROOT[@]}" "${PKGMNGR[@]}" info)

        UPDATE=("${ROOT[@]}" "${PKGMNGR[@]}" update)
        UPGRADE=("${ROOT[@]}" "${PKGMNGR[@]}" upgrade)

        DRYRUN_FLAG=(--dry-run)

        return 0

    
    elif command -v apk >/dev/null 2>&1; then 

        PKGMNGR=(apk)

        INSTALL_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" add)
        REMOVE_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" del)
        QUERY_PKG=("${PKGMNGR[@]}" info -e)
        QUERY_REPO=("${PKGMNGR[@]}" info)

        UPDATE=("${ROOT[@]}" "${PKGMNGR[@]}" update)
        UPGRADE=("${ROOT[@]}" "${PKGMNGR[@]}" upgrade)

        DRYRUN_FLAG=(--simulate)

        return 0

    ###Template for adding another Package Manager### 
    #elif command -v #package-manager >/dev/null 2>&1; then 

        #PKGMNGR=(package-manager)

        #INSTALL_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" package-manager-install_package-command)
        #REMOVE_PKG=("${ROOT[@]}" "${PKGMNGR[@]}" package-manager-remove_package-command)
        #QUERY_PKG=("${PKGMNGR[@]}" package-manager-query-installed_package-command)
        #QUERY_REPO=("${PKGMNGR[@]}" package-manager-query-repo_package-command)

        #UPDATE=("${ROOT[@]}" "${PKGMNGR[@]}" package-manager-update_package-command)
        #UPGRADE=("${ROOT[@]}" "${PKGMNGR[@]}" package-manager-upgrade_package-command)

        #DRYRUN_FLAG=(package-manager-dry-run_package-command)

        #return 0

    else 

        printf "\nError, this is an unsupported Package Manager!\n\n"
        return 2 
    
    fi


}



check_builtins(){


    local pkg="$1"
    local check=1

    command -v type -a "$pkg" >/dev/null 2>&1
    check="$?"

    check_builtin "$pkg"
    if [[ "$check" -eq 0 ]]; then

        printf "'%s' exists on your system!" "$pkg"

    else 

        printf "'%s' doesn't exist on your system!" "$pkg"

    fi

    return "$check"

}



query_pkg(){

    check_root || return "$?"
    get_pkgmgr || return "$?"

    local log_query_pkg_success=$(mktemp)
    local log_query_pkg_failure=$(mktemp)
    trap 'rm -f "$log_query_pkg_success" "$log_query_pkg_failure"' EXIT INT TERM

    local from_file=""
    local dry_run=0
    local pkgs=()

    shift
    while [ $# -gt 0 ]; do
        
        case "$1" in

            --from-file)
                from_file="$2"
                shift 2
            ;;

            -*)
                printf "Error: Invalid option: %s\n" "$1"
                return 1
            ;;

            *)
                pkgs+=("$1")
                shift
            ;;

        esac

    done


        
    #Read packages from file if given
    if [[ -n "$from_file" ]]; then
        while IFS= read -r line; do
            #Trim spaces
            line="${line#"${line%%[![:space:]]*}"}"
            line="${line%"${line##*[![:space:]]}"}"

            #Skip empty lines or comment lines
            [[ -z "$line" || "$line" =~ ^# ]] && continue

            #Split line into words and append to pkgs array
            for pkg in $line; do
                pkgs+=("$pkg")
            done
        done < "$from_file"
    fi

        
    if [ ${#pkgs[@]} -eq 0 ]; then
        
        echo "No packages specified"
        return 4
        
    fi





    for pkg in "${pkgs[@]}"; do

        "${QUERY_PKG[@]}" "$pkg" \
            && printf "Package '%s' exists\n" "$pkg" >> "$log_query_pkg_success" \
            || printf "Package '%s' not found\n" "$pkg" >> "$log_query_pkg_failure"
    
    done



    clear_space
    print_line_separater
    clear_space
    cat "$log_query_pkg_success" "$log_query_pkg_failure"
    print_line_separater
    clear_space
    rm -f "$log_query_pkg_success" "$log_query_pkg_failure"



}



query_repo(){

    check_root || return "$?"
    get_pkgmgr || return "$?"

    local log_query_repo_success=$(mktemp)
    local log_query_repo_failure=$(mktemp)
    trap 'rm -f "$log_query_repo_success" "$log_query_repo_failure"' EXIT INT TERM

    local from_file=""
    local dry_run=0
    local pkgs=()

    shift
    while [[ $# -gt 0 ]]; do
        
        case "$1" in

            --from-file)
                from_file="$2"
                shift 2
            ;;

            -*)
                printf "Error: Invalid option: %s\n" "$1"
                return 1
            ;;

            *)
                pkgs+=("$1")
                shift
            ;;

        esac

    done


        
    #Read packages from file if given
    if [[ -n "$from_file" ]]; then
        while IFS= read -r line; do
            
            #Trim spaces
            line="${line#"${line%%[![:space:]]*}"}"
            line="${line%"${line##*[![:space:]]}"}"

            #Skip empty lines or comment lines
            [[ -z "$line" || "$line" =~ ^# ]] && continue

            #Split line into words and append to pkgs array
            for pkg in $line; do
                pkgs+=("$pkg")
            done
        done < "$from_file"
    fi

        
    if [ ${#pkgs[@]} -eq 0 ]; then
        
        printf "No packages specified"
        return 4
        
    fi





    for pkg in "${pkgs[@]}"; do


        "${QUERY_REPO[@]}" "$pkg" \
            && printf "Package '%s' exists in the %s Repo\n" "$pkg" "${PKGMNGR[@]}" >> "$log_query_repo_success" \
            || printf "Package '%s' not found in the %s Repo\n" "$pkg" "${PKGMNGR[@]}" >> "$log_query_repo_failure"

        
    done



    clear_space
    print_line_separater
    clear_space
    cat "$log_query_repo_success" "$log_query_repo_failure"
    print_line_separater
    clear_space
    rm -f "$log_query_repo_success" "$log_query_repo_failure"


}


install_packages(){


    check_root || return "$?"
    get_pkgmgr || return "$?"

    local log_install_success=$(mktemp)
    local log_install_failure=$(mktemp)
    trap 'rm -f "$log_install_success" "$log_install_failure"' EXIT INT TERM

    local from_file=""
    local dry_run=0
    local pkgs=()

    shift
    while [ $# -gt 0 ]; do
        
        case "$1" in

            --from-file)
                from_file="$2"
                shift 2
            ;;

            --dry-run)
                dry_run=1
                shift
            ;;

            --) #end of flags
                shift
                break
            ;;

            -*)
                printf "Error: Invalid option: %s\n" "$1"
                return 1
            ;;

            *)
                pkgs+=("$1")
                shift
                ;;

        esac

    done


        
    #Read packages from file if given
    if [[ -n "$from_file" ]]; then
        while IFS= read -r line; do
            
            #Trim spaces
            line="${line#"${line%%[![:space:]]*}"}"
            line="${line%"${line##*[![:space:]]}"}"

            #Skip empty lines or comment lines
            [[ -z "$line" || "$line" =~ ^# ]] && continue

            #Split line into words and append to pkgs array
            for pkg in $line; do
                pkgs+=("$pkg")
            done
        done < "$from_file"
    fi



    for pkg in "${pkgs[@]}"; do

        if [[ "$dry_run" -eq 1 ]]; then
            "${INSTALL_PKG[@]}" "${DRYRUN_FLAG[@]}" "$pkg"
        fi


        if "${INSTALL_PKG[@]}" "$pkg" && printf "Package '%s' has been installed\n" "$pkg"; then

            printf "\nPackage '%s' has been installed" "$pkg" >> "$log_install_success"

        else

            printf "\nError: Package '%s' has not been installed" "$pkg" >> "$log_install_failure"
            #Find out why, use query!!!
            query_repo "$pkg"


        fi
        
    done


    clear_space
    print_line_separater
    clear_space
    cat "$log_install_success" "$log_install_failure"
    clear_space
    print_line_separater
    clear_space
    rm -f "$log_install_success" "$log_install_failure"


}



update_repo(){

    check_root
    get_pkgmgr

    "${UPDATE[@]}"


}


upgrade_packages(){

    check_root
    get_pkgmgr

    "${UPGRADE[@]}"

}


remove_packages(){


    check_root || return "$?"
    get_pkgmgr || return "$?"

    local log_remove_success=$(mktemp)
    local log_remove_failure=$(mktemp)
    trap 'rm -f "$log_remove_success" "$log_remove_failure"' EXIT INT TERM
    
    local from_file=""
    local dry_run=0
    local pkgs=()

    shift
    while [ $# -gt 0 ]; do
        
        case "$1" in

            --from-file)
                from_file="$2"
                shift 2
            ;;

            --dry-run)
                dry_run=1
                shift
            ;;

            --) #end of flags
                shift
                break
            ;;

            -*)
                printf "Error: Invalid option: %s\n" "$1"
                return 1
            ;;

            *)
                pkgs+=("$1")
                shift
                ;;

        esac

    done


        
    #Read packages from file if given
    if [[ -n "$from_file" ]]; then
        while IFS= read -r line; do
            
            #Trim spaces
            line="${line#"${line%%[![:space:]]*}"}"
            line="${line%"${line##*[![:space:]]}"}"

            #Skip empty lines or comment lines
            [[ -z "$line" || "$line" =~ ^# ]] && continue

            #Split line into words and append to pkgs array
            for pkg in $line; do
                pkgs+=("$pkg")
            done
        done < "$from_file"
    fi



    for pkg in "${pkgs[@]}"; do

        if [[ "$dry_run" -eq 1 ]]; then
            "${REMOVE_PKG[@]}" "${DRYRUN_FLAG[@]}" "$pkg"
        fi


        if "${REMOVE_PKG[@]}" "$pkg" && printf "Package '%s' has been removed\n" "$pkg"; then

            printf "\nPackage '%s' has been removed" "$pkg" >> "$log_remove_success"

        else

            printf "\nError: Package '%s' has not been removed" "$pkg" >> "$log_remove_failure"
            #Find out why, use query!!!
            query_repo "$pkg"


        fi
        
    done



    


    clear_space
    print_line_separater
    clear_space
    cat "$log_remove_success" "$log_remove_failure"
    clear_space
    print_line_separater
    clear_space
    rm -f "$log_remove_success" "$log_remove_failure"

}



usage(){


  \printf "
  Finzell's Unified Linux Kernel Package Management Resolver - a Unified Package Management Tool for Bash & zShell compatible with Linux & MacOS

  \tUsage: sc <Alias> || sc <Flag> || sc <Flag> <Alias>

  \t\t-> sc -l | Lists all saved Shortcuts allowing the User to change directory based-off the corresponding number entered in the terminal via User prompt
  \t\t-> sc -fc | Checks the existence of the Database File
  \t\t-> sc -fe | Edits the Database File using Nano, Vi, Vim, Nvim, or Emacs
  \t\t-> sc -ff | Flushes the Database File - emptying its contents, but leaving the File there
  \t\t-> sc -fd | Deletes the Database File
  \t\t-> sc -fs | Shows the Database File's entries - via Cat or Less depending on the User's Database size
  \t\t-> sc -fr | Restores the Database File's contents from an automatic backup - added safety net in the event of User error or unintended behaviour
  
  \t\t-> sc <Alias> | Will change directory to the corresponding alias in the Database File
  \t\t-> sc -c <Alias> | Creates a Shortcut to the current directory with the given Alias
  \t\t-> sc -d <Alias> | Deletes a Shortcut from the Database with the given Alias
  
  \t\tThese two functions exist for Re-installation and Uninstallation:
  \t\t\t-> sc --reinstall | Reinstalls the script again by calling the install script
  \t\t\t-> sc --uninstall | Uninstalls the program, removing the Alias' set in the .rc files, and removing the Man Page, as well as Deleting the Program Folder

  \tThere are more verbose Flag names that can viewed in the manual page via 'man sc'\n\n
  "


}



linpkg_main(){


    case "$1" in


        #if $2 is --from-file, then install from file
        --install | -i)
            install_packages "$@" || return $?
        ;;

         #if $2 is --from-file, then remove from file
        --remove | -r)
            remove_packages "$@" || return $?
        ;;

        --query-pkg | -qp)
            query_pkg "$@" || return $?
        ;;

        --query-repo | -qr)
            query_repo "$@" || return $?
        ;;

        --update)
            update_repo || return $?
        ;;

        --upgrade)
            upgrade_packages
        ;;

        --update-upgrade | -uu)
            update_repo
            upgrade_packages
        ;;

        --help | -h)
            usage
        ;;
        
        *)
            printf "Error: Invalid argument!"
            clear_space
            usage
        ;;

    esac

}



linpkg_main "$@"