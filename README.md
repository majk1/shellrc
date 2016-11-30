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