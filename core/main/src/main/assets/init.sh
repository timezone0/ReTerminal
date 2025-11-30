set -e # Exit immediately on Failure

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/share/bin:/usr/share/sbin:/usr/local/bin:/usr/local/sbin:/system/bin:/system/xbin
export HOME=/root

if [ ! -s /etc/resolv.conf ]; then
  echo "nameserver 8.8.8.8" >/etc/resolv.conf
fi

export PS1="\[\e[38;5;46m\]\u\[\033[39m\]@reterm \[\033[39m\]\w \[\033[0m\]\\$ "
# shellcheck disable=SC2034
export PIP_BREAK_SYSTEM_PACKAGES=1
required_packages="bash gcompat glib nano zsh"
missing_packages=""
for pkg in $required_packages; do
  if ! apk info -e $pkg >/dev/null 2>&1; then
    missing_packages="$missing_packages $pkg"
  fi
done
if [ -n "$missing_packages" ]; then
  echo -e "\e[34;1m[*] \e[0mInstalling Important packages\e[0m"
  apk update && apk upgrade
  apk add $missing_packages
  if [ $? -eq 0 ]; then
    echo -e "\e[32;1m[+] \e[0mSuccessfully Installed\e[0m"
  fi
  echo -e "\e[34m[*] \e[0mUse \e[32mapk\e[0m to install new packages\e[0m"
fi

#fix linker warning
if [[ ! -f /linkerconfig/ld.config.txt ]]; then
  mkdir -p /linkerconfig
  touch /linkerconfig/ld.config.txt
fi

if [ "$#" -eq 0 ]; then
  source /etc/profile
  #    export PS1="\[\e[38;5;46m\]\u\[\033[39m\]@reterm \[\033[39m\]\w \[\033[0m\]\\$ "
  #    /bin/ash
  cd $HOME

  echo "tar -cvpf /sdcard/alpine-backup.tar.gz --exclude=./apex --exclude=./odm --exclude=./product --exclude=./system --exclude=./system_ext --exclude=./vendor --exclude=./linkerconfig --exclude=./sdcard --exclude=./storage --exclude=./data --exclude=./tmp --exclude=./proc --exclude=./dev --exclude=./sys -C /data/user/0/com.rk.terminal/local/alpine ." >$HOME/.backup
  echo "tar -xvzf /sdcard/alpine-backup.tar.gz -C /data/user/0/com.rk.terminal/local/alpine" >$HOME/.restore

  ZSHRC_FILE="$HOME/.zshrc"

  if [ ! -f "$ZSHRC_FILE" ]; then
    echo "PROMPT='%F{green}%n%f@reterm %~ %# '" >>"$ZSHRC_FILE"
    echo "bindkey '\e[H' beginning-of-line" >>"$ZSHRC_FILE"
    echo "bindkey '\e[F' end-of-line" >>"$ZSHRC_FILE"
  fi

  /bin/zsh
else
  exec "$@"
fi

