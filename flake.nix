{
  description = "An example NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cn = {
      url = "github:nixos-cn/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # rnix-lsp = {
    #   url = "github:nix-community/rnix-lsp";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neon = {
      url = "git+file:///home/sine/code/ssine/neon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs: {
    nixosConfigurations = {
      code01 = import ./hosts/code01 inputs;
    };
    homeConfigurations = {
      # devbox = import ./hosts/bytedance-devbox inputs;
      wsl = import ./hosts/wsl2 inputs;
    };
    nixopsConfigurations.default = {
      nixpkgs = inputs.nixpkgs;
      network = {
        description = "personal environment";
        storage.memory = { };
      };
      homeserver = import ./hosts/server/configuration.nix inputs;
    };
  };

  nixConfig.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" "https://cache.nixos.org/" ];
}
