{
  description = "An example NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cn = {
      url = "github:nixos-cn/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-cn }: {
    nixosConfigurations = {
      code01 = import ./hosts/code01 { inherit nixpkgs home-manager nixos-cn; };
    };
    homeConfigurations.sine = home-manager.lib.homeManagerConfiguration {
      system = "x86_64-linux";
      homeDirectory = "/home/sine";
      username = "sine";
      configuration = import ./hosts/wsl2/home.nix;
    };
    homeConfigurations."liusiyao.sine" = home-manager.lib.homeManagerConfiguration {
      system = "x86_64-linux";
      homeDirectory = "/home/liusiyao.sine";
      username = "liusiyao.sine";
      configuration = import ./hosts/bytedance-devbox/home.nix;
    };
  };

  nixConfig.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" "https://cache.nixos.org/" ];
}
