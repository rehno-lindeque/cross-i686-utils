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
        /* owner = "DavidEGrayson"; */
        /* repo = "nixpkgs"; */
        /* rev = "873da5aa4014fb836a19f3afc2a848443ff2ede8"; */
        /* sha256 = "047km1cnkalbjf9nwvw3ixi29c0h48xyjigccsgmingbbx2ig1pn"; */
        # https://github.com/NixOS/nixpkgs/compare/master...DavidEGrayson:cross_system_fixes_2
        /* owner = "DavidEGrayson"; */
        /* repo = "nixpkgs"; */
        /* rev = "9cedf1b7a794e70706804b7239807f39c0a76ecb"; */
        /* sha256 = "0p7bd1w8kplrn6dkr1c4lp163l439pmclai2rbfz1p1q09f4p7cv"; */
        # https://github.com/NixOS/nixpkgs/pull/15043
        # TODO?
        # https://github.com/Ericson2314/nixpkgs/tree/vcunat-cross-stdenv
        /* owner = "Ericson2314"; */
        /* repo = "nixpkgs"; */
        /* rev = "5ace2337bcb68ed53df180b9167ed80006209582"; */
        /* sha256 = "1j2hpsdx58qjy8hr1si1vv3drap8lz1jwdzrmq8p9r7r8g7rmbdm"; */
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
              /* uclibcCross = overrideDerivation super.uclibcCross */
              /* uclibcCross = overrideDerivation super.uclibcCross */
              /* libcCross = overrideDerivation super.libcCross */
              uclibc = overrideDerivation super.uclibc
              /* uclibc = super.uclibc.override */
                (oldAttrs:
                  {
                    # UCLIBC_SUSV3_LEGACY defines 'usleep', needed for socat dependency libxio.a
                    /* nixConfig = oldAttrs.nixConfig + '' */
                    /*   UCLIBC_SUSV3_LEGACY y */
                    /* ''; */

                    /* crossAttrs.extraCrossConfig = oldAttrs.crossAttrs.extraCrossConfig + '' */
                    /* crossAttrs.extraCrossConfig = '' */
                    /*   UCLIBC_SUSV3_LEGACY y */
                    /* ''; */
                    /* crossAttrs = { */
                    /*   extraCrossConfig = '' */
                    /*     UCLIBC_SUSV3_LEGACY y */
                    /*     printf "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" &1>2 */
                    /*   ''; */
                    /*   /1* postConfigure = stdenv.lib.optionalString useMusl '' *1/ */
                    /*   /1*   makeFlagsArray+=("CC=$crossConfig-gcc -isystem ${musl.crossDrv}/include -B${musl.crossDrv}/lib -L${musl.crossDrv}/lib") *1/ */
                    /*   /1* ''; *1/ */
                    /* }; */

                    /* # UCLIBC_SUSV3_LEGACY defines 'usleep', needed for socat dependency libxio.a */
                    /* nixConfig = '' */
                    /*   RUNTIME_PREFIX "/" */
                    /*   DEVEL_PREFIX "/" */
                    /*   UCLIBC_HAS_WCHAR y */
                    /*   UCLIBC_HAS_FTW y */
                    /*   UCLIBC_HAS_RPC y */
                    /*   DO_C99_MATH y */
                    /*   UCLIBC_HAS_PROGRAM_INVOCATION_NAME y */
                    /*   UCLIBC_SUSV3_LEGACY y */
                    /*   UCLIBC_HAS_THREADS_NATIVE y */
                    /*   KERNEL_HEADERS "${linuxHeaders}/include" */
                    /* ''; */
                    /* crossAttrs = '' */
                    /*   UCLIBC_SUSV3_LEGACY y */
                    /* ''; */
                    crossAttrs.extraCrossConfig = ''
                      UCLIBC_SUSV3_LEGACY y
                    '';
                    configurePhase = oldAttrs.configurePhase + ''
                      echo "=========================================" &1>2
                      echo "=========================================" &1>2
                      echo "$extraCrossConfig" &1>2
                      echo "=========================================" &1>2
                      echo "=========================================" &1>2
                    '';
                  }
                );
              libcCross = overrideDerivation super.libcCross
                (oldAttrs:
                  {
                    extraCrossConfig = ''
                      UCLIBC_SUSV3_LEGACY y
                      BR2_UCLIBC_CONFIG y
                      UCLIBC_SUSV3_LEGACY_MACROS y
                    '';
                    configurePhase = oldAttrs.configurePhase + ''
                      echo "=========================================" &1>2
                      echo "=========================================" &1>2
                      echo "$extraCrossConfig" &1>2
                      echo "=========================================" &1>2
                      echo "=========================================" &1>2
                      sleep 10;
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
              socat = /* overrideDerivation */ super.socat.override
                (oldAttrs:
                  {
                    /* cc = self.stdenv.gccCross; */
                    /* libccc = self.stdenv.gccCross; */
                    /* libc = self.pkgs.glibc_multi; */
                    /* libc = self.pkgs.libcCross; */
                    /* libc = self.pkgs.uclibc; */
                    /* crossAttrs.extraCrossConfig = '' */
                    /*   UCLIBC_SUSV3_LEGACY y */
                    /* ''; */
                    /* crossAttrs = '' */
                    /*   UCLIBC_SUSV3_LEGACY y */
                    /* ''; */
                    /* configurePhase = '' */
                    /*   gcc --version &1>2 */
                    /*   gcc -print-libgcc-file-name &1>2 */
                    /* ''; #  + oldAttrs.configurePhase; */
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

