#! /home/pete/CitrusPerl/perl/bin/perl

# AM1.pl - Angular Meter Process Control Screen Example
# Written in wxPerl. Tested on Citrus Perl 5.16 with wxWidgets 2.8.x.
# Ported by: James M. Lynes. Jr.
# Last Modified Date: February 3, 2013
#
# Creates 4 Angular Meters
# Supports meter select/de-select and alarm limit changes
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
use Wx::Event qw(EVT_PAINT EVT_TIMER EVT_LEFT_DOWN EVT_RIGHT_DOWN);
use AngularMeter1;						# Package named AngularMeter
use Data::Dumper;

sub new {
    my($self) = @_;

    $self = $self->SUPER::new(undef, -1, "wxPerl Process Control Example - Angular Meters", 
                              [0, 0], [750, 750]);

    my $font = Wx::Font->new(12, wxFONTFAMILY_SWISS, wxNORMAL, wxBOLD);
    $self->SetFont($font);
    Wx::StaticText->new($self, -1, "Boiler 1", [160, 15], wxDefaultSize, wxALIGN_LEFT);
    Wx::StaticText->new($self, -1, "Boiler 2", [465, 15], wxDefaultSize, wxALIGN_LEFT);

    my($meters, $width, $height) = (4, 275, 275);
    my($sx, $sy, $hinc, $vinc) = (60, 80, 30, 30);
# Create 4 panels to hold 4 angular meters
    $self->{MP1} = Wx::Panel->new($self, wxID_ANY, [$sx, $sy], [$width, $height]);
    $self->{MP2} = Wx::Panel->new($self, wxID_ANY, [$width+$sx+$hinc, $sy], [$width, $height]);
    $self->{MP3} = Wx::Panel->new($self, wxID_ANY, [$sx, $height+$sy+$vinc], [$width, $height]);
    $self->{MP4} = Wx::Panel->new($self, wxID_ANY, [$width+$sx+$hinc, $height+$sy+$vinc], [$width, $height]);

# Create 4 angular meter objects
    $self->{AM1} = AngularMeter::Data->new();
        AngularMeter->SetValue(30, $self->{AM1});
        $self->{AM1}->AlarmLimit(35);
        $self->{AM1}->Label("Pump 1 RPM");
    $self->{AM2} = AngularMeter::Data->new();
        AngularMeter->SetValue(50, $self->{AM2});
        $self->{AM2}->AlarmLimit(55);
        $self->{AM2}->Label("Pump 2 RPM");
    $self->{AM3} = AngularMeter::Data->new();
        AngularMeter->SetValue(70, $self->{AM3});
        $self->{AM3}->AlarmLimit(75);
        $self->{AM3}->Label("Pump 1 Flow");
    $self->{AM4} = AngularMeter::Data->new();
        AngularMeter->SetValue(10, $self->{AM4});
        $self->{AM4}->AlarmLimit(15);
        $self->{AM4}->Label("Pump 2 Flow");
#
# Setup event handlers
#
# Timer
    my $timer = Wx::Timer->new($self);
    $timer->Start(1000);
    EVT_TIMER($self, -1, \&onTimer);
# Paint
    EVT_PAINT($self, \&onPaint);
# Mouse
    EVT_LEFT_DOWN($self->{MP1}, sub{$self->_evt_left_down( $self->{AM1}, @_);});
    EVT_LEFT_DOWN($self->{MP2}, sub{$self->_evt_left_down( $self->{AM2}, @_);});
    EVT_LEFT_DOWN($self->{MP3}, sub{$self->_evt_left_down( $self->{AM3}, @_);});
    EVT_LEFT_DOWN($self->{MP4}, sub{$self->_evt_left_down( $self->{AM4}, @_);});

    EVT_RIGHT_DOWN($self->{MP1}, sub{$self->_evt_right_down( $self->{AM1}, @_);});
    EVT_RIGHT_DOWN($self->{MP2}, sub{$self->_evt_right_down( $self->{AM2}, @_);});
    EVT_RIGHT_DOWN($self->{MP3}, sub{$self->_evt_right_down( $self->{AM3}, @_);});
    EVT_RIGHT_DOWN($self->{MP4}, sub{$self->_evt_right_down( $self->{AM4}, @_);});
    return $self;
}
1;

#
# Right Mouse Pressed Event - Change the Selected Meter's Limit -----------------
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
        my $msg = Wx::MessageBox("        No Meter Selected\n        Left Click on a Meter to Select",
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
# Random values to drive meter needles
#
sub onTimer {
    my($self, $event) = @_;

    my $dir = (rand 10) < 5 ? -1 : 1;
    my $inc = (rand 2) * $dir;
    AngularMeter->SetValue($self->{AM1}->RealVal($self->{AM1}->RealVal() + $inc), $self->{AM1});

    $dir = (rand 10) < 5 ? -1 : 1;
    $inc = (rand 2) * $dir;
    AngularMeter->SetValue($self->{AM2}->RealVal($self->{AM2}->RealVal() + $inc), $self->{AM2});

    $dir = (rand 10) < 5 ? -1 : 1;
    $inc = (rand 2) * $dir;
    AngularMeter->SetValue($self->{AM3}->RealVal($self->{AM3}->RealVal() + $inc), $self->{AM3});

    $dir = (rand 10) < 5 ? -1 : 1;
    $inc = (rand 2) * $dir;
    AngularMeter->SetValue($self->{AM4}->RealVal($self->{AM4}->RealVal() + $inc), $self->{AM4});

    $self->Refresh(0);
}
#
# Paint the meters
#
sub onPaint {
    my($self, $event) = @_;
# Draw the 4 meters
    AngularMeter->Draw($self->{MP1}, $self->{AM1});
    AngularMeter->Draw($self->{MP2}, $self->{AM2});
    AngularMeter->Draw($self->{MP3}, $self->{AM3});
    AngularMeter->Draw($self->{MP4}, $self->{AM4});
}

