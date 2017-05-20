#! /usr/bin/env perl6
#Note that this is *not* run during panda install - it is intended to be
# run manually for testing / recompiling without needing to do a 'panda install'
#
# The example here is how the 'make' sub generates the makefile in the above Build.pm file
# and then builds our collection of shared resources
use v6;

class Build {
    need LibraryMake;
    # adapted from deprecated Native::Resources

    #| Sets up a C<Makefile> and runs C<make>.  C<$folder> should be
    #| C<"$folder/resources/lib"> and C<$libname> should be the name of the library
    #| without any prefixes or extensions.
    sub make(Str $folder, Str $destfolder, Str :$libname) {
        my %vars = LibraryMake::get-vars($destfolder);
        my @fake-shared-object-extensions = <.so .dll .dylib>.grep(* ne %vars<SO>);

        %vars<FAKESO> = @fake-shared-object-extensions.map("resources/lib/lib$libname" ~ *).eager;

        my $fake-so-rules = %vars<FAKESO>.map(-> $filename {
            qq{$filename:\n\tperl6 -e "print ''" > $filename}
        }).join("\n");

        mkdir($destfolder);
        LibraryMake::process-makefile($folder, %vars);
        spurt("$folder/Makefile", $fake-so-rules, :append);
        shell(%vars<MAKE>);
    }

    method build($workdir) {
        my $destdir = 'resources/lib';
        mkdir $destdir;
        make($workdir, "$destdir", :libname<buf>);
    }
}

# Build.pm can also be run standalone
sub MAIN(Str $working-directory = '.' ) {
    Build.new.build($working-directory);
}
