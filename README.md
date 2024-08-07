# Shell script collection

Useful scripts for unix like systems mostly for developers

## Usage

### Install script

with wget:

```shell
wget -q -O- "https://majk1.github.io/shellrc/installer.sh" | bash -s -- -u
```

with curl:

```shell
curl -L -s -o- "https://majk1.github.io/shellrc/installer.sh" | bash -s -- -u
```

for silent install use -su parameter instad of -u

### Upgrade / reinstall

just type:

```shell
update-shellrc
```

### List latest version

with wget:

```shell
wget -q -O- "https://majk1.github.io/shellrc/installer.sh" | bash -s -- -a
```

with curl:

```shell
curl -L -s -o- "https://majk1.github.io/shellrc/installer.sh" | bash -s -- -a
```

### Using git repo

#### clone repository

```shell
git clone https://github.com/majk1/shellrc.git
```

#### source shellrc.sh  

```shell
source ~/scripts/shellrc.sh
```

## Changelog

- **1.7.27**  
  FZF ALT_C and COMPLETION_TRIGGER has been added  
  zsh added `complete aliases`  
  `ffmpeg-to-stereo`: improved
  imporved `.vimrc` and added `config.nvim` into `rc` files (link this directory to `~/.config/nvim`)

- **1.7.26**  
  python3 version for `urlencode`, `urldecode`, `millis` and `nanos`  
  `ffmpeg-to-stereo`: added metadata support and additional parameters  
  java: Added version 16 and 18, changed default to version 17  
  darwin: Added `psgrep`, and initial version of `reminders`  

- **1.7.25**  
  Added macos battery logger script  
  Added macos `free` command replacement (memory status)  
  Added homebrew specific bash completion  
  Added more JDK pattern to find appropriate version
  Added auto-clone for `z`  
  Added Viscosity VPN control command line functions  
  Removed directory restriction for jdk path to enable the use of symlinks  
  zsh source order fix and other completion fixes  

