#! /usr/bin/env perl6
#Note `zef build .` will run this script
use v6;
class Build {
    use Native::Compile;

    method build($dir, Bool :$make = ! $*DISTRO.is-win) {
        my $destdir = 'resources/libraries';
        mkdir 'resources';
        mkdir $destdir;
	my $libname = 'base64';
	my IO() $path = $destdir ~ '/' ~ $libname;
        my $target = $*VM.platform-library-name($path);
	if !$make && $target.IO.e {
	    # to allow distribution of precompiled binaries
	    note "using prebuilt library: $target";
	}
	else {
            build :$dir, :lib<base64>, :src<src/base64.c>;
	}
        True;
    }
}

# Build.pm can also be run standalone
sub MAIN(Str $working-directory = '.', Bool :$make = ! $*DISTRO.is-win ) {
    Build.new.build($working-directory, :$make);
}
