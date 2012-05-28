package test::Karasuma::ID;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::More;
use Karasuma::ID;

sub _length : Test(2) {
    ok +KARASUMA_ID_BIT_LENGTH;
    is +KARASUMA_ID_BYTE_LENGTH * 8, KARASUMA_ID_BIT_LENGTH;
}

sub _new_from_bytes : Test(21) {
    for (
        [undef, 0, ''],
        ['', 0, ''],
        ['0', 0, '30'],
        ["abcdefghijklmno", 0, "6162636465666768696a6b6c6d6e6f"],
        ["abcdefghijklmnop", 1, "6162636465666768696a6b6c6d6e6f70"],
        ["ABCDEFGHIJKLMNOP", 1, "4142434445464748494a4b4c4d4e4f50"],
        ["\x{FE}\x{EE}\x{CE}\x{aB}31\x{FA}ab\x{21}a\x{09}\x{0A}\x{0C}s\x{0D}", 1, "feeeceab3331fa61622161090a0c730d"],
    ) {
        my $id = Karasuma::ID->new_from_bytes($_->[0]);
        is !!$id->is_valid_id, !!$_->[1];
        is $id->as_bytes, defined $_->[0] ? $_->[0] : '';
        is $id->as_text, $_->[2];
    }
}

sub _new_from_text : Test(21) {
    for (
        ['', 0, undef],
        ['', 0, ''],
        ["\x{00}", 0, '0', "00"],
        ["abcdefghijklmno", 0, "6162636465666768696a6b6c6d6e6f"],
        ["abcdefghijklmnop", 1, "6162636465666768696a6b6c6d6e6f70"],
        ["ABCDEFGHIJKLMNOP", 1, "4142434445464748494a4b4c4d4e4f50"],
        ["\x{FE}\x{EE}\x{CE}\x{aB}31\x{FA}ab\x{21}a\x{09}\x{0A}\x{0C}s\x{0D}", 1, "feeeceab3331fa61622161090a0c730d"],
    ) {
        my $id = Karasuma::ID->new_from_text($_->[2]);
        is !!$id->is_valid_id, !!$_->[1];
        is $id->as_bytes, $_->[0];
        is $id->as_text, $_->[3] || $_->[2] || '';
    }
}

sub _new_void_id : Test(1) {
    my $id = Karasuma::ID->new_void_id;
    is $id->as_text, '00000000000000000000000000000000';
}

sub _is_equal_id : Test(4) {
    my $id1 = Karasuma::ID->new_from_text('feeeceab3331fa61622161090a0c730d');
    my $id2 = Karasuma::ID->new_from_text('feeeceab3331fa61622161090a0c731d');
    my $id2_2 = Karasuma::ID->new_from_text('feeeceab3331fa61622161090a0c731d');
    
    ok !$id1->is_equal_id($id2);
    ok $id2->is_equal_id($id2);
    ok $id2->is_equal_id($id2_2);
    ok !$id2->is_equal_id($id1);
}

sub _components : Test(20) {
    Karasuma::ID->define_id_structure;
    for (values %$Karasuma::ID::Defs) {
        ok defined $_->{start};
        ok $_->{length};
        ok $_->{start} + $_->{length} - 1 < KARASUMA_ID_BIT_LENGTH;
        ok $_->{number_format};
    }
}

__PACKAGE__->runtests;

1;
