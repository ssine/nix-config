{ home-manager, ... }@inputs:
let system = "x86_64-linux";
in
home-manager.lib.homeManagerConfiguration {
  system = "x86_64-linux";
  homeDirectory = "/home/sine";
  username = "sine";
  configuration = import ./home.nix inputs;
}
