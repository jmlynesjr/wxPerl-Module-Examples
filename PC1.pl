#! /home/pete/CitrusPerl/perl/bin/perl

# PC1.pl - wxPerl Process Control Example
#          uses the LinearMeter4.pm modular meter
#          uses the AngularMeter1.pm modular meter
#
# Last modified by James M. Lynes, Jr - February 3,2013
#
# Draws and animates 4 Linear Meters and 2 Angular Meters
# Linear Meters change green/red to indicate limit violations
# Creates a 1 second timer to update the animation
# Left click selects/deselects the meter and sets the border to yellow/blue
# Right click on a selected meter pops a limit change dialog
# Right click on a deselected meter pops an error messsage box
# Multiple meters may be selected at the same time - may want to limit
#   this in the future.
#
# The Linear Meter panel is created 40 units longer than the meter to allow space
# for drawing the meter label
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
use lib '/home/pete/Projects/perlprojects/AngularMeter';	# Point to development dir
use lib '/home/pete/Projects/perlprojects/LinearMeter';		# Point to development dir
use Wx qw(:everything);
use base qw(Wx::Frame);
use LinearMeter4;						# Package names LinearMeter
use AngularMeter1;						# Package named AngularMeter
use Data::Dumper;
use Wx::Event qw(EVT_PAINT EVT_TIMER EVT_LEFT_DOWN EVT_RIGHT_DOWN);

