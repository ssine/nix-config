{ home-manager, ... }@inputs:
let system = "x86_64-linux";
in
home-manager.lib.homeManagerConfiguration {
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  modules = [
    (import ./home.nix inputs)
    {
      home = {
        username = "sine";
        homeDirectory = "/home/sine";
        stateVersion = "22.05";
      };
    }
  ];
}
