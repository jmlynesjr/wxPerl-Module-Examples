#! /home/pete/CitrusPerl/perl/bin/perl
#############################################################################
## Name:        lib/Wx/DemoModules/wxGridTable.pm
## Purpose:     wxPerl demo hlper for wxGrid custom wxGridTable
## Author:      Mattia Barbon
## Modified by:
## Created:     05/08/2003
## RCS-ID:      $Id: wxGridTable.pm 3118 2011-11-18 09:58:12Z mdootson $
## Copyright:   (c) 2003, 2005, 2006, 2011 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

# wxGridTable.pl
# wxGridTable.pm modified into a standalone test program for a "Virtual" Grid control with
#    custom Column and Row header text, fonts, colors, sizes and several other
#    configurable options. The data and mouse events are unchanged from the original example.
# Combines the wxDemo wxGridTable.pm with my Grid.pl test code(see PM post below) along
#     with the  http://wiki.wxperl.nl/Wx::GridTableBase example.
# See the  Perl Monks post: http://www.perlmonks.org/?node=1025489
#    "Wx::Perl: How to change/set font and size of Wx::ListCtrl column headings?"
#    for the history of this example code.    
# Last Modified: James M. Lynes Jr. March 31,2013

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
use Data::Dumper;

sub new {
    my($self) = @_;

    $self = $self->SUPER::new(undef, -1, "wxGridTable.pl - Virtual Grid Control Example", 
                              wxDefaultPosition, [950,650]);
    my $gtapp = MyGridTableApp->new($self);
    return $self;
}
1;

# Custom Grid Table sub-classed from PlGridTable called from MyGridTableApp
package MyGridTable;

use strict;
use warnings;
use Wx qw(:everything);
use Wx::Grid;
use base qw(Wx::PlGridTable);
use Data::Dumper;

use Wx qw(wxRED wxGREEN);

sub new {
  my( $class ) = @_;
  my $self = $class->SUPER::new;

  $self->{default} = Wx::GridCellAttr->new;			# Cell attributes for demo purposes
  $self->{red_bg} = Wx::GridCellAttr->new;
  $self->{green_fg} = Wx::GridCellAttr->new;

  $self->{red_bg}->SetBackgroundColour( wxRED );
  $self->{green_fg}->SetTextColour( wxGREEN );

  return $self;
}

# Overridden Methods from the base class - these get modified/expanded in a real app
sub GetNumberRows { 1000 }					# Base demo is set for 100000 x 100000
sub GetNumberCols { 10 }
sub IsEmptyCell { 0 }

sub GetValue {
  my( $grid, $y, $x ) = @_;

  return "($y, $x)";
}

sub SetValue {
  my( $grid, $x, $y, $value ) = @_;

  die "Read-Only table";
}

sub GetTypeName {						# Verified that swapping bool and double
  my( $grid, $r, $c ) = @_;					# Swap the columns

  return $c == 0 ? 'double' :					# Col 0 Boolean
         $c == 1 ? 'bool' :					# Col 1 Double
                   'string';					# All others String
}

sub CanGetValueAs {
  my( $grid, $r, $c, $type ) = @_;

  return $c == 0 ? $type eq 'double' :
         $c == 1 ? $type eq 'bool' :
                   $type eq 'string';
}

sub GetValueAsBool {						# Even rows false
  my( $grid, $r, $c ) = @_;					# Odd rows true

  return $r % 2;
}

sub GetValueAsDouble {						# Row # plus (Col #/1000)
  my( $grid, $r, $c ) = @_;

  return $r + $c / 1000;
}

sub GetAttr {							# Cell attributes
  my( $grid, $row, $col, $kind ) = @_;

  return $grid->{default} if $row % 2 && $col % 2;		# Odd rows and odd cols default format
  return $grid->{red_bg} if $row % 2;				# Odd rows only - red background
  return $grid->{green_fg} if $col % 2;				# Odd cols only - green foreground text
  return Wx::GridCellAttr->new;					# Even rows and even cols - default format 
}

sub SetColLabelValue {						# Copied from the wiki for custom labels
   my ($grid, $col, $value) = @_;
   $col = $grid->_checkCol($col);
   return unless defined $col;
   $$grid{coldata}->[$col]->{label} = $value;
}

