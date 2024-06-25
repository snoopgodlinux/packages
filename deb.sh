#!/bin/bash
#
# [Release]: SnoopGod 24.04.2 LTS amd64
# [Website]: https://snoopgod.com/releases/?ver=24.04.2
# [License]: http://www.gnu.org/licenses/gpl-3.0.html

## ---------------- ##
## DEFINE FUNCTIONS ##
## ---------------- ##

## Packages local path
## -------------------
packagesdir="/media/neoslab/Works/Server/www.snoopgod.com/packages/"

## Build Debian Packages
## ---------------------
function buildpackages()
{
    # Define `basepath`
    basepath=$(pwd)

    # Create build directory
    mkdir "$basepath/build"

    # Correct user permissions
    find $basepath/. -type f -name "postinst" -exec chmod +x {} \;
    find $basepath/. -type f -name "preinst" -exec chmod +x {} \;

    # Generate DEB packages
    echo -e "---------------------------------------------------------------"
    for basedir in "$basepath"/*;
    do
        for deb in "$basedir"/*;
        do
            if test -d "$deb";
            then
                category="$(basename -- $basedir)"
                mkdir -p "$basepath/build/$category"

                debname="${deb##*/}"
                echo -e "Building $debname DEB package"
                echo -e "---------------------------------------------------------------"
                dpkg-deb --build --root-owner-group $deb
                ar x "$deb.deb"
                unzstd "$basepath/control.tar.zst"
                unzstd "$basepath/data.tar.zst"
                xz --threads=0 --verbose "$basepath/control.tar"
                xz --threads=0 --verbose "$basepath/data.tar"
                rm -f "$deb.deb"
                ar cr "$deb.deb" debian-binary "$basepath/control.tar.xz" "$basepath/data.tar.xz"
                rm -f debian-binary "$basepath/control.tar" "$basepath/control.tar.xz" "$basepath/control.tar.zst" "$basepath/data.tar" "$basepath/data.tar.xz" "$basepath/data.tar.zst"
                mv "$deb.deb" "$basepath/build/$category"
                reprepro -V --basedir $packagesdir -S $category includedeb noble "$basepath/build/$category/$debname.deb"
                echo -e "---------------------------------------------------------------"
            fi
        done
    done

    # Remove build directory
    rm -rf "$basepath/build"

}

## -------------- ##
## EXECUTE SCRIPT ##
## -------------- ##

## Launch
## ------
function launch()
{
	# Build Packages
	buildpackages
}

## -------- ##
## CALLBACK ##
## -------- ##

launch
