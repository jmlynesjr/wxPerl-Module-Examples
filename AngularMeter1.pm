#! /home/pete/CitrusPerl/perl/bin/perl
#
# AngularMeter1.pm
# This module draws a round panel meter.
#
#
# Written in wxPerl. Tested on Citrus Perl 5.16 with wxWidgets 2.8.x.
# Ported by: James M. Lynes. Jr.
# Last Modified Date: February 3, 2013
#
# Adapted from AngularMeter.cpp by Marco Cavallini
# based in part(mostly) on the work of
# the KWIC project (http://www.koansoftware.com/kwic/index.htm).
# Referenced on pg 596 of the "Wx Book" -
# "Cross-Platform GUI Programming with wxWidgets", Smart, Hock, & Csomor
#
# Added limit checking with green/red zones - Normal/Hi-limit
#   could reverse colors to alarm on a low limit if needed.
# Added animation - Timer in driver program randomizes the data
# Added Meter identification label
# Uses Class::Accessor:Fast to create objects and accessors
#
package AngularMeter;
use 5.010;
use strict;
use warnings;
use Wx qw(:everything);
use Math::Trig;
use Data::Dumper;
#
# Configuration Data ------------------------------------------------------------------
#
my %defaults = (
		MeterWidth => 275,					# Define the meter size
		MeterHeight => 275,					# Must be square to look right
		ScaledVal => 0,						# Value scaled to the display
		RealVal => 0,						# Value to display
		Tick => 9,						# Number of tic marks
		Sec => 2,						# Number of sections - green/red
		RangeStart => 0,					# Define Meter Span - Min
		RangeEnd => 100,					#                   - Max
		AlarmLimit => 65,					# Alarm Limit
		AngleStart => -20,					# East is 0 degrees, + is CCW
		AngleEnd => 200,
		SectorColours => [wxGREEN, wxRED],			# Only using two sections
		BackColour => wxLIGHT_GREY,
		NeedleColour => wxBLACK,
		BorderColour => wxBLUE,
		Font => Wx::Font->new(8, wxFONTFAMILY_SWISS, wxNORMAL, wxNORMAL),
		DrawCurrent => 1,					# Turn on/off value displayed as text
		Label => "",						# Label Meter at bottom of display
		Selected => 0,						# Is this meter selected
		);

my $PI = 4.0*atan(1.0); 

