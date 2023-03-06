use v6;

unit module Base64::Native:ver<0.0.8>;

use NativeCall;

constant BASE64-LIB = %?RESOURCES<libraries/base64>;

sub base64_encode(Blob, size_t, Blob, size_t) is native(BASE64-LIB) { * }
sub base64_encode_uri(Blob, size_t, Blob, size_t)  is native(BASE64-LIB) { * }
sub base64_decode(Blob, size_t, Blob, size_t --> ssize_t)  is native(BASE64-LIB) { * }

sub encode-alloc(Blob $in) {
    my \out-blocks = ($in.bytes + 2) div 3;
    buf8.allocate: out-blocks * 4;
}

sub decode-alloc(Blob $in) {
    my \out-blocks = ($in.bytes + 3) div 4;
    buf8.allocate: out-blocks * 3;
}

our proto sub base64-encode($, $?, :$enc, :$str, :$uri)  is export { * }

multi sub base64-encode(Str $in, :$enc = 'utf8', |c) {
    base64-encode($in.encode($enc), |c)
}
multi sub base64-encode(:$str! where .so, |c --> Str) {
    base64-encode(|c).decode;
}
multi sub base64-encode(Blob $in, Blob $out = encode-alloc($in), :$uri --> Blob) {
    $uri
        ?? base64_encode_uri($in, $in.bytes, $out, $out.bytes)
        !! base64_encode($in, $in.bytes, $out, $out.bytes);
    $out;
}

our proto sub base64-decode($, $?)  is export { * }

multi sub base64-decode(Str $in, |c --> Blob) {
    base64-decode($in.encode('latin-1'), |c)
}
multi sub base64-decode(Blob $in, Blob $out = decode-alloc($in) --> Blob) {
    my ssize_t $n = base64_decode($in, $in.bytes, $out, $out.bytes);
    die "unable to decode as base64. stopped at byte {-$n}: 0x{$in[-$n - 1].base(16)} {$in[-$n - 1].chr.raku}"
        if $n < 0;
    $out.reallocate($n)
        if $n < $out.bytes;
    $out;
}
