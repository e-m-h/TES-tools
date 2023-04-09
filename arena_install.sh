#!/usr/bin/env bash

##########################
#  ARENA INSTALL SCRIPT  #  
##########################
#  #Stages#
#  1)  Check  for  DOSBox  (abort  if  not  found)  
#  2)  Install  DOSBox  if  needed  (Fedora/Debian/openSUSE)  
#  3)  Unpack  Arena  in  $HOME/DOS  (by  default)  
#  4)  Modify  dosbox.cfg  to  launch  directly  
#  5)  Extra  neat  things  
#########################################################

#################
#   VARIABLES   #
#################

Install_Dir=${Install_Dir:-${HOME}/DOS/}
ArenaURL="https://cdnstatic.bethsoft.com/elderscrolls.com/assets/files/tes/extras/Arena106Setup.zip"
versionNumber="v0.5"

set -e


#################
#   FUNCTIONS   #
#################

check_DOSBox() {
  if [[ -x $(command -v dosbox) ]]; then
    printf "DOSBox has been found. Continuing with installation...\n";  
  else
    install_DOSBox;
  fi
}

check_EUID() {
  if [[ ${EUID} == 0 ]];  then
    printf "You are running as root. Please run  as  a  normal  user.  Exiting.\n";
    exit 1;
  fi
}

check_existing_install() {
  if [[ -d ${Install_Dir}/ARENA/ ]]; then
    printf "Arena installation already found. Would you like to overwrite? [y/N] "; read -r answerYN
      case "${answerYN}" in
        Y|y)
          return
          ;;
        N|n|"")
          printf "Installation cancelled. Exiting.\n";
          exit 1
          ;;
        *)
          printf "Not an accepted option. Exiting.\n";
          exit 1
          ;;
      esac
  fi
}

install_DOSBox() {
  if [[ $(command -v apt-get) ]]; then
    printf "Ubuntu/Debian based distribution found. Installing via apt-get. You may be asked for your password...\n";
    sudo apt-get install dosbox;
  elif [[ $(command -v yum) ]]; then
    printf "Fedora/Red Hat based distribution found. Installing via yum. You may be asked for your password...\n";
    sudo yum install dosbox;
  elif [[ $(command -v zypper) ]]; then
    printf "OpenSUSE/SUSE based distribution found. Installing via zypper. You may be asked for your password...\n";
    sudo zypper install dosbox;
  fi
}

install_Directory() {
  printf "The install directory will be %s. Is this OK? [Y/n] " "${Install_Dir}"; read -r answerYN
    case ${answerYN} in
      Y|y|"")
        mkdir -p "${Install_Dir}"
        ;;
      N|n)
        printf "Where would you like it installed, then? (somewhere in %s/ recommended) " "${HOME}"; read -r Install_Dir;
        mkdir -p "${Install_Dir}"
        ;;
      *)
        printf "Not an accepted option. Exiting.\n";
        exit 1
        ;;
    esac
}

install_Arena() {
  if [[ $(command -v unzip) && $(command -v unrar) ]]; then
    mkdir -p "${HOME}"/.config/Arena/;
    printf "Downloading Arena...\n";
    wget ${ArenaURL} -O "${Install_Dir}"Arena106Setup.zip
    printf "Unpacking  Arena...\n";
    printf "%s" "${Install_Dir}" > "${HOME}"/.config/Arena/arena_install_dir;
    unzip "${Install_Dir}/Arena106Setup.zip" -d "${Install_Dir}"
    unrar x "${Install_Dir}/Arena106.exe" "${Install_Dir}"
    printf "Removing installation files...\n";
    rm -vf "${Install_Dir}"Arena106.exe;
    rm -vf "${Install_Dir}"Arena106Setup.zip;
  else
    printf "Both 'unzip' and 'unrar' utilities are required. Please make sure both are installed. Exiting...\n"
    exit 1
  fi 
}

install_Arena_icon() {
  cp "TES_Arena.desktop" "$(xdg-user-dir DESKTOP)"/ && printf "Desktop shortcut created...\n";
  cp "arena_icon.png" "${HOME}"/.config/Arena/;
  printf "Exec=dosbox -conf %s/.config/Arena/arena.conf\n" "${HOME}" >> "$(xdg-user-dir DESKTOP)"/TES_Arena.desktop;
  printf "Icon=%s/.config/Arena/arena_icon.png" "${HOME}" >> "$(xdg-user-dir DESKTOP)"/TES_Arena.desktop;
  chmod 700 "$(xdg-user-dir DESKTOP)"/TES_Arena.desktop
}