sub GetColLabelValue {						# Copied from the wiki for custom labels
   my ($grid, $col) = @_;
   $col = $grid->_checkCol($col);
   return undef unless defined $col;
   return $$grid{coldata}->[$col]->{label};
}

sub _checkCol {							# Copied from the wiki for custom labels
   my ($grid, $col) = @_;
   my $cols = $grid->GetNumberCols;
   return undef unless defined $col && abs($col) < $cols;
   return $cols + $col if $col < 0;
   return $col;
}

sub SetRowLabelValue {						# Modeled after the wiki for custom labels
   my ($grid, $row, $value) = @_;
   $row = $grid->_checkRow($row);
   return unless defined $row;
   $$grid{rowdata}->[$row]->{label} = $value;
}

sub GetRowLabelValue {						# Modeled after the wiki for custom labels
   my ($grid, $row) = @_;
   $row = $grid->_checkRow($row);
   return undef unless defined $row;
   return $$grid{rowdata}->[$row]->{label};
}

sub _checkRow {							# Modeled after the wiki for custom labels
   my ($grid, $row) = @_;
   my $rows = $grid->GetNumberRows;
   return undef unless defined $row && abs($row) < $rows;
   return $rows + $row if $row < 0;
   return $row;
}

# Demo application for an enhanced "Virtual" Grid Control - fromm wxPerl Demo application
package MyGridTableApp;

use strict;
use warnings;
use Wx qw(:everything);
use base qw(Wx::Grid);
use Data::Dumper;

use Wx::Event qw(EVT_GRID_CELL_LEFT_CLICK EVT_GRID_CELL_RIGHT_CLICK
    EVT_GRID_CELL_LEFT_DCLICK EVT_GRID_CELL_RIGHT_DCLICK
    EVT_GRID_LABEL_LEFT_CLICK EVT_GRID_LABEL_RIGHT_CLICK
    EVT_GRID_LABEL_LEFT_DCLICK EVT_GRID_LABEL_RIGHT_DCLICK
    EVT_GRID_ROW_SIZE EVT_GRID_COL_SIZE EVT_GRID_RANGE_SELECT
    EVT_GRID_SELECT_CELL);
    
# events changed names in version 2.9.x
my $events29plus = ( defined(&Wx::Event::EVT_GRID_CELL_CHANGED) );

