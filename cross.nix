# run as
# nix-build -A socat.crossDrv
let
  # Base packages
  fetchFromGitHub = (import <nixpkgs> {}).fetchFromGitHub;
  nixpkgs =
    fetchFromGitHub
      {
        /* owner = "NixOS"; */
        /* repo = "nixpkgs-channels"; */
        # Nix 14.04-small
        /* rev = "8a3eea054838b55aca962c3fbde9c83c102b8bf2"; */
        /* sha256 = "1i2s1n7kq16932xf0p4ffgp7rs1j71yzny8kk2r2nyj48i8njqkx"; */
        # Nix 15.09-small
        /* rev = "a888bbacb1d37c800b183fad1e721da31206864b"; */
        /* sha256 = "0yq9frfvnf4mscsm9w751kssclwh6mv0sq4shki0l29gshglbvig"; */
        # Nix 16.03-small
        /* rev = "c1c0484041ab6f9c6858c8ade80a8477c9ae4442"; */
        /* sha256 = "14zivn0wcqh07dw2vy9n6k7s3b2xdq1x37ziqmk2j7zxgx61f5xs"; */
        # HEAD
        /* rev = "210b3b3184b27be8597f320fc9f337d3997dce94"; */
        /* sha256 = "03gl40738zyrsg5md5l5gyi5d1f5h4h4kbliissbxi4q7qwr38v5"; */
        # https://github.com/NixOS/nixpkgs/pull/18386
        owner = "DavidEGrayson";
        repo = "nixpkgs";
        rev = "873da5aa4014fb836a19f3afc2a848443ff2ede8";
        sha256 = "047km1cnkalbjf9nwvw3ixi29c0h48xyjigccsgmingbbx2ig1pn";
        # https://github.com/NixOS/nixpkgs/compare/master...DavidEGrayson:cross_system_fixes_2
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

in
  import nixpkgs
    {
      crossSystem = {
        /* config = "mips-unknown-linux"; */
        config = "i686-unknown-linux";
        bigEndian = true;
        /* arch = "mips"; */
        /* arch = "i686"; */
        arch = "i386";
        float = "soft";
        withTLS = true;
        /* libc = "glibc"; # "uclibc"; ? */
        libc = "uclibc";
        platform = pc32 // {
          name = "tpsys";
          kernelMajor = "2.6"; # 2.6.16.20
          /* kernelArch = "mips32"; */
        };
        openssl.system = "linux-generic32";
        gcc = {
          arch = "i686";
          /* arch = "mips32"; */
        };
      };
      config = {
        packageOverrides = super:
          let self = super.pkgs;
          in
            with self.stdenv.lib;
            {
              uclibc = overrideDerivation super.uclibc
                (oldAttrs:
                  {
                    # UCLIBC_SUSV4_LEGACY defines 'usleep', needed for socat dependency libxio.a
                    nixConfig = oldAttrs.nixConfig + ''
                      UCLIBC_SUSV3_LEGACY y
                    '';
                  }
                );
              nix = overrideDerivation super.nix
                (oldAttrs:
                  {
                    /* postUnpack="" */
                  }
                );
              readline = overrideDerivation super.readline
                (oldAttrs: 
                  {
                    /* dontStrip = true; */
                    /* bash_cv_func_sigsetjmp = "missing"; */
                    bash_cv_wcwidth_broken = "no";
                  }
                );
              socat = overrideDerivation super.socat
                (oldAttrs:
                  {
                    gcc = self.gcc49;
                    /* libc = self.pkgs.glibc_multi; */
                    /* libc = self.pkgs.libcCross; */
                    /* libc = self.pkgs.uclibc; */
                  }
                );
              /* petool = self.callPackage (self.fetchFromGitHub { */
              /*   owner = "cnc-patch"; */
              /*   repo = "petool"; */
              /*   rev = "f0231058829dcb34f04d0e427b464371a44f8522"; */
              /*   sha256 = "0qjf4bzj52j6sw4rl7nndkz335k1vjgfd13lrqwihsjhicbyj71m"; */
              /* }) {}; */
              /* mkCncGame = self.callPackage ./template.nix {}; */
            };
      };
    }

