#!/usr/bin/with-contenv sh


# Usage:
# . /etc/services.d/_includes/helpers.sh
#


_get_openvpn_device()
{

  if [ ! "$_openvpn_device" ]; then
    _openvpn_config_file="/config/openvpn/default.conf"

    while true; do

      if [ -f "$_openvpn_config_file" ]; then
        _openvpn_device="$(cat "$_openvpn_config_file" | grep -i "^dev " | cut -d ' ' -f2)"
        [ "$_openvpn_device" ] && break
      fi

      sleep 1
    done
    export _openvpn_device
  fi
}

_get_lan_interface()
{
  [ "$_openvpn_device" ] || _get_openvpn_device;

  if [ ! "$lan_interface" ]; then
    while true; do

      _lan_ifaces="$(ls -1 /sys/class/net | grep -v "^lo\|^${_openvpn_device}")"

      for if in eth0 eth1 eth; do
        _lan_iface="$(echo $_lan_ifaces | grep "^$if")"
        [ "$_lan_iface" ] && break
      done

      [ "$_lan_iface" ] || _lan_iface="$(echo $_lan_ifaces | head -1)"
      [ "$_lan_iface" ] && break
      sleep 1
    done
    export lan_interface="$_lan_iface"
  fi  

  export _lan_interface="$lan_interface"
}

_get_lan_ip()
{
  if [ ! "$_lan_ip" ]; then
    [ "$_lan_interface" ] || _get_lan_interface;

    while true; do
      _lan_ip="$(ip -4 -o address show "$_lan_interface" | tr -s ' ' | cut -d' ' -f4 | sed -e 's|/.*||g')"
      [ "$_lan_ip" ] && break
      sleep 1
    done
  fi
  export _lan_ip
}





_wait_for_openvpn()
{
  [ "$_openvpn_device" ] || _get_openvpn_device;
  unset _iface

  while true; do
    for i in $(ls /sys/class/net | grep $_openvpn_device); do
      _iface=$i
      break
    done

    [ "$_iface" ] && break
    sleep 1
  done

  while true; do
    _local_ip="$(ip addr show dev $_iface | grep -o inet.* | cut -d ' ' -f2)"

    [ "$_local_ip" ] && break
    sleep 1
  done

  export _openvpn_local_ip=$_local_ip
  export _openvpn_interface=$_iface
}



