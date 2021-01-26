{ pkgs ? import <nixpkgs> { } }:
let
  tasmota = import ./tasmota.nix;

  # https://tasmota.github.io/docs/Commands

  # Custom NodeMCU board with an AM-2301 temperature and humidity sensor and an
  # HC-SR501 PIR motion sensor
  # https://tasmota.github.io/docs/PIR-Motion-Sensors/
  config-2c-3a-e8-0e-63-de = [
    {
      cmnd = "Template";
      value = tasmota.template {
        name = "MySensor";
        gpio = {
          GPIO14 = tasmota.component.AM2301;
        };
      };
    }
    {
      cmnd = "SwitchMode1";
      value = 1;
    }
    {
      cmnd = "SwitchTopic";
      value = 0;
    }
    {
      cmnd = "Rule1";
      value = "on Switch1#state=1 do publish stat/%topic%/PIR1 ON endon on Switch1#state=0 do Publish stat/%topic%/PIR1 OFF endon";
    }
    {
      cmnd = "Rule1";
      value = 0;
    }
    {
      cmnd = "Module";
      value = 0;
    }
  ];

  # Custom NodeMCU board with an AM-2301 temperature and humidity sensor on GPIO14
  config-2c-3a-e8-08-23-20 = [
    {
      cmnd = "Template";
      value = tasmota.template {
        name = "MySensor";
        gpio = {
          GPIO14 = tasmota.component.AM2301;
        };
      };
    }
    {
      cmnd = "Module";
      value = 0;
    }
  ];

  # MagicHome LED controller
  config-60-01-94-96-80-4e = [
    {
      cmnd = "Template";
      value = tasmota.template {
        name = "ZJ-ESP-IR-B-v2.3";
        gpio = with tasmota.component; {
          GPIO4 = IRrecv;
          GPIO5 = PWM1;
          GPIO12 = PWM3;
          GPIO13 = PWM2;
        };
      };
    }
    {
      cmnd = "Fade";
      value = 1;
    }
    {
      cmnd = "Speed";
      value = 1;
    }
    {
      cmnd = "Module";
      value = 0;
    }
  ];

  # Sonoff Basic with a switch on GPIO14
  config-60-01-94-68-c8-18 = [
    {
      cmnd = "Template";
      value = tasmota.template {
        name = "Sonoff Basic";
        gpio = with tasmota.component; {
          GPIO0 = Button1;
          GPIO1 = User;
          GPIO2 = User;
          GPIO3 = User;
          GPIO4 = User;
          GPIO12 = Relay1;
          GPIO13 = Led1i;
          GPIO14 = Switch1;
        };
        base = tasmota.base.SonoffBasic;
      };
    }
    {
      cmnd = "Module";
      value = 0;
    }
  ];

  # Sonoff TH16 with an Si7021 temperature and humidity sensor
  config-a4-cf-12-d8-92-ea = [
    {
      cmnd = "Template";
      value = tasmota.template {
        name = "Sonoff TH";
        gpio = with tasmota.component; {
          GPIO0 = Button1;
          GPIO1 = User;
          GPIO2 = User;
          GPIO3 = User;
          GPIO4 = User;
          GPIO12 = Relay1;
          GPIO13 = Led1i;
          GPIO14 = SI7021;
        };
        base = tasmota.base.SonoffTH;
      };
    }
    {
      cmnd = "Module";
      value = 0;
    }
  ];

  # Sonoff TH16 with an Si7021 temperature and humidity sensor
  config-a4-cf-12-d8-a2-dd = [
    {
      cmnd = "Template";
      value = tasmota.template {
        name = "Sonoff TH";
        gpio = with tasmota.component; {
          GPIO0 = Button1;
          GPIO1 = User;
          GPIO2 = User;
          GPIO3 = User;
          GPIO4 = User;
          GPIO12 = Relay1;
          GPIO13 = Led1i;
          GPIO14 = SI7021;
        };
        base = tasmota.base.SonoffTH;
      };
    }
    {
      cmnd = "Module";
      value = 0;
    }
  ];

  backlogMessage = with builtins; config:
    let
      mkCommand = { cmnd, value }: "${cmnd} ${toString value}";
    in
    assert length config <= 30;
    concatStringsSep ";" (map mkCommand config);

  IrRemote1 = {
    # See the command list https://tasmota.github.io/docs/Commands/#light
    "0x00FF906F" = "Dimmer +";
    "0x00FFB847" = "Dimmer -";
    "0x00FFF807" = "Power OFF";
    "0x00FFB04F" = "Power ON";
    # White
    "0x00FFA857" = "Color ffffff"; # W
    # Red shades
    "0x00FF9867" = "Color ff0000"; # R
    "0x00FFE817" = "Color ff5500";
    "0x00FF02FD" = "Color ff8000";
    "0x00FF50AF" = "Color ffd500";
    "0x00FF38C7" = "Color ffff00";
  };

  IrRemote2 = {
    # Green shades
    "0x00FFD827" = "Color 00ff00"; # G
    "0x00FF48B7" = "Color 00ff55";
    "0x00FF32CD" = "Color 00ff80";
    "0x00FF7887" = "Color 00ffd5";
    "0x00FF28D7" = "Color 00d5ff";
  };

  IrRemote3 = {
    # Blue shades
    "0x00FF8877" = "Color 0000ff"; # B
    "0x00FF6897" = "Color 3333ff";
    "0x00FF20DF" = "Color 5500ff";
    "0x00FF708F" = "Color aa00ff";
    "0x00FFF00F" = "Color ff00d4";
    # Schemes
    "0x00FFB24D" = ""; # FLASH
    "0x00FF00FF" = ""; # STROBE
    "0x00FF58A7" = "Scheme 2"; # FADE
    "0x00FF30CF" = "Scheme 4"; # SMOOTH
  };

  ruleMessage = with builtins; keyMap:
    let
      lengthLimit = 511;  # https://tasmota.github.io/docs/Rules/#rule-syntax

      mkRule = code: command: "ON IrReceived#Data=${code} DO ${command} ENDON";

      rules = attrValues (mapAttrs mkRule keyMap);
      message = concatStringsSep " " rules;

    in
    assert stringLength message <= lengthLimit; message;


  send = device: command: value:
    "${pkgs.mosquitto}/bin/mosquitto_pub --host mqtt --topic cmnd/${device}/${command} --message '${toString value}'";

in
pkgs.writeScript "provision.sh" ''
  ${send "tasmota_0E63DE" "Backlog" (backlogMessage config-2c-3a-e8-0e-63-de)}
  ${send "tasmota_082320" "Backlog" (backlogMessage config-2c-3a-e8-08-23-20)}
  ${send "tasmota_68C818" "Backlog" (backlogMessage config-60-01-94-68-c8-18)}
  ${send "tasmota_D892EA" "Backlog" (backlogMessage config-a4-cf-12-d8-92-ea)}
  ${send "tasmota_D8A2DD" "Backlog" (backlogMessage config-a4-cf-12-d8-a2-dd)}

  ${send "tasmota_96804E" "Rule1" (ruleMessage IrRemote1)}
  ${send "tasmota_96804E" "Rule1" 1}
  ${send "tasmota_96804E" "Rule2" (ruleMessage IrRemote2)}
  ${send "tasmota_96804E" "Rule2" 1}
  ${send "tasmota_96804E" "Rule3" (ruleMessage IrRemote3)}
  ${send "tasmota_96804E" "Rule3" 1}
  ${send "tasmota_96804E" "Backlog" (backlogMessage config-60-01-94-96-80-4e)}
''
