#! /home/pete/CitrusPerl/perl/bin/perl

# LedPanelApp.pl - Application to draw a simulated LED Dot Matrix Style Display
#
# Based on a wxWidgets C++ application by Christian Gr�fe (info@mcs-soft.de)
# Reimplemented in wxPerl by James M. Lynes, Jr
# Last Modified: March 14, 2013
#
# Led size can vary from about 3 on up to 10 or more
# Led colors supported are: Red, Green, Blue, Yellow, Magenta, Cyan, Gray
# Display can scroll Left, Right, Up, or Down
# "Inverse video" is supported
# 5x7 dot matrix style characters are used
#
# This test application displays 7 scrolling LED style panels
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
use Wx::Event qw(EVT_PAINT EVT_TIMER);
use LedPanelDisplay;
use Data::Dumper;

sub new {
    my($self) = @_;
#
# Create Top Level Window
#
    $self = $self->SUPER::new(undef, -1, "LedPanelApp1.pl", [0,0], [1020,425]);
    $self->SetBackgroundColour(wxBLUE);
#
# Create Seven Panels, One Led Display per Panel
#
    $self->{LP1} = Wx::Panel->new($self, -1, [10,10], [1000,32], wxRAISED_BORDER);
    $self->{LP1}->SetBackgroundColour(wxBLACK);
    $self->{LP2} = Wx::Panel->new($self, -1, [10,48], [1000,40], wxRAISED_BORDER);
    $self->{LP2}->SetBackgroundColour(wxBLACK);
    $self->{LP3} = Wx::Panel->new($self, -1, [10,93], [1000,47], wxRAISED_BORDER);
    $self->{LP3}->SetBackgroundColour(wxBLACK);
    $self->{LP4} = Wx::Panel->new($self, -1, [10,145], [1000,54], wxRAISED_BORDER);
    $self->{LP4}->SetBackgroundColour(wxBLACK);
    $self->{LP5} = Wx::Panel->new($self, -1, [10,204], [1000,61], wxRAISED_BORDER);
    $self->{LP5}->SetBackgroundColour(wxBLACK);
    $self->{LP6} = Wx::Panel->new($self, -1, [10,270], [1000,68], wxRAISED_BORDER);
    $self->{LP6}->SetBackgroundColour(wxBLACK);
    $self->{LP7} = Wx::Panel->new($self, -1, [10,343], [1000,75], wxRAISED_BORDER);
    $self->{LP7}->SetBackgroundColour(wxBLACK);
#
# Create Seven Led Displays, Sizes 4 thru 10, Colors Red thru Gray, Assorted Text
#

my %colors = (
		red	 =>	0,
		green	 =>	1,
		blue	 =>	2,
		yellow	 =>	3,
		magenta  =>	4,
		cyan	 =>	5,
		gray	 =>	6,
	     );


    $self->{led1} = LedPanelDisplay->new(width => 216, height =>7, ledsize => 4, id => "led1",);
    $self->{led1}->{message} = "LINE 1 ABCDEFGHIJKLM                     ";
    $self->{led1}->{pallet} = $colors{red};
    $self->{led1}->{spacing} = 1;
    $self->{led1}->{scrolldirection} = "left";
    $self->{led1}->{invert} = 1;
    LedPanelDisplay->Init($self->{led1});

    $self->{led2} = LedPanelDisplay->new(width => 216, height =>7, ledsize => 5, id => "led2");
    $self->{led2}->{message} = "LINE 2 NOPQRSTUVWXYZ             ";
    $self->{led2}->{pallet} = $colors{green};
    $self->{led2}->{scrolldirection} = "right";
    $self->{led2}->{invert} = 1;
    $self->{led2}->{showinactives} = 0;
    LedPanelDisplay->Init($self->{led2});

    $self->{led3} = LedPanelDisplay->new(width => 216, height =>7, ledsize => 6, id => "led3");
    $self->{led3}->{message} = "     LINE 3 abcdefghijklm       ";
    $self->{led3}->{pallet} = $colors{blue};
    $self->{led3}->{scrolldirection} = "up";
    $self->{led3}->{showinactives} = 0;
    LedPanelDisplay->Init($self->{led3});

    $self->{led4} = LedPanelDisplay->new(width => 216, height =>7, ledsize => 7, id => "led4");
    $self->{led4}->{message} = "LINE 4 nopqrstuvwxyz     ";
    $self->{led4}->{pallet} = $colors{yellow};
    $self->{led4}->{scrolldirection} = "down";
    LedPanelDisplay->Init($self->{led4});

    $self->{led5} = LedPanelDisplay->new(width => 216, height =>7, ledsize => 8, id => "led5");
    $self->{led5}->{message} = "LINE 5 !\"#\$%&()*+,-./:;   ";
    $self->{led5}->{pallet} = $colors{magenta};
    $self->{led5}->{scrolldirection} = "left";
    LedPanelDisplay->Init($self->{led5});

    $self->{led6} = LedPanelDisplay->new(width => 216, height =>7, ledsize => 9, id => "led6");
    $self->{led6}->{message} = "    LINE 6 <=>?@[]^_` ";
    $self->{led6}->{pallet} = $colors{cyan};
    $self->{led6}->{scrolldirection} = "right";
    LedPanelDisplay->Init($self->{led6});

    $self->{led7} = LedPanelDisplay->new(width => 216, height =>7, ledsize => 10, id => "led7");
    $self->{led7}->{message} = "LINE 7 {|}~      ";
    $self->{led7}->{pallet} = $colors{gray};
    $self->{led7}->{scrolldirection} = "left";
    LedPanelDisplay->Init($self->{led7});

    EVT_PAINT($self, \&onPaint);
    EVT_TIMER($self, -1, \&onTimer);

    my $timer = Wx::Timer->new($self);
    $timer->Start(1000);

    return $self;
}
1;
sub onTimer {
    my($self, $event) = @_;
    my @displays = qw(led1 led2 led3 led4 led5 led6 led7);
    foreach my $display (@displays) {
        if($self->{$display}->{scrolldirection} eq "none") {next;}
        if($self->{$display}->{scrolldirection} eq "left") {
            LedPanelMatrix->ShiftLeft($self->{$display}->{dispmat});}
        if($self->{$display}->{scrolldirection} eq "right") {
            LedPanelMatrix->ShiftRight($self->{$display}->{dispmat});}
        if($self->{$display}->{scrolldirection} eq "up") {
            LedPanelMatrix->ShiftUp($self->{$display}->{dispmat});}
        if($self->{$display}->{scrolldirection} eq "down") {
            LedPanelMatrix->ShiftDown($self->{$display}->{dispmat});}
    }
    $self->Refresh(0);
}
sub onPaint {
    my($self, $event) = @_; 
#
# Draw the Seven Led Displays
#
    LedPanelDisplay->Draw($self->{LP1}, $self->{led1});
    LedPanelDisplay->Draw($self->{LP2}, $self->{led2});
    LedPanelDisplay->Draw($self->{LP3}, $self->{led3});
    LedPanelDisplay->Draw($self->{LP4}, $self->{led4});
    LedPanelDisplay->Draw($self->{LP5}, $self->{led5});
    LedPanelDisplay->Draw($self->{LP6}, $self->{led6});
    LedPanelDisplay->Draw($self->{LP7}, $self->{led7});
}

