#!/system/bin/sh

ssid=$(getprop persist.sys.wifi.rsdb.name)
passwd=$(getprop persist.sys.wifi.rsdb.passwd)
security_type=$(getprop persist.sys.wifi.rsdb.security.type)
ap_band=$(getprop persist.sys.softap.band)
LOGCAT_TAG=softap
interface=wlan1

stop(){
      ndc netd 6001 tether stop
      ndc netd 6002 softap stopap
}

start(){
       sleep 3
       busybox ifconfig $interface down
       ndc netd 5000 softap fwreload $interface AP
       busybox ifconfig $interface up
	   # cat /sys/class/net/wlan1/address | busybox awk -F':' '{print "-"$5$6}'
	   ssid_suffix=`cat /sys/class/net/$interface/address | busybox awk -F':' '{print "-"$5$6}'`
	   #ssid+=$ssid_suffix
       log -t $LOGCAT_TAG "Start wifi softap: name=$ssid, pwd=$passwd"
       echo "Start wifi softap: name=$ssid, pwd=$passwd"

       ndc netd 5001 softap set $interface $ssid broadcast $ap_band $security_type $passwd
       ndc netd 5002 softap startap

		ndc netd 5003 interface setcfg $interface 192.168.43.69 24 broadcast multicast
		ndc netd 5004 tether interface add $interface
		ndc netd 5005 network interface add local $interface
		ndc netd 5006 network route add local $interface 192.168.43.0/24
		ndc netd 5007 ipfwd enable tethering
		ndc netd 5008 tether start 192.168.43.2 192.168.43.254
		#ndc netd 5008 tether start 192.168.42.2 192.168.42.254 192.168.43.2 192.168.43.254 192.168.44.2 192.168.44.254 192.168.45.2 192.168.45.254 192.168.46.2 192.168.46.254 192.168.47.2 192.168.47.254 192.168.48.2 192.168.48.254 192.168.49.2 192.168.49.254

		NETID=$(getprop vendor.netid.wlan0)
		SYSTEM_DNS1=$(getprop net.dns1)
		SYSTEM_DNS2=$(getprop net.dns2)
		ndc netd 5009 tether dns set $NETID $SYSTEM_DNS1 $SYSTEM_DNS2
		ndc netd 5010 nat enable $interface wlan0 1 192.168.43.0/24
		ndc netd 5011 ipfwd add $interface wlan0
}

stop
start

