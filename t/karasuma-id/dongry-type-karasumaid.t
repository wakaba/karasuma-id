use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->parent->subdir('modules', '*', 'lib')->stringify;
use Test::X1;
use Test::More;
use Class::Registry;
BEGIN { $INC{'Dongry/Type.pm'} = 1; sub Dongry::Type::import { } }
use Karasuma::ID::Dongry::Type::KarasumaID;
use Karasuma::ID;
Class::Registry->require(karasuma_id => 'Karasuma::ID');

test {
    my $id1 = Karasuma::ID->new_from_text('feeeceab3331fa61622161090a0c730d');
    is $Dongry::Types->{karasuma_id}->{serialize}->($id1), "\xfe\xee\xce\xab\x33\x31\xfa\x61\x62\x21\x61\x09\x0a\x0c\x73\x0d";
    is $Dongry::Types->{karasuma_id_optional}->{serialize}->($id1), "\xfe\xee\xce\xab\x33\x31\xfa\x61\x62\x21\x61\x09\x0a\x0c\x73\x0d";
    shift->done;
} n => 2, name => 'serialize_id';

test {
    my $id1 = Karasuma::ID->new_from_text('feeec abc');
    ok $Dongry::Types->{karasuma_id}->{serialize}->($id1);
    ok $Dongry::Types->{karasuma_id_optional}->{serialize}->($id1);
    shift->done;
} n => 2, name => 'serialize_id invalid';

test {
    is $Dongry::Types->{karasuma_id}->{serialize}->(undef), "\x00" x 16;
    is $Dongry::Types->{karasuma_id_optional}->{serialize}->(undef), "\x00" x 16;
    shift->done;
} n => 2, name => 'serialize_id invalid';

test {
    my $id1 = $Dongry::Types->{karasuma_id}->{parse}->("\xfe\xee\xce\xab\x33\x31\xfa\x61\x62\x21\x61\x09\x0a\x0c\x73\x0d");
    isa_ok $id1, 'Karasuma::ID';
    is $id1->as_text, 'feeeceab3331fa61622161090a0c730d';

    my $id2 = $Dongry::Types->{karasuma_id_optional}->{parse}->("\xfe\xee\xce\xab\x33\x31\xfa\x61\x62\x21\x61\x09\x0a\x0c\x73\x0d");
    isa_ok $id2, 'Karasuma::ID';
    is $id2->as_text, 'feeeceab3331fa61622161090a0c730d';
    shift->done;
} n => 4, name => 'parse_id';

test {
    my $id1 = $Dongry::Types->{karasuma_id}->{parse}->("\x00" x 16);
    isa_ok $id1, 'Karasuma::ID';
    is $id1->as_text, '00' x 16;

    my $id2 = $Dongry::Types->{karasuma_id_optional}->{parse}->("\x00" x 16);
    is $id2, undef;
    shift->done;
} n => 3, name => 'parse_id void';

test {
    is $Dongry::Types->{karasuma_id}->{parse}->(undef), undef;
    is $Dongry::Types->{karasuma_id_optional}->{parse}->(undef), undef;
    shift->done;
} n => 2, name => 'parse_id undef';

test {
    my $id1 = $Dongry::Types->{karasuma_id}->{parse}->("abc def");
    isa_ok $id1, 'Karasuma::ID';
    ok !$id1->is_valid_id;

    my $id2 = $Dongry::Types->{karasuma_id_optional}->{parse}->("abc def");
    isa_ok $id2, 'Karasuma::ID';
    ok !$id2->is_valid_id;
    shift->done;
} n => 4, name => 'parse_id invalid';

run_tests;

1;
