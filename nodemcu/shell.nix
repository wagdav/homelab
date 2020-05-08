with import <nixpkgs> {};

let

  firmware = fetchurl {
    url = "https://github.com/arendst/Tasmota/releases/download/v8.2.0/tasmota.bin";
    sha256 = "12a03e7f486c2974a79f058f0a94cc063c8aa35550370e5e9e2764ec99bc341a";
  };

in

mkShell {
  buildInputs = [ esptool picocom ];

  shellHook = ''
    PORT=/dev/ttyUSB0
    BAUD=115200

    flash_erase() {
      esptool.py --baud $BAUD --port $PORT erase_flash
    }

    flash_write() {
      esptool.py --baud $BAUD --port $PORT write_flash -fs 1MB -fm dout 0x0 ${firmware}
    }

    serial_terminal() {
      picocom --baud $BAUD --omap crcrlf --echo $PORT
    }

    commit() {
      picocom --baud $BAUD --quiet --exit-after 1000 $PORT
    }

    device_reset() {
      echo "Reset 1"
    }

    device_config() {
      if [ "$#" -ne 2 ]; then
        echo "Usage: device_config WIFI_SSID WIFI_KEY" >&2
        exit 1
      fi

      WIFI_SSID="$1"
      WIFI_KEY="$2"

      echo -n "Backlog "

      echo -n "SSID1 $WIFI_SSID;"
      echo -n "Password1 $WIFI_KEY;"

      echo -n "MqttHost mqtt.thewagner.home;"
      echo -n "MqttUser 0;"
      echo -n "MqttPassword 0;"

      echo -n "Module 34;"

      echo ""
    }
  '';
}
