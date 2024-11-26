use Test;
use Base64::Native;
use NativeCall;

plan 4;
constant Lib = Base64::Native::BASE64-LIB;

ok Lib.IO.s, "library has been built";
unless Lib.IO.s {
    bail-out "unable to access {Lib.basename}, has it been built, (e.g. 'zef build .' or 'raku Build.rakumod'" ~ ('Makefile'.IO.e ?? ", or 'make'" !! '') ~ ')';
}

for qw<base64_encode base64_encode_uri base64_decode> -> $sym {
    lives-ok({ cglobal(Lib, $sym, Pointer) }, "$sym is present in {Lib.IO.basename}");
}
