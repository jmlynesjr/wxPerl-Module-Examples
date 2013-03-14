#! /home/pete/CitrusPerl/perl/bin/perl

# Create a table to hold the character definitions for display definition
# One row per character
# 5x7 matrix - 35 bits
#
# Based on a wxWidgets C++ application by Christian Gr�fe (info@mcs-soft.de)
# Reimplemented in wxPerl by James M. Lynes, Jr
# Last Modified: March 14, 2013

package LedPanelCtbl;
use strict;
use warnings;
use Wx qw(:everything);
use Data::Dumper;

sub new {
    my $class = shift;
    my $self = {
		 0	=>	[0x0E, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0E],
		 1	=>	[0x04, 0x0C, 0x14, 0x04, 0x04, 0x04, 0x0E],
		 2	=>	[0x0E, 0x11, 0x01, 0x02, 0x04, 0x08, 0x1F],
		 3	=>	[0x0E, 0x11, 0x01, 0x0E, 0x01, 0x11, 0x0E],
		 4	=>	[0x02, 0x06, 0x0A, 0x12, 0x1F, 0x02, 0x02],
		 5	=>	[0x1F, 0x10, 0x10, 0x0E, 0x01, 0x01, 0x1E],
		 6	=>	[0x06, 0x08, 0x10, 0x1E, 0x11, 0x11, 0x0E],
		 7	=>	[0x1F, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08],
		 8	=>	[0x0E, 0x11, 0x11, 0x0E, 0x11, 0x11, 0x0E],
		 9	=>	[0x0E, 0x11, 0x11, 0x0F, 0x01, 0x01, 0x0E],
		 A	=>	[0x0E, 0x11, 0x11, 0x11, 0x1F, 0x11, 0x11],
		 B	=>	[0x1E, 0x11, 0x11, 0x1E, 0x11, 0x11, 0x1E],
		 C	=>	[0x0E, 0x11, 0x10, 0x10, 0x10, 0x11, 0x0E],
		 D	=>	[0x1C, 0x12, 0x11, 0x11, 0x11, 0x12, 0x1C],
		 E	=>	[0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x1F],
		 F	=>	[0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x10],
		 G	=>	[0x0E, 0x11, 0x10, 0x17, 0x11, 0x11, 0x0E],
		 H	=>	[0x11, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11],
		 I	=>	[0x0E, 0x04, 0x04, 0x04, 0x04, 0x04, 0x0E],
		 J	=>	[0x07, 0x02, 0x02, 0x02, 0x02, 0x12, 0x0C],
		 K	=>	[0x11, 0x12, 0x14, 0x18, 0x14, 0x12, 0x11],
		 L	=>	[0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1F],
		 M	=>	[0x11, 0x1B, 0x15, 0x15, 0x11, 0x11, 0x11],
		 N	=>	[0x11, 0x19, 0x15, 0x13, 0x11, 0x11, 0x11],
		 O	=>	[0x0E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E],
		 P	=>	[0x1E, 0x11, 0x11, 0x1E, 0x10, 0x10, 0x10],
		 Q	=>	[0x0E, 0x11, 0x11, 0x11, 0x15, 0x0E, 0x01],
		 R	=>	[0x1E, 0x11, 0x11, 0x1E, 0x14, 0x12, 0x11],
		 S	=>	[0x0E, 0x11, 0x10, 0x0E, 0x01, 0x11, 0x0E],
		 T	=>	[0x1F, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04],
		 U	=>	[0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E],
		 V	=>	[0x11, 0x11, 0x11, 0x11, 0x11, 0x0A, 0x04],
		 W	=>	[0x11, 0x11, 0x11, 0x15, 0x15, 0x1B, 0x11],
		 X	=>	[0x11, 0x11, 0x0A, 0x04, 0x0A, 0x11, 0x11],
		 Y	=>	[0x11, 0x11, 0x0A, 0x04, 0x04, 0x04, 0x04],
		 Z	=>	[0x1F, 0x01, 0x02, 0x04, 0x08, 0x10, 0x1F],
		 a      =>	[0x00, 0x00, 0x0E, 0x01, 0x0F, 0x11, 0x0F],
		 b      =>	[0x10, 0x10, 0x1E, 0x11, 0x11, 0x11, 0x1E],
		 c      =>	[0x00, 0x00, 0x0F, 0x10, 0x10, 0x10, 0x0F],
		 d      =>	[0x01, 0x01, 0x0F, 0x11, 0x11, 0x11, 0x0F],
		 e      =>	[0x00, 0x00, 0x0E, 0x11, 0x1F, 0x10, 0x0E],
		 f      =>	[0x06, 0x08, 0x08, 0x1C, 0x08, 0x08, 0x08],
		 g      =>	[0x00, 0x0E, 0x11, 0x11, 0x0F, 0x01, 0x0E],
		 h      =>	[0x10, 0x10, 0x16, 0x19, 0x11, 0x11, 0x11],
		 i      =>	[0x04, 0x00, 0x0C, 0x04, 0x04, 0x04, 0x0E],
		 j      =>	[0x02, 0x00, 0x06, 0x02, 0x02, 0x0A, 0x04],
		 k      =>	[0x10, 0x10, 0x12, 0x14, 0x18, 0x14, 0x12],
		 l      =>	[0x0C, 0x04, 0x04, 0x04, 0x04, 0x04, 0x0E],
		 m      =>	[0x00, 0x00, 0x1A, 0x15, 0x15, 0x15, 0x15],
		 n      =>	[0x00, 0x00, 0x16, 0x19, 0x11, 0x11, 0x11],
		 o      =>	[0x00, 0x00, 0x0E, 0x11, 0x11, 0x11, 0x0E],
		 p      =>	[0x00, 0x00, 0x1C, 0x12, 0x12, 0x1C, 0x10],
		 q      =>	[0x00, 0x00, 0x0E, 0x12, 0x12, 0x0E, 0x02],
		 r      =>	[0x00, 0x00, 0x16, 0x18, 0x10, 0x10, 0x10],
		 s      =>	[0x00, 0x00, 0x0E, 0x10, 0x0E, 0x01, 0x0E],
		 t      =>	[0x08, 0x08, 0x1C, 0x08, 0x08, 0x0A, 0x04],
		 u      =>	[0x00, 0x00, 0x11, 0x11, 0x11, 0x11, 0x0E],
		 v      =>	[0x00, 0x00, 0x11, 0x11, 0x11, 0x0A, 0x04],
		 w      =>	[0x00, 0x00, 0x11, 0x11, 0x15, 0x15, 0x0A],
		 x      =>	[0x00, 0x00, 0x11, 0x0A, 0x04, 0x0A, 0x11],
		 y      =>	[0x00, 0x00, 0x11, 0x0A, 0x04, 0x04, 0x04],
		 z      =>	[0x00, 0x00, 0x1F, 0x02, 0x04, 0x08, 0x1F],
		'!'     =>	[0x04, 0x04, 0x04, 0x04, 0x04, 0x00, 0x04],
		'"'     =>	[0x0A, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00],
		'#'     =>	[0x0A, 0x0A, 0x1F, 0x0A, 0x1F, 0x0A, 0x0A],
		'$'     =>	[0x04, 0x0E, 0x10, 0x0E, 0x01, 0x0E, 0x04],
		'%'     =>	[0x01, 0x09, 0x02, 0x04, 0x08, 0x12, 0x10],
		'&'     =>	[0x0C, 0x12, 0x12, 0x0C, 0x13, 0x12, 0x0D],
		'('     =>	[0x02, 0x04, 0x08, 0x08, 0x08, 0x04, 0x02],
		')'     =>	[0x08, 0x04, 0x02, 0x02, 0x02, 0x04, 0x08],
		'*'     =>	[0x00, 0x04, 0x15, 0x0E, 0x15, 0x04, 0x00],
		'+'     =>	[0x00, 0x04, 0x04, 0x1F, 0x04, 0x04, 0x00],
		','     =>	[0x00, 0x00, 0x00, 0x00, 0x08, 0x08, 0x10],
		'-'     =>	[0x00, 0x00, 0x00, 0x0E, 0x00, 0x00, 0x00],
		'.'     =>	[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10],
		'/'     =>	[0x01, 0x01, 0x02, 0x04, 0x08, 0x10, 0x10],
		':'     =>	[0x00, 0x00, 0x10, 0x00, 0x10, 0x00, 0x00],
		';'     =>	[0x00, 0x00, 0x08, 0x00, 0x08, 0x08, 0x10],
		'<'     =>	[0x00, 0x02, 0x04, 0x08, 0x04, 0x02, 0x00],
		'='     =>	[0x00, 0x00, 0x1F, 0x00, 0x1F, 0x00, 0x00],
		'>'     =>	[0x00, 0x08, 0x04, 0x02, 0x04, 0x08, 0x00],
		'?'     =>	[0x0E, 0x11, 0x01, 0x02, 0x04, 0x00, 0x04],
		'@'     =>	[0x0E, 0x11, 0x17, 0x15, 0x17, 0x10, 0x0E],
		'['     =>	[0x0E, 0x08, 0x08, 0x08, 0x08, 0x08, 0x0E],
		']'     =>	[0x0E, 0x02, 0x02, 0x02, 0x02, 0x02, 0x0E],
		'^'     =>	[0x04, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00],
		'_'     =>	[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1F],
		'`'     =>	[0x08, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00],
		'{'     =>	[0x02, 0x04, 0x04, 0x08, 0x04, 0x04, 0x02],
		'|'     =>	[0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04],
		'}'     =>	[0x08, 0x04, 0x04, 0x02, 0x04, 0x04, 0x08],
		'~'     =>	[0x00, 0x00, 0x0A, 0x14, 0x00, 0x00, 0x00],
		' '     =>	[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
               };
    bless($self, $class);
    return $self;
}
1;
#
# Expand a row above into a 5 x 7 matrix - makes the Ctbl definition more compact
#
sub LedPanelCtbl::expand {
    my($class, $self, $char, $destobj) = @_;
    my $dw = $destobj->{width};
    my $dh = $destobj->{height};
    my $dc = $destobj->{columns};

        for my $r (0..$dh-1) {
            my $c = 0;
            for my $b (0..4) {
                $destobj->{matrix}[$r][$c] = ($self->{$char}[$r] >> (4-$b) & 0x01);
                $c++;
            }
        }
    $destobj->{columns} = 5;
}
