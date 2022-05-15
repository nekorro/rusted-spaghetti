#!/bin/bash

if [[ -z "${PASSWORD}" ]]; then
  export PASSWORD="5c301bb8-6c77-41a0-a606-4ba11bbab084"
fi
echo ${PASSWORD}

export PASSWORD_JSON="$(echo -n "$PASSWORD" | jq -Rc)"

if [[ -z "${ENCRYPT}" ]]; then
  export ENCRYPT="chacha20-ietf-poly1305"
fi

if [[ -z "${V2_Path}" ]]; then
  export V2_Path="s233"
fi
echo ${V2_Path}

if [[ -z "${QR_Path}" ]]; then
  export QR_Path="/qr_img"
fi
echo ${QR_Path}

case "$AppName" in
	*.*)
		export DOMAIN="$AppName"
		;;
	*)
		export DOMAIN="$AppName.herokuapp.com"
		;;
esac

bash /conf/shadowsocks_config.json >  /etc/shadowsocks/config.json
echo /etc/shadowsocks/config.json
cat /etc/shadowsocks/config.json

bash /conf/nginx_ss.conf > /etc/nginx/conf.d/ss.conf
echo /etc/nginx/conf.d/ss.conf
cat /etc/nginx/conf.d/ss.conf

plugin=$(echo -n "v2ray;path=/${V2_Path};host=${DOMAIN};tls" | sed -e 's/\//%2F/g' -e 's/=/%3D/g' -e 's/;/%3B/g')
ss="ss://$(echo -n ${ENCRYPT}:${PASSWORD} | base64 -w 0)@${DOMAIN}:443?plugin=${plugin}"
echo -n "${ss}" | qrencode -t ansiutf8

if [ "$PublicQR" = "true" ]; then
  [ ! -d /wwwroot/${QR_Path} ] && mkdir /wwwroot/${QR_Path}
  echo "${ss}" | tr -d '\n' > /wwwroot/${QR_Path}/index.html
  echo -n "${ss}" | qrencode -s 6 -o /wwwroot/${QR_Path}/vpn.png
else
  echo "Do not generate QR-code png"
fi

/ssbin/ssserver -c /etc/shadowsocks/config.json &
rm -rf /etc/nginx/sites-enabled/default
nginx -g 'daemon off;'
