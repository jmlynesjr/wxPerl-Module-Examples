#! /home/pete/CitrusPerl/perl/bin/perl
# Change header 2.pl: following James: http://www.perlmonks.org/?node_id=1025552

# Original Author: HelenCr of Perl Monks
# Last Modified by: James M. Lynes Jr. March 28,2013

# Experiment with formatting a ListCtrl column header, font, backcolor, textcolor
# See Perl Monks post reference above for the history.

use strict;
use warnings;
use Wx;
 use 5.014;
 use autodie; 
 use Carp;
 use Carp qw {cluck};
# use Carp::Always; 

package MyFrame;
   use Wx ':everything';
   use Wx ':listctrl';
   use Wx::Event 'EVT_BUTTON';
   use parent -norequire, 'Wx::Frame';
use Data::Dumper;
   sub new { 	#1	MyFrame::
      my ($class, $parent, $title) = @_;
      my $self = $class->SUPER::new(
         $parent,	-1, 		# parent window; ID -1 means any
         $title,  # title
         [150, 150 ],	# position
         [ 350, 400 ],	# size
      );

      my $panel = Wx::Panel->new($self);

      $self->{list_control} = Wx::ListCtrl->new($panel, -1, wxDefaultPosition, [340,100], wxLC_REPORT);
      $self->{list_control}->SetBackgroundColour(wxWHITE);
      $self->{list_control}->SetTextColour(wxBLUE);
      $self->{list_control}->SetFont(Wx::Font->new(14, wxFONTFAMILY_ROMAN, wxNORMAL, wxNORMAL));

		my $itemCol = Wx::ListItem->new;
		$itemCol->SetText('Column 1');
                $itemCol->SetWidth(100);
		$self->{list_control}->InsertColumn(0, $itemCol);

		$itemCol->SetText('Column 2');
                $itemCol->SetWidth(135);
		$self->{list_control}->InsertColumn(1, $itemCol);

		$itemCol->SetText('Column 3');
                $itemCol->SetWidth(100);
		$self->{list_control}->InsertColumn(2, $itemCol);

		$self->{list_control}->InsertStringItem( 0, 'Data 1' );
		$self->{list_control}->SetItem( 0, 1, 'Data 3');
        
                my $f = Wx::Font->new(12, wxFONTFAMILY_ROMAN, wxNORMAL, wxBOLD);        
                my $item = $self->{list_control}->GetItem(0);
                $item->SetTextColour(wxRED);
                $item->SetFont($f);
		$self->{list_control}->SetItem($item);

		$self->{list_control}->InsertStringItem( 1, 'Data 2' );
		$self->{list_control}->SetItem( 1, 1, 'Data 4');

                $item = $self->{list_control}->GetItem(1);
                $item->SetTextColour(wxRED);
                $item->SetFont($f);
		$self->{list_control}->SetItem($item);

		my $btn_header = Wx::Button->new($panel, -1, 'Change header', wxDefaultPosition, wxDefaultSize);
		my $btn_item = Wx::Button->new($panel, -1, 'Change item font', wxDefaultPosition, wxDefaultSize);
		my $btn_header2 = Wx::Button->new($panel, -1, 'Change header2 font', wxDefaultPosition, wxDefaultSize);

		EVT_BUTTON ($self, $btn_header, sub { $self->{list_control}->MyFrame::on_header });
		EVT_BUTTON ($self, $btn_item, sub { $self->{list_control}->MyFrame::on_item });
		EVT_BUTTON ($self, $btn_header2, sub { $self->{list_control}->MyFrame::on_header2 });

      my $sizer = Wx::BoxSizer->new(wxVERTICAL);
      $sizer->Add($self->{list_control}, 0, wxALL, 10);
      $sizer->Add($btn_header, 0, wxALL, 10);
      $sizer->Add($btn_item, 0, wxALL, 10);
      $sizer->Add($btn_header2, 0, wxALL, 10);
      $panel->SetSizer($sizer);
      $panel->Layout();
      return $self;
   }	#1 end sub new MyFrame::
	
	sub on_header {
		my $this = shift;
		my $column = $this->GetColumn(1);
		$column->SetText('NEW TITLE');
		$this->SetColumn(1, $column);
	} #1	end sub on_header

	sub on_item {
		my $this = shift;
		my $item = $this->GetItem(1);
                $item->SetTextColour(wxGREEN);
		my $f = Wx::Font->new(12, wxFONTFAMILY_ROMAN, wxNORMAL, wxBOLD);
                $item->SetFont($f);
		$this->SetItem($item);
	} #1	end sub on_item

	sub on_header2 {
		my $this = shift;
		my $itemCol = Wx::ListItem->new;
		$itemCol->SetText('Column 2');
		$this->SetColumn(1, $itemCol);
	} #1	end sub on_header2

# end package MyFrame::		

package main;
my $frame = MyFrame->new(undef, 'Setting headers');
$frame->Show(1);   
my $app = Wx::SimpleApp->new;
$app->MainLoop;

1;

