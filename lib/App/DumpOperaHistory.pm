package App::DumpOperaHistory;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

$SPEC{dump_opera_history} = {
    v => 1.1,
    summary => 'Dump Opera history',
    description => <<'_',

This script supports Opera 12.x, the last "true" version of Opera. History is
stored in a plaintext file.

_
    args => {
        path => {
            schema => 'filename*',
        },
        detail => {
            schema => 'bool*',
            cmdline_aliases => {l=>{}},
        },
    },
};
sub dump_opera_history {
    my %args = @_;

    my $path = $args{path} // "$ENV{HOME}/.opera/global_history.dat";
    return [412, "Can't find $path"] unless -f $path;
    open my $fh, "<", $path or return [500, "Can't open $path: $!"];

    my @rows;
    my $resmeta = {};
    while (1) {
        my $row = {};
        defined($row->{title}           = <$fh>) or last; chomp $row->{title};
        defined($row->{url}             = <$fh>) or last; chomp $row->{url};
        defined($row->{last_visit_time} = <$fh>) or last; chomp $row->{last_visit_time};
        defined(my $flags               = <$fh>) or last; chomp($flags);

        if ($args{detail}) {
            push @rows, $row;
        } else {
            push @rows, $row->{url};
        }
    }

    $resmeta->{'table.fields'} = [qw/url title last_visit_time/]
        if $args{detail};
    [200, "OK", \@rows, $resmeta];
}

1;
# ABSTRACT:

=head1 SYNOPSIS

See the included script L<dump-opera-history>.


=head1 SEE ALSO

L<App::DumpChromeHistory>

L<App::DumpHistoryHistory>
