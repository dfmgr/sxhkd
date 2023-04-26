#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202304251442-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.com
# @@License          :  WTFPL
# @@ReadME           :  install.sh --help
# @@Copyright        :  Copyright: (c) 2023 Jason Hempstead, Casjays Developments
# @@Created          :  Tuesday, Apr 25, 2023 14:42 EDT
# @@File             :  install.sh
# @@Description      :  Install configurations for sxhkd
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  installers/dfmgr
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# shell check options
# shellcheck disable=SC2317
# shellcheck disable=SC2120
# shellcheck disable=SC2155
# shellcheck disable=SC2199
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="sxhkd"
VERSION="202304251442-git"
HOME="${USER_HOME:-$HOME}"
USER="${SUDO_USER:-$USER}"
RUN_USER="${SUDO_USER:-$USER}"
SCRIPT_SRC_DIR="${BASH_SOURCE%/*}"
export SCRIPTS_PREFIX="dfmgr"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
BUILD_APPNAME="$APPNAME"
APPDIR="$HOME/.config/$APPNAME"
REPO_BRANCH="${GIT_REPO_BRANCH:-main}"
PLUGIN_DIR="$HOME/.local/share/$APPNAME/plugins"
REPO="https://github.com/$SCRIPTS_PREFIX/$APPNAME"
INSTDIR="$HOME/.local/share/CasjaysDev/$SCRIPTS_PREFIX/$APPNAME"
REPORAW="https://github.com/$SCRIPTS_PREFIX/$APPNAME/raw/$REPO_BRANCH"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
trap 'retVal=$?;trap_exit' ERR EXIT SIGINT
#if [ ! -t 0 ] && { [ "$1" = --term ] || [ $# = 0 ]; }; then { [ "$1" = --term ] && shift 1 || true; } && TERMINAL_APP="TRUE" myterminal -e "$APPNAME $*" && exit || exit 1; fi
[ "$1" = "--debug" ] && set -x && export SCRIPT_OPTS="--debug" && export _DEBUG="on"
[ "$1" = "--raw" ] && export SHOW_RAW="true"
set -o pipefail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
for app in curl wget git; do type -P "$app" >/dev/null 2>&1 || missing_app+=("$app"); done && [ -z "${missing_app[*]}" ] || { printf '%s\n' "${missing_app[*]}" && exit 1; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Import functions
CASJAYSDEVDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}"
SCRIPTSFUNCTDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}/functions"
SCRIPTSFUNCTFILE="${SCRIPTSAPPFUNCTFILE:-mgr-installers.bash}"
SCRIPTSFUNCTURL="${SCRIPTSAPPFUNCTURL:-https://github.com/dfmgr/installer/raw/main/functions}"
connect_test() { curl -q -ILSsf --retry 1 -m 1 "https://1.1.1.1" | grep -iq 'server:*.cloudflare' || return 1; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$PWD/$SCRIPTSFUNCTFILE" ]; then
  . "$PWD/$SCRIPTSFUNCTFILE"
elif [ -f "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" ]; then
  . "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE"
elif connect_test; then
  curl -q -LSsf "$SCRIPTSFUNCTURL/$SCRIPTSFUNCTFILE" -o "/tmp/$SCRIPTSFUNCTFILE" || exit 1
  . "/tmp/$SCRIPTSFUNCTFILE"
else
  echo "Can not load the functions file: $SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" 1>&2
  exit 90
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define custom functions
__download_file() { curl -q -LSsf "$1" -o "$2" || return 1; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# OS Support: supported_os unsupported_oses
supported_os linux mac windows
unsupported_oses
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# get sudo credentials
sudorun "true"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Requires root - restarting with sudo
#sudoreq "$0 *"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Make sure the scripts repo is installed
scripts_check
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Call the main function
dfmgr_install
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Script options IE: --help --version
show_optvars "$@"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# trap the cleanup function
trap_exit
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Initialize the installer
dfmgr_run_init
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Do not update
#installer_noupdate "$@"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Defaults
APPNAME="sxhkd"
BUILD_APPNAME="sxhkd"
APPVERSION="$(__appversion "https://github.com/$SCRIPTS_PREFIX/$APPNAME/raw/$REPO_BRANCH/version.txt")"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup plugins
PLUGIN_REPOS=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Specify required system packages you can prefix os to OS_PACKAGES: MAC_OS_PACKAGES WIN_OS_PACKAGES
OS_PACKAGES="sxhkd guake links xwallpaper"
OS_PACKAGES+=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define required system python packages
PYTHON_PACKAGES=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define required system perl packages
PERL_PACKAGES=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# define additional packages - tries to install via tha package managers
NODEJS=""
PERL_CPAN=""
RUBY_GEMS=""
PYTHON_PIP=""
PHP_COMPOSER=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Specify ARCH_USER_REPO Pacakges
AUR_PACKAGES=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define pre-install scripts
__run_pre_install() {

  return ${?:-0}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run before primary post install function
__run_prepost_install() {

  return ${?:-0}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run after primary post install function
__run_post_install() {
  if pgrep sxhkd &>/dev/null; then
    pkill -USR1 -x sxhkd && cmd_exists notifications && notifications "sxhkd" "Reloaded config"
  fi
  return ${?:-0}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Custom plugin function
__custom_plugin() {
  local exitCodeC=0
  # execute "git_clone $repo $dir" "Installing plugin name"
  return $exitCodeC
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Other dependencies
dotfilesreq misc
dotfilesreqadmin cron
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# END OF CONFIGURATION
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Require a version higher than
dfmgr_req_version "$APPVERSION"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Run pre-install commands
execute "__run_pre_install" "Running pre-installation commands"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# define arch user repo packages
if_os_id arch && ARCH_USER_REPO="$AUR_PACKAGES"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# define linux packages
if if_os linux; then
  if if_os_id arch; then
    SYSTEM_PACKAGES="$OS_PACKAGES $ARCH_OS_PACKAGES"
  elif if_os_id centos; then
    SYSTEM_PACKAGES="$OS_PACKAGES $CENTOS_OS_PACKAGES"
  elif if_os_id debian; then
    SYSTEM_PACKAGES="$OS_PACKAGES $DEBIAN_OS_PACKAGES"
  elif if_os_id ubuntu; then
    SYSTEM_PACKAGES="$OS_PACKAGES $UBUNTU_OS_PACKAGES"
  else
    SYSTEM_PACKAGES="$OS_PACKAGES"
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define MacOS packages - homebrew
if if_os mac; then
  SYSTEM_PACKAGES="$OS_PACKAGES $MAC_OS_PACKAGES"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define Windows packages - choco
if if_os win; then
  SYSTEM_PACKAGES="$OS_PACKAGES $WIN_OS_PACKAGES"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install required packages using the aur - Requires yay to be installed
install_aur "${ARCH_USER_REPO//,/ }"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install packages - useful for package that have the same name on all oses
install_packages "${SYSTEM_PACKAGES//,/ }"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install required packages using file from pkmgr repo
install_required "$APPNAME"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check for perl modules and install using system package manager
install_perl "${PERL_PACKAGES//,/ }"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check for python modules and install using system package manager
install_python "${PYTHON_PACKAGES//,/ }"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check for pip binaries and install using python package manager
install_pip "${PYTHON_PIP//,/ }"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check for cpan binaries and install using perl package manager
install_cpan "${PERL_CPAN//,/ }"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check for ruby binaries and install using ruby package manager
install_gem "${RUBY_GEMS//,/ }"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check for npm binaries and install using npm/yarn package manager
install_npm "${NODEJS//,/ }"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check for php binaries and install using php composer
install_php "${PHP_COMPOSER//,/ }"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Ensure directories exist
ensure_dirs
ensure_perms
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Backup if needed
if [ -d "$APPDIR" ]; then
  execute "backupapp $APPDIR $APPNAME" "Backing up $APPDIR"
fi
# Main progam
if __am_i_online; then
  if [ -d "$INSTDIR/.git" ]; then
    execute "git_update $INSTDIR" "Updating $APPNAME configurations"
  else
    execute "git_clone $REPO $INSTDIR" "Installing $APPNAME configurations"
  fi
  # exit on fail
  failexitcode $? "Git has failed"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install Plugins
if __am_i_online; then
  if [ "$PLUGIN_REPOS" != "" ]; then
    exitCodeP=0
    [ -d "$PLUGIN_DIR" ] || mkdir -p "$PLUGIN_DIR"
    for plugin in $PLUGIN_REPOS; do
      plugin_name="$(basename "$plugin")"
      plugin_dir="$PLUGIN_DIR/$plugin_name"
      if [ -d "$plugin_dir/.git" ]; then
        execute "git_update $plugin_dir" "Updating plugin $plugin_name"
        [ $? -ne 0 ] && exitCodeP=$(($? + exitCodeP)) && printf_red "Failed to update $plugin_name"
      else
        execute "git_clone $plugin $plugin_dir" "Installing plugin $plugin_name"
        [ $? -ne 0 ] && exitCodeP=$(($? + exitCodeP)) && printf_red "Failed to install $plugin_name"
      fi
    done
  fi
  __custom_plugin
  exitCodeP=$(($? + exitCodeP))
  # exit on fail
  failexitcode $exitCodeP "Installation of plugin failed"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run post install scripts
run_postinst() {
  __run_prepost_install
  dfmgr_run_post
  __run_post_install
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run post install scripts
execute "run_postinst" "Running post install scripts"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Output post install message

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# create version file
dfmgr_install_version
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run exit function
run_exit
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run any external scripts
if ! __cmd_exists "$BUILD_APPNAME" && [ -f "$INSTDIR/build.sh" ]; then
  BUILD_SCRIPT_SRC_DIR="$PLUGIN_DIR/source"
  BUILD_SRC_URL=""
  export BUILD_SCRIPT_SRC_DIR BUILD_SRC_URL
  eval "$INSTDIR/build.sh"
  __cmd_exists $BUILD_APPNAME || printf_red "$BUILD_APPNAME is not installed: run $INSTDIR/build.sh"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# End application
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# lets exit with code
exit ${EXIT:-${exitCode:-0}}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ex: ts=2 sw=2 et filetype=sh
