#! /home/pete/CitrusPerl/perl/bin/perl

# LCD Alarm Clock Custom Dialog using a Text Validator
# Derived from lib/wx/DemoModules/wxValidator.pm
# Example of building a custom dialog
#
# James M. Lynes, Jr.
# Last Modified: February 14, 2013
#
# Set the Alarm time and Clock Type - 12 or 24 Hour style

package LCDAlarmClockDialog;

use strict;
use warnings;
use base qw(Wx::Dialog);
use Wx qw(wxID_OK wxID_CANCEL);
use Data::Dumper;

sub new {
    my( $class, $parent ) = @_;
    my $self = $class->SUPER::new( $parent, -1, 'LCD Alarm Clock Configuration Dialog',
                                   [400,250], [350, 175] );

    $self->{time} = $parent->{clock}->time;			# Pass in default time value
    $self->{timedefault} = $parent->{clock}->time;		# Save default data for later rollback


    Wx::StaticText->new( $self, -1, "Enter the Alarm Time in 24 hour format (hh:mm)", [10, 10] );

# simple time validator - allow digits and the colon(:) - has to be a character class
# One validator for each Text Ctrl to be validated - repeat this block
    my $timeval = LCDAlarmClockDialog::Validator->new( '[\d:]', \($self->{time}) );
    my $t1 = Wx::TextCtrl->new( $self, -1, '', [10, 40] );
    $t1->SetValidator( $timeval );

# Radiobox used for clock type entry
    my @opts = ("12 Hour Format", "24 Hour Format");
    $self->{radiobox} = Wx::RadioBox->new($self, -1, "Clock Type", [10, 80],
                                    [300, 50], \@opts);
    $self->{radiobox}->SetSelection(1);				# Default to 24 hour Mode

# the validation/data transfer phase are automatic for a
# dialog where the Ok button has ID wxID_OK, otherwise
# an explicit call to Validate/TransferDataFromWindow is required
# when closing the dialog - See lib/wx/DemoModules/wxValidator.pm Frame example
    Wx::Button->new( $self, wxID_OK, "Ok", [10, 140] );
    Wx::Button->new( $self, wxID_CANCEL, "Cancel", [100, 140] );

    return $self;
}
1;
#
# Return values back to dialog caller
#
sub get_time {							# One get_xxxx sub for each dialog data item
    my($self) = @_;
    my $time = $self->{time};
    if($time =~ /^(\d{1,2}:\d{2,}$)/) {				# ##:## or #:## confirmed?
        my @hrmn =  split ":", $time;
        if( $hrmn[0] <= 23 && $hrmn[1] <= 59) {return $time};	# Valid time range? Yes
    }
    return $self->{timedefault};				# No, return the default time
}
sub get_clock_type {						# Index 0 - 12 Hour type
    my($self) = @_;						#       1 - 24 Hour type
    return $self->{radiobox}->GetSelection;
}
    
package LCDAlarmClockDialog::Validator;

use strict;
use warnings;
use base qw(Wx::Perl::TextValidator);
use Data::Dumper;

# trivial class, just to log method calls when uncommented
sub Validate {
    my $self = shift;

#    Wx::LogMessage( "In Validate(): data is '%s'", 
#                    $self->GetWindow->GetValue );

    return $self->SUPER::Validate( @_ );
}

sub TransferFromWindow {
    my $self = shift;

#    Wx::LogMessage( "In TransferFromWindow(): data is '%s'", 
#                    $self->GetWindow->GetValue );
    return $self->SUPER::TransferFromWindow( @_ );
}

sub TransferToWindow {
    my $self = shift;

#    peeking at internals; naughty me...
#    Wx::LogMessage( "In TransferToWindow(): data is '%s'",
#                    ${$self->{data}} );

    return $self->SUPER::TransferToWindow( @_ );
}
#
# Define Accessors for the LCDAlarmClockDialog object
#
package LCDAlarmClockDialog::Data;
use strict;
use warnings;
use Class::Accessor::Fast;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw(time flag2412));
#
# Create an LCDAlarmClockDialog object
#
sub new {shift->SUPER::new(@_);}
1;

