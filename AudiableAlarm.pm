#! /home/pete/CitrusPerl/perl/bin/perl

# AudiableAlarm.pm - Module to play a selected MP3 file as an alarm sound
#
# Method: StartAlarm
#
# Calling Sequence(where $self is the top level window):
#    use AudiableAlarm;
#    $self->{alarm} = AudiableAlarm::Data->new();
#    $self->{alarm}->AlarmFile("/home/pete/Projects/perlprojects/AlarmClock/test.mp3");
#    AudiableAlarm->StartAlarm($self);
#    AudiableAlarm->StopAlarm($self);
# Don't call StopAlarm before StartAlarm, the media object won't yet exist
# The AlarmFile name has to be a full pathname
#
# James M. Lynes, Jr
# Last Modified: February 8, 2013
#

package AudiableAlarm;
use strict;
use warnings;
use Wx;
use Wx::Media;
use Wx::Event qw(EVT_LEFT_DOWN EVT_RIGHT_DOWN);
use Data::Dumper;

my %defaults = (
               AlarmFile => "",
    );

sub StartAlarm {
    my($class, $self) = @_;
    $self->{media} = Wx::MediaCtrl->new( $self, -1, '', [-1,-1], [-1,-1], 0 );
    EVT_LEFT_DOWN($self->{media}, \&onEvtDown);
    EVT_RIGHT_DOWN($self->{media}, \&onEvtDown);
    $self->{media}->LoadFile($self->{alarm}->AlarmFile());
    $self->{media}->Play();
}
sub StopAlarm {
    my($class, $self) = @_;
    $self->{media}->Stop();
}
sub onEvtDown {
    my($self, $event) = @_;
    $self->Stop();
    $event->Skip();
}
package AudiableAlarm::Data;
use strict;
use warnings;
use Class::Accessor::Fast;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw(AlarmFile));

sub new {shift->SUPER::new(@_, \%defaults);}
1;