modify_DOSBox_conf() {
  mkdir -p "${HOME}"/bin/;
  cp arena.conf "${HOME}"/.config/Arena/;
  printf "@echo off\nmount c %s -freesize 600\nC:\ncd arena\narena.bat" "${Install_Dir}" >> "${HOME}"/.config/Arena/arena.conf;
  sed -i 's/core=auto/core=dynamic/' "${HOME}"/.config/Arena/arena.conf;
  sed -i 's/aspect=false/aspect=true/' "${HOME}"/.config/Arena/arena.conf;
  sed -i 's/autolock=false/autolock=true/' "${HOME}"/.config/Arena/arena.conf;
  sed -i 's/output=surface/output=overlay/' "${HOME}"/.config/Arena/arena.conf;
  sed -i 's/cycles=auto/cycles=max limit 50000/' "${HOME}"/.config/Arena/arena.conf;
  sed -i 's/windowresolution=original/windowresolution=1024x768/' "${HOME}"/.config/Arena/arena.conf;
#  sed -i 's/memsize=16/memsize=24/' "${HOME}"/.config/Arena/arena.conf;
  printf "dosbox -conf %s/.config/Arena/arena.conf" "${HOME}" > "${HOME}"/bin/Arena;
  chmod 755 "${HOME}/bin/Arena"
}

run_Instructions() {
  printf "\n*** Install process appears to have completed successfully. Launch using the desktop shortcut, or by executing the command \"sh ~/bin/Arena\" from a terminal. ***\n";
}

uninstall_Arena() {
  printf "Are you sure you want to uninstall Arena? All saved games and configuration files will be removed. [y/N] "; read -r answerYN
    case ${answerYN} in
      Y|y)
        if [[ -e "${HOME}"/.config/Arena/arena_install_dir ]]; then
          Install_Dir=$(cat "${HOME}"/.config/Arena/arena_install_dir);
          rm -rf "${Install_Dir}/ARENA" && printf "Arena removed...\n";
          rm -vf "${HOME}"/{bin/Arena,.config/Arena/{arena.conf,arena_icon.png,arena_install_dir}} && printf "Arena configuration removed...\n";
          rm -vf "$(xdg-user-dir DESKTOP)"/TES_Arena.desktop;
          rm -f "${HOME}"/.config/arena_install_dir;
          rm -rf "${HOME}"/.config/Arena
        elif [[ -e "${HOME}"/.config/arena_install_dir ]]; then
          Install_Dir=$(cat "${HOME}"/.config/arena_install_dir);
          rm -rf "${Install_Dir}/ARENA" && printf "Arena removed...\n";
          rm -vf "${HOME}"/{bin/Arena,.config/Arena/{arena.conf,arena_icon.png,arena_install_dir}} && printf "Arena configuration removed...\n";
          rm -vf "$(xdg-user-dir DESKTOP)"/TES_Arena.desktop;
          rm -f "${HOME}"/.config/arena_install_dir;
          rm -rf "${HOME}"/.config/Arena
        else
          printf "Arena install not found! Exiting. \n";
          exit 1
        fi
        ;;
      N|n|"")
        printf "Exiting\n";  
        return
        ;;
      *)
        printf "Not an accepted option. Exiting.\n";
        exit 1
        ;;
    esac
}

uninstall_DOSBox_and_Arena() {
  printf "Are you sure you want to uninstall DOSBox and Arena? All saved games and configuration files will be removed. [y/N] "; read -r answerYN
  case ${answerYN} in
    Y|y)
      printf "Removing DOSBox...\n";
      if [[ $(command -v apt-get) ]]; then
        sudo apt-get remove dosbox;
      elif [[ $(command -v yum) ]]; then
        sudo yum remove dosbox;
      elif [[ $(command -v zypper) ]]; then
        sudo zypper remove dosbox;
      fi
      uninstall_Arena
      ;;
    N|n|"")
      printf "Exiting\n";  
      return
      ;;
    *)
      printf "Not an accepted option. Exiting.\n";
      exit 1
      ;;
    esac
}

############
#   MAIN   #
############

check_EUID;
printf "*** Arena Installer for Linux (%s) ***\n" "${versionNumber}";
printf "Please make your selection: \n\
1) Install DOSBox and Arena\n\
2) Install Arena files ONLY\n\
3) Uninstall Arena\n\
4) Uninstall DOSBox and Arena\n\
5) Exit\n\
Selection: "; read -r SELECTION
  case ${SELECTION} in
    1)  
      check_DOSBox;
      install_Directory;
      check_existing_install;
      install_Arena;
      modify_DOSBox_conf;
#      install_Arena_icon;
      run_Instructions
      ;;
    2)
      check_existing_install;
      install_Directory;
      install_Arena
      ;;
    3)
      uninstall_Arena
      ;;
    4)
      uninstall_DOSBox_and_Arena
      ;;
    5)
      exit  0
      ;;
    *)
      printf "Not an accepted option. Exiting.\n";
      exit
      ;;
  esac  
  
#######
# END #
#######
