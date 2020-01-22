# -*- coding: UTF-8, tab-width: 4 -*-

# µPy WiFi docs:
# http://docs.micropython.org/en/latest/library/network.WLAN.html
# STA = Station = Client mode, as opposed to AP = Access Point

# import webrepl
# webrepl.start()

import network

def setup_wifi_basic(ssid, psk, ip, snm, dgw, dns):
    ip_cfg = (ip, (snm or '255.255.255.0'), dgw, (dns or '127.0.0.1'),)

    # ap = network.WLAN(network.AP_IF)
    # ap.active(False)

    cln = network.WLAN(network.STA_IF)
    cln.active(False)
    try:
        cln.disconnect()
    except OSError:
        pass

    cln.active(True)
    cln.ifconfig(ip_cfg)
    cln.connect(ssid, psk)
    return cln


NETWORK_STATUS_NAMES = {
    network.STAT_CONNECT_FAIL:      'connect_fail',     #
    network.STAT_CONNECTING:        'connecting',       #
    network.STAT_GOT_IP:            'got_ip',           #
    network.STAT_IDLE:              'idle',             #
    network.STAT_NO_AP_FOUND:       'no_ap_found',      #
    network.STAT_WRONG_PASSWORD:    'wrong_password',   #
}

def decode_wifi_status(status_num=None):
    if status_num is None:
        status_num = network.WLAN(network.STA_IF).status()
    return NETWORK_STATUS_NAMES.get(status_num)
