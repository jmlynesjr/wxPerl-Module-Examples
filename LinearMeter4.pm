# LinearMeter4.pm - Linear Meter Object
#
# Last modified by James M. Lynes, Jr - February 3,2013
#
# Creates a Linear Panel Meter
# Can be drawn vertical or horizontal
# Modified LinearMeter.pl into an object that can be used to create multiple meters
# Adapted from LinearMeter.cpp by Marco Cavallini
# based in part(mostly) on the work of
# the KWIC project (http://www.koansoftware.com/kwic/index.htm).
# Referenced on pg 596 of the "Wx Book" -
# "Cross-Platform GUI Programming with wxWidgets", Smart, Hock, & Csomor
#
# Added high-limit/alarm processing- red/green color change
# Added label display between the bottom of the meter and the bottom of the panel
# Set an initial value, high-limit, and tic array
# Added DrawLimitBar to draw a tic mark at the current limit value
# Deleted drawing the 1st and last tags to reduce crowding of the display
# Added a "Selected" flag
# Driver program implements mouse events for limit modification
#   and timer event to drive the animation.
# Uses Class::Accessor::Fast for object and accessor creation
#
# To-Do: Rework meter so that a wider border can be drawn. PANEL(BORDER(METER))
#        Currently the border draws on top of the meter space.

package LinearMeter;
use strict;
use warnings;
use Wx qw(:everything);
use Data::Dumper;
#
# Configuration Data ------------------------------------------------
#
my %defaults = (
		MeterHeight      => 300,			# Swap these for horizontal display
    		MeterWidth       => 100,
    		ActiveBar        => wxGREEN,
    		PassiveBar       => wxWHITE,
    		ValueColour      => wxBLACK,
    		BorderColour     => wxBLUE,
    		LimitColour      => wxBLACK,
    		AlarmLimitColour => wxRED,
    		TagsColour       => wxBLACK,
    		ScaledValue      => 0,
    		RealVal          => 0,
    		AlarmLimit       => 0,				# High-Limit setpoint
    		TagsVal          => [],
    		TagsNum          => 0,
    		StartTag         => 0,
    		NumTags          => 10,
    		IncTag           => 10,
    		Max              => 100,			# Span
    		Min              => 0,
    		InitialValue     => 0,				# Initial value displayed
    		LastPos          => 0,				# Last mouse position
    		DirHorizFlag     => 0,				# 0-Verticle, 1-Horizontal
    		ShowCurrent      => 1,
    		ShowLimits       => 1,
    		ShowLabel        => 1,
    		Font             => Wx::Font->new(8, wxFONTFAMILY_SWISS, wxNORMAL, wxNORMAL),
    		Label            => "",
    		Selected         => 0,
	       );
    
