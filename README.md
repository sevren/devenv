# devenv
Scripts and Configurations for my developer environment

The setup.sh in the Scripts folder will perform the following:

1. Apt-get update packages and install several developer tools: git, build-essentials etc.. and i3
2. Install Albert launcher
3. Create Home directories Tools, Work and .Config/i3 .Config/albert
4. Copy over all configurations
5. Start spacemacs and let it install its packages
6. Install the latest go tools and go get those packages
7. Download Oracle JDK 10 and install it into $HOME/Tools/JDK\
8. Download Intellij and run the setup

*OBS: This script requires user input!*

## Running

```bash
git clone https://github.com/sevren/devenv.git
cd devenv/Scripts
./setup.sh
```

