package Karasuma::ID;
use strict;
use warnings;
use utf8;
our $VERSION = '1.0';
use Math::BigInt lib => 'GMP';
use Exporter::Lite;

our @EXPORT;

# ------ Definitions ------

use constant KARASUMA_ID_BIT_LENGTH => 128;
use constant KARASUMA_ID_BYTE_LENGTH => KARASUMA_ID_BIT_LENGTH / 8;

push @EXPORT, qw(KARASUMA_ID_BIT_LENGTH KARASUMA_ID_BYTE_LENGTH);

sub define_id_structure {
    my ($class, %args) = @_;
    
    no strict 'refs';
    my $defs = ${$class . '::Defs'} = {};

    $defs->{id} = {
        start => 0,
        length => 128,
        number_format => 'hex',
    };

    return $defs;
}

# ------ Constructors ------

sub new_from_bytes {
    return bless \(defined $_[1] ? $_[1] : ''), $_[0];
}

sub new_from_text {
    return bless \(pack 'H*', defined $_[1] ? $_[1] : ''), $_[0];
}

my $VoidID = "0" x (KARASUMA_ID_BYTE_LENGTH * 2);

sub new_void_id {
    return $_[0]->new_from_text($VoidID);
}

# ------ Properties ------

sub is_valid_id {
    return 0 unless defined ${$_[0]};
    return 0 if utf8::is_utf8(${$_[0]});
    return KARASUMA_ID_BYTE_LENGTH == length ${$_[0]};
}

sub is_equal_id {
    return $_[0]->as_bytes eq $_[1]->as_bytes;
}

sub is_void_id {
    return $_[0]->as_text eq $VoidID;
}

# ------ Serialization ------

sub as_bytes {
    return ${$_[0]};
}

sub as_text {
    return unpack 'H*', ${$_[0]};
}

sub TO_JSON {
    return $_[0]->as_text;
}

sub dump_long {
    my $self = shift;
    my $dump = '';

    my $bin = Math::BigInt->new('0x' . $self->as_text)->as_bin;
    $bin =~ s/^0b//;
    $bin = ('0' x 128) . $bin;
    $bin = substr $bin, -128;

    my $defs = do {
        no strict 'refs';
        ${(ref $self) . '::Defs'} || (ref $self)->define_id_structure;
    };

    my @component = (['id', 0]);
    while (@component) {
        my ($label, $depth) = @{shift @component};
        my $def = $defs->{$label};
        
        my $value = substr $bin, $def->{start}, $def->{length};
        my $m_value = Math::BigInt->new('0b' . $value);
        if ($def->{number_format} eq 'dec') {
            $value = '' . $m_value;
        } elsif ($def->{number_format} eq 'hex') {
            $value = '' . $m_value->as_hex;
        }

        my $name = $value;
        if ($def->{to_string}) {
            if (ref $def->{to_string} eq 'HASH') {
                $name = $def->{to_string}->{$m_value};
                $name = $value if not defined $name;
            }
        }

        $dump .= '  ' x $depth;
        if ($name eq $value) {
            $dump .= sprintf "%s = %s\n",
                $label,
                $value;
        } else {
            $dump .= sprintf "%s = %s (%s)\n",
                $label,
                $name,
                $value;
        }
        unshift @component,
            map { [$_, $depth + 1] } @{$def->{subcomponents} || []};
    }
    
    return $dump;
}

1;