#
# Draw the Linear Meter ----------------------------------------------------------
#
sub Draw {
    my($class, $panel, $meter) = @_;
    my $dc = Wx::PaintDC->new($panel);
    my $memdc = Wx::MemoryDC->new();
    $memdc->SelectObject(Wx::Bitmap->new($meter->MeterWidth(), $meter->MeterHeight()));
    my($w, $h) = $memdc->GetSizeWH();
    my $brush = Wx::Brush->new($meter->PassiveBar(), wxSOLID);
    $memdc->SetBackground($brush);
    $memdc->Clear();
    SetUp($memdc, $meter);						# Set the initial value and tic marks
    my $pen = Wx::Pen->new($meter->BorderColour(), 3, wxSOLID);
    $memdc->SetPen($pen);
    $memdc->DrawRectangle(0, 0, $w, $h);
    $pen = Wx::Pen->new($meter->BorderColour(), 3, wxSOLID);
    $memdc->SetPen($pen);
    $brush = Wx::Brush->new($meter->ActiveBar(), wxSOLID);
    if($meter->RealVal() > $meter->AlarmLimit()) {$brush = Wx::Brush->new($meter->AlarmLimitColour(), wxSOLID)}
    $memdc->SetBrush($brush);
    my $yPoint;
    my $rectHeight;
    if($meter->DirHorizFlag()) {					# Horizontal Orientation
        $memdc->DrawRectangle(1, 1, $meter->ScaledValue(), $h-2);
    }
    else {								# Verticle Orientation
        $yPoint = $h - $meter->ScaledValue();
        if($meter->ScaledValue() == 0) {
            $rectHeight = $meter->ScaledValue();
        }
        else {
            if($meter->RealVal() == $meter->Max()) {
               $rectHeight = $meter->ScaledValue();
               $yPoint -= 1;
            }
            else {
                $rectHeight = $meter->ScaledValue() - 1;
            }
        $memdc->DrawRectangle(1, $yPoint, $w-2, $rectHeight);
       }
    }
    if($meter->ShowCurrent()) {DrawCurrent($memdc, $meter)}
    if($meter->ShowLimits()) {DrawLimits($memdc, $meter)}
    if($meter->TagsNum() > 0) {DrawTags($memdc, $meter)}
    $dc->Blit(0, 0, $w, $h, $memdc, 0, 0);			# Keep blit above DrawLabel call
    if($meter->ShowLabel()) {DrawLabel($dc, $meter)}		# <----
}
sub SetUp {							# Set and update the displayed value
    my($dc, $meter) = @_;
    SetValue($dc, $meter->InitialValue(), $meter);

    if($meter->TagsNum() == 0) {				# Build tic marks 1st time through
        for($meter->StartTag()..$meter->NumTags()) {		# Quick and dirty
            AddTag($_ * $meter->IncTag(), $meter);
        }
    }
} 
sub DrawCurrent {						# Draw the current value as text
    my($dc, $meter) = @_;
    my($w, $h) = $dc->GetSizeWH();
    my $valuetext = sprintf("%d", $meter->RealVal());
    my ($tw, $th) = $dc->GetTextExtent($valuetext);
    $dc->SetTextForeground($meter->ValueColour());
    $dc->SetFont($meter->Font());
    $dc->DrawText($valuetext, $w/2-$tw/2, $h/2-$th/2);    
}
sub DrawLimits {						# Draw Min and Max as text
    my($dc, $meter) = @_;
    my($w, $h) = $dc->GetSizeWH();
    $dc->SetFont($meter->Font());
    $dc->SetTextForeground($meter->LimitColour());
    if($meter->DirHorizFlag()) {
        my $valuetext = sprintf("%d", $meter->Min());
        my ($tw, $th) = $dc->GetTextExtent($valuetext);
        $dc->DrawText($valuetext, 5, $h/2-$th/2);
        $valuetext = sprintf("%d", $meter->Max());
        ($tw, $th) = $dc->GetTextExtent($valuetext);
        $dc->DrawText($valuetext, $w-$tw-5, $h/2-$th/2);
    }
    else {
        my $valuetext = sprintf("%d", $meter->Min());
        my ($tw, $th) = $dc->GetTextExtent($valuetext);
        $dc->DrawText($valuetext, $w/2-$tw/2, $h-$th-5);
        $valuetext = sprintf("%d", $meter->Max());
        ($tw, $th) = $dc->GetTextExtent($valuetext);
        $dc->DrawText($valuetext, $w/2-$tw/2, 5);
    }     
}
sub DrawTags {							# Draw tic marks and labels
    my($dc, $meter) = @_;
    my($w, $h) = $dc->GetSizeWH();
    my $tcoeff;
    if($meter->DirHorizFlag) {
        $tcoeff = ($w-2)/($meter->Max-$meter->Min);
    }
    else {
        $tcoeff = ($h-2)/($meter->Max-$meter->Min);
    }
    my $pen = Wx::Pen->new($meter->TagsColour, 1, wxSOLID);
    $dc->SetPen($pen);
    my $brush = Wx::Brush->new($meter->TagsColour, wxSOLID);
    $dc->SetBrush($brush);
    $dc->SetTextForeground($meter->TagsColour);
    my $tag = 1;
    while($tag < ($meter->TagsNum-1)) {
        my $scalval = (${$meter->TagsVal}[$tag]-$meter->Min) * $tcoeff;
        my $textvalue = sprintf("%d", ${$meter->TagsVal}[$tag]);
        if($meter->DirHorizFlag) {
            $dc->DrawLine($scalval+1, $h-2, $scalval+1, $h-10);
            my($tw, $th) = $dc->GetTextExtent($textvalue);
            $dc->DrawText($textvalue, $scalval+1-($tw/2), $h-10-$th);
        }
        else {
            $dc->DrawLine($w-2, $h-$scalval-1, $w-10, $h-$scalval-1);
            my($tw, $th) = $dc->GetTextExtent($textvalue);
            $dc->DrawText($textvalue, $w-10-$tw, $h-$scalval-($th/2));
        }
    $tag++;
    }
    DrawLimitBar($dc, $meter);  
}
sub DrawLimitBar {					# Draw small bar at limit setting
    my($dc, $meter) = @_;
    my($w, $h) = $dc->GetSizeWH();
    my $tcoeff;
    if($meter->DirHorizFlag()) {
        $tcoeff = ($w-2)/($meter->Max()-$meter->Min());
    }
    else {
        $tcoeff = ($h-2)/($meter->Max()-$meter->Min());
    }

    my $pen = Wx::Pen->new(Wx::Colour->new("orange"), 3, wxSOLID);
    $dc->SetPen($pen);
    my $brush = Wx::Brush->new($meter->TagsColour(), wxSOLID);
    $dc->SetBrush($brush);
    $dc->SetTextForeground($meter->TagsColour());

    my $scalval = ($meter->AlarmLimit()-$meter->Min()) * $tcoeff;
    if($meter->DirHorizFlag()) {
        $dc->DrawLine($scalval+1, $h-2, $scalval+1, $h-20);
    }
    else {
        $dc->DrawLine($w-2, $h-$scalval, $w-20, $h-$scalval);
    }  
}
sub AddTag {						# Add a tic mark to array
    my($val, $meter) = @_;
    push(@{$meter->TagsVal}, $val);
    $meter->TagsNum($meter->TagsNum+1);    
}
sub SetValue {						# Scale the value for display
    my($dc, $Value, $meter) = @_;
    my($w, $h) = $dc->GetSizeWH();
    my $coeff;
    if($meter->DirHorizFlag()) {
        $coeff = ($w-2)/($meter->Max()-$meter->Min());
    }
    else {
        $coeff = ($h-2)/($meter->Max()-$meter->Min());
    }
    $meter->ScaledValue(($Value-$meter->Min()) * $coeff);
    $meter->RealVal($Value);
}
sub DrawLabel {						# Draw a label at bottom of meter
    my($dc, $meter) = @_;
    my $memdc = Wx::MemoryDC->new();
    $memdc->SelectObject(Wx::Bitmap->new($meter->MeterWidth(), 40));
    my($w, $h) = $memdc->GetSizeWH();
    my $brush = Wx::Brush->new(wxLIGHT_GREY, wxSOLID);
    $memdc->SetBackground($brush);
    my $pen = Wx::Pen->new($meter->TagsColour(), 1, wxSOLID);
    $memdc->SetPen($pen);
    $memdc->SetTextForeground($meter->TagsColour());
    $memdc->SetFont($meter->Font());
    $memdc->Clear();
    my @te = $memdc->GetTextExtent($meter->Label());
    my $x = (($w-$te[0])/2)-5;
    $memdc->DrawText($meter->Label(), $x, 5);
    $dc->Blit(0, $meter->MeterHeight(), $w, $meter->MeterHeight()+40,  $memdc, 0, 0);
}
#
# Object Accessors ------------------------------------------------------------------
#
package LinearMeter::Data;
use strict;
use warnings;
use Class::Accessor::Fast;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw(MeterHeight  MeterWidth ActiveBar PassiveBar ValueColour 
                             BorderColour LimitColour AlarmLimitColour TagsColour ScaledValue
                             RealVal AlarmLimit TagsVal TagsNum StartTag NumTags IncTag Max
                             Min InitialValue lastpos DirHorizFlag ShowCurrent ShowLimits
                             ShowLabel Font Label Selected));

sub new {shift->SUPER::new(@_, \%defaults);}
1;
