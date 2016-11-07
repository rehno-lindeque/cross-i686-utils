# run as
# nix-build -A socat.crossDrv -K cross.nix
# see also
# https://github.com/andrew-d/static-binaries
let
  # Base packages
  inherit (import <nixpkgs> {}) fetchFromGitHub;
  nixpkgs =
    fetchFromGitHub
      {
        /* owner = "NixOS"; */
        /* repo = "nixpkgs-channels"; */
        # https://github.com/NixOS/nixpkgs/pull/20108 (Top level cleanup)
        owner = "Ericson2314";
        repo = "nixpkgs";
        rev = "0e81f5a93d4869c768596c5269976fb38d461a1e";
        sha256 = "0hmsdq2whdmz5w3gh7zsz0fmj2dnvrsnq53ygrqn9q9323y4f1bz";
      };
  /* nixpkgs = <nixpkgs>; */

  # From nixpkgs/pkgs/top-level/platforms.nix
  pcBase =
    {
      name = "pc";
      uboot = null;
      kernelHeadersBaseConfig = "defconfig";
      kernelBaseConfig = "defconfig";
      kernelAutoModules = true;
      kernelTarget = "bzImage";
    };

  pc32 = pcBase // { kernelArch = "i386"; };

  pc32_simplekernel = pc32 //
    {
      kernelAutoModules = false;
    };

  cross = {
      config = "i686-unknown-linux";
      bigEndian = true;
      arch = "i386";
      float = "soft";
      withTLS = true;
      libc = "uclibc"; # appears to be easier to cross-compile than glibc
      platform = pc32 // {
        name = "tpsys";
        kernelMajor = "2.6"; # 2.6.16.20
      };
      openssl.system = "linux-generic32";
      gcc.arch = "i686";
      uclibc.extraConfig = ''
        UCLIBC_HAS_RESOLVER_SUPPORT y
        UCLIBC_SUSV3_LEGACY y
      '';
    };
in
  import nixpkgs
    {
      crossSystem = cross;
      config = {
        packageOverrides = super:
          let self = super.pkgs;
          in
            with self.stdenv.lib;
            {
              readline = overrideDerivation super.readline
                (oldAttrs: 
                  {
                    bash_cv_wcwidth_broken = "no";
                  }
                );
            };
      };
    }

