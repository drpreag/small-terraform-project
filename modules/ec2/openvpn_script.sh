# Docker volume
OVPN_DATA="/opt/openvpn/ovpn-data-example"

# SET UP OPENVPN, do this only once
# ONLY_ONCE - Create volume out of docker-compose
docker volume create --name "ovpn-data-example"


# ONLY_ONCE - Create and initialize openvpn
docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://bastion.scand-it.com
# ONLY_ONCE - In the below step, you have to provide a password for CA and key
docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki

# Start OpenVPN container with docker-compose
docker-compose up -d
# pr start openvpn wirh docker run
docker run --name openvpn -v $OVPN_DATA:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn

# there is bash alias, used to run docker-compose commands
alias dcr='docker-compose run openvpn'


# Commands to manage users... and stuff
dcr ovpn_getclient_all
dcr ovpn_getclient $USER > /home/pvlajkovic/$USER.ovpn
dcr ovpn_listclients
dcr easyrsa build-client-full $USER <nopass>
dcr ovpn_revokeclient $USER remove

scp pvlajkovic@bastion.scand-it.com:/home/pvlajkovic/pvlajkovic.ovpn ./

# docker-compose.yml
version: '3.9'
services:
  openvpn:
    cap_add:
     - NET_ADMIN
    image: kylemanna/openvpn
    container_name: openvpn
    ports:
     - "1194:1194/udp"
    restart: always
    volumes:
     - ovpn-data-example:/etc/openvpn

volumes:
  ovpn-data-example:
    external: true


new_client () {
	# Generates the custom client.ovpn
	{
	cat /etc/openvpn/server/client-common.txt
	echo "<ca>"
	cat /etc/openvpn/server/easy-rsa/pki/ca.crt
	echo "</ca>"
	echo "<cert>"
	sed -ne '/BEGIN CERTIFICATE/,$ p' /etc/openvpn/server/easy-rsa/pki/issued/"$client".crt
	echo "</cert>"
	echo "<key>"
	cat /etc/openvpn/server/easy-rsa/pki/private/"$client".key
	echo "</key>"
	echo "<tls-crypt>"
	sed -ne '/BEGIN OpenVPN Static key/,$ p' /etc/openvpn/server/tc.key
	echo "</tls-crypt>"
	} > ~/"$client".ovpn
}