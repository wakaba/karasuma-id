use strict;
BEGIN {
    my $file_name = __FILE__;
    $file_name =~ s{[^/]+$}{};
    $file_name ||= '.';
    $file_name .= '/../config/perl/libs.txt';
    open my $file, '<', $file_name or die "$0: $file_name: $!";
    unshift @INC, split /:/, scalar <$file>;
}
use warnings;

my $class = $ENV{KARASUMA_ID_CLASS} || 'Karasuma::ID';
my $config_class = $ENV{APP_CONFIG_CLASS};
eval qq{ require $class } or die $@;
if ($config_class) {
    eval qq{ require $config_class } or die $@;
}

my $input = shift || '0000000000000000004f696193000000';
my $id;
if ($input =~ /\\x/) {
    $input =~ s/\\x([0-9A-Fa-f]{2})/pack 'C', hex $1/ge;
    $id = $class->new_from_bytes($input);
} elsif ($input =~ /[^0-9A-Fa-f]/) {
    $id = $class->new_from_bytes($input);
} else {
    $id = $class->new_from_text($input);
}

print $id->dump_long;

1;
