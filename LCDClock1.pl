#! /home/pete/CitrusPerl/perl/bin/perl

# LCDClock1.pl
#
# Uses LCDdisplayClock1.pm module to build an LCD Clock
# LCDdisplayClock1.pm is subclassed from LCDdisplay1.pm
# Includes a flashing colon(:) to indicate seconds, if enabled
# Can display in 12 or 24 hour format, decimal indicates pm
# LCDdisplayClock1.pm can display 0-F, :, -, _, and a few other special characters
# Up/down count, display your favorite nationa debt, etc.
#
# James M. Lynes, Jr
# Last Modified: February 5, 2013
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
use Wx::Event qw(EVT_PAINT EVT_SIZE EVT_TIMER);
use LCDdisplayClock1;
use Data::Dumper;

sub new {
    my($self) = @_;

    $self = $self->SUPER::new(undef, -1, "LCD Clock", 
                              wxDefaultPosition, [400, 200]);

    EVT_PAINT( $self, \&onPaint );				# Initialize event handlers
    EVT_SIZE( $self, \&onSize );
    EVT_TIMER( $self, -1, \&onTimer);

    $self->{LCD} = LCDdisplayClock1::Data->new();		# Create an LCD Clock object
    $self->{LCD} ->m1224Flag(1);				# 1->12hr mode, 0->24hr mode
    $self->{LCD}->mBlinkFlag(1);				# Blink colon ? 1->yes
    $self->{LCD}->mNumberDigits(5);				# 5 digit display including :
    $self->{LCD}->mValue("");					# Initialize the display
    $self->SetBackgroundColour($self->{LCD}->mDefaultColour);	# Black background

    my $timer = Wx::Timer->new($self);				# Initialize 1 second timer
    $timer->Start(1000);			

    return $self;
}
1;
#
# Dismiss a size event
#
sub onSize{
    my($self, $event) = @_;
    $event->Skip();
}
#
# Draw the LCD
#
sub onPaint {
    my($self, $event) = @_;
    LCDdisplayClock1->Draw($self, $self->{LCD});
}
#
# Format the time for display
#
sub onTimer {
    my($self, $event) = @_;
    my($min, $hour) = (localtime)[1,2];
    my $dot = ""; 
    if($self->{LCD}->m1224Flag && $hour > 12) {
        $hour = $hour-12;
        $dot = ".";
    }
    my $colon = ":";
    if($self->{LCD}->mBlinkFlag) {				# Blink the colon?
        if($self->{LCD}->mToggle) {				# yes, toggle the :
            $self->{LCD}->mToggle(0);
            $colon = ":";
        }
        else {
            $self->{LCD}->mToggle(1);
            $colon = " ";
        }
    }
    my $minstr = sprintf("%02d", $min);
    my $hourstr = sprintf("%02d", $hour);
    $self->{LCD}->mValue($hourstr . $colon . $minstr . $dot);
    $self->Refresh(0);
}
