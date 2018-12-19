#!/usr/bin/env  bash

#################################
#  DAGGERFALL  INSTALL  SCRIPT  #  
#################################
#  #Stages#
#  1)  Check  for  DOSBox  (abort  if  not  found)  
#  2)  Install  DOSBox  if  needed  (Fedora/Debian/openSUSE)  
#  3)  Unpack  Daggerfall  in  $HOME/DOS  (by  default)  
#  4)  Unpack  extras  (DOS32A,  view  distance  patcher,  etc.)
#  5)  Modify  dosbox.cfg  to  launch  directly  
#  6)  Extra  neat  things  
#########################################################

###############
#  VARIABLES  #
###############

DOSBox_Check=$(command  -v  dosbox)
Install_Dir=${Install_Dir:-${HOME}/DOS/}
versionNumber="v0.53"

#Just  in  case...
set  -e


###############
#  FUNCTIONS  #
###############

check_DOSBox()  {
  if  [[  -x  ${DOSBox_Check}  ]];  then
    printf  "DOSBox  has  been  found.  Continuing  with  installation...\n";  
  else
    install_DOSBox;
  fi
}

check_EUID()  {
  if  [[  ${EUID}  ==  0  ]];  then
    printf  "You  are  running  as  root.  Please  run  as  a  normal  user.  Exiting.\n";
    exit  1;
  fi
}

check_existing_install()  {
  if  [[  -d  ${Install_Dir}/DAGGER/  ]];  then
    printf  "Daggerfall  installation  already  found.  Would  you  like  to  overwrite?  [y/N]  ";  read  -r  answerYN
      case  "${answerYN}"  in
        Y|y)
          return
          ;;
        N|n|"")
          printf  "Installation  cancelled.  Exiting.\n";
          exit  1
          ;;
        *)
          printf  "Not  an  accepted  option.  Exiting.\n";
          exit  1
          ;;
      esac
  fi
}

install_DOSBox()  {
  if  [[  $(command  -v  zypper)  ]];  then
    printf  "OpenSUSE/SUSE  based  distribution  found.  Installing  via  zypper.  You  may  be  asked  for  your  password...\n";
    sudo  zypper  install  dosbox;
  elif  [[  $(command  -v  apt-get)  ]];  then
    printf  "Ubuntu/Debian  based  distribution  found.  Installing  via  apt-get.  You  may  be  asked  for  your  password...\n";
    sudo  apt-get  install  dosbox;
  elif  [[  $(command  -v  yum)  ]];  then
    printf  "Fedora/Red  Hat  based  distribution  found.  Installing  via  yum.  You  may  be  asked  for  your  password...\n";
    sudo  yum  install  dosbox;
  fi
}

install_Directory()  {
  printf  "The  install  directory  will  be  %s.  Is  this  OK?  [Y/n]  "  "${Install_Dir}";  read  -r  answerYN
    case  ${answerYN}  in
      Y|y|"")
        mkdir  -p  "${Install_Dir}"
        ;;
      N|n)
        printf  "Where  would  you  like  it  installed,  then?  (somewhere  in  %s/  recommended)  "  "${HOME}";  read  -r  Install_Dir;
        mkdir  -p  "${Install_Dir}"
        ;;
      *)
        printf  "Not  an  accepted  option.  Exiting.\n";
        exit  1
        ;;
    esac
}

install_Daggerfall_original()  {
  mkdir  -p  "${HOME}"/.config/Daggerfall/;
  printf  "%s"  "${Install_Dir}"  >  "${HOME}"/.config/dagger_install_dir;
  printf  "Unpacking  Daggerfall  (Original)...\n";
  tar  -C  "${Install_Dir}"  -xf  dagger_original.tgz;
}

