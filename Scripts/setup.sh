#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
TOOLS_DIR=$HOME/Tools
WORK_DIR=$HOME/Work
CONFIG_DIR=$HOME/.config
INTELLIJ_VER="ideaIC-2018.1.5.tar.gz"

echo "Updating and Installing packages"
sudo apt-get update
sudo apt-get install -y apt-transport-https curl wget git build-essential xautolock i3 tcpdump emacs python virtualenv libssl-dev wireshark vim feh blueman

echo "Enabling Albert for installation"
wget -nv -O Release.key \
     https://build.opensuse.org/projects/home:manuelschneid3r/public_key
sudo apt-key add - < Release.key
sudo apt-get update

echo "Installing Albert"
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_18.04/ /' > /etc/apt/sources.list.d/home:manuelschneid3r.list"
sudo apt-get update
sudo apt-get install albert

echo "Home Directory Structure"
mkdir -p $CONFIG_DIR/i3
mkdir -p $CONFIG_DIR/albert
mkdir -p $TOOLS_DIR/JDK
mkdir -p $WORK_DIR

echo "Generating ssh-keys automagically"
ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''

echo "Setup GitConfig"
git config --global user.name "Sevren"
git config --global user.email kgoguev@mail.com

echo "Installing spacemacs"
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
cd ~/.emacs.d
git checkout develop
cd -

echo "Copying over config file for spacemacs"
cp ../Configs/Spacemacs/.spacemacs $HOME/.spacemacs

echo "Copying i3 configuration"
cp -r ../Configs/i3/* $CONFIG_DIR/i3/

echo "Copying over albert configuration"
cp -r ../Config/albert/* $CONFIG_DIR/albert

echo "Fixing Gnome terminal.desktop so that it shows up in the search for albert"
sudo sed -i'' "s/OnlyShowIn=GNOME;Unity;/#OnlyShowIn=GNOME;Unity;/g" /usr/share/applications/gnome-terminal.desktop

echo "Starting emacs in the backround so that it can download the appropriate packages"
emacs &

echo "Set emacs as default system wide editor"
sudo update-alternatives --set editor /usr/bin/emacs25

echo "Setup vimrc just in case"
git clone --depth=1 https://github.com/sevren/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

echo "Fetching go"
#Download Latest Go
GOURLREGEX='https://dl.google.com/go/go[0-9\.]+\.linux-amd64.tar.gz'
echo "Finding latest version of Go for AMD64..."
url="$(wget -qO- https://golang.org/dl/ | grep -oP 'https:\/\/dl\.google\.com\/go\/go([0-9\.]+)\.linux-amd64\.tar\.gz' | head -n 1 )"
latest="$(echo $url | grep -oP 'go[0-9\.]+' | grep -oP '[0-9\.]+' | head -c -2 )"
echo "Downloading latest Go for AMD64: ${latest}"
wget --quiet --continue --show-progress "${url}"
unset url
unset GOURLREGEX

# Remove Old Go
sudo rm -rf /usr/local/go

# Install new Go
sudo tar -C /usr/local -xzf go"${latest}".linux-amd64.tar.gz
echo "Create the skeleton for your local users go directory"
mkdir -p ~/go/{bin,pkg,src}
echo "Setting up GOPATH and JAVA_HOME PATH"
echo "export GOPATH=~/go" >> ~/.profile && source ~/.profile
echo "export JAVA_HOME=${HOME}/Tools/JDK/currentjava" >> ~/.profile && source ~/.profile
echo "Setting PATH to include golang binaries and JAVA_HOME path"
echo "export PATH='$PATH':/usr/local/go/bin:$GOPATH/bin:${JAVA_HOME}/bin" >> ~/.profile && source ~/.profile
echo "Installing dep for dependency management"
go get -u github.com/golang/dep/cmd/dep


# Remove Download
rm go"${latest}".linux-amd64.tar.gz

# Print Go Version
/usr/local/go/bin/go version

echo "Installing Go Development Packages"
go get -u -v github.com/nsf/gocode
go get -u -v github.com/rogpeppe/godef
go get -u -v golang.org/x/tools/cmd/guru
go get -u -v golang.org/x/tools/cmd/gorename
go get -u -v golang.org/x/tools/cmd/goimports
go get -u -v github.com/zmb3/gogetdoc
go get -u -v github.com/cweill/gotests/...
go get -u github.com/haya14busa/gopkgs/cmd/gopkgs
go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct
go get -u github.com/josharian/impl
go get -u -v github.com/davecgh/go-spew
go get -u -v github.com/spf13/viper
go get -u -v github.com/google/gopacket
go get -u github.com/derekparker/delve/cmd/dlv

echo "Docker Installation and Docker Compose"
curl -fsSL https://get.docker.com/ | sh
sleep 5
sudo systemctl enable docker

sudo groupadd docker
sudo usermod -aG docker ${USER}

sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

cd $HOME
echo "Get Intellij VERSION ${INTELLIJ_VER}"
wget -O /tmp/intellij.tar.gz http://download.jetbrains.com/idea/${INTELLIJ_VER}
tar xfz /tmp/intellij.tar.gz -C $HOME/Tools/
sudo $TOOLS_DIR/idea-IC-181.5281.24/bin/idea.sh &

echo "Get JDK 10 from Oracle"
wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/10.0.1+10/fb4372174a714e6b8c52526dc134031e/jdk-10.0.1_linux-x64_bin.tar.gz

tar xfz jdk-10.0.1_linux-x64_bin.tar.gz -C $HOME/Tools/JDK
ln -sfn $HOME/Tools/JDK/jdk-10.0.1 $HOME/Tools/JDK/currentjava

java -version

rm -rf $HOME/jdk-10.0.1_linux-x64_bin.tar.gz
