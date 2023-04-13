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

INSTALL_DIR=${INSTALL_DIR:-${HOME}/DOS/}
ARENA_URL="https://cdnstatic.bethsoft.com/elderscrolls.com/assets/files/tes/extras/Arena106Setup.zip"
#ARENA_URL="/home/eric/projects/test/Arena106Setup.zip"
VERSION="v0.6"

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
  if [[ -d ${INSTALL_DIR}/ARENA/ ]]; then
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
  printf "The install directory will be %s. Is this OK? [Y/n] " "${INSTALL_DIR}"; read -r answerYN
    case ${answerYN} in
      Y|y|"")
        mkdir -p "${INSTALL_DIR}"
        ;;
      N|n)
        printf "Where would you like it installed, then? (somewhere in %s/ recommended) " "${HOME}"; read -r INSTALL_DIR;
        mkdir -p "${INSTALL_DIR}"
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
    wget ${ARENA_URL} -O "${INSTALL_DIR}"Arena106Setup.zip
    #cp ${ARENA_URL} "${INSTALL_DIR}"
    printf "Unpacking  Arena...\n";
    printf "%s" "${INSTALL_DIR}" > "${HOME}"/.config/Arena/arena_install_directory;
    unzip "${INSTALL_DIR}/Arena106Setup.zip" -d "${INSTALL_DIR}"
    unrar x "${INSTALL_DIR}/Arena106.exe" "${INSTALL_DIR}"
    printf "Removing installation files...\n";
    rm -vf "${INSTALL_DIR}"Arena106.exe;
    rm -vf "${INSTALL_DIR}"Arena106Setup.zip;
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
  find "${HOME}"/.config/dosbox/ -iname "dosbox*.conf" -exec cp {} "${HOME}"/.config/Arena/arena.conf \; 2>/dev/null
  if [[ $(dosbox -version | head -n1 | cut -f1 -d,) == 'dosbox-staging' ]]; then
    printf "@echo off\nmount c %s -freesize 600\nC:\ncd arena\narena.bat" "${INSTALL_DIR}" >> "${HOME}"/.config/Arena/arena.conf;
    sed -i 's/core      = auto/core      = dynamic/' "${HOME}"/.config/Arena/arena.conf;
    sed -i 's/aspect             = false/aspect             = true/' "${HOME}"/.config/Arena/arena.conf;
    sed -i 's/output              = surface/output              = openglpp/' "${HOME}"/.config/Arena/arena.conf;
    sed -i 's/cycles    = auto/cycles    = max limit 50000/' "${HOME}"/.config/Arena/arena.conf;
    sed -i 's/memsize            = 16/memsize            = 32/' "${HOME}"/.config/Arena/arena.conf;
  else
    printf "@echo off\nmount c %s -freesize 600\nC:\ncd arena\narena.bat" "${Install_Dir}" >> "${HOME}"/.config/Arena/arena.conf;
    sed -i 's/core=auto/core=dynamic/' "${HOME}"/.config/Arena/arena.conf;
    sed -i 's/aspect=false/aspect=true/' "${HOME}"/.config/Arena/arena.conf;
    sed -i 's/autolock=false/autolock=true/' "${HOME}"/.config/Arena/arena.conf;
    sed -i 's/output=surface/output=overlay/' "${HOME}"/.config/Arena/arena.conf;
    sed -i 's/cycles=auto/cycles=max limit 50000/' "${HOME}"/.config/Arena/arena.conf;
    sed -i 's/windowresolution=original/windowresolution=1024x768/' "${HOME}"/.config/Arena/arena.conf;
    sed -i 's/memsize=16/memsize=32/' "${HOME}"/.config/Arena/arena.conf;
  fi
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
        if [[ -e "${HOME}"/.config/Arena/arena_install_directory ]]; then
          INSTALL_DIR=$(cat "${HOME}"/.config/Arena/arena_install_directory);
          rm -rf "${INSTALL_DIR}/ARENA" && printf "Arena removed...\n";
          rm -vf "${HOME}"/{bin/Arena,.config/Arena/{arena.conf,arena_icon.png,arena_install_directory}} && printf "Arena configuration removed...\n";
          rm -vf "$(xdg-user-dir DESKTOP)"/TES_Arena.desktop;
          rm -f "${HOME}"/.config/arena_install_directory;
          rm -rf "${HOME}"/.config/Arena
        elif [[ -e "${HOME}"/.config/arena_install_directory ]]; then
          INSTALL_DIR=$(cat "${HOME}"/.config/arena_install_directory);
          rm -rf "${INSTALL_DIR}/ARENA" && printf "Arena removed...\n";
          rm -vf "${HOME}"/{bin/Arena,.config/Arena/{arena.conf,arena_icon.png,arena_install_directory}} && printf "Arena configuration removed...\n";
          rm -vf "$(xdg-user-dir DESKTOP)"/TES_Arena.desktop;
          rm -f "${HOME}"/.config/arena_install_directory;
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
printf "*** Arena Installer for Linux (%s) ***\n" "${VERSION}";
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
