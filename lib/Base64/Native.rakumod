use v6;

unit module Base64::Native:ver<0.0.10>;

use NativeCall;

constant BASE64-LIB = %?RESOURCES<libraries/base64>;

sub base64_encode(Blob, size_t, Blob, size_t) is native(BASE64-LIB) { * }
sub base64_encode_uri(Blob, size_t, Blob, size_t)  is native(BASE64-LIB) { * }
sub base64_decode(Blob, size_t, Blob, size_t --> ssize_t)  is native(BASE64-LIB) { * }

sub encode-alloc(Blob:D $in) {
    my \out-blocks = ($in.bytes + 2) div 3;
    buf8.allocate: out-blocks * 4;
}

sub decode-alloc(Blob:D $in) {
    my \out-blocks = ($in.bytes + 3) div 4;
    buf8.allocate: out-blocks * 3;
}

our proto sub base64-encode($, $?, :$enc, :$str, :$uri)  is export { * }

multi sub base64-encode(Str:D $in, :$enc = 'utf8', |c) {
    base64-encode($in.encode($enc), |c)
}
multi sub base64-encode(:$str! where .so, |c --> Str) {
    base64-encode(|c).decode;
}
multi sub base64-encode(Blob:D $in, Blob:D $out = $in.&encode-alloc, :$uri --> Blob) {
    $uri
        ?? base64_encode_uri($in, $in.bytes, $out, $out.bytes)
        !! base64_encode($in, $in.bytes, $out, $out.bytes);
    $out;
}

our proto sub base64-decode($, $?)  is export { * }

multi sub base64-decode(Str:D $in, |c --> Blob) {
    base64-decode($in.encode('latin-1'), |c)
}
multi sub base64-decode(Blob:D $in, Blob:D $out = $in.&decode-alloc --> Blob) {
    my ssize_t $n = base64_decode($in, $in.bytes, $out, $out.bytes);
    die "unable to decode as base64. stopped at byte {-$n}: 0x{$in[1 - $n].base(16)} {$in[1 - $n].chr.raku}"
        if $n < 0;
    $out.reallocate($n)
        if $n < $out.bytes;
    $out;
}
