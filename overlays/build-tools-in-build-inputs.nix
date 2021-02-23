{ builtAttrs
, packageSet
, namePositions
}@attrs:

final: prev:
let
  inherit (prev) lib;
  inherit (import ../lib { inherit lib; }) checkMkDerivationFor;

  buildTools = [
    "darwin.cctools"
  ];

  checkDerivation = drvArgs: drv:
    (map
      (tool: rec {
        name = "build-tools-in-build-inputs";
        _unused = lib.elem (lib.attrByPath
          (lib.splitString "." tool)
          (throw "‘${tool}’ does not exist in Nixpkgs.")
          prev
        ) (drvArgs.buildInputs or [ ]);
        cond = true;
        msg = ''
          ${tool} is a build tool so it likely goes to `nativeBuildInputs`, not `buildInputs`.
        '';
        locations = [
          (builtins.unsafeGetAttrPos "buildInputs" drvArgs)
        ];
      })
      buildTools
    );

in
  checkMkDerivationFor checkDerivation attrs final prev
