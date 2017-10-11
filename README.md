# Shell script collection

Useful scripts for unix like systems mostly for developers

## Usage

### Install script

with wget:
```
wget -q -O- "https://majk1.github.io/shellrc/installer.sh" | bash -s -- -u
```

with curl:
```
curl -L -s -o- "https://majk1.github.io/shellrc/installer.sh" | bash -s -- -u
```

for silent install use -su parameter instad of -u

### Upgrade / reinstall

just type:
```
update-shellrc
```

### List latest version

with wget:
```
wget -q -O- "https://majk1.github.io/shellrc/installer.sh" | bash -s -- -a
```

with curl:
```
curl -L -s -o- "https://majk1.github.io/shellrc/installer.sh" | bash -s -- -a
```

### Using git repo


#### clone repository:
  
```
git clone https://github.com/majk1/shellrc.git
```

#### source shellrc.sh  

```
source ~/scripts/shellrc.sh
```

## Changelog

 * **1.6**  
   Moved to github  

 * **1.5.1**  
   Added oneliner `-1` argument for `jmeminfo`
  
 * **1.5**  
   Added `jmeminfo` utility script to get the jvm memory usage

 * **1.4**  
   Added `imgcat` and `imgls` utility script for **iTerm2**  
   Added `jvisualvm-jboss` function to easy start **jvisualvm** with the right classpath and module path for **jboss/wildfly**  
   `df` alias fixed for **apfs** (macOS)  

 * **1.3**  
   Java 9 support PATH support
   Java 8 installer renamed to install-oracle-jdk-8.sh
   MaxPermSize removed from the jdk installer, added MaxMetaspaceSize  
   toUTF8 alias added (iconv iso8859-2 to utf-8)