#
# Draw the Angular Meter ----------------------------------------------------------
#
sub Draw {
    my($class, $panel, $meter) = @_;
    my $dc = Wx::PaintDC->new($panel);
    my( $w, $h) = $dc->GetSizeWH();
    my $memdc = Wx::MemoryDC->new();
    $memdc->SelectObject(Wx::Bitmap->new($meter->MeterWidth, $meter->MeterHeight));
    my $brush = Wx::Brush->new($meter->BackColour, wxSOLID);
    $memdc->SetBackground($brush);
    $memdc->SetBrush($brush);
    $memdc->Clear();
    my $pen = Wx::Pen->new($meter->BorderColour, 6, wxSOLID);
    $memdc->SetPen($pen);
    $memdc->DrawRectangle(0, 0, $w, $h);
    DrawSectors($memdc, $meter);
    if($meter->Tick > 0) {DrawTicks($memdc, $meter);}
    DrawNeedle($memdc, $meter);
    if($meter->DrawCurrent) { DrawCurrentValue($memdc, $meter);}
    DrawLabel($memdc, $meter);
    $dc->Blit(0, 0, $w, $h, $memdc, 0, 0);
}
sub DrawCurrentValue {
    my($dc, $meter) = @_;
    my( $w, $h) = $dc->GetSizeWH();
    my $valuetext = sprintf("%d", $meter->RealVal);
    my @te = $dc->GetTextExtent($valuetext);
    my $x = ($w-$te[0])/2;
    $dc->SetFont($meter->Font);
    $dc->DrawText($valuetext, $x, ($h/2)+20);
}
sub DrawNeedle {
    my($dc, $meter) = @_;
    my($w, $h) = $dc->GetSizeWH();
    my $pen = Wx::Pen->new($meter->NeedleColour, 1, wxSOLID);
    $dc->SetPen($pen);
    my $brush = Wx::Brush->new($meter->NeedleColour, wxSOLID);
    $dc->SetBrush($brush);
    my $val = ($meter->ScaledVal + $meter->AngleStart) * $PI/180;
    my $dyi = sin($val-90)*2;
    my $dxi = cos($val-90)*2;
    my @points;
    $points[0] = Wx::Point->new($w/2-$dxi, $h/2-$dyi);
    $dxi = cos($val) * ($h/2-4);
    $dyi = sin($val) * ($h/2-4);
    $points[2] = Wx::Point->new($w/2-$dxi, $h/2-$dyi);
    $dxi = cos($val+90)*2;
    $dyi = sin($val+90)*2;
    $points[4] = Wx::Point->new($w/2-$dxi, $h/2-$dyi);
    $points[5] = $points[0];
    $val = ($meter->ScaledVal + $meter->AngleStart + 1) * $PI/180;
    $dxi = cos($val) * ($h/2-10);
    $dyi = sin($val) * ($h/2-10);
    $points[3] = Wx::Point->new($w/2-$dxi, $h/2-$dyi); 
    $val = ($meter->ScaledVal + $meter->AngleStart - 1) * $PI/180;
    $dxi = cos($val) * ($h/2-10);
    $dyi = sin($val) * ($h/2-10);
    $points[1] = Wx::Point->new($w/2-$dxi, $h/2-$dyi);
    $dc->DrawPolygon(\@points, 0, 0, wxODDEVEN_RULE); 
    $brush = Wx::Brush->new(wxWHITE, wxSOLID);			# Draw white dot at base of needle
    $dc->SetBrush($brush);
    $dc->DrawCircle($w/2, $h/2, 4);  
}
sub DrawSectors {
    my($dc, $meter) = @_;
    my($w, $h) = $dc->GetSizeWH();
    my $pen = Wx::Pen->new(wxBLACK, 1, wxSOLID);
    $dc->SetPen($pen);
    my $starc = $meter->AngleStart;
    my $endarc = $starc + (($meter->AngleEnd - $meter->AngleStart)
		        * ($meter->AlarmLimit-$meter->RangeStart)/($meter->RangeEnd-$meter->RangeStart));
    my $ctr = 0;
    while($ctr < $meter->Sec) {
          my $brush = Wx::Brush->new(${$meter->SectorColours}[$ctr], wxSOLID);
          $dc->SetBrush($brush);
          $dc->DrawEllipticArc(0, 0, $w, $h, 180-$endarc, 180-$starc);
          $starc = $endarc;
          $endarc = $meter->AngleEnd;
          $ctr++;
    }
    my $val = $meter->AngleStart * $PI / 180;
    my $dx = cos($val) * $h/2;
    my $dy = sin($val) * $h/2;
    $dc->DrawLine($w/2, $h/2, $w/2-$dx, $h/2-$dy);
    $val = $meter->AngleEnd * $PI / 180;
    $dx = cos($val) * $h/2;
    $dy = sin($val) * $h/2;
    $dc->DrawLine($w/2, $h/2, $w/2-$dx, $h/2-$dy);
}
sub DrawTicks {
    my($dc, $meter) = @_;
    my($w, $h) = $dc->GetSizeWH();
    my $interval = ($meter->AngleEnd - $meter->AngleStart) / ($meter->Tick +1);
    my $valint = $interval + $meter->AngleStart;
    my $ctr = 0;
    while($ctr < $meter->Tick) {
        my $val = $valint * $PI/180;
        my $dx = cos($val) * $h/2;
        my $dy = sin($val) * $h/2;
        my $tx = cos($val) * (($h/2)-10);
        my $ty = sin($val) * (($h/2)-10);
        $dc->DrawLine($w/2-$tx, $h/2-$ty, $w/2-$dx, $h/2-$dy);
        my $DeltaRange = $meter->RangeEnd - $meter->RangeStart;
        my $DeltaAngle = $meter->AngleEnd - $meter->AngleStart;
        my $Coeff = $DeltaAngle / $DeltaRange;
        my $rightval = (($valint - $meter->AngleStart) / $Coeff) + $meter->RangeStart;
        my $string = sprintf("%d", $rightval+.5);
        my($tew, $teh, $dct, $ext) = $dc->GetTextExtent($string);
        $val = ($valint - 4) * $PI/180;
        $tx = cos($val) * (($h/2)-12);
        $ty = sin($val) * (($h/2)-12);
        $dc->SetFont($meter->Font);
        $dc->DrawRotatedText($string, $w/2-$tx, $h/2-$ty, 90-$valint);
        $valint = $valint + $interval;
        $ctr++;
    }
}
sub SetValue {							# Scale the value for display
    my($class, $Value, $meter) = @_;
    my $DeltaRange = $meter->RangeEnd - $meter->RangeStart;
    my $RangeZero = $DeltaRange - $meter->RangeStart;
    my $DeltaAngle = $meter->AngleEnd - $meter->AngleStart;
    my $Coeff = $DeltaAngle / $DeltaRange;
    $meter->ScaledVal(($Value - $meter->RangeStart) * $Coeff);
    $meter->RealVal($Value);
}
sub DrawLabel {							# Draw a label at bottom of meter
    my($dc, $meter) = @_;
    my($w, $h) = $dc->GetSizeWH();
    my @te = $dc->GetTextExtent($meter->Label);
    my $x = ($w-$te[0])/2;
    $dc->DrawText($meter->Label, $x, $h-25);
}

package AngularMeter::Data;
use strict;
use warnings;
use Class::Accessor::Fast;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw(MeterWidth MeterHeight ScaledVal RealVal
                          Tick Sec RangeStart RangeEnd AlarmLimit AngleStart
                          AngleEnd SectorColours BackColour NeedleColour
                          BorderColour Font DrawCurrent Label Selected));

sub new {shift->SUPER::new(@_, \%defaults);}
1;
