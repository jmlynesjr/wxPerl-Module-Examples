#! /home/pete/CitrusPerl/perl/bin/perl

# LCDAlarmClockDialog.pl
# Test driver for a custom dialog module example
#
# James M. Lynes, Jr.
# Last Modified: February 14, 2013
#
package main;
use strict;
use warnings;
my $app = App->new();
$app->MainLoop;

package App;
use strict;
use warnings;
use base 'Wx::App';
sub OnInit {
    my $frame = Frame->new();
    $frame->Show(1);
}

package Frame;
use strict;
use warnings;
use Wx qw(:everything);
use base qw(Wx::Frame);
use LCDAlarmClockDialog;
use Data::Dumper;

sub new {
    my($self) = @_;

    $self = $self->SUPER::new(undef, -1, "Custom LCD Alarm CLock Dialog Tester", 
                              wxDefaultPosition, wxDefaultSize);
    my %defaults = (
                    time     => "00:00",
		    flag2412 => 1,						# 24 Hour default type
    );

    $self->{clock} = LCDAlarmClockDialog::Data->new(\%defaults);		# Create a clock dialog object
    my $dialog = LCDAlarmClockDialog->new( $self );				# Create the dialog
    $dialog->ShowModal;								# Open the dialog pop-up
    print Dumper($dialog->get_time);						# Dump the returned time value
    print Dumper($dialog->get_clock_type);					# Dump the returned clock type
    return $self;
}
1;

