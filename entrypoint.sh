#!/bin/sh
set -e

if [ -z "${UUID}" ]; then
  echo "ERROR: UUID environment variable is not set" >&2
  exit 1
fi
WS_PATH="${WS_PATH:-/a7ws}"
PORT="${PORT:-8080}"

mkdir -p /usr/local/etc/xray

cat > /usr/local/etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${PORT},
      "protocol": "vless",
      "settings": {
        "clients": [ { "id": "${UUID}" } ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "${WS_PATH}" }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [ "http", "tls" ]
      }
    }
  ],
  "outbounds": [ { "protocol": "freedom" } ]
}
EOF

echo "Starting xray: port=${PORT} ws_path=${WS_PATH}"
exec xray run -config /usr/local/etc/xray/config.json
