#! /home/pete/CitrusPerl/perl/bin/perl

# Create a LedPanel Display Object
#
# Based on a wxWidgets C++ application by Christian Gr�fe (info@mcs-soft.de)
# Reimplemented in wxPerl by James M. Lynes, Jr
# Last Modified: March 14, 2013
#

package LedPanelDisplay;
use strict;
use warnings;
use Wx qw(:everything);
use LedPanelMatrix;
use LedPanelCtbl;
use LedPanelColourTbl;
use Data::Dumper;

sub new {
    my $class = shift;
    my $self = {
                width   	=> 0,
                height  	=> 0,
                ledsize 	=> 4,
                spacing 	=> 1,
                message		=> "",
		scrolldirection => "none",
                invert          => 0,
                showinactives   => 1,
		id      	=> [],
		pallet  	=> 0,
		bgcolor 	=> wxBLACK,
                @_,
               };
    bless($self, $class);
    return $self;
}
1;

#
# Set up the Led On, Off, & None bitmaps for this display
#
sub LedPanelDisplay::Init {
    my($class, $self) = @_;
    $self->{memdcLedOn} = LedPanelDisplay->LedOnMemDc($self);
    $self->{memdcLedOff} = LedPanelDisplay->LedOffMemDc($self);
    $self->{memdcLedNone} = LedPanelDisplay->LedNoneMemDc($self);
    $self->{dispmat} = LedPanelDisplay->BuildMatrix($self);

    if(!$self->{invert}) {
        $self->{memdcLed1} = $self->{memdcLedOn};
        $self->{memdcLed0} = $self->{memdcLedOff};
    }
    if($self->{invert}) {
        $self->{memdcLed1} = $self->{memdcLedOff};
        $self->{memdcLed0} = $self->{memdcLedOn};
    }
    if(!$self->{showinactives}) {
        $self->{memdcLed0} = $self->{memdcLedNone};     
    }
}
#
# Draw each LED by copying the appropriate(On, Off, None) bitmap into the DC
#
sub LedPanelDisplay::Draw {
    my($class, $panel, $self) = @_;
    my $disp = Wx::PaintDC->new($panel);
    my $sz = $self->{ledsize};
    my $bmw = $self->{dispmat}->{columns};
    my $bmh = $self->{height};
    my $w = 0;
    my $h = 0;
        for my $r (0..$bmh-1) {
            for my $c (0..$bmw-1) {
                if($self->{dispmat}->{matrix}[$r][$c] == 1) {
                    $disp->Blit($w,$h,$sz,$sz,$self->{memdcLed1},0,0);
                    $w = $w + $sz;
                }
                else {
                    $disp->Blit($w,$h,$sz,$sz,$self->{memdcLed0},0,0);
                    $w = $w + $sz;
                }
            }
        $h = $h + $sz;
        $w = 0;
        }
    return;
}
#
# Create the LedOn bitmap/memory DC
#
sub LedPanelDisplay::LedOnMemDc {
    my($class, $self) = @_;
    my $sz = $self->{ledsize};
    my $LedOn = Wx::Bitmap->new($sz,$sz);
    my $memdcLedOn = Wx::MemoryDC->new();
    my $brush = Wx::Brush->new($self->{bgcolor}, wxSOLID);
    $memdcLedOn->SelectObject($LedOn);
    $memdcLedOn->SetBackground($brush);
    $memdcLedOn->Clear();

    my $pallet = LedPanelColourTbl->new();
    my $pen = Wx::Pen->new(($pallet->{dark}[$self->{pallet}]), 1, wxSOLID);
    $brush = Wx::Brush->new(($pallet->{base}[$self->{pallet}]), wxSOLID);
    $memdcLedOn->SetPen($pen);
    $memdcLedOn->SetBrush($brush);
    $memdcLedOn->DrawEllipse(0,0,$sz,$sz);
    $pen = Wx::Pen->new(($pallet->{light}[$self->{pallet}]), 1, wxSOLID);
    $memdcLedOn->SetPen($pen);
    $memdcLedOn->DrawEllipticArc(0,0,$sz,$sz,75,195);
    return $memdcLedOn;
}
#
# Create the LedOff bitmap/memory DC
#
sub LedPanelDisplay::LedOffMemDc {
    my($class, $self) = @_;
    my $sz = $self->{ledsize};
    my $LedOff = Wx::Bitmap->new($sz,$sz);
    my $memdcLedOff = Wx::MemoryDC->new();
    my $brush = Wx::Brush->new($self->{bgcolor}, wxSOLID);
    $memdcLedOff->SelectObject($LedOff);
    $memdcLedOff->SetBackground($brush);
    $memdcLedOff->Clear();

    my $pallet = LedPanelColourTbl->new();
    my $pen = Wx::Pen->new(($pallet->{dark}[$self->{pallet}]), 1, wxSOLID);
    $brush = Wx::Brush->new(($pallet->{verydark}[$self->{pallet}]), wxSOLID);
    $memdcLedOff->SetPen($pen);
    $memdcLedOff->SetBrush($brush);
    $memdcLedOff->DrawEllipse(0,0,$sz,$sz);
    return $memdcLedOff;
}
#
# Create the LedNone bitmap/memory DC
#
sub LedPanelDisplay::LedNoneMemDc {
    my($class, $self) = @_;
    my $sz = $self->{ledsize};
    my $LedNone = Wx::Bitmap->new($sz,$sz);
    my $memdcLedNone = Wx::MemoryDC->new();
    my $brush = Wx::Brush->new($self->{bgcolor}, wxSOLID);
    $memdcLedNone->SelectObject($LedNone);
    $memdcLedNone->SetBackground($brush);
    $memdcLedNone->Clear();
    return $memdcLedNone;
}
#
# Create the display bitmap from the message text and spacing paramrters
#
sub LedPanelDisplay::BuildMatrix {
    my($class, $self) = @_;
    my $ctbl = LedPanelCtbl->new();
    my $spacemat = LedPanelMatrix->new(width => 1, height =>7);
    LedPanelMatrix->fill($spacemat, [[0],[0],[0],[0],[0],[0],[0]]);
    my $charmat = LedPanelMatrix->new(width => 5, height =>7);
    my $dispmat = LedPanelMatrix->new(width => 80, height => 7);
    my $tmpmat = LedPanelMatrix->new(width => 80, height =>7);
    my @text = (split //, $self->{message});
    for my $char (@text) {
        LedPanelCtbl->expand($ctbl, $char, $charmat);
        LedPanelMatrix->append($dispmat, $charmat, $tmpmat);
        for my $spaces (1..$self->{spacing}) {
            LedPanelMatrix->append($dispmat, $spacemat, $tmpmat);
        }
    }
    return $dispmat;
}
