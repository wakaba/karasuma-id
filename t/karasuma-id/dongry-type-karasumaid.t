package test::Karasuma::ID::Dongry::Type::KarasumaID;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use lib glob file(__FILE__)->dir->parent->parent->subdir('modules', '*', 'lib')->stringify;
use base qw(Test::Class);
use Test::More;
use Class::Registry;
BEGIN { $INC{'Dongry/Type.pm'} = 1; sub Dongry::Type::import { } }
use Karasuma::ID::Dongry::Type::KarasumaID;
use Karasuma::ID;
Class::Registry->require(karasuma_id => 'Karasuma::ID');

sub _serialize_id : Test(2) {
    my $id1 = Karasuma::ID->new_from_text('feeeceab3331fa61622161090a0c730d');
    is $Dongry::Types->{karasuma_id}->{serialize}->($id1), "\xfe\xee\xce\xab\x33\x31\xfa\x61\x62\x21\x61\x09\x0a\x0c\x73\x0d";
    is $Dongry::Types->{karasuma_id_nullable}->{serialize}->($id1), "\xfe\xee\xce\xab\x33\x31\xfa\x61\x62\x21\x61\x09\x0a\x0c\x73\x0d";
}

sub _serialize_id_invalid : Test(2) {
    my $id1 = Karasuma::ID->new_from_text('feeec abc');
    ok $Dongry::Types->{karasuma_id}->{serialize}->($id1);
    ok $Dongry::Types->{karasuma_id_nullable}->{serialize}->($id1);
}

sub _serialize_id_undef : Test(2) {
    is $Dongry::Types->{karasuma_id}->{serialize}->(undef), "\x00" x 16;
    is $Dongry::Types->{karasuma_id_nullable}->{serialize}->(undef), "\x00" x 16;
}

sub _parse_id : Test(4) {
    my $id1 = $Dongry::Types->{karasuma_id}->{parse}->("\xfe\xee\xce\xab\x33\x31\xfa\x61\x62\x21\x61\x09\x0a\x0c\x73\x0d");
    isa_ok $id1, 'Karasuma::ID';
    is $id1->as_text, 'feeeceab3331fa61622161090a0c730d';

    my $id2 = $Dongry::Types->{karasuma_id_nullable}->{parse}->("\xfe\xee\xce\xab\x33\x31\xfa\x61\x62\x21\x61\x09\x0a\x0c\x73\x0d");
    isa_ok $id2, 'Karasuma::ID';
    is $id2->as_text, 'feeeceab3331fa61622161090a0c730d';
}

sub _parse_id_void : Test(3) {
    my $id1 = $Dongry::Types->{karasuma_id}->{parse}->("\x00" x 16);
    isa_ok $id1, 'Karasuma::ID';
    is $id1->as_text, '00' x 16;

    my $id2 = $Dongry::Types->{karasuma_id_nullable}->{parse}->("\x00" x 16);
    is $id2, undef;
}

sub _parse_id_undef : Test(2) {
    is $Dongry::Types->{karasuma_id}->{parse}->(undef), undef;
    is $Dongry::Types->{karasuma_id_nullable}->{parse}->(undef), undef;
}

sub _parse_id_broken : Test(4) {
    my $id1 = $Dongry::Types->{karasuma_id}->{parse}->("abc def");
    isa_ok $id1, 'Karasuma::ID';
    ok !$id1->is_valid_id;

    my $id2 = $Dongry::Types->{karasuma_id_nullable}->{parse}->("abc def");
    isa_ok $id2, 'Karasuma::ID';
    ok !$id2->is_valid_id;
}

__PACKAGE__->runtests;

1;