sub new {
    my ($self) = @_;
    my($meters, $width, $height) = (8, 100, 550);
    $self = $self->SUPER::new(undef, -1, "wxPerl Process Control Example", wxDefaultPosition,
                              [(($meters)+1)*10+20 + (($meters)*$width),($height+90)]);
    my $font = Wx::Font->new(12, wxFONTFAMILY_SWISS, wxNORMAL, wxBOLD);
    $self->SetFont($font);
    Wx::StaticText->new($self, -1, "Boiler 1", [190, 15], wxDefaultSize, wxALIGN_LEFT);
    Wx::StaticText->new($self, -1, "Substation 1", [625, 15], wxDefaultSize, wxALIGN_LEFT);
 
# Create 6 panels to hold 6 meters
    $self->{MP1} = Wx::Panel->new($self, wxID_ANY, [10 ,40], [$width, $height+40]);
    $self->{MP2} = Wx::Panel->new($self, wxID_ANY, [($width*1)+20 ,40], [$width, $height+40]);
    $self->{MP3} = Wx::Panel->new($self, wxID_ANY, [($width*2)+30 ,40], [$width, $height+40]);
    $self->{MP4} = Wx::Panel->new($self, wxID_ANY, [($width*3)+40 ,40], [$width, $height+40]);
    $self->{MP5} = Wx::Panel->new($self, wxID_ANY, [($width*5)+40 ,40], [275, 275]);
    $self->{MP6} = Wx::Panel->new($self, wxID_ANY, [($width*5)+40 ,350], [275,275]);


# Create 6 meter objects - Override some default values
    $self->{LM1} = LinearMeter::Data->new();
        $self->{LM1}->InitialValue(73);
        $self->{LM1}->AlarmLimit(76);
        $self->{LM1}->Label("Temp 1");
        $self->{LM1}->MeterHeight($height);
        $self->{LM1}->MeterWidth($width);
    $self->{LM2} = LinearMeter::Data->new();
        $self->{LM2}->InitialValue(28);
        $self->{LM2}->AlarmLimit(31);
        $self->{LM2}->Label("Flow 1");
        $self->{LM2}->MeterHeight($height);
        $self->{LM2}->MeterWidth($width);
    $self->{LM3} = LinearMeter::Data->new();
        $self->{LM3}->InitialValue(42);
        $self->{LM3}->AlarmLimit(46);
        $self->{LM3}->Label("Pressure 1");
        $self->{LM3}->MeterHeight($height);
        $self->{LM3}->MeterWidth($width);
    $self->{LM4} = LinearMeter::Data->new();
        $self->{LM4}->InitialValue(62);
        $self->{LM4}->AlarmLimit(66);
        $self->{LM4}->Label("Level 1");
        $self->{LM4}->MeterHeight($height);
        $self->{LM4}->MeterWidth($width);
    $self->{AM1} = AngularMeter::Data->new();
        AngularMeter->SetValue(26, $self->{AM1});
        $self->{AM1}->RangeStart(25);
        $self->{AM1}->RangeEnd(30);
        $self->{AM1}->Tick(4);
        $self->{AM1}->AlarmLimit(26.5);
        $self->{AM1}->Label("KVolts");
    $self->{AM2} = AngularMeter::Data->new();
        AngularMeter->SetValue(50, $self->{AM2});
        $self->{AM2}->AlarmLimit(60);
        $self->{AM2}->Label("Amps");

#
# Set up Event Handlers -------------------------------------------------------
#
# Timer
    my $timer = Wx::Timer->new( $self );
    $timer->Start( 1000 );					# 1 second period
    EVT_TIMER($self, -1, \&onTimer);
# Paint
    EVT_PAINT($self, \&onPaint);
# Mouse
    EVT_LEFT_DOWN($self->{MP1}, sub{$self->_evt_left_down( $self->{LM1}, @_);});
    EVT_LEFT_DOWN($self->{MP2}, sub{$self->_evt_left_down( $self->{LM2}, @_);});
    EVT_LEFT_DOWN($self->{MP3}, sub{$self->_evt_left_down( $self->{LM3}, @_);});
    EVT_LEFT_DOWN($self->{MP4}, sub{$self->_evt_left_down( $self->{LM4}, @_);});
    EVT_LEFT_DOWN($self->{MP5}, sub{$self->_evt_left_down( $self->{AM1}, @_);});
    EVT_LEFT_DOWN($self->{MP6}, sub{$self->_evt_left_down( $self->{AM2}, @_);});

    EVT_RIGHT_DOWN($self->{MP1}, sub{$self->_evt_right_down( $self->{LM1}, @_);});
    EVT_RIGHT_DOWN($self->{MP2}, sub{$self->_evt_right_down( $self->{LM2}, @_);});
    EVT_RIGHT_DOWN($self->{MP3}, sub{$self->_evt_right_down( $self->{LM3}, @_);});
    EVT_RIGHT_DOWN($self->{MP4}, sub{$self->_evt_right_down( $self->{LM4}, @_);});
    EVT_RIGHT_DOWN($self->{MP5}, sub{$self->_evt_right_down( $self->{AM1}, @_);});
    EVT_RIGHT_DOWN($self->{MP6}, sub{$self->_evt_right_down( $self->{AM2}, @_);});

    return $self;
}
1;
#
# Right Mouse Pressed Event - Change the Selected Meter's ALARM Limit -----------------
#
sub _evt_right_down {
    my($frame, $meter, $panel, $event) = @_;
    if($meter->Selected()) {
        my $label = $meter->Label();
        my $dialog = Wx::TextEntryDialog->new( $frame,
                     "Select a New Limit", "Change the  $label  Alarm Limit",
                     $meter->AlarmLimit());
        if($dialog->ShowModal == wxID_CANCEL) {
            $meter->BorderColour(wxBLUE);
            $meter->Selected(0);
            return;
        };
        $meter->AlarmLimit($dialog->GetValue());
        $meter->BorderColour(wxBLUE);
        $meter->Selected(0);
    }
    else {
        my $label = $meter->Label();
        my $msg = Wx::MessageBox("     No Meter Selected\n     Left Click on a Meter to Select",
                 "$label Alarm Limit Entry Error", wxICON_ERROR, $frame);    
    }
    $event->Skip(1);
}
#
# Left Mouse Pressed Event - Selects a Meter - Selection will Toggle -----------
#
sub _evt_left_down {
    my($frame, $meter, $panel, $event) = @_;
    if($meter->Selected()) {
        $meter->BorderColour(wxBLUE);
        $meter->Selected(0);
    }
    else {
    $meter->BorderColour(Wx::Colour->new("yellow"));        
    $meter->Selected(1);
    }
    $event->Skip(1);
}
#
# 1 second timer to simulate meter movement ---------------------------------
#
sub onTimer {
    my($self, $event) = @_;
								# Randomize for each meter
								# for a more natural look
    my $dir = (rand 10) < 5 ? -1 : 1;
    my $inc = (rand 1) * $dir;
    $self->{LM1}->InitialValue($self->{LM1}->InitialValue() + $inc);
    LinearMeter->Draw($self->{MP1}, $self->{LM1});

    $dir = (rand 10) < 5 ? -1 : 1;
    $inc = (rand 1) * $dir;
    $self->{LM2}->InitialValue($self->{LM2}->InitialValue() + $inc);
    LinearMeter->Draw($self->{MP2}, $self->{LM2});

    $dir = (rand 10) < 5 ? -1 : 1;
    $inc = (rand 1) * $dir;
    $self->{LM3}->InitialValue($self->{LM3}->InitialValue() + $inc);
    LinearMeter->Draw($self->{MP3}, $self->{LM3});

    $dir = (rand 10) < 5 ? -1 : 1;
    $inc = (rand 1) * $dir;
    $self->{LM4}->InitialValue($self->{LM4}->InitialValue() + $inc);
    LinearMeter->Draw($self->{MP4}, $self->{LM4});

    $dir = (rand 10) < 5 ? -1 : 1;
    $inc = (rand .1) * $dir;
    AngularMeter->SetValue($self->{AM1}->RealVal($self->{AM1}->RealVal() + $inc), $self->{AM1});

    $dir = (rand 10) < 5 ? -1 : 1;
    $inc = (rand 1) * $dir;
    AngularMeter->SetValue($self->{AM2}->RealVal($self->{AM2}->RealVal() + $inc), $self->{AM2});
    $self->Refresh(0);

}
#
# Paint the Meters ---------------------------------------------------------------------
#
sub onPaint {
    my($self, $event) = @_;
# Draw the 8 meters
    LinearMeter->Draw($self->{MP1}, $self->{LM1});
    LinearMeter->Draw($self->{MP2}, $self->{LM2});
    LinearMeter->Draw($self->{MP3}, $self->{LM3});
    LinearMeter->Draw($self->{MP4}, $self->{LM4});
    AngularMeter->Draw($self->{MP5}, $self->{AM1});
    AngularMeter->Draw($self->{MP6}, $self->{AM2});

} 

