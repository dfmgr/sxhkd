## sxhkd  
  
simple X hotkey daemon, by the developer of bspwm, that reacts to input events by executing commands  
  
Automatic install/update:

```shell
bash -c "$(curl -LSs https://github.com/dfmgr/sxhkd/raw/master/install.sh)"
```

Manual install:
  
requires:

Debian based:

```shell
apt install sxhkd
```  

Fedora Based:

```shell
yum install sxhkd
```  

Arch Based:

```shell
pacman -S sxhkd
```  

MacOS:  

```shell
brew install 
```
  
```shell
mv -fv "$HOME/.config/sxhkd" "$HOME/.config/sxhkd.bak"
git clone https://github.com/dfmgr/sxhkd "$HOME/.config/sxhkd"
```
  
<p align=center>
  <a href="https://wiki.archlinux.org/index.php/sxhkd" target="_blank" rel="noopener noreferrer">sxhkd wiki</a>  |  
  <a href="https://github.com/baskerville/sxhkd" target="_blank" rel="noopener noreferrer">sxhkd site</a>
</p>  
