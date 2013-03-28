#! /home/pete/CitrusPerl/perl/bin/perl

# CppTrial-pg347.pl modified to Grid.pl
# Cross-Platform GUI Programming with wxWidgets - Smart, Hock, & Csomor
# C++ Example from pg 347 - Simple Grid Example
# Ported to wxPerl by James M. Lynes Jr. - Last Modified March 28,2013
# Expanded to test column and row label formatting
# Appends 1000 rows of dummy data

use strict;
use warnings;
use Wx qw(:everything);
use Wx::Grid;					# Package not loaded by "use Wx qw(:everything)"
use Data::Dumper;

# create the WxApplication
my $app = Wx::SimpleApp->new;
my $frame = Wx::Frame->new(undef, -1, 'Grid.pl', wxDefaultPosition, wxDefaultSize,
		            wxDEFAULT_DIALOG_STYLE | wxRESIZE_BORDER);
myStdDialogs($frame);
$frame->Show;
$app->MainLoop;

sub myStdDialogs {
	my ( $self ) = @_;
	
	my $grid = Wx::Grid->new($self, wxID_ANY, wxDefaultPosition,
		   Wx::Size->new(950,400));

	$grid->CreateGrid(8, 7);				# 8 rows by 7 columns

	$grid->EnableGridLines(1);				# Grid lines 1-on, 0-off
	$grid->SetGridLineColour(wxBLACK);

	$grid->SetDefaultColSize(120,1);			# Default Cell width (Fit overrides)
	$grid->SetDefaultRowSize(40,1);				# Default Cell Height (Fit overrides)

# Your color choices may vary. Not artistic at all! :)

# Label colors and fonts - note affects both column and row labels - didn't see separate row/col methods
	$grid->SetLabelBackgroundColour(wxBLUE);
	$grid->SetLabelTextColour(Wx::Colour->new("yellow"));
	$grid->SetLabelFont(Wx::Font->new(14, wxFONTFAMILY_ROMAN, wxNORMAL, wxBOLD));

# Selection mode - (optionss-cells,rows,cols)
	$grid->SetSelectionMode(wxGridSelectRows);		# Always select complete rows

# Color changes for when cells are selected/highlighted
	$grid->SetSelectionForeground(wxRED);
        $grid->SetSelectionBackground(wxGREEN);			# Click within grid, background goes green
								# Click on row label, background stays black
								# until clicking within grid, then green(???)
# Column label height and Row label width
	$grid->SetColLabelSize(60);
	$grid->SetRowLabelSize(90);				# 0 hides the row labels

# Custom column labels						# Very creative!
	$grid->SetColLabelValue(0,"Column 1");
	$grid->SetColLabelValue(1,"Column 2");
	$grid->SetColLabelValue(2,"Column 3");
	$grid->SetColLabelValue(3,"Column 4");
	$grid->SetColLabelValue(4,"Column 5");
	$grid->SetColLabelValue(5,"Column 6");
	$grid->SetColLabelValue(6,"Column 7");

# Custom row labels						# More creative
	$grid->SetRowLabelValue(0,"Row 1");
	$grid->SetRowLabelValue(1,"Row 2");
	$grid->SetRowLabelValue(2,"Row 3");
	$grid->SetRowLabelValue(3,"Row 4");
	$grid->SetRowLabelValue(4,"Row 5");
	$grid->SetRowLabelValue(5,"Row 6");
	$grid->SetRowLabelValue(6,"Row 7");
	$grid->SetRowLabelValue(7,"Row 8");

# Misc dummy grid data
	$grid->SetCellValue(0, 0, "wxGrid is Good");		# A1
	
	$grid->SetCellValue(0, 3, "This is Read-only");		# D1
	$grid->SetReadOnly(0, 3);
	
	$grid->SetCellValue(3, 3, "Green on Grey");		# D4
	$grid->SetCellFont(3, 3, Wx::Font->new(10, wxFONTFAMILY_ROMAN, wxNORMAL, wxBOLD));
	$grid->SetCellTextColour(3, 3, wxGREEN);
	$grid->SetCellBackgroundColour(3, 3, wxLIGHT_GREY);

	$grid->SetColFormatFloat(5, 6, 4);			# Seems to right justify this column
	$grid->SetCellValue(0, 5, "3.1415");			# F1

	for (0..1000) {						# Additional rows causes the scroll bar to appear
	    appendrow($grid);
	}
	
	$grid->Fit();						# Shrink row/col sizes to fit(comment out?)
								# overrides defaults above
	$self->SetClientSize($grid->GetSize);
}

sub appendrow {							# Append a row of dummy data
	my ($grid) = @_;
	$grid->AppendRows(1, 1);
	my $rows = $grid->GetNumberRows();
	$grid->SetRowLabelValue($rows-1,"Row $rows");
	for my $c(0..6) {
	    my $ctr = $c + 1;	
	    $grid->SetCellValue($rows-1, $c, "New Row: Col $ctr"); # Get real data from SQL table
	}
}
