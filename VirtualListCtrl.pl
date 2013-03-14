#! /home/pete/CitrusPerl/perl/bin/perl

# wxPerl Virtual list control test
# Created by: HelenCR
# Last Modified: March 14,2013 by James M. Lynes, Jr. 

package MyForm; 

use strict; 
use warnings; 
use Wx qw[:everything]; 
use base 'Wx::Frame'; 

sub new { 
    my $class = shift; 
    my $self = $class->SUPER::new( undef, -1, 'Phone book', [ 200,  200 ], wxDefaultSize); 

    my $panel = Wx::Panel->new($self, -1, wxDefaultPosition, wxDefaultSize);
 
    $self->{list_ctrl} = MyListCtrl->new($panel); 

    my $sizer = Wx::BoxSizer->new(wxVERTICAL); 
    $sizer->Add( $self->{list_ctrl}, 0, wxALL | wxEXPAND, 5 ); 
    $panel->SetSizer($sizer);
	 
    return $self; 
} 
 
package MyListCtrl;

# Subclass ListCtrl to allow use of a Virtual List Control and a custom OnGetItemText Subroutine

use strict;
use warnings;
use base qw(Wx::ListCtrl);
use Wx qw(:everything);

sub new {
    my( $class, $parent ) = @_;
    my $self = $class->SUPER::new( $parent, -1, wxDefaultPosition, wxDefaultSize,
                                   wxBORDER_SUNKEN | wxLC_REPORT | wxLC_VIRTUAL | wxLC_HRULES );

    $self->InsertColumn( 0, 'Last Name' ); 
    $self->InsertColumn( 1, 'First Name' ); 
    $self->InsertColumn( 2, 'Addr City' ); 
    $self->InsertColumn( 3, 'Addr State' ); 
    $self->SetItemCount( 1000 );

    return $self;
}

sub OnGetItemText { 
    print "Entered OnGetItemText\n"; 
    my ($line, $column, $data_item); 
    my ($self, $item, $col) = @_; 
    $data_item = 'test'; 
    return $data_item;
} 

my $app = Wx::SimpleApp->new; 
my $frame = MyForm->new; 
$frame->Show(1); 
$app->MainLoop;

