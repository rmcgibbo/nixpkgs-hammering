{ pkgs }:

{
  # positive cases
  unused-pattern = pkgs.callPackage ./unused-pattern.nix { };

  # negative cases
  used-pattern = pkgs.callPackage ./used-pattern.nix {
    var1 = 1;
    var2 = 2;
  };
  used-single = pkgs.callPackage ./used-single.nix { };
  unused-single = pkgs.callPackage ./unused-single.nix { };
}
