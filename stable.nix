with (import <nixpkgs> {});

let 

  pythonPackages = python27Packages;

  yade-env = pythonPackages.python.buildEnv.override
                  {
                    extraLibs =
                      with pythonPackages;
                      [
                        pygments
                        pexpect
                        decorator
                        numpy
                        ipython
                        ipython_genutils 
                        traitlets
                        enum
                        six
                        boost
                      ];
                  };


    minieigen = pythonPackages.buildPythonPackage rec {
      name = "minieigen";

      src = pkgs.fetchurl {
        url = "https://github.com/eudoxos/minieigen/archive/master.zip";
        sha256 = "71d91f716aeb85e6433696fc0754c32d8f4956f3685d12df925c2c9183a2a108";
      };

      buildInputs = [ unzip pythonPackages.boost boost.dev eigen3_3 ];

      patchPhase = ''
        sed -i "s/^.*libraries=libraries.//g" setup.py 
      '';

      preConfigure = ''
        export LDFLAGS="-L${eigen3_3.out}/lib -l boost_python"
        export CFLAGS="-I${eigen3_3.out}/include/eigen3"
      '';

    };

in 

 {

    yade-env = buildEnv
      {
        name = "yade-env";
        paths = 
          [
            yade-env
          ];
      };


    yade-stable = stdenv.mkDerivation {

      name = "yade-stable";

      buildInputs = [ 
                 pkgconfig cmake boost.dev python27Packages.boost 
                 cgal loki python27Full python27Packages.numpy python27Packages.ipython 
                 eigen3_3 bzip2.dev zlib.dev openblas vtk gmp gmp.dev gts metis 
                 mpfr mpfr.dev suitesparse glib.dev pcre.dev minieigen
      ];

      src = fetchgit
      {
        url = "https://launchpad.net/yade/trunk/yade-1.00.0/+download/yade-2017.01a.tar.gz";
	md5 = "29f83f12f6cdacfd24f1928d90f72906";
      };

      enableParallelBuilding = true;

      system = builtins.currentSystem;

      preConfigure = ''
        cmakeFlags="-DCMAKE_INSTALL_PREFIX=$out -DENABLE_GUI=OFF -DSUFFIX=stable"
      '';

      patches = [ "./cmake.patch" ];

    };


 }
