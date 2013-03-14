#! /home/pete/CitrusPerl/perl/bin/perl

# Create a table to hold the color pallet definitions
# One row per pallet
#  0      1     2      3       4       5     6    (array index)
# Red, Green, Blue, Yellow, Magenta, Cyan, Gray
# Each color has 4 shades - base, dark, verydark, & light
#
# Based on a wxWidgets C++ application by Christian Gr�fe (info@mcs-soft.de)
# Reimplemented in wxPerl by James M. Lynes, Jr
# Last Modified: March 14, 2013

package LedPanelColourTbl;
use strict;
use warnings;
use Wx qw(:everything);
use Data::Dumper;

sub new {
    my $class = shift;
    my $self = {
		 base	  =>	[Wx::Colour->new(255,  0,  0),
				 Wx::Colour->new(  0,255,  0),
				 Wx::Colour->new(  0,  0,255),
				 Wx::Colour->new(255,255,  0),
				 Wx::Colour->new(255,  0,255),
				 Wx::Colour->new(  0,255,255),
				 Wx::Colour->new(128,128,128)],

		 dark	  =>	[Wx::Colour->new(128,  0,  0),
				 Wx::Colour->new(  0,128,  0),
				 Wx::Colour->new(  0,  0,128),
				 Wx::Colour->new(128,128,  0),
				 Wx::Colour->new(128,  0,128),
				 Wx::Colour->new(  0,128,128),
				 Wx::Colour->new( 64, 64, 64)],

		 verydark =>	[Wx::Colour->new( 64,  0,  0),
				 Wx::Colour->new(  0, 64,  0),
				 Wx::Colour->new(  0,  0, 64),
				 Wx::Colour->new( 64 ,64,  0),
				 Wx::Colour->new( 64,  0, 64),
				 Wx::Colour->new(  0 ,64, 64),
				 Wx::Colour->new( 32, 32, 32)],

		 light	  =>	[Wx::Colour->new(255,128,128),
				 Wx::Colour->new(128,255,128),
				 Wx::Colour->new(128,128,255),
				 Wx::Colour->new(255,255,128),
				 Wx::Colour->new(255,128,255),
				 Wx::Colour->new(128,255,255),
				 Wx::Colour->new(192,192,192)],		
               };
    bless($self, $class);
    return $self;
}
1;

