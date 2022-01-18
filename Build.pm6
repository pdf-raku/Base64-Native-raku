#! /usr/bin/env perl6
#Note `zef build .` will run this script
use v6;

class Build {
    need LibraryMake;
    # adapted from deprecated Native::Resources

    #| Sets up a C<Makefile> and runs C<make>.  C<$folder> should be
    #| C<"$folder/resources/libraries"> and C<$libname> should be the name of the library
    #| without any prefixes or extensions.
    sub make(Str $folder, Str $destfolder, IO() :$libname!) {
        if Rakudo::Internals.IS-WIN {
            # choco install make mingw
            "Makefile".IO.spurt: "build/makefile-windows".IO.slurp;
            shell("make dll");
        }
        else {
            my %vars = LibraryMake::get-vars($destfolder);
            %vars<LIB_BASE> = $libname;
            %vars<LIB_NAME> = ~ $*VM.platform-library-name($libname);
            mkdir($destfolder);
            LibraryMake::process-makefile($folder, %vars);
            shell(%vars<MAKE>);
        }
    }

    method build($workdir) {

        my $destdir = 'resources/libraries';
        mkdir 'resources';
        mkdir $destdir;
        make($workdir, $destdir, :libname<base64>);
        True;
    }
}

# Build.pm can also be run standalone
sub MAIN(Str $working-directory = '.' ) {
    Build.new.build($working-directory);
}
