#!/usr/bin/env perl

##-d:DProf

$| = 1;

my $bytes;
while(1) {
    my $len = read(STDIN, $bytes, 4) || exit 0;
    if($len != 4) { die "can't read from stdin"; }
    my $bytes2 = $bytes;
    $len = unpack("N", $bytes);
    if($len > 200*1024*1024) { die "too much data"; }
    $len2 = read(STDIN, $bytes, $len);
    if($len2 != $len) { die "can't read full packet"; }
    syswrite(STDOUT, $bytes2);
    syswrite(STDOUT, $bytes);
}
