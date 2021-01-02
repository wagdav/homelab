# Generate Tasmota JSON templates
# https://tasmota.github.io/docs/Templates/

let
  Generic' = 18;

  template = { name, gpio, base ? Generic', flag ? 0 }:
    let

      # https://tasmota.github.io/docs/Templates/#gpio
      toList =
        { GPIO0 ? component.None
        , GPIO1 ? component.None
        , GPIO2 ? component.None
        , GPIO3 ? component.None
        , GPIO4 ? component.None
        , GPIO5 ? component.None
        , GPIO9 ? component.None
        , GPIO10 ? component.None
        , GPIO12 ? component.None
        , GPIO13 ? component.None
        , GPIO14 ? component.None
        , GPIO15 ? component.None
        , GPIO16 ? component.None
        ,
        }: [
          GPIO0
          GPIO1
          GPIO2
          GPIO3
          GPIO4
          GPIO5
          GPIO9
          GPIO10
          GPIO12
          GPIO13
          GPIO14
          GPIO15
          GPIO16
        ];

    in

      builtins.toJSON {
        BASE = base;
        FLAG = flag;
        GPIO = toList gpio;
        NAME = name;
      };

  # https://tasmota.github.io/docs/Modules/
  base = {
    SonoffBasic = 1;
    SonoffTH = 4;
    Generic = Generic';
  };

  # https://tasmota.github.io/docs/Components/
  component = {
    AM2301 = 2;
    Button1 = 17;
    IRrecv = 51;
    Led1i = 56;
    None = 0;
    PWM1 = 37;
    PWM2 = 38;
    PWM3 = 39;
    Relay1 = 21;
    SI7021 = 3;
    Switch1 = 9;
    User = 255;
  };

in
{
  inherit component template base;
}
