{ u-boot-src
, rpi-linux-6_6-src
, rpi-firmware-src
, rpi-firmware-nonfree-src
, rpi-bluez-firmware-src
, buildUBoot
, raspberrypifw
, callPackage
, linux_rpi4
, lib
, ...
}:
let
  # Helpers for building the `pkgs.rpi-kernels' map.
  rpi-kernel = { kernel, version, fw, wireless-fw, argsOverride ? null }:
    let
      new-kernel = linux_rpi4.override {
        argsOverride = {
          src = kernel;
          inherit version;
          modDirVersion = version;
        } // (if builtins.isNull argsOverride then { } else argsOverride);
      };
      new-fw = raspberrypifw.overrideAttrs (oldfw: { src = fw; });
      new-wireless-fw = callPackage wireless-fw { };
      version-slug = builtins.replaceStrings [ "." ] [ "_" ] version;
    in
    {
      kernel = new-kernel;
      firmware = new-fw;
      wireless-firmware = new-wireless-fw;
    };
in
{
  # rpi kernels and firmware are available at
  # `pkgs.rpi-kernels.<VERSION>.{kernel,firmware,wireless-firmware}'. 
  #
  # For example: `pkgs.rpi-kernels.v5_15_87.kernel'
  latest = rpi-kernel {
    version = "6.6.28";
    kernel = rpi-linux-6_6-src;
    fw = rpi-firmware-src;
    wireless-fw = import ./raspberrypi-wireless-firmware.nix {
      bluez-firmware = rpi-bluez-firmware-src;
      firmware-nonfree = rpi-firmware-nonfree-src;
    };
    argsOverride = {
      structuredExtraConfig = with lib.kernel; {
        KUNIT = no;
        GPIO_PWM = no;
      };
    };
  };
}
