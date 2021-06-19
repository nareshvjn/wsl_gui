#!/bin/bash

#Guide to Install GNOME gui in wsl2
#https://gist.github.com/tdcosta100/385636cbae39fc8cd0937139e87b1c74

sudo apt update
sudo apt install ubuntu-desktop-minimal tigervnc-standalone-server -y
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install dotnet-runtime-5.0 apt-transport-https -y
sudo wget -O /etc/apt/trusted.gpg.d/wsl-transdebian.gpg https://arkane-systems.github.io/wsl-transdebian/apt/wsl-transdebian.gpg
sudo chmod a+r /etc/apt/trusted.gpg.d/wsl-transdebian.gpg
source /etc/os-release
cat << EOF | sudo tee /etc/apt/sources.list.d/wsl-transdebian.list
deb https://arkane-systems.github.io/wsl-transdebian/apt/ $VERSION_CODENAME main
deb-src https://arkane-systems.github.io/wsl-transdebian/apt/ $VERSION_CODENAME main
EOF
sudo apt update
sudo apt install systemd-genie -y
vncpasswd
sudo -H vncpasswd
sudo -H -u gdm vncpasswd
sudo mv /usr/bin/Xorg /usr/bin/Xorg_old
sudo touch /usr/bin/Xorg_new
echo "#!/bin/bash
for arg do
  shift
  case $arg in
    # Xvnc doesn't support vtxx argument. So we convert to ttyxx instead
    vt*)
      set -- "$@" "${arg//vt/tty}"
      ;;
    # -keeptty is not supported at all by Xvnc
    -keeptty)
      ;;
    # -novtswitch is not supported at all by Xvnc
    -novtswitch)
      ;;
    # other arguments are kept intact
    *)
      set -- "$@" "$arg"
      ;;
  esac
done

# Here you can change or add options to fit your needs
command=("/usr/bin/Xvnc" "-geometry" "1366x768" "-PasswordFile" "${HOME:-/root}/.vnc/passwd" "$@") 

systemd-cat -t /usr/bin/Xorg echo "Starting Xvnc:" "${command[@]}"

exec "${command[@]}"" | sudo tee -a /usr/bin/Xorg_new > /dev/null
sudo chmod 0755 /usr/bin/Xorg_new
sudo ln -sf Xorg_new /usr/bin/Xorg
echo 'AutomaticLoginEnable=true
 AutomaticLogin=nkvjn' >> /etc/gdm3/custom.conf
echo 'Open VNCviewer in windows and conect to localhost:5900'
genie -s
