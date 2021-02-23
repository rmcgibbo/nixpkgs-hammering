{ builtAttrs
, packageSet
, namePositions
}@attrs:

final: prev:
let
  inherit (prev) lib;
  inherit (import ../lib { inherit lib; }) checkMkDerivationFor;

  buildTools = [
    "antlr"
    "asciidoc"
    "asciidoctor"
    "autoconf"
    "autogen"
    "automake"
    "automoc4"
    "autoreconfHook"
    "bazel"
    "bc"
    "bdf2psf"
    "bison"
    "bmake"
    "breakpointHook"
    "bzip2"
    "bundler"
    "darwin.cctools"
    "cmake"
    "docutils"
    "dos2unix"
    "desktop-file-utils"
    "docbook2x"
    "docbook_xml_dtd_412"
    "docbook_xml_dtd_42"
    "docbook_xml_dtd_43"
    "docbook_xml_dtd_44"
    "docbook_xml_dtd_45"
    "docbook-xsl-nons"
    "docbook-xsl-ns"
    "ensureNewerSourcesForZipFilesHook"
    "extra-cmake-modules"
    "flex"
    "gawk"
    "gcc"
    "gcc10"
    "getopt"
    "git"
    "gnustep-make"
    "gnum4"
    "gnumake"
    "gnused"
    "gogUnpackHook"
    "go-md2man"
    "gtk-doc"
    "gzip"
    "help2man"
    "intltool"
    "libtool"
    "lit"
    "lld"
    "llvm"
    "llvmPackages"
    "makeSetupHook"
    "makeWrapper"
    "man"
    "maven"
    "meson"
    "ninja"
    "nodePackages.node-gyp"
    "nodePackages.node-gyp-build"
    "nodePackages.node-pre-gyp"
    "pandoc"
    "patch"
    "patchelf"
    "pkg-config"
    "poetry"
    "pythonPackages.pytest"
    "qmake4Hook"
    "wrapQtAppsHook"
    "ronn"
    "rpcsvc-proto"
    "rpm"
    "rpmextract"
    "rsync"
    "pythonPackages.setuptools-git"
    "pythonPackages.setuptools-scm"
    "pythonPackages.setuptools-scm-git-archive"
    "pythonPackages.sphinx"
    "squashfsTools"
    "sudo"
    "subversion"
    "swig"
    "unzip"
    "updateAutotoolsGnuConfigScriptsHook"
    "util-linux"
    "vala"
    "wafHook"
    "which"
    "wrapGAppsHook"
    "pythonPackages.wrapPython"
    "qt5.wrapQtAppsHook"
    "xcbuildHook"
    "xcodebuild"
    "xmlto"
    "xvfb_run"
    "yacc"
    "yarn"
    "zip"
  ];

  checkDerivation = drvArgs: drv:
    (map
      (tool: {
        name = "build-tools-in-build-inputs";
        cond = lib.elem (lib.attrByPath (lib.splitString "." tool) (throw "‘${tool}’ does not exist in Nixpkgs.")) (drvArgs.buildInputs or [ ]);
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
