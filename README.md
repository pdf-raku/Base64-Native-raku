Base64-Native-raku
----------------

Faster than average Base 64 encoding and decoding.

[![Actions Status](https://github.com/pdf-raku/Base64-Native-raku/workflows/test/badge.svg)](https://github.com/pdf-raku/Base64-Native-raku/actions)

## Synopsis

```
use Base64::Native;

## Encoding ##

my buf8 $buf = base64-encode("Lorem ipsum");
say $buf;
# Buf[uint8]:0x<54 47 39 79 5a 57 30 67 61 58 42 7a 64 57 30 3d>
say base64-encode("Lorem ipsum", :str);
# TG9yZW0gaXBzdW0=

## Decoding ##

say base64-decode($buf);
# Buf[uint8]:0x<4c 6f 72 65 6d 20 69 70 73 75 6d>
say base64-decode("TG9yZW0gaXBzdW0=").decode;
# "Lorem ipsum"

```

### URI Encoding

By default, codes 62 and 63 are encoded to '+' and '/'. The `:uri` option
maps these to '-' and '_'.
```
use Base64::Native;

my $data = base64-decode("AB+/");
say base64-encode( $data, :str );
# AB+/
say base64-encode( $data, :str, :uri );
# AB-_
```

### URI Decoding

URI and standard (MIME) mappings are both recognized by the `base64-decode` routine.

```
use Base64::Native;

say base64-decode("AB+/");
# Buf[uint8]:0x<00 1f bf>
say base64-decode("AB-_");
# Buf[uint8]:0x<00 1f bf>
```
