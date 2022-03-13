{ nixpkgs, home-manager, ... }:
let system = "x86_64-linux";
in
nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ./configuration.nix
    ../../modules/os/core.nix
    ../../modules/os/desktop.nix
    ../../modules/virtualbox
    {
      users.users.sine = {
        isNormalUser = true;
        hashedPassword = "$6$viGXSwfbN8Jg$6XMLyK1D7DXDQD08uqeewkWLZGNT2ByG/sUxEnN.OM/MnO457ZjLDKvaOroShlwA7Se4w1JFAtQkg5Y6wApk30";
        extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
        shell = pkgs.zsh;
      };
    }
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.sine = {
        imports = [
          ../../modules/home-manager/konsole
          ../../modules/home-manager/vscode
          ../../modules/home-manager/zsh
        ];
      };
    }
  ];
}
