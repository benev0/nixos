{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.leagacyPackages.${system};
    in
    {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs system;};
          modules = [
            ./hosts/default/configuration.nix
            nixos-hardware.nixosModules.asus-rog-strix-g733qs
          ];
        };
      };
    };
}

