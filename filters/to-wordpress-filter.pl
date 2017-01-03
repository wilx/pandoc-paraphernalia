#!/usr/bin/perl
use strict;
use warnings;
use Pandoc::Filter;
use Pandoc::Elements;
use Scalar::Util qw(reftype);
use Data::Dumper;

use Carp;
local $SIG{__WARN__} = sub { print( Carp::longmess (shift) ); };
local $SIG{__DIE__} = sub { print( Carp::longmess (shift) ); };

sub test {
    my $x = $_[0];
    return (defined($x)
            && ((ref($x) ne ''
                 && ((reftype($x) eq 'ARRAY'
                      && scalar(@$x) != 0)
                     || (reftype($x) eq 'HASH'
                         && scalar(keys(%$x)) != 0))
                )
                || (ref($x) eq ''
                    && length($x) != 0))
            ? 1 
            : 0);
}

pandoc_filter Link => sub {
    if (test($_->attr)
        && !test($_->attr->[0])
        && !test($_->attr->[1])
        && !test($_->attr->[2])
        && $_->target->[1] eq ''
        && test($_->content)
        && $_->content->[0]->isa('Pandoc::Document::Str')
        && $_->content->[0]->content eq $_->target->[0]) {
        print STDERR "Changing link to text: ", $_->target->[0], "\n";
        return Str $_->target->[0];
    }
    else {
        return $_;
    }
};