sub new {
  my ($class, $frame) = @_;
  my $grid = $class->SUPER::new($frame, wxID_ANY, wxDefaultPosition,		# Grid object
		   		Wx::Size->new(950,700));

  my $table = MyGridTable->new;							# Virtual Table object
  $grid->SetTable( $table );

# Custom Grid Formatting Examples- text, fonts, colors, sizes, gridlines - from Grid.pl
	$grid->SetLabelBackgroundColour(wxBLUE);
	$grid->SetLabelTextColour(Wx::Colour->new("yellow"));
	$grid->SetLabelFont(Wx::Font->new(14, wxFONTFAMILY_ROMAN, wxNORMAL, wxBOLD));
	$grid->SetColLabelSize(40);				# Col height
	$grid->SetRowLabelSize(100);				# Row height - 0 hides the row labels
	$grid->SetDefaultColSize(120,1);			# Default Cell width (Fit overrides)
	$grid->SetDefaultRowSize(40,1);				# Default Cell Height (Fit overrides)
	$grid->EnableGridLines(1);				# Grid lines 1-on, 0-off
	$grid->SetGridLineColour(wxBLUE);
	$grid->SetSelectionMode(wxGridSelectRows);		# Always select complete rows
	$grid->SetSelectionForeground(wxRED);
        $grid->SetSelectionBackground(wxGREEN);			# Click within grid, background goes green
								# Click on row label, background stays black
								# until clicking within grid, then green(???)

        for my $c (0..$grid->GetNumberCols()-1) {		# Column Header Text
            my $cptr = $c+1;
            $grid->SetColLabelValue($c, "Col $cptr");
        }

        for my $r (0..$grid->GetNumberRows()-1) {		# Row Header Text
            my $rptr = $r+1;
            $grid->SetRowLabelValue($r, "Row $rptr");
        }

# Sample Events - logs the events
  EVT_GRID_CELL_LEFT_CLICK( $grid, c_log_skip( "Cell left click" ) );
  EVT_GRID_CELL_RIGHT_CLICK( $grid, c_log_skip( "Cell right click" ) );
  EVT_GRID_CELL_LEFT_DCLICK( $grid, c_log_skip( "Cell left double click" ) );
  EVT_GRID_CELL_RIGHT_DCLICK( $grid, c_log_skip( "Cell right double click" ) );
  EVT_GRID_LABEL_LEFT_CLICK( $grid, c_log_skip( "Label left click" ) );
  EVT_GRID_LABEL_RIGHT_CLICK( $grid, c_log_skip( "Label right click" ) );
  EVT_GRID_LABEL_LEFT_DCLICK( $grid, c_log_skip( "Label left double click" ) );
  EVT_GRID_LABEL_RIGHT_DCLICK( $grid, c_log_skip( "Label right double click" ) );

  EVT_GRID_ROW_SIZE( $grid, sub {
                       Wx::LogMessage( "%s %s", "Row size", GS2S( $_[1] ) );
                       $_[1]->Skip;
                     } );
  EVT_GRID_COL_SIZE( $grid, sub {
                       Wx::LogMessage( "%s %s", "Col size", GS2S( $_[1] ) );
                       $_[1]->Skip;
                     } );

  EVT_GRID_RANGE_SELECT( $grid, sub {
                           Wx::LogMessage( "Range %sselect (%d, %d, %d, %d)",
                                           ( $_[1]->Selecting ? '' : 'de' ),
                                           $_[1]->GetLeftCol, $_[1]->GetTopRow,
                                           $_[1]->GetRightCol,
                                           $_[1]->GetBottomRow );
                           $_[0]->ShowSelections;
                           $_[1]->Skip;
                         } );
  
  if( $events29plus ) {
        Wx::Event::EVT_GRID_CELL_CHANGED( $grid, c_log_skip( "Cell content changed" ) );
    } else {
        Wx::Event::EVT_GRID_CELL_CHANGE( $grid, c_log_skip( "Cell content changed" ) );
  }
  
  EVT_GRID_SELECT_CELL( $grid, c_log_skip( "Cell select" ) );

  return $grid;
}

sub ShowSelections {
    my $grid = shift;

    my @cells = $grid->GetSelectedCells;
    if( @cells ) {
        Wx::LogMessage( "Cells %s selected", join ', ',
                                                  map { "(" . $_->GetCol .
                                                        ", " . $_->GetRow . ")"
                                                       } @cells );
    } else {
        Wx::LogMessage( "No cells selected" );
    }

    my @tl = $grid->GetSelectionBlockTopLeft;
    my @br = $grid->GetSelectionBlockBottomRight;
    if( @tl && @br ) {
        Wx::LogMessage( "Blocks %s selected",
                        join ', ',
                        map { "(" . $tl[$_]->GetCol .
                              ", " . $tl[$_]->GetRow . "-" .
                              $br[$_]->GetCol . ", " .
                              $br[$_]->GetRow . ")"
                            } 0 .. $#tl );
    } else {
        Wx::LogMessage( "No blocks selected" );
    }

    my @rows = $grid->GetSelectedRows;
    if( @rows ) {
        Wx::LogMessage( "Rows %s selected", join ', ', @rows );
    } else {
        Wx::LogMessage( "No rows selected" );
    }

    my @cols = $grid->GetSelectedCols;
    if( @cols ) {
        Wx::LogMessage( "Columns %s selected", join ', ', @cols );
    } else {
        Wx::LogMessage( "No columns selected" );
    }
}

# pretty printer for Wx::GridEvent
sub G2S {
  my $event = shift;
  my( $x, $y ) = ( $event->GetCol, $event->GetRow );

  return "( $x, $y )";
}

# prety printer for Wx::GridSizeEvent
sub GS2S {
  my $event = shift;
  my $roc = $event->GetRowOrCol;

  return "( $roc )";
}

# creates an anonymous sub that logs and skips any grid event
sub c_log_skip {
  my $text = shift;

  return sub {
    Wx::LogMessage( "%s %s", $text, G2S( $_[1] ) );
    $_[0]->ShowSelections;
    $_[1]->Skip;
  };
}
1;
