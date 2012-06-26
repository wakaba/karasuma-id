use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->parent->subdir('modules', '*', 'lib')->stringify;
use Test::More;
use Test::X1;
use Karasuma::ID;

test {
    ok +KARASUMA_ID_BIT_LENGTH;
    is +KARASUMA_ID_BYTE_LENGTH * 8, KARASUMA_ID_BIT_LENGTH;
    shift->done;
} n => 2;

for my $test (
    [undef, 0, ''],
    ['', 0, ''],
    ['0', 0, '30'],
    ["abcdefghijklmno", 0, "6162636465666768696a6b6c6d6e6f"],
    ["abcdefghijklmnop", 1, "6162636465666768696a6b6c6d6e6f70"],
    ["ABCDEFGHIJKLMNOP", 1, "4142434445464748494a4b4c4d4e4f50"],
    ["\x{FE}\x{EE}\x{CE}\x{aB}31\x{FA}ab\x{21}a\x{09}\x{0A}\x{0C}s\x{0D}", 1, "feeeceab3331fa61622161090a0c730d"],
) {
    test {
        my $id = Karasuma::ID->new_from_bytes($test->[0]);
        is !!$id->is_valid_id, !!$test->[1];
        is $id->as_bytes, defined $test->[0] ? $test->[0] : '';
        is $id->as_text, $test->[2];
        shift->done;
    } n => 3, name => ['new_from_bytes', $test->[0]];
}

for my $test (
    ['', 0, undef],
    ['', 0, ''],
    ["\x{00}", 0, '0', "00"],
    ["abcdefghijklmno", 0, "6162636465666768696a6b6c6d6e6f"],
    ["abcdefghijklmnop", 1, "6162636465666768696a6b6c6d6e6f70"],
    ["ABCDEFGHIJKLMNOP", 1, "4142434445464748494a4b4c4d4e4f50"],
    ["\x{FE}\x{EE}\x{CE}\x{aB}31\x{FA}ab\x{21}a\x{09}\x{0A}\x{0C}s\x{0D}", 1, "feeeceab3331fa61622161090a0c730d"],
) {
    test {
        my $id = Karasuma::ID->new_from_text($test->[2]);
        is !!$id->is_valid_id, !!$test->[1];
        is $id->as_bytes, $test->[0];
        is $id->as_text, $test->[3] || $test->[2] || '';
        ok !$id->is_void_id;
        shift->done;
    } n => 4, name => ['new_from_text', $test->[2]];
}

test {
    my $id = Karasuma::ID->new_void_id;
    is $id->as_text, '00000000000000000000000000000000';
    ok $id->is_void_id;
    shift->done;
} n => 2, name => 'void_id';

test {
    my $id1 = Karasuma::ID->new_from_text('feeeceab3331fa61622161090a0c730d');
    my $id2 = Karasuma::ID->new_from_text('feeeceab3331fa61622161090a0c731d');
    my $id2_2 = Karasuma::ID->new_from_text('feeeceab3331fa61622161090a0c731d');
    
    ok !$id1->is_equal_id($id2);
    ok $id2->is_equal_id($id2);
    ok $id2->is_equal_id($id2_2);
    ok !$id2->is_equal_id($id1);
    ok !$id1->is_void_id;
    shift->done;
} n => 5, name => 'equal_id';

Karasuma::ID->define_id_structure;
test {
    for (values %$Karasuma::ID::Defs) {
        ok defined $_->{start};
        ok $_->{length};
        ok $_->{start} + $_->{length} - 1 < KARASUMA_ID_BIT_LENGTH;
        ok $_->{number_format};
    }
    shift->done;
} n => 4 * (keys %$Karasuma::ID::Defs), name => 'components';

run_tests;

1;
