# TES-tools
Tools for TES: Arena and Daggerfall that I wrote for fun and/or convenience. The older Elder Scrolls (© 1993-2015 Bethesda Softworks LLC) games seemed to be lacking in Linux support, so these scripts are intended to help in that regard.


## arena_install.sh
This is a makeself script for the installation of The Elder Scrolls I: Arena. To create the self-extracting shell script:

Place the Arena archive and arena.sh in the same directory ("\~/project/files" in this example). Make sure "arena_install.sh" is executable.
From "\~/project", execute the following: 
```makeself files/ arenaInstaller.sh "Arena Installer for Linux" ./arena_install.sh```

You should now have an executable, self-extracting archive called "arenaInstaller.sh"

## dagger.sh
###### -Needs revision-
This is a makeself script for the installation of The Elder Scrolls II: Daggerfall. To create the self-extracting shell script:

Place the Daggerfall archive and dagger.sh in the same directory (" ~/project/files" in this example). Make sure "dagger.sh" is executable.
From "\~/project", execute the following: 
```makeself files/ daggerInstall.sh "Daggerfall Installer for Linux" ./dfsetup.sh```

You should now have an executable, self-extracting archive called "daggerInstall.sh"
