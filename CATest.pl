#! /home/pete/CitrusPerl/perl/bin/perl

# Test of Class::Accessor::Fast

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

    $self = $self->SUPER::new(undef, -1, "Class::Accessor Test", 
                              wxDefaultPosition, wxDefaultSize);
    my %defaults = (
                    vara => 10,
                    varb => 20,
                    varc => 30,
                    vard => 40,
                    vare => 50,
    );

    my $obj = Data->new(\%defaults);			# Object created and initialized correctly
    print Dumper($obj);

    $obj->vara(100);					# Use of generated accessors
    $obj->varb(200);
    $obj->varc(300);
    $obj->vard(400);
    $obj->vare(500);
    print Dumper($obj);

    return $self;
}
1;
BEGIN {							# Begin block required since Data is
package Data;						# not in a separate module. Therefore
use strict;						# mk_accessors is not run before being used
use warnings;						# and accessor subs would not be defined.
use Class::Accessor::Fast;				# Normally use Data would fix this issue
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw(vara varb varc vard vare));

sub new {shift->SUPER::new(@_);}
1;
}
