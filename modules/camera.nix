{ config, pkgs, ... }:

let

  dt_ao_overlay = _final: prev: {
    deviceTree = {
      applyOverlays = prev.callPackage ../overlays/apply-overlays-dtmerge.nix { };
      compileDTS = prev.deviceTree.compileDTS;
    };
  };

in

{
  nixpkgs.overlays = [
    (import ../overlays/libcamera.nix)
    dt_ao_overlay
  ];

  environment.systemPackages = with pkgs; [
    (callPackage ../rpicam-apps.nix { })
    libcamera
  ];

  hardware.deviceTree.filter = "bcm2837-rpi-3*";
  hardware.deviceTree.overlays = [{
    name = "ov5647-overlay";
    dtsText = ''
      // SPDX-License-Identifier: GPL-2.0-only
      // Definitions for OV5647 camera module on VC I2C bus
      /dts-v1/;
      /plugin/;

      /{
        compatible = "brcm,bcm2837";

        i2c_frag: fragment@0 {
            target = <&i2c_csi_dsi>;
            __overlay__ {
                #address-cells = <1>;
                #size-cells = <0>;
                status = "okay";

                cam_node: ov5647@36 {
                    compatible = "ovti,ov5647";
                    reg = <0x36>;
                    status = "disabled";

                    clocks = <&cam1_clk>;

                    avdd-supply = <&cam1_reg>;
                    dovdd-supply = <&cam_dummy_reg>;
                    dvdd-supply = <&cam_dummy_reg>;

                    rotation = <0>;
                    orientation = <2>;

                    port {
                        cam_endpoint: endpoint {
                            clock-lanes = <0>;
                            data-lanes = <1 2>;
                            clock-noncontinuous;
                            link-frequencies =
                                /bits/ 64 <297000000>;
                        };
                    };
                };

                vcm_node: ad5398@c {
                    compatible = "adi,ad5398";
                    reg = <0x0c>;
                    status = "disabled";
                    VANA-supply = <&cam1_reg>;
                };
            };
        };

        csi_frag: fragment@1 {
            target = <&csi1>;
            csi: __overlay__ {
                status = "okay";
                brcm,media-controller;

                port {
                    csi_ep: endpoint {
                        remote-endpoint = <&cam_endpoint>;
                        data-lanes = <1 2>;
                    };
                };
            };
        };

        fragment@2 {
            target = <&i2c0if>;
            __overlay__ {
                status = "okay";
            };
        };

        fragment@3 {
            target = <&i2c0mux>;
            __overlay__ {
                status = "okay";
            };
        };

        reg_frag: fragment@4 {
            target = <&cam1_reg>;
            __overlay__ {
                startup-delay-us = <20000>;
            };
        };

        clk_frag: fragment@5 {
            target = <&cam1_clk>;
            __overlay__ {
                status = "okay";
                clock-frequency = <25000000>;
            };
        };

        __overrides__ {
            rotation = <&cam_node>,"rotation:0";
            orientation = <&cam_node>,"orientation:0";
            media-controller = <&csi>,"brcm,media-controller?";
            cam0 = <&i2c_frag>, "target:0=",<&i2c_csi_dsi0>,
                   <&csi_frag>, "target:0=",<&csi0>,
                   <&reg_frag>, "target:0=",<&cam0_reg>,
                   <&clk_frag>, "target:0=",<&cam0_clk>,
                   <&cam_node>, "clocks:0=",<&cam0_clk>,
                   <&cam_node>, "avdd-supply:0=",<&cam0_reg>,
                   <&vcm_node>, "VANA-supply:0=",<&cam0_reg>;
            vcm = <&vcm_node>, "status=okay",
                   <&cam_node>,"lens-focus:0=", <&vcm_node>;
        };
      };

      &cam_node {
        status = "okay";
      };

      &cam_endpoint {
        remote-endpoint = <&csi_ep>;
      };
    '';
  }];
}
