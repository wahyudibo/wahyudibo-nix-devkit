{
  description = "Wahyudibo's DevKit - full reproducible dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Pinned: later revs require go>=1.26, ahead of nixos-25.11's go 1.25.10.
    sops-nix.url = "github:Mic92/sops-nix/f1406619a3884cd5c47992a70b8b35c9c0fcb4c9";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      homeConfigurations = {
        wahyudibo = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home/home.nix
          ];
        };
      };
    };
}
