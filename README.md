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

- **1.7.8**  
  function `wildfly-pid` has been optimized (implementation with awk)  
  added `format-number` command to format numbers to humand readable form (and added into `currency-exchange`)  
  added `netinfo` (*macos only*) command to query system network interface informations  
  added `unicode` command to (*download the list and*) search for unicode symbol by keywords given as argumemts:  
  example: `unicode black circle`  

- **1.7.7**  
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
