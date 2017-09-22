# Shell script collection

Useful scripts for unix like systems.

## Usage

### Install script

with wget:
```
wget -q -O- "https://bitbucket.org/mn3monic/scripts/downloads/installer.sh" | bash -s -- -u
```

with curl:
```
curl -L -s -o- "https://bitbucket.org/mn3monic/scripts/downloads/installer.sh" | bash -s -- -u
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
wget -q -O- "https://bitbucket.org/mn3monic/scripts/downloads/installer.sh" | bash -s -- -a
```

with curl:
```
curl -L -s -o- "https://bitbucket.org/mn3monic/scripts/downloads/installer.sh" | bash -s -- -a
```

### Using git repo


#### clone repository:
  
```
cd ~
git clone https://bitbucket.org/mn3monic/scripts.git
```

#### source shellrc.sh  

```
source ~/scripts/shellrc.sh
```

## Changelog

 * **1.3**  
   Java 9 support PATH support
   Java 8 installer renamed to install-oracle-jdk-8.sh
   MaxPermSize removed from the jdk installer, added MaxMetaspaceSize  
   toUTF8 alias added (iconv iso8859-2 to utf-8)
