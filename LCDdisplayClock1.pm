#! /home/pete/CitrusPerl/perl/bin/perl
#
# LCDdisplayClock1.pm
# Module subclass to draw an LCD clock
#
# Derived class from LCDdisplay1.pm
# Adds 3 extra member variables needed to make a clock from an LCDdisplay object 
#

package LCDdisplayClock1;
use strict;
use warnings;
use Wx;
use base qw(LCDdisplay1);					# LCDdisplay object
use Data::Dumper;

package LCDdisplayClock1::Data;
use strict;
use warnings;
use base qw(LCDdisplay1::Data);
use Data::Dumper;

__PACKAGE__->mk_accessors(qw( mToggle mBlinkFlag m1224Flag));

sub new {
    my($self) = shift->SUPER::new(@_);				# Create an LCDdisplay object
								# Add 3 additional member variables
    $self->mToggle(0);						# used to toggle the :
    $self->mBlinkFlag(0);					# used to enable blinking the :
    $self->m1224Flag(0);					# 12 or 24 hour display format

    return $self;
}
1;
