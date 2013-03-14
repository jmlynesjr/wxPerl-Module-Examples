#! /home/pete/CitrusPerl/perl/bin/perl

# Create a matrix to hold a bitmap for display definition
# The bitmap will be two dimensional - rows x columns
# 7 rows, columns will be 5x number of characters in the message
# plus the spacing columns.
#
# Based on a wxWidgets C++ application by Christian Gr�fe (info@mcs-soft.de)
# Reimplemented in wxPerl by James M. Lynes, Jr
# Last Modified: March 14, 2013

package LedPanelMatrix;
use strict;
use warnings;
use Wx qw(:everything);
use Data::Dumper;

sub new {
    my $class = shift;
    my $self = {
                width   => 0,
                height  => 0,
		columns => 0,
                matrix => [],
                @_,
               };
    bless($self, $class);
    return $self;
}
1;
#
# Fill a matrix with a source value(s)
#
sub LedPanelMatrix::fill {
    my($class, $self, @source) = @_;
    for my $i (0..($self->{width}-1)) {
        for my $j (0..($self->{height}-1)) {
            push ($self->{matrix}, $source[$i][$j]);
        }
    }
    $self->{columns} = $self->{width};
return;
}
#
# Append a source matrix to a destination matrix - add a character or space matrix to the display matrix
#
sub LedPanelMatrix::append {
    my($class, $destobj, $sourceobj, $tmpobj) = @_;
    my $dw = $destobj->{width};
    my $dh = $destobj->{height};
    my $dc = $destobj->{columns};
    my $sw = $sourceobj->{width};
    my $sh = $sourceobj->{height};
    for my $r (0..$dh-1) {
        if($dc > 0) {
            for my $c (0..$dc-1) {
                $tmpobj->{matrix}[$r][$c] = $destobj->{matrix}[$r][$c];
            }
        }
        my $ctr = $dc;
        for my $c (0..$sw-1) {
            $tmpobj->{matrix}[$r][$ctr] = $sourceobj->{matrix}[$r][$c];
            $ctr++;
        }
    }
    $destobj->{matrix} = $tmpobj->{matrix};
    $destobj->{columns} = $destobj->{columns} + $sourceobj->{width};
}
#
# Shift the matrix left by one column, first column wraps to last column
#
sub LedPanelMatrix::ShiftLeft {
    my($class, $mobj) = @_;
    my $mw = $mobj->{columns};
    my $mh = $mobj->{height};
    my $tmpobj = LedPanelMatrix->new(width => 1, height => $mh);
    for my $r (0..$mh-1) {
        $tmpobj->{matrix}[$r][0] = $mobj->{matrix}[$r][0];
    }
    for my $r (0..$mh-1) {
        for my $c (0..$mw-2) {
            $mobj->{matrix}[$r][$c] = $mobj->{matrix}[$r][$c+1];

        }
        $mobj->{matrix}[$r][$mw-1] = $tmpobj->{matrix}[$r][0];
    }
}
#
# Shift the matrix right by one column, last column wraps to first column
#
sub LedPanelMatrix::ShiftRight {
    my($class, $mobj) = @_;
    my $mw = $mobj->{columns};
    my $mh = $mobj->{height};
    my $tmpobj = LedPanelMatrix->new(width => 1, height => $mh);
    for my $r (0..$mh-1) {
        $tmpobj->{matrix}[$r][0] = $mobj->{matrix}[$r][$mw-1];
    }
    for my $r (0..$mh-1) {
        for my $c (0..$mw-2) {
            $mobj->{matrix}[$r][$mw-1-$c] = $mobj->{matrix}[$r][$mw-2-$c];

        }
        $mobj->{matrix}[$r][0] = $tmpobj->{matrix}[$r][0];
    }
}
#
# Shift the matrix up by one row, top row wraps to bottom row
#
sub LedPanelMatrix::ShiftUp {
    my($class, $mobj) = @_;
    my $mw = $mobj->{columns};
    my $mh = $mobj->{height};
    my $tmpobj = LedPanelMatrix->new(width => $mw, height => 1);
    for my $c (0..$mw-1) {
        $tmpobj->{matrix}[0][$c] = $mobj->{matrix}[0][$c];
    }
    for my $c (0..$mw-1) {
        for my $r (0..$mh-2) {
            $mobj->{matrix}[$r][$c] = $mobj->{matrix}[$r+1][$c];

        }
        $mobj->{matrix}[$mh-1][$c] = $tmpobj->{matrix}[0][$c];
    }
}
#
# Shift the matrix down by one row, bottom row wraps to top row
#
sub LedPanelMatrix::ShiftDown {
    my($class, $mobj) = @_;
    my $mw = $mobj->{columns};
    my $mh = $mobj->{height};
    my $tmpobj = LedPanelMatrix->new(width => $mw, height => 1);
    for my $c (0..$mw-1) {
        $tmpobj->{matrix}[0][$c] = $mobj->{matrix}[$mh-1][$c];
    }
    for my $c (0..$mw-1) {
        for my $r (0..$mh-2) {
            $mobj->{matrix}[$mh-$r-1][$c] = $mobj->{matrix}[$mh-$r-2][$c];

        }
        $mobj->{matrix}[0][$c] = $tmpobj->{matrix}[0][$c];
    }
}