- **1.7.24**  
  added `uibuilder` function to generate [UIBuilder](https://uibuilder.devbench.io) project  
  ffmpeg utils stereo downmix fix  
  added `mkvMergeSub` `--no-conv` parameter to skip subtitle UTF-8 conversion  
  removed jdk 10 and 12 alias, added jdk 17  

- **1.7.23**  
  fixed `installer.sh`  
  added lastX aliases  

- **1.7.22**  
  added GraalVM 21  
  added zsh command line syntax highlighting

- **1.7.21**  
  added fzf loading and default env variables
  
- **1.7.20**  
  fixed `mvn` code completion indirect variable expansion shell incompatibility (bash supported `${!var}` has been replaced to use eval instead of zsh supported `${(P)var}`)  
  added `mvn` javadoc and source skip completion

- **1.7.19**  
  zsh bindkey for *bash style* backward kill word for `ctrl+e`  
  zsh added `-u` to compinit to ignore insecure directories (SHOULD BE FIXED INSTEAD)  
  added `airport` alias for macos  
  `brew` completion cache is disabled for other shell than bash  
  `pip` completion fix

- **1.7.18**  
  fix for java8 selection alias (graalvm was selected if it was present, instead of openjdk)  
  history size has been set to unlimited for all shells  
  bash-completion for `mvn` fix to be able to use in zsh as well  

- **1.7.17**  
  brew completion fix

- **1.7.16**  
  added `ij-config-hide-py-scientific-toolwindow` function to hide py scientific toolwindow  
  added `brew` bash completion cache (this makes the first command completion a lot faster)  
  added `to-monospace` command, which is a script that creates a monospaced RTF version of the input parameter  
  added GraalVM support (*alias and home*)  
  added `java_list` alias to list currently installed JVMs  

- **1.7.15**  
  added `git-merge-master` function which will fetch with `-p` and run `git merge origin/master`  
  added `--no-sub` option to the `ffmpeg-to-stereo`  
  added `adoptopenjdk` support to the java version switcher  

- **1.7.14**  
  added `mvn` bash completion  
  added `ffmpeg-utils` bash completion (`ffmpeg-info` `ffmpeg-to-stereo` `mkvMergeSub`)  
  `to-stereo` renamed to `ffmpeg-utils` and added `ffmpeg-info` function  
  added bash completion source directory `usr/local/etc/bash_completion`  
  commented out default `MAVEN_OPTS`, use project specific `.mvn/jvm.config` and `.mvn/maven.config` instead  

- **1.7.13**  
  `dupli.py` shebang python version fix (python3)  
  `installer.sh` bugfix #8  
  `rc/inputrc` now includes key binding to support alt+left/right in IntelliJ IDEA on mac os  

- **1.7.12**  
  bugfix #8 - cannot update bug - version number > 9  
  added default env for `docker-env`  and `--clear` attribute to remove env vars  

- **1.7.11**  
  added java (jdk) 11 support  
  renamed `mvn_gen_pom` to `mvn-gen-pom`   

- **1.7.10**  
  fixed `currency-exchange` source URL changed to HTTPS only  
  added `ffmpeg-to-stereo` function to generate dolby stereo video files from 5.1 or 7.1 channel,
  producing higher volume during speak and lower volume during action and music  
  added `mvn_gen_pom` function to generate maven pom.xml template

- **1.7.9**  
  added `dupli.py` as alias for `dupli` (script to find and list duplicate files)  
  added `to_stereo.sh` alternative ffmpeg parameteres (*still in comment, not a real util*)  
  added *backward-kill-word* as **ctrl+e**  

- **1.7.8**  
  fixed java_home for 9 and 10, default java is now java 10  

- **1.7.7**  
  alias `toUTF8` has been removed  
  added `git-pull` function in git.sh  
  function `wildfly-pid` has been optimized (implementation with awk)  
  added `format-number` command to format numbers to humand readable form (and added into `currency-exchange`)  
  added `netinfo` (*macos only*) command to query system network interface informations  
  added `unicode` command to (*download the list and*) search for unicode symbol by keywords given as argumemts:  
  ^- example: `unicode black circle`  
  command `mvn-search version` now supports combined parameter by version request and
  for also for flags, like: `mvn-search -1 v org.projectlombok:lombok` or `mvn-search -n1 s lombok`  

- **1.7.6**  
  added `mvn-search` util script  
  renamed mvnCleaner to mvn-cleaner  

- **1.7.5**  
  added `dus` function into core.sh (sorted du: *du -sh "$@" | sort -h*)  
  added `hr` function into core.sh (prints a horizontal separator line)  
  added `currency-exchange` util script  

- **1.7.4**  
  added `pip` command bash completion  
  added and linked ipv6-utils.sh with functions: `ipv6_mac_to_ipv6` and `ipv6_ipv6_to_mac`  
  added `set-session-title` and `unset-session-titel` functions to set/unset `SESSION_TITLE` env var - prefix for terminal title  
  added `docker-storage-usage` function for mac os docker replaces `docker-qcow2-usage`  
  added `docker-stats` function which runs `docker stats` with formatting where container name is also included  
  added `run-in` function in core, usage: `run-in [-v] <directory> <all other arguments are the command to run with arguments>`  

- **1.7.3**  
  `gifenc` and `to-stereo.sh` drafts  
  `netsh interface portproxy` alias `netsh-portproxy` on cygwin  
  `shellrc.sh` - force en_US.UTF-8 - LANG and LC_ALL env vars  

  - **core**:  
    `create-openssl-key-and-cert` function added to core.sh (run without params for usage)  
    `create-openssl-dh` function added to core.sh (run without params for usage)  

  - **darwin**:  
    `dns-flush-cache` function added to flush dns cache  
    `appBundleId` function has been renamed to `app-bundle-id`  

  - **docker**:  
    `docker-registry-mark-for-delete` function added  

- **1.7.2**  
  commented out the line to source .profile in shellrc, causing an infinite loop

- **1.7.1**  
  `wildfly-pid` fixed + also prints standalone  
  `grephash` and `grephashempty` alias fix  
  custom bash-completion removed in cygwin  
  added `millis`() function to get current time in milliseconds  
  added `nanos`() function to get current time in nanoseconds  
  added `backup`() function to create a backup of a file in format: {original_file_name.original_file_ext.bck-YYYYMMDDHHmmss}  

- **1.7**  
  `wildfly-pid` "ps a" replaced to "ps ax"  
  added conditional `colorcat` alias (if source-highlight command present)  
  `jcmd` bash completion added  
  added bashcompinit to zsh  

- **1.6.3**  
  `idea` command removed (can be created in IntelliJIDEA *menu -> Tools -> Create Command-line Launcher*)  
  `wildfly-pid` function added to *java.sh*  

- **1.6.2**  
  mvnCleaner - count + fixes

- **1.6.1**  
  Added mvnCleaner

- **1.6**  
  Moved to github  

- **1.5.1**  
  Added oneliner `-1` argument for `jmeminfo`

- **1.5**  
  Added `jmeminfo` utility script to get the jvm memory usage

- **1.4**  
  Added `imgcat` and `imgls` utility script for **iTerm2**  
  Added `jvisualvm-jboss` function to easy start **jvisualvm** with the right classpath and module path for **jboss/wildfly**  
  `df` alias fixed for **apfs** (macOS)  

- **1.3**  
  Java 9 support PATH support
  Java 8 installer renamed to install-oracle-jdk-8.sh
  MaxPermSize removed from the jdk installer, added MaxMetaspaceSize  
  toUTF8 alias added (iconv iso8859-2 to utf-8)
