
<!--#echo json="package.json" key="name" underline="=" -->
flasher
=======
<!--/#echo -->


Upload firmware
---------------

```bash
$ upyu-flasher erase_flash
$ upyu-flasher upload_firmware firmware.stable/esp8266-20190529-v1.11.bin
```


REPL terminal
-------------

```bash
$ upyu-flasher repl
```


WiFi setup
----------

```bash
$ upyu-flasher setup_wifi nm_cfg wifi.cfg/smarthome.ini ip doorknob
```

* Read SSID, PSK, IP address etc. from NetworkManager config file
  `wifi.cfg/smarthome.ini`,
* but override the IP address with what `/etc/hosts` has for hostname
  `doorknob`.
  * Also sets hostname to `doorknob` since no other hostname was given
    in this command.
* Upload as `_cfg_wifi.py`, and also apply it.


