#!/bin/sh

set -e

ADDITIONAL_OPTIONS=""
CONF_PATH="/config/aria2.conf"
USING_DEFAULT_CONFIGURATION=1

GID=`id -g`
UID=`id -u`

echo "====== UID, GID information ============="
echo "UID: ${UID}"
echo "GID: ${GID}"

echo "====== Setting aria2 configuration ======"

# Check if the /config folder exists or not
[ ! -d /config ] && echo -e "\e[1;38;5;9mConfig directory does not exist!!\e[0m" && exit 1

# Check if the /downloads folder exists or not
[ ! -d /downloads ] && echo -e "\e[1;38;5;9mDownloads directory does not exist!!\e[0m" && exit 1

# If "/config/aria2.sessions" does not exist, create one.
[ ! -e /config/aria2.sessions ] && touch /config/aria2.sessions

# If "/config/aria2.conf" does not exist, use the default configuration file.
if [ ! -e "${CONF_PATH}" ]; then
  cp /aria2/default-aria2.conf "${CONF_PATH}"
  USING_DEFAULT_CONFIGURATION=0
fi

if [ -n "${INPUT_FILE}" ] && [ -e "/config/${INPUT_FILE}" ]; then
  ADDITIONAL_OPTIONS="--input-file=/config/${INPUT_FILE}"
else
  ADDITIONAL_OPTIONS="--input-file=/config/aria2.sessions"
fi

if [ -n "${LOG_FILE}" ]; then
  # Check if the /log folder exists or not
  [ ! -d /log ] && echo -e "\e[1;38;5;9mLog directory does not exist!!\e[0m" && exit 1

  [ ! -e "/log/${LOG_FILE}" ] && touch "/log/${LOG_FILE}"
  ADDITIONAL_OPTIONS="${ADDITIONAL_OPTIONS} --log=/log/${LOG_FILE}"
  chown -R ${UID}:${GID} /log
  chmod 600 "/log/${LOG_FILE}"
fi

if [ -n "${LOG_LEVEL}" ]; then
  ADDITIONAL_OPTIONS="${ADDITIONAL_OPTIONS} --log-level=${LOG_LEVEL}"
fi

if [ "${USING_DEFAULT_CONFIGURATION}" -eq "0" ]; then
  RANDOM_RPC_SECRET=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
  RPC_OPTIONS="enable-rpc=true\nrpc-allow-origin-all=true\nrpc-listen-all=true\n"
  RPC_OPTIONS="${RPC_OPTIONS}rpc-secret=${RANDOM_RPC_SECRET}\n"
  echo -e "\e[1;38;5;10mRPC Secret: ${RANDOM_RPC_SECRET}\e[0m"
  echo -e "\e[1;38;5;9mFor security and privacy reason, consider using TLS connection to protect the RPC connections\e[0m"
  echo -e "${RPC_OPTIONS}" >> "${CONF_PATH}"
fi

chown -R ${UID}:${GID} /config
find /config -type d -exec chmod 755 {} +
find /config -type f -exec chmod 644 {} +
chmod 600 "${CONF_PATH}"

echo "====== DONE ============================="

exec stdbuf -o 0 -e 0 aria2c ${ADDITIONAL_OPTIONS} --conf-path=${CONF_PATH}
