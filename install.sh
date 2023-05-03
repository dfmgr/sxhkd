#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202304302239-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.com
# @@License          :  WTFPL
# @@ReadME           :  install.sh --help
# @@Copyright        :  Copyright: (c) 2023 Jason Hempstead, Casjays Developments
# @@Created          :  Sunday, Apr 30, 2023 22:39 EDT
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
VERSION="202304302239-git"
HOME="${USER_HOME:-$HOME}"
USER="${SUDO_USER:-$USER}"
RUN_USER="${SUDO_USER:-$USER}"
SCRIPT_SRC_DIR="${BASH_SOURCE%/*}"
export SCRIPTS_PREFIX="dfmgr"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
REPO_BRANCH="${GIT_REPO_BRANCH:-main}"
PLUGIN_DIR="$HOME/.local/share/$APPNAME/plugins"
REPO="https://github.com/$SCRIPTS_PREFIX/$APPNAME"
INSTDIR="$HOME/.local/share/CasjaysDev/$SCRIPTS_PREFIX/$APPNAME"
REPORAW="https://github.com/$SCRIPTS_PREFIX/$APPNAME/raw/$REPO_BRANCH"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPDIR="$HOME/.config/$APPNAME"
PLUGIN_DIR="$HOME/.local/share/$APPNAME/plugins"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
BUILD_NAME="$APPNAME"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
trap 'retVal=$?;trap_exit' ERR EXIT SIGINT
#if [ ! -t 0 ] && { [ "$1" = --term ] || [ $# = 0 ]; }; then { [ "$1" = --term ] && shift 1 || true; } && TERMINAL_APP="TRUE" myterminal -e "$APPNAME $*" && exit || exit 1; fi
[ "$1" = "--debug" ] && set -x && export SCRIPT_OPTS="--debug" && export _DEBUG="on"
[ "$1" = "--raw" ] && export SHOW_RAW="true"
set -o pipefail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
for app in curl wget git; do type -P "$app" >/dev/null 2>&1 || missing_app+=("$app"); done && [ -z "${missing_app[*]}" ] || { printf '%s\n' "${missing_app[*]}" && exit 1; }
connect_test() { curl -q -ILSsf --retry 1 -m 1 "https://1.1.1.1" | grep -iq 'server:*.cloudflare' || return 1; }
verify_url() { urlcheck "$1" &>/dev/null || { printf_red "😿 The URL $1 returned an error. 😿" && exit 1; }; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Import functions
CASJAYSDEVDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}"
SCRIPTSFUNCTDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}/functions"
SCRIPTSFUNCTFILE="${SCRIPTSAPPFUNCTFILE:-mgr-installers.bash}"
SCRIPTSFUNCTURL="${SCRIPTSAPPFUNCTURL:-https://github.com/dfmgr/installer/raw/main/functions}"
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
__am_i_online() { connect_test || return 1; }
__run_git_clone_pull() { git_update "$1" "$2"; }
__cmd_exists() { builtin type -P $1 &>/dev/null; }
__mkdir() { mkdir -p "$1" &>/dev/null || return 1; }
__app_is_running() { pidof "$1" &>/dev/null || return 1; }
__mv_f() { [ -e "$1" ] && mv -f "$@" &>/dev/null || return 1; }
__cp_rf() { [ -e "$1" ] && cp -Rfa "$@" &>/dev/null || return 1; }
__chmod() { [ -e "$2" ] && chmod -Rf "$@" 2>/dev/null || return 1; }
__replace_one() { $sed -i "s|$1|$2|g" "$3" &>/dev/null || return 1; }
__rm_rf() { [ -e "$1" ] && { rm -Rf "$@" &>/dev/null || return 1; } || true; }
__rm_link() { [ -e "$1" ] && { rm -rf "$1" &>/dev/null || return 1; } || true; }
__download_file() { curl -q -LSsf "$1" -o "$2" 2>/dev/null || return 1; }
__input_is_number() { test -n "$1" && test -z "${1//[0-9]/}" || return 1; }
__failexitcode() { [ $1 -ne 0 ] && printf_red "😠 $2 😠" && exit ${1:-4}; }
__get_exit_status() { s=$? && getRunStatus=$((s + ${getRunStatus:-0})) && return $s; }
__service_is_running() { systemctl is-active $1 2>&1 | grep -qiw 'active' || return 1; }
__service_is_active() { systemctl is-enabled $1 2>&1 | grep -qiw 'enabled' || return 1; }
__get_version() { echo "$@" | awk -F '.' '{ printf("%d%d%d%d\n", $1,$2,$3,$4) }'; }
__silent_start() { __cmd_exists $1 && (eval "$*" &>/dev/null &) && __app_is_running $1 || return 1; }
__symlink() { { __rm_rf "$2" || true; } && ln_sf "$1" "$2" &>/dev/null || { [ -L "$2" ] || return 1; }; }
__get_pid() { ps -aux | grep -v ' grep ' | grep "$1" | awk -F ' ' '{print $2}' | grep ${2:-[0-9]} || return 1; }
__dir_count() { find -L "${1:-./}" -maxdepth "${2:-1}" -not -path "${1:-./}/.git/*" -type d 2>/dev/null | wc -l; }
__file_count() { find -L "${1:-./}" -maxdepth "${2:-1}" -not -path "${1:-./}/.git/*" -type f 2>/dev/null | wc -l; }
__kill_process_id() { __input_is_number $1 && pid=$1 && { [ -z "$pid" ] || kill -15 $pid &>/dev/null; } || return 1; }
__kill() { __kill_process_id "$1" || __kill_process_name "$1" || { ! __app_is_running "$1" || kill -9 $pid &>/dev/null; } || return 1; }
__replace_all() { [ -n "$3" ] && [ -e "$3" ] && find "$3" -not -path "$3/.git/*" -type f -exec $sed -i "s|$1|$2|g" {} \; >/dev/null 2>&1 || return 1; }
__kill_process_name() { local pid="$(pidof "$1" 2>/dev/null)" && { [ -z "$pid" ] || { kill -19 $pid &>/dev/null && ! __app_is_running "$1" && return 0; } || kill -9 $pid &>/dev/null; } || return 1; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sed="$(builtin type -P gsed 2>/dev/null || builtin type -P sed 2>/dev/null || return)"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Script options IE: --help --version
show_optvars "$@"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Verify repository exists
verify_url "$REPO"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# OS Support: supported_os unsupported_oses
supported_os linux
unsupported_oses mac windows
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
APPVERSION="$(__appversion "https://github.com/$SCRIPTS_PREFIX/$APPNAME/raw/$REPO_BRANCH/version.txt")"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define these if build script is used
BUILD_NAME="sxhkd"
BUILD_SCRIPT_REBUILD="false"
BUILD_SRC_URL=""
BUILD_SCRIPT_SRC_DIR="$PLUGIN_DIR/source"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup plugins
PLUGIN_REPOS=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Grab release from github releases
LATEST_RELEASE=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Specify global packages
GLOBAL_OS_PACKAGES="sxhkd "
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define linux only packages
LINUX_OS_PACKAGES="sxhkd guake links xwallpaper"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define MacOS only packages
MAC_OS_PACKAGES=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define Windows only packages
WIN_OS_PACKAGES=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Specify ARCH_USER_REPO Pacakges
AUR_PACKAGES=""
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
# Run custom actions
__app_is_running sxhkd && SXHKD_IS_RUNNING="true"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Show a custom message after install
__run_post_message() {
  true
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define pre-install scripts
__run_pre_install() {
  local getRunStatus=0

  return $getRunStatus
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run before primary post install function
__run_prepost_install() {
  local getRunStatus=0
  if [ "$SXHKD_IS_RUNNING" = "true" ]; then
    pkill -USR1 -x sxhkd
    __app_is_running sxhkd && notifications "sxhkd" "🎊 Reloaded config"
  fi
  return $getRunStatus
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run after primary post install function
__run_post_install() {
  local getRunStatus=0

  return $getRunStatus
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Custom plugin function
__custom_plugin() {
  local getRunStatus=0
  # execute "__run_git_clone_pull repo dir" "Installing plugName"
  return $getRunStatus
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# execute build script if exists and install failed or set BUILD_SCRIPT_REBUILD to true to always rebuild
__run_build_script() {
  local getRunStatus=0
  if ! __cmd_exists "$BUILD_NAME" && [ -f "$INSTDIR/build.sh" ]; then
    export BUILD_NAME BUILD_SCRIPT_SRC_DIR BUILD_SRC_URL BUILD_SCRIPT_REBUILD
    [ -x "$INSTDIR/build.sh" ] || chmod 755 "$INSTDIR/build.sh"
    eval "$INSTDIR/build.sh"
  fi
  return $getRunStatus
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
    SYSTEM_PACKAGES="$GLOBAL_OS_PACKAGES $LINUX_OS_PACKAGES $ARCH_OS_PACKAGES"
  elif if_os_id centos; then
    SYSTEM_PACKAGES="$GLOBAL_OS_PACKAGES $LINUX_OS_PACKAGES $CENTOS_OS_PACKAGES"
  elif if_os_id debian; then
    SYSTEM_PACKAGES="$GLOBAL_OS_PACKAGES $LINUX_OS_PACKAGES $DEBIAN_OS_PACKAGES"
  elif if_os_id ubuntu; then
    SYSTEM_PACKAGES="$GLOBAL_OS_PACKAGES $LINUX_OS_PACKAGES $UBUNTU_OS_PACKAGES"
  else
    SYSTEM_PACKAGES="$GLOBAL_OS_PACKAGES $LINUX_OS_PACKAGES"
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define MacOS packages - homebrew
if if_os mac; then
  SYSTEM_PACKAGES="$GLOBAL_OS_PACKAGES $MAC_OS_PACKAGES"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define Windows packages - choco
if if_os win; then
  SYSTEM_PACKAGES="$GLOBAL_OS_PACKAGES $WIN_OS_PACKAGES"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Attempt install from github release
install_latest_release "$LATEST_RELEASE"
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
[ -d "$APPDIR" ] && execute "backupapp $APPDIR $APPNAME" "Backing up $APPDIR"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Get configuration files
instCode=0
if __am_i_online; then
  if [ -d "$INSTDIR/.git" ]; then
    execute "__run_git_clone_pull $INSTDIR" "Updating $APPNAME configurations"
    instCode=$?
  else
    execute "__run_git_clone_pull $REPO $INSTDIR" "Installing $APPNAME configurations"
    instCode=$?
  fi
  # exit on fail
  __failexitcode $instCode "Failed to setup the git repo from $REPO"
fi
unset instCode
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install Plugins
exitCodeP=0
if __am_i_online; then
  if [ "$PLUGIN_REPOS" != "" ]; then
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
  __failexitcode $exitCodeP "Installation of plugin failed"
fi
unset exitCodeP
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run post install scripts
run_postinst() {
  local exitCodeP=0
  __run_prepost_install || exitCodeP=$((exitCodeP + 1))
  dfmgr_run_post || exitCodeP=$((exitCodeP + 1))
  __run_post_install || exitCodeP=$((exitCodeP + 1))
  return $exitCodeP
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run post install scripts
execute "run_postinst" "Running post install scripts"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# create version file
dfmgr_install_version
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run exit function
run_exit
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run any external scripts
__run_build_script
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Output post install message
__run_post_message
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# End application
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# lets exit with code
exit ${EXIT:-${exitCode:-0}}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ex: ts=2 sw=2 et filetype=sh
