#! /home/pete/CitrusPerl/perl/bin/perl

# LCDAlarmClock1.pl
#
# Uses the LCDdisplayClock1.pm and AudiableAlarm.pm modules to build an LCD Clock with alarm
# LCDdisplayClock1.pm is subclassed from LCDdisplay1.pm
# Includes a flashing colon(:) to indicate seconds, if enabled
# Can display in 12 or 24 hour format, decimal indicates pm
# LCDdisplayClock1.pm can display 0-F, :, -, _, and a few other special characters
# Up/down count, display your favorite national debt, etc.
#
# Left Click on clock to set(ok) or stop(cancel) alarm
# Alarm time entered in 24 hour format
#
# James M. Lynes, Jr
# Last Modified: February 8, 2013
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
use Wx::Event qw(EVT_PAINT EVT_SIZE EVT_TIMER EVT_LEFT_DOWN);
use lib '/home/pete/Projects/perlprojects/LCDdisplay';
use LCDdisplayClock1;
use AudiableAlarm;
use Data::Dumper;

sub new {
    my($self) = @_;

    $self = $self->SUPER::new(undef, -1, "LCD Alarm Clock", 
                              wxDefaultPosition, [400, 200]);

    EVT_PAINT( $self, \&onPaint );				# Initialize event handlers
    EVT_SIZE( $self, \&onSize );
    EVT_TIMER( $self, -1, \&onTimer);
    EVT_LEFT_DOWN($self, \&onLeftDown);

    $self->{LCD} = LCDdisplayClock1::Data->new();		# Create an LCD Clock object
    $self->{LCD} ->m1224Flag(0);				# 1->12hr mode, 0->24hr mode
    $self->{LCD}->mBlinkFlag(1);				# Blink colon ? 1->yes
    $self->{LCD}->mNumberDigits(5);				# 5 digit display including :
    $self->{LCD}->mValue("");					# Initialize the display
    $self->SetBackgroundColour($self->{LCD}->mDefaultColour);	# Black background

    my $timer = Wx::Timer->new($self);				# Initialize 1 second timer
    $timer->Start(1000);

    $self->{alarm} = AudiableAlarm::Data->new();		# Create the AudiableAlarm object
    $self->{alarm}->AlarmFile("/home/pete/Projects/perlprojects/AlarmClock/test.mp3");
    $self->{alarmenabled} = 0;
    $self->{alarmhour} = 0;
    $self->{alarmmin} = 0;
    $self->{alarmactive} = 0;

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
    if($self->{alarmenabled}) {
        if($hour == $self->{alarmhour} && $min == $self->{alarmmin}) {
            AudiableAlarm->StartAlarm($self);
            $self->{alarmactive} = 1;
            $self->{alarmenabled} = 0;
        }
    }			
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
#
# Popup the Alarm Timeset Dialog
#
sub onLeftDown {
    my($self, $event) = @_;
    my $hr = sprintf("%02d", $self->{alarmhour});
    my $mn = sprintf("%02d", $self->{alarmmin});
    my $dialog = Wx::TextEntryDialog->new( $self,
                 "Select the Alarm Time(HH:MM)", "LCD Alarm Clock Time Set", "$hr : $mn");
    if($dialog->ShowModal == wxID_CANCEL) {
        if($self->{alarmactive}) {AudiableAlarm->StopAlarm($self);}
        $self->{alarmhour} = 0;
        $self->{alarmmin} = 0;
        $self->{alarmenabled} = 0;
        $self->{alarmactive} = 0;        
        $event->Skip();
        return;
    }
    my @time = split /:/, $dialog->GetValue();
    $self->{alarmhour} = $time[0];
    $self->{alarmmin} = $time[1];
    $self->{alarmenabled} = 1;
    $event->Skip();
}