install_Daggerfall_patched()  {
  mkdir  -p  "${HOME}"/.config/Daggerfall/;
  printf  "Unpacking  Daggerfall...\n";
  printf  "%s"  "${Install_Dir}"  >  "${HOME}"/.config/Daggerfall/dagger_install_dir;
  tar  -C  "${Install_Dir}"  -xf  dagger_original.tgz;
  cp  DOS32A.EXE  "${Install_Dir}"/DAGGER/  &&  printf  "DOS32A  copied...\n";
  #Install  additional  patches  in  order  from  oldest  to  newest
  cp  Q0C00Y03/Q0C00Y03.{QBN,QRC}  "${Install_Dir}"/DAGGER/ARENA2/  &&  printf  "Q0C00Y03  quest  patch  (by  GhanBuriGhan)  applied...\n";
  cp  fixqs001/*  "${Install_Dir}"/DAGGER/ARENA2/  &&  printf  "'fixqs001'  quest  patches  (by  Donald  Tipton)  applied...\n";
  cp  SPELLS/SPELLS.STD  "${Install_Dir}"/DAGGER/ARENA2/  &&  printf  "SPELLS.STD  fix  (by  Nwart)  applied...\n";
  cp  FACTFIX/FACTION.TXT  "${Install_Dir}"/DAGGER/ARENA2/  &&  printf  "FACTIONFIX  (by  PLRDLF)  applied...\n";
  cp  POLITIC/POLITIC.PAK  "${Install_Dir}"/DAGGER/ARENA2/  &&  printf  "POLITIC.PAK  fix  (by  Uniblab)  applied...\n";
  cp  Dark-elves/{TEXTURE.346,FACES.CIF}  "${Install_Dir}"/DAGGER/ARENA2/  &&  printf  "Wayrest  Dark  elves  fix  (by  Andy  Polis  and  DelphiSnake)  applied...\n";
  cp  HACKFALL/*  "${Install_Dir}"/DAGGER/ARENA2/  &&  printf  "HackFall  fixes  (by  DelphiSnake)  applied...\n";
  cp  DFGRAFIX/*  "${Install_Dir}"/DAGGER/ARENA2/  &&  printf  "Graphics  fixes  (by  MrFlibble)  applied...\n";
  mv  "${Install_Dir}"/DAGGER/ARENA2/{P0B1XL08,P0B10L08}.QBN  &&  printf  "'A  Test  of  Determination'  quest  fix  (by  Ancestral  Ghost)  applied...\n";
  cp  DFQFIX/*  "${Install_Dir}"/DAGGER/ARENA2/  &&  printf  "Most  recent  quest  patches  as  of  October  06,  2016  (by  PLRDLF)  applied...\n";
  cp  DFBIOFIX/*.TXT  "${Install_Dir}"/DAGGER/ARENA2/  &&  printf  "Biography  file  fixes  (by  DeepFighter)  applied...\n";
  cp  -r  README/  "${Install_Dir}"/DAGGER/  &&  printf  "Patch  documentation  copied  to  %sDAGGER/README\n"  "${Install_Dir}";
}

install_Daggerfall_icon()  {
  cp  "TES_Daggerfall.desktop"  "${HOME}"/Desktop/  &&  printf  "Desktop  shortcut  created...\n";
  cp  "dagger_icon.png"  "${HOME}"/.config/Daggerfall/;
  printf  "Exec=dosbox  -conf  %s/.config/Daggerfall/dagger.conf\n"  "${HOME}"  >>  "${HOME}"/Desktop/TES_Daggerfall.desktop;
  printf  "Icon=%s/.config/Daggerfall/dagger_icon.png"  "${HOME}"  >>  "${HOME}"/Desktop/TES_Daggerfall.desktop;
  chmod  700  "${HOME}"/Desktop/TES_Daggerfall.desktop
}

install_Pirates()  {
  if  [[  -d  ${Install_Dir}/DAGGER/  ]];  then  
    cp  PIRATES/{FALL.EXE,ReadMe.doc,Pirates.gif}  "${Install_Dir}"DAGGER/  &&  printf  "Pirates  of  Tamriel  (modified  FALL.EXE)  and  documentation  copied...\n";
    cp  PIRATES/*  "${Install_Dir}"DAGGER/ARENA2/  &&  printf  "Character  classes,  quests,  sounds,  and  text  copied...\n";
    printf  "Pirates  of  Tamriel  installed  successfully!  Launch  the  game  as  you  normally  would.\n"
  else
    printf  "Daggerfall  installation  not  found!  Exiting.\n";
    exit  1;
  fi
}

modify_DOSBox_conf()  {
  mkdir  -p  "${HOME}"/bin/;
  cp  dagger.conf  "${HOME}"/.config/Daggerfall/;
  printf  "@echo  off\nmount  c  %s  -freesize  600\nC:\ncd  dagger\nfall.bat"  "${Install_Dir}"  >>  "${HOME}"/.config/Daggerfall/dagger.conf;
  sed  -i  's/core=auto/core=normal/'  "${HOME}"/.config/Daggerfall/dagger.conf;
  sed  -i  's/aspect=false/aspect=true/'  "${HOME}"/.config/Daggerfall/dagger.conf;
  sed  -i  's/memsize=16/memsize=24/'  "${HOME}"/.config/Daggerfall/dagger.conf;
  printf  "dosbox  -conf  %s/.config/Daggerfall/dagger.conf"  "${HOME}"  >  "${HOME}"/bin/Daggerfall;
  chmod  755  "${HOME}/bin/Daggerfall"
  if  [[  -e  "${Install_Dir}/DAGGER/DOS32A.EXE"  ]];  then
    sed  -i  's/^fall\.exe\  z\.cfg/dos32a\.exe\  fall\.exe\  z\.cfg/'  "${Install_Dir}"/DAGGER/FALL.BAT  &&  printf  "DOS32A  implemented...\n";  
  fi
  printf "\nexit" >> "${Install_Dir}"/DAGGER/FALL.BAT
}

run_Instructions()  {
  printf  "\n***  Install  process  appears  to  have  completed  successfully.  Launch  using  the  desktop  shortcut,  or  by  executing  the  command  \"sh  ~/bin/Daggerfall\"  from  a  terminal.  ***\n";
}

uninstall_Daggerfall()  {
  printf  "Are  you  sure  you  want  to  uninstall  Daggerfall?  You will have an option to keep your saved games.  [y/N]  ";  read  -r  answerYN
    case  ${answerYN}  in
      Y|y)
        if  [[  -e  "${HOME}"/.config/Daggerfall/dagger_install_dir  ]];  then
          Install_Dir=$(cat  "${HOME}"/.config/Daggerfall/dagger_install_dir);
          printf  "Would  you  like  to  keep  your  saved  games?  [Y/n]  ";  read  -r  answerYN
            case  ${answerYN}  in
              Y|y|"")
		rm -rf ${Install_Dir}/DAGGER/{ARENA2,DATA,README}
		find ${Install_Dir}/DAGGER/ -type f -maxdepth 1 -exec rm -vf {} \;
#                rm  -rf  "${Install_Dir}/DAGGER/ARENA2/"  &&  printf  "Daggerfall  removed...\n";
		printf  "Daggerfall  removed...\n";
                rm  -vf  "${HOME}"/{bin/Daggerfall,.config/Daggerfall/{dagger.conf,dagger_icon.png,dagger_install_dir}}  &&  printf  "Daggerfall  configuration  removed...\n";
                rm  -vf  "${HOME}"/Desktop/TES_Daggerfall.desktop;
                rm  -f  "${HOME}"/.config/dagger_install_dir;
                rm  -rf  "${HOME}"/.config/Daggerfall
# Here
	    esac	
        elif  [[  -e  "${HOME}"/.config/dagger_install_dir  ]];  then
          Install_Dir=$(cat  "${HOME}"/.config/dagger_install_dir);
          rm  -rf  "${Install_Dir}/DAGGER"  &&  printf  "Daggerfall  removed...\n";
          rm  -vf  "${HOME}"/{bin/Daggerfall,.config/Daggerfall/{dagger.conf,dagger_icon.png,dagger_install_dir}}  &&  printf  "Daggerfall  configuration  removed...\n";
          rm  -vf  "${HOME}"/Desktop/TES_Daggerfall.desktop;
          rm  -f  "${HOME}"/.config/dagger_install_dir;
          rm  -rf  "${HOME}"/.config/Daggerfall
        else
          printf  "Daggerfall  install  not  found!  Exiting.  \n";
          exit  1
        fi
        ;;
      N|n|"")
        printf  "Exiting\n";  
        return
        ;;
      *)
        printf  "Not  an  accepted  option.  Exiting.\n";
        exit  1
        ;;
    esac
}

uninstall_DOSBox_and_Daggerfall()  {
  printf  "Are  you  sure  you  want  to  uninstall  DOSBox  and  Daggerfall?  All  saved  games  and  configuration  files  will  be  removed.  [y/N]  ";  read  -r  answerYN
  case  ${answerYN}  in
    Y|y)
      printf  "Removing  DOSBox...\n";
      if  [[  $(command  -v  apt-get)  ]];  then
        sudo  apt-get  remove  dosbox;
      elif  [[  $(command  -v  yum)  ]];  then
        sudo  yum  remove  dosbox;
      elif  [[  $(command  -v  zypper)  ]];  then
        sudo  zypper  remove  dosbox;
      fi
      uninstall_Daggerfall
      ;;
    N|n|"")
      printf  "Exiting\n";  
      return
      ;;
    *)
      printf  "Not  an  accepted  option.  Exiting.\n";
      exit  1
      ;;
    esac
}

viewbased_Control()  {
  printf  "Would  you  like  a  more  modern  WASD/Mouselook  control  scheme  set  up  by  default?  [Y/n]  ";  read  -r  answerYN
  case  ${answerYN}  in
    Y|y|"")
#      mv  "${Install_Dir}"/DAGGER/ARENA2/VIEWPLYR.{DAT,Original};
#      cp  VIEWPLYR.DAT  "${Install_Dir}"/DAGGER/ARENA2/;
      sed  -i  's/betaplyr.dat/viewplyr.dat/'  "${Install_Dir}"/DAGGER/Z.CFG  &&  printf  "WASD/Mouselook  control  scheme  applied\n"
      ;;
    N|n)
      return
      ;;
    *)
      printf  "Not  an  accepted  option.  Exiting.\n";
      exit  1
    ;;
  esac
}


##########
#  MAIN  #
##########

check_EUID;
printf  "***  Daggerfall  Installer  for  Linux  (%s)  ***\n"  "${versionNumber}";
printf  "Please  make  your  selection:  \n\
1)  Install  DOSBox  and  Daggerfall  (fully  patched)  -  **RECOMMENDED**  \n\
2)  Install  DOSBox  and  Daggerfall  (original  1.07.213  w/  NoCD)\n\
3)  Install  Daggerfall  files  ONLY  (fully  patched)\n\
4)  Install  Daggerfall  files  ONLY  (original  1.07.213  w/  NoCD)\n\
5)  Install  Pirates  of  Tamriel  mod  (*WARNING*  -  Overwrites  original  Daggerfall  install)\n\
6)  Uninstall  Daggerfall\n\
7)  Uninstall  DOSBox  and  Daggerfall\n\
8)  Exit\n\
Selection:  ";  read  -r  SELECTION
  case  ${SELECTION}  in
    1)  
      check_DOSBox;
      install_Directory;
      check_existing_install;
      install_Daggerfall_patched;
      modify_DOSBox_conf;
      install_Daggerfall_icon;
      viewbased_Control;
      run_Instructions
      ;;
    2)
      check_DOSBox;
      install_Directory;
      check_existing_install;
      install_Daggerfall_original;
      modify_DOSBox_conf;
      install_Daggerfall_icon;
      viewbased_Control;
      run_Instructions
      ;;
    3)
      check_existing_install;
      install_Directory;
      install_Daggerfall_patched
      ;;
    4)
      check_existing_install;
      install_Directory;
      install_Daggerfall_original
      ;;
    5)  
      install_Pirates
      ;;
    6)
      uninstall_Daggerfall
      ;;
    7)
      uninstall_DOSBox_and_Daggerfall
      ;;
    8)
      exit 0
      ;;
  esac  
  
#######
# END #
#######
