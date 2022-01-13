#! /usr/bin/env perl6
#Note `zef build .` will run this script
use v6;

class Build {
    need LibraryMake;
    # adapted from deprecated Native::Resources
    #| Sets up a C<Makefile> and runs C<make>.  C<$folder> should be
    #| C<"$folder/resources/libraries"> and C<$libname> should be the name of the library
    #| without any prefixes or extensions.
    our sub make(Str $folder, Str $destfolder, IO() :$libname!, :$target!) {
        my %vars = LibraryMake::get-vars($destfolder);
        %vars<LIB_BASE> = $libname;
        %vars<LIB_NAME> = ~ $target;
        mkdir($destfolder);
	LibraryMake::process-makefile($folder, %vars);
        shell(%vars<MAKE>);
    }

    method build($workdir, Bool :$make = ! $*DISTRO.is-win) {
        my $destdir = 'resources/libraries';
        mkdir 'resources';
        mkdir $destdir;
	my $libname = 'base64';
	my IO() $path = $destdir ~ '/' ~ $libname;
        my $target = $*VM.platform-library-name($path);
	if !$make && $target.IO.e {
	    note "using prebuilt library: $target";
	}
	else {
            make($workdir, $destdir, :libname<base64>, :$target);
	}
        True;
    }
}

# Build.pm can also be run standalone
sub MAIN(Str $working-directory = '.', Bool :$make = ! $*DISTRO.is-win ) {
    Build.new.build($working-directory, :$make, :blah(42));
}
