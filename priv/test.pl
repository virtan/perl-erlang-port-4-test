#!/usr/bin/env perl

##-d:DProf

use Erlang::Port4;
#use Data::Dumper;

sub extract_data {
    my $data = shift;
    my $port = shift;

    my $object;
    my @arr;
    foreach my $i (@$data) {
        $object = $port->to_s($$i);
        push @arr, $object;
    }
    $port->_newTuple(\@arr);
}

my $port = Erlang::Port4->new(\&extract_data);
$port->loop();



