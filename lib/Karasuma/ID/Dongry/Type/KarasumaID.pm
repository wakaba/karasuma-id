package Karasuma::ID::Dongry::Type::KarasumaID;
use strict;
use warnings;
use Class::Registry;
use Dongry::Type -Base;

Class::Registry->default(karasuma_id => 'Karasuma::ID');

$Dongry::Types->{karasuma_id} = {
    parse => sub {
        if (not defined $_[0]) {
            return undef;
        } else {
            return Class::Registry->require('karasuma_id')->new_from_bytes($_[0]);
        }
    },
    serialize => sub {
        if (defined $_[0]) {
            if (not ref $_[0]) {
                require Carp;
                Carp::croak("An attempt is made to cast a non-reference into Karasuma ID");
            }
            return $_[0]->as_bytes;
        } else {
            return Class::Registry->require('karasuma_id')->new_void_id->as_bytes;
        }
    },
};

1;
