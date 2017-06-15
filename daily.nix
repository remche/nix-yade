with (import <nixpkgs> {});

let 

  pythonPackages = python27Packages;

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

    minieigen = minieigen;

    yade-daily = stdenv.mkDerivation rec {

      name = "yade-daily";

      nativeBuildInputs = [pkgconfig cmake makeWrapper python2Packages.wrapPython];

      buildInputs = [ 
        boost.dev cgal loki python27Full python27Packages.numpy eigen3_3 bzip2.dev zlib.dev 
        openblas vtk gmp gmp.dev gts metis mpfr mpfr.dev suitesparse glib.dev pcre.dev minieigen
      ];

      pythonPath = with pythonPackages; [
                        pygments pexpect decorator numpy
                        ipython ipython_genutils traitlets
                        enum six boost minieigen
                      ];


      src = fetchgit
      {
        url = "git://github.com/yade/trunk.git";
        rev = "52aa595c23bbadea83704bf687f7996acf075a25";
	sha256 = "09q4g136vrcfc8pd3iviw21ypknaynssx6ibcyjmppaa5a7q2vdx";
      };

      postInstall = ''
        wrapPythonPrograms
      '';


      enableParallelBuilding = true;

      system = builtins.currentSystem;

      preConfigure = ''
        cmakeFlags="-DCMAKE_INSTALL_PREFIX=$out -DENABLE_GUI=OFF -DSUFFIX=daily"
      '';

    };

 }

