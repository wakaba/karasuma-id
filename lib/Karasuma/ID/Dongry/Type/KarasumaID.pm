package Karasuma::ID::Dongry::Type::KarasumaID;
use strict;
use warnings;
use Class::Registry;
use Dongry::Type -Base;

Class::Registry->default(karasuma_id => 'Karasuma::ID');

our $VoidID;

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
            $VoidID ||= Class::Registry->require('karasuma_id')->new_void_id;
            return $VoidID->as_bytes;
        }
    },
};

$Dongry::Types->{karasuma_id_optional} = {
    parse => sub {
        if (not defined $_[0]) {
            return undef;
        } else {
            my $id = Class::Registry->require('karasuma_id')->new_from_bytes($_[0]);
            $VoidID ||= Class::Registry->require('karasuma_id')->new_void_id;
            if ($id->is_equal_id($VoidID)) {
                return undef;
            } else {
                return $id;
            }
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
            $VoidID ||= Class::Registry->require('karasuma_id')->new_void_id;
            return $VoidID->as_bytes;
        }
    },
};

1;
