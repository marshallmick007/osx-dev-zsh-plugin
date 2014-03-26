
local MAMPDIR=/Applications/MAMP/bin
local MYSQLPID=/usr/local/var/mysql/Robotop.local.pid
local APACHEPID=/Applications/MAMP/Library/logs/httpd.pid
local MONGODBPID=${HOME}/.mongodb/mongodb.pid
local MONGODBCONF=${HOME}/.mongodb/mongod.conf
local NGINX=/usr/local/sbin/nginx
local NGINX_BASE=/usr/local/etc/nginx
local NGINXPID=/usr/local/var/run/nginx.pid

## Used in echo -e statements
local E_PURPLE="\033[0;35m"
local E_NC="\033[0m"
local E_RED="\033[1;31m"
local E_GREEN="\033[0;32m"

local STARTED="${E_GREEN}Started${E_NC}"
local STOPPED="${E_RED}Stopped${E_NC}"

function devstatus()
{
  echo -e "DEV Server Status"
  echo -e "-----------------"

  status-nginx
  status-mysql
  #status-apache
  #status-mongodb
}

function restart-nginx()
{
  sudo kill -HUP $( cat $NGINXPID )
}

function restart-nginx-launchctl()
{
  stop-nginx
  sleep 1
  start-nginx
}

function stop-nginx()
{
  echo -e "Stopping nginx..."
  sudo launchctl stop homebrew.mxcl.nginx
  sleep 1
  status-nginx
}

function start-nginx()
{
  echo -e "Starting nginx..."
  echo -e "  May need to run:"
  echo -e "  ${E_PURPLE}sudo launchctl load /Library/LaunchAgents/homebrew.mxcl.nginx.plist${E_NC}"
  sudo launchctl start homebrew.mxcl.nginx
  sleep 1
  status-nginx
}

function status-nginx()
{
  _print-dev-server-status "${NGINXPID}" "nginx"
}

function stop-apache()
{
  echo -e "Stopping Apache..."
  sudo ${MAMPDIR}/stopApache.sh
  sleep 1
  status-apache
}

function start-apache()
{
  echo -e "Starting Apache..."
  sudo ${MAMPDIR}/startApache.sh
  sleep 1
  status-apache
}

function restart-apache()
{
  stop-apache
  start-apache
}

function status-apache()
{
  _print-dev-server-status "${APACHEPID}" "httpd"
}

function start-mysql()
{
  echo -e "Starting MySql..."
  launchctl start homebrew.mxcl.mysql
  sleep 1
  status-mysql
}

function stop-mysql()
{
  echo -e "Stopping MySql..."
  launchctl stop homebrew.mxcl.mysql
  sleep 1
  status-mysql
}

function restart-mysql()
{
  stop-mysql
  start-mysql
}

function status-mysql()
{
  _print-dev-server-status "${MYSQLPID}" "mysql"
}

function start-mongodb()
{
  echo -e "Starting MongoDB..."
  mongod --fork -f ${MONGODBCONF}
  status-mongodb
}

function stop-mongodb()
{
  echo -e "Stopping MongoDB..."
  mongo localhost/admin --eval "db.shutdownServer();"
  sleep 1
  status-mongodb
}

function restart-mongodb()
{
  stop-mongodb
  start-mongodb
}

function status-mongodb()
{
  _print-dev-server-status "${MONGODBPID}" "mongod"
}

_print-dev-server-status() {
  pidfile="$1"
  service="$2"
  if [ -e "${pidfile}" ]; then
    PID=`cat "${pidfile}"`
    running=`ps | grep -v "grep" | grep "${service}" | grep -c "${PID}"`
    if [ "1" -eq "${running}" ]; then
      _print-status-for-cmd ${service} ${STARTED}
    else
      echo -e "${service} is ${STOPPED} - PID file present, but no process found"
    fi
  else
    _print-status-for-cmd ${service} ${STOPPED}
  fi
}

_print-status-for-cmd() {
  service="$1"
  readonly mystat=$2
  #addtl="$3"
  echo -e "${E_NC}${service} is ${mystat}"
}
