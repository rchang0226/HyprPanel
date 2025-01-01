{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ags,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forEachSystem = nixpkgs.lib.genAttrs systems;
  in {
    packages = forEachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = ags.lib.bundle {
        inherit pkgs;
        src = ./.;
        name = "hyprpanel"; # name of executable
        entry = "app.ts";

        extraPackages =
          (with ags.packages.${system}; [
            tray
            hyprland
            apps
            battery
            bluetooth
            mpris
            network
            notifd
            powerprofiles
            wireplumber
          ])
          ++ (with pkgs; [
            fish
            typescript
            libnotify
            dart-sass
            fd
            btop
            bluez
            libgtop
            gobject-introspection
            glib
            bluez-tools
            grimblast
            brightnessctl
            gnome-bluetooth
            (python3.withPackages (ps:
              with ps; [
                gpustat
                dbus-python
                pygobject3
              ]))
            matugen
            hyprpicker
            hyprsunset
            hypridle
            wireplumber
            networkmanager
            upower
            gvfs
            swww
            pywal
          ])
          ++ (nixpkgs.lib.optionals (system == "x86_64-linux") [pkgs.gpu-screen-recorder]);
      };
    });

    homeManagerModules.hyprpanel = import ./nix/module.nix self;
  };
}
