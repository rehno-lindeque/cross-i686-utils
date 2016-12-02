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
        /* rev = "0e81f5a93d4869c768596c5269976fb38d461a1e"; */
        /* sha256 = "0hmsdq2whdmz5w3gh7zsz0fmj2dnvrsnq53ygrqn9q9323y4f1bz"; */
        rev = "96e1220813888f8870de6c3f323db4435f38e849";
        sha256 = "0c22jhrh9wn3p4v42syc9wzq8lhwri4wwsqnnfqqyqgmfq9scjj7";
      };
  /* nixpkgs = <nixpkgs>; */
  nativePkgs = (import nixpkgs {}).pkgs;
  inherit (nativePkgs.lib) traceVal traceShowVal traceShowValMarked;

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
              nix = overrideDerivation super.nix
                (oldAttrs:
                  {
                    /* nativeBuildInputs = traceVal oldAttrs.nativeBuildInputs ++ [ nativePkgs.curl nativePkgs.gnutar ]; */
                    /* preUnpack = '' */
                    /*   echo ".................." &1>2 */
                    /*   cat <<EOF */
                    /*   {oldAttrs.unpackPhase} */
                    /*   EOF &1>2 */
                    /* ''; */

                    unpackPhase = ''
                      runHook preUnpack

                      echo ${oldAttrs.src}  "&&&&&&&&&&&&&&&&&&&&&&&&&&&" &1>2
                      # unpackFile doesn't appear to work for some reason, so we're using our own:
                      # unpackFile ${oldAttrs.src}
                      # xz -d < "${oldAttrs.src}" | ${nativePkgs.gnutar}/bin/tar xf -
                      ${nativePkgs.xz}/bin/xz -d < "${oldAttrs.src}" | tar xf -
                      # cd ${oldAttrs.name}
                      cd nix-1.11.4
                      echo $(pwd) &1>2
                      # ls $(pwd) &1>2
                      echo "---------------------------" &1>2
                      # echo "${super.bzip2.crossDrv}" &1>2
                      locate libbz2 &1>2
                      # ls -R $(locate libbz2) &1>2
                      echo "---------------------------" &1>2
                      # ls -R "${nativePkgs.bzip2.out}" &1>2
                      ls -R "${super.bzip2.crossDrv.dev}" &1>2
                      sleep 10
                      # sourceRoot=`pwd`/`ls -d S*`
                      echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&" &1>2

                      # cp -R {pixie-src} pixie-src
                      # mkdir pypy-src
                      # (cd pypy-src
                      #  tar --strip-components=1 -xjf $ {pypy-src})
                      # chmod -R +w pypy-src pixie-src

                      runHook postUnpack
                    '';

                    postUnpack = oldAttrs.postUnpack +
                      '' export CPATH="${super.bzip2.crossDrv.dev}/include"
                         export NIX_CROSS_LDFLAGS="-L${super.bzip2.crossDrv.out}/lib -rpath-link ${super.bzip2.crossDrv.out}/lib $NIX_CROSS_LDFLAGS"
                         # export NIX_LDFLAGS="-L${super.bzip2.crossDrv.out}/lib -rpath-link ${super.bzip2.crossDrv.out}/lib $NIX_LDFLAGS"
                         # export LDFLAGS="-L${super.bzip2.crossDrv}/lib -rpath-link ${super.bzip2.crossDrv}/lib $NIX_LDFLAGS"
                         # echo 'POSTUNPACK........................................................................' &1>2
                         echo 'POSTUNPACK........................................................................' &1>2
                         echo 'NIX_LDFLAGS' $NIX_LDFLAGS &1>2
                         echo 'POSTUNPACK........................................................................' &1>2
                         echo 'NIX_CROSS_LDFLAGS' $NIX_CROSS_LDFLAGS &1>2
                         echo 'POSTUNPACK........................................................................' &1>2
                         echo 'LDFLAGS' $LDFLAGS &1>2
                         echo 'POSTUNPACK........................................................................' &1>2
                      '';

                    /* buildInputs = super.nix.buildInputs ++ [ super.bzip2.crossDrv ]; */

                    /* configureFlags = oldAttrs.configureFlags + */
                    /*   '' */
                    /*     --with-bzip2=${super.bzip2.crossDrv} */
                    /*   ''; */
                        /* --with-www-curl=${perlPackages.WWWCurl}/${perl.libPrefix} */
                  }
                );
            };
      };
    }

