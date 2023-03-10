{ nixpkgs ? import <nixpkgs> {}, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, arithmoi, base, bv, bytestring, directory
      , http-media, lib, lucid, network, scotty, servant, servant-server
      , sqlite-simple, text, time, wai, wai-middleware-static, warp
      }:
      mkDerivation {
        pname = "9k";
        version = "0";
        src = ./.;
        enableSharedExecutables = false;
        enableSharedLibraries = false;
        configureFlags = [
          "--ghc-option=-optl=-static"
          "--ghc-option=-optl=-pthread"
          "--ghc-option=-optl=-L${pkgs.gmp6.override { withStatic = true; }}/lib"
          "--ghc-option=-optl=-L${pkgs.zlib.static}/lib"
          "--ghc-option=-optl=-L${pkgs.glibc.static}/lib"
        ];
        isLibrary = true;
        isExecutable = true;
        libraryHaskellDepends = [ base ];
        executableHaskellDepends = [
          arithmoi base bv bytestring directory http-media lucid network
          scotty servant servant-server sqlite-simple text time wai
          wai-middleware-static warp
        ];
        license = lib.licenses.bsd3;
        mainProgram = "9k";
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
