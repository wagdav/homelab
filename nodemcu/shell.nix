with import <nixpkgs> { };
let

  firmware = fetchurl {
    url = "https://github.com/arendst/Tasmota/releases/download/v14.1.0/tasmota.bin";
    sha256 = "sha256-tcy79NlSnmJ3foLfYIDLPbR5fpW9ItVkuApO9+MS9n0=";
  };

in
mkShell {
  buildInputs = [ esptool picocom ];

  shellHook = ''
    PORT=/dev/ttyUSB0
    BAUD=115200

    flash_backup() {
      esptool.py --baud $BAUD --port $PORT read_flash 0x00000 0x100000 image1M.bin
    }

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

      echo -n "MqttHost nuc;"
      echo -n "MqttUser 0;"
      echo -n "MqttPassword 0;"

      echo ""
    }
  '';
}
