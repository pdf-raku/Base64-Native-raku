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
        my %vars = LibraryMake::get-vars($destfolder);
        %vars<LIB_BASE> = $libname;
        %vars<LIB_NAME> = ~ $*VM.platform-library-name($libname);
        mkdir($destfolder);
        LibraryMake::process-makefile($folder, %vars);
        my $proc = shell(%vars<MAKE>);
	if $proc.exitcode && Rakudo::Internals.IS-WIN {
	    #issue #1
	    note 'oops, lets try that again with gcc/make under mingw...';
	    %vars<MAKE> = 'make';
	    %vars<CC> = 'gcc';
	    %vars<CCFLAGS> = '-fPIC -O3 -DNDEBUG --std=gnu99 -Wextra -Wall';
	    %vars<LD> = 'gcc';
	    %vars<LDSHARED> = '-shared';
	    %vars<LDFLAGS> = '-fPIC -O3';
	    %vars<CCOUT> = '-o ';
	    %vars<LDOUT> = '-o ';
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
