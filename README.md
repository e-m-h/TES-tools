# TES-tools 
Tools for TES: Arena and Daggerfall that I wrote for fun and/or convenience. The older Elder Scrolls (© Microsoft) games were lacking in Linux support, so these scripts are intended to help in that regard.


## ArenaInstaller.sh
This is a makeself archive that will install DOSBox (if necessary), download the Arena game files from Bethesda, and set up the DOSBox configuration as well as a desktop icon (if desired). It is completely self-contained and can be used on its own just by following the instructions directly below. 

### To install, execute the following (assuming `ArenaInstaller.sh` is in the user's "Downloads" directory):
```
chmod 755 ~/Downloads/ArenaInstaller.sh
sh ~/Downloads/ArenaInstaller.sh
```

<sub>Icon by blakegedye on DeviantArt - will be removed if requested by the original author</sub>

## arena_install.sh 
This is the makeself script for the installation of The Elder Scrolls I: Arena (used in the above `ArenaInstaller.sh`. To create the self-extracting shell script:

1. Place the necessary files (looks for `arena.conf` DOSBox config and a `*.png` icon) and arena_install.sh in the same directory (`~/project/files` in this example). 
2. Make sure `arena_install.sh` is executable: `chmod 755 arena_install.sh`
3. From `~/project`, execute the following: `makeself files/ ArenaInstaller.sh "Arena Installer for Linux" ./arena_install.sh`

You should now have an executable, self-extracting archive called `ArenaInstaller.sh`.

## dagger.sh
This is a makeself script for the installation of The Elder Scrolls II: Daggerfall. To create the self-extracting shell script:

1. Place the Daggerfall archive and `dagger.sh` in the same directory (`~/project/files` in this example). 
2. Make sure `dagger.sh` is executable. `chmod 755 dagger.sh`
3. From `~/project`, execute the following: `makeself files/ daggerInstall.sh "Daggerfall Installer for Linux" ./dfsetup.sh`

You should now have an executable, self-extracting archive called `daggerInstall.sh`.
