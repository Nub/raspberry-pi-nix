{
  description = "raspberry-pi nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/9a9960b98418f8c385f52de3b09a63f9c561427a";
    u-boot-src = {
      flake = false;
      url = "https://ftp.denx.de/pub/u-boot/u-boot-2024.04.tar.bz2";
    };
    rpi-linux-6_6-src = {
      flake = false;
      url = "github:raspberrypi/linux/stable_20240423";
    };
    rpi-firmware-src = {
      flake = false;
      url = "github:raspberrypi/firmware/1.20240424";
    };
    rpi-firmware-nonfree-src = {
      flake = false;
      url = "github:RPi-Distro/firmware-nonfree/88aa085bfa1a4650e1ccd88896f8343c22a24055";
    };
    rpi-bluez-firmware-src = {
      flake = false;
      url = "github:RPi-Distro/bluez-firmware/d9d4741caba7314d6500f588b1eaa5ab387a4ff5";
    };
    libcamera-apps-src = {
      flake = false;
      url = "github:raspberrypi/libcamera-apps/v1.4.4";
    };
    libcamera-src = {
      flake = false;
      url = "github:raspberrypi/libcamera/eb00c13d7c9f937732305d47af5b8ccf895e700f"; # v0.2.0+rpt20240418
    };
    libpisp-src = {
      flake = false;
      url = "github:raspberrypi/libpisp/v1.0.5";
    };
    utils.url = "github:numtide/flake-utils";
  };

  outputs = srcs@{ self, utils, nixpkgs, u-boot-src, ... }:   
  utils.lib.eachDefaultSystem (system:
    let
      libcamera = import ./overlays/libcamera.nix (builtins.removeAttrs srcs [ "self" ]);
      pinned = nixpkgs.legacyPackages.${system}.pkgsCross.aarch64-multiplatform;
      # kernel_version = "v6_6_28";
      rpi-kernels = (pinned.callPackage (import ./overlays/kernel.nix) (builtins.removeAttrs srcs [ "self" ]));
      kernel = rpi-kernels.latest.kernel;
      firmware = rpi-kernels.latest.firmware;
      uboot = pinned.ubootRaspberryPi4_64bit;
    in
    {
      overlays = {
        inherit libcamera;
      };

      packages.nixosModules.raspberry-pi = import ./rpi {
        inherit pinned kernel firmware uboot;
        libcamera-overlay = libcamera;
      };

      packages.kernel = kernel; 
      packages.firmware = firmware; 
      packages.uboot = uboot;

      packages.test-nixos = (pinned.nixos {
        imports = [
        # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          self.packages.${system}.nixosModules.raspberry-pi
        ];
      }).config.system.build.sdImage;
    }
    );
}
