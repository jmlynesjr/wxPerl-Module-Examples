#! /home/pete/CitrusPerl/perl/bin/perl

# ImpedanceGraph2.pl
# Impedance calculator for Ls & Cs with graphic display
#
# Example of using GD::Graph with wxPerl to draw a simple line graph.
#
# Calculates and graphs the L or C impedance for a range of frequencies.
#	Graph and save_chart borrowed from GD::Graph sample51.pl
#
# Notes: Original version used the Linux Gnome File Viewer - eog - to display the graph file.
#
#	 This version uses a Display Dialog and Display Panel to display the
#	 png graph image using a PaintDC. This version is platform Independant.
#
# James M. Lynes, Jr.
# Last Modified: June 29, 2013
#
# DisplayDialog and DisplayPanel code provided by Mark Dootson, integrated June 29, 2013.
#

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
    Wx::InitAllImageHandlers();
    my $frame = Frame->new();
    $frame->Show(1);
}

package DisplayPanel;
use strict;
use warnings;
use Wx qw(:everything);
use base qw(Wx::Panel);
use Wx::Event qw( EVT_PAINT );

sub new {
	my ($class, $parent, $bitmap) = @_;
	my $self = $class->SUPER::new($parent, -1, wxDefaultPosition, 
		                      [ $bitmap->GetWidth, $bitmap->GetHeight ], wxBORDER_NONE);	
	$self->{bitmap} = $bitmap;
	EVT_PAINT($self, \&OnEvtPaint);
	return $self;
}

sub OnEvtPaint {
	my ($self, $event) = @_;
	my $dc = Wx::PaintDC->new($self);
        $dc->DrawBitmap($self->{bitmap}, 0,0,0);
}
	
package DisplayDialog;
use strict;
use warnings;
use Wx qw(:everything);
use base qw(Wx::Dialog);

sub new {
	my($class, $parent, $image) = @_;
	
	my $self = $class->SUPER::new($parent, -1, 'Impedance vs. Frequency Graph');
	
	my $bitmap = Wx::Bitmap->new($image);
	my $canvas = DisplayPanel->new($self, $bitmap);
	
	my $sizer = Wx::BoxSizer->new(wxVERTICAL);
	$sizer->Add($canvas,1,wxEXPAND|wxALL,0);
	$self->SetSizerAndFit($sizer);
	return $self;	
}

package Frame;
use strict;
use warnings;
use Wx qw(:everything);
use base qw(Wx::Frame);
use Wx::Event qw(EVT_BUTTON EVT_CHOICE);
use GD::Graph::lines;
use Data::Dumper;

sub new {
    my($self) = @_;

    $self = $self->SUPER::new(undef, -1, "L or C Impedance Graph", 
                              wxDefaultPosition, [375, 550]);

    my @Inductors = ("nH", "uH", "mH");
    my @Capacitors = ("pF", "nF", "uF");
    my @Frequency = ("Hz", "KHz", "MHz");
    $self->{lmultiplyer} = 1E-09;	# nH Default Scale Factors
    $self->{cmultiplyer} = 1E-12;	# pF
    $self->{flmultiplyer} = 1E06;	# MHz
    $self->{fhmultiplyer} = 1E06;	# MHz
    $self->{swmultiplyer} = 1E06;	# Mhz
    $self->{xamultiplyer} = 1E06;	# Mhz

    $self->{st1} = Wx::StaticText->new($self, -1, "Inductor Value", Wx::Point->new(25,50),
                                       wxDefaultSize, wxALIGN_LEFT);
    $self->{st2} = Wx::StaticText->new($self, -1, "Capacitor Value", Wx::Point->new(25,100),
                                       wxDefaultSize, wxALIGN_LEFT);
    $self->{st3} = Wx::StaticText->new($self, -1, "Sweep Start", Wx::Point->new(25,150),
                                       wxDefaultSize, wxALIGN_LEFT);
    $self->{st4} = Wx::StaticText->new($self, -1, "Sweep End", Wx::Point->new(25,200),
                                       wxDefaultSize, wxALIGN_LEFT);
    $self->{st5} = Wx::StaticText->new($self, -1, "Sweep Step", Wx::Point->new(25,250),
                                       wxDefaultSize, wxALIGN_LEFT);
    $self->{st6} = Wx::StaticText->new($self, -1, "Enter an L or C and a Sweep Range to be Graphed",
                                       Wx::Point->new(25,15), wxDefaultSize, wxALIGN_LEFT);
    $self->{st7} = Wx::StaticText->new($self, -1, "Y-Axis Max", Wx::Point->new(25,450),
                                       wxDefaultSize, wxALIGN_LEFT);
    $self->{st8} = Wx::StaticText->new($self, -1, "Y-Axis Ticks", Wx::Point->new(25,475),
                                       wxDefaultSize, wxALIGN_LEFT);
    $self->{st8} = Wx::StaticText->new($self, -1, "X-Axis Scale", Wx::Point->new(25,500),
                                       wxDefaultSize, wxALIGN_LEFT);

 
    $self->{tc1} = Wx::TextCtrl->new($self, -1, "", Wx::Point->new(150,50), Wx::Size->new(100,20));
    $self->{tc2} = Wx::TextCtrl->new($self, -1, "", Wx::Point->new(150,100), Wx::Size->new(100,20));
    $self->{tc3} = Wx::TextCtrl->new($self, -1, "", Wx::Point->new(150,150), Wx::Size->new(100,20));
    $self->{tc4} = Wx::TextCtrl->new($self, -1, "", Wx::Point->new(150,200), Wx::Size->new(100,20));
    $self->{tc5} = Wx::TextCtrl->new($self, -1, "", Wx::Point->new(150,250), Wx::Size->new(100,20));
    $self->{tc6} = Wx::TextCtrl->new($self, -1, "", Wx::Point->new(150,450), Wx::Size->new(100,20));
    $self->{tc7} = Wx::TextCtrl->new($self, -1, "", Wx::Point->new(150,475), Wx::Size->new(100,20));
    $self->{tc1}->SetValue(0);		# L = 0 Default Data Values
    $self->{tc2}->SetValue(0);		# C = 0
    $self->{tc3}->SetValue(1);		# 1 MHz
    $self->{tc4}->SetValue(30);		# 30 MHz
    $self->{tc5}->SetValue(1);		# 1 MHz
    $self->{tc6}->SetValue(10000);	# 10K ohms
    $self->{tc7}->SetValue(20);		# 20 ticks

    $self->{lc} = Wx::Choice->new($self, 1, Wx::Point->new(250, 50), wxDefaultSize, \@Inductors);
    $self->{cc} = Wx::Choice->new($self, 2, Wx::Point->new(250, 100), wxDefaultSize, \@Capacitors);
    $self->{flc} = Wx::Choice->new($self, 3, Wx::Point->new(250, 150), wxDefaultSize, \@Frequency);
    $self->{fhc} = Wx::Choice->new($self, 4, Wx::Point->new(250, 200), wxDefaultSize, \@Frequency);
    $self->{swc} = Wx::Choice->new($self, 5, Wx::Point->new(250, 250), wxDefaultSize, \@Frequency);
    $self->{xscale} = Wx::Choice->new($self, 6, Wx::Point->new(150, 500), wxDefaultSize, \@Frequency);
    $self->{flc}->SetSelection(2);	# MHz Defaut Choices
    $self->{fhc}->SetSelection(2);	# MHz
    $self->{swc}->SetSelection(2);	# MHz
    $self->{xscale}->SetSelection(2);	# MHz
    $self->{bt1} = Wx::Button->new($self, 4, "Graph Cs", Wx::Point->new(25,350), wxDefaultSize);
    $self->{bt1} = Wx::Button->new($self, 5, "Graph Ls", Wx::Point->new(150,350), wxDefaultSize);
    $self->{bt1} = Wx::Button->new($self, 6, "Clear C and L", Wx::Point->new(25,300), wxDefaultSize);
    $self->{bt2} = Wx::Button->new($self, wxID_CLOSE, "Exit", Wx::Point->new(25,400), wxDefaultSize); 

    EVT_BUTTON($self, 4, \&CalcC);
    EVT_BUTTON($self, 5, \&CalcL);
    EVT_BUTTON($self, 6, \&ClearAll);
    EVT_BUTTON($self, wxID_CLOSE, \&Close);
    EVT_CHOICE($self, 1, \&ChoiceL);
    EVT_CHOICE($self, 2, \&ChoiceC);
    EVT_CHOICE($self, 3, \&ChoiceFL);
    EVT_CHOICE($self, 4, \&ChoiceFH);
    EVT_CHOICE($self, 5, \&ChoiceSW);
    EVT_CHOICE($self, 6, \&ChoiceXA);
    
    return $self;
}

sub CalcC {
    my($self, $event) = @_;
    my @xvalues;
    my @yvalues;
    my $C = $self->{tc2}->GetValue * $self->{cmultiplyer};
    if($C == 0) {return};
    my $fl = $self->{tc3}->GetValue * $self->{flmultiplyer};
    my $fh = $self->{tc4}->GetValue * $self->{fhmultiplyer};
    my $sw = $self->{tc5}->GetValue * $self->{swmultiplyer};
    for(my $F = $fl; $F <= $fh; $F += $sw) {
        my $I = 1/(6.28 * $C * $F);
        push(@xvalues, $F/$self->{xamultiplyer});
        push(@yvalues, $I);
    }
    Graph($self, \@xvalues, \@yvalues);
}

sub CalcL {
    my($self, $event) = @_;
    my @xvalues;
    my @yvalues;
    my $L = $self->{tc1}->GetValue * $self->{lmultiplyer};
    if($L == 0) {return};
    my $fl = $self->{tc3}->GetValue * $self->{flmultiplyer};
    my $fh = $self->{tc4}->GetValue * $self->{fhmultiplyer};
    my $sw = $self->{tc5}->GetValue * $self->{swmultiplyer};
    for(my $F = $fl; $F <= $fh; $F += $sw) {
        my $I = 6.28 * $L * $F;
        push(@xvalues, $F/$self->{xamultiplyer});
        push(@yvalues, $I);
    }
    Graph($self, \@xvalues, \@yvalues);
}

sub ChoiceL {
    my($self, $event) = @_;
    if($self->{lc}->GetSelection == 0) {$self->{lmultiplyer} = 1E-09};	# nH
    if($self->{lc}->GetSelection == 1) {$self->{lmultiplyer} = 1E-06};	# uH
    if($self->{lc}->GetSelection == 2) {$self->{lmultiplyer} = 1E-03};	# mH
}

sub ChoiceC {
    my($self, $event) = @_;
    if($self->{cc}->GetSelection == 0) {$self->{cmultiplyer} = 1E-12};	# pF
    if($self->{cc}->GetSelection == 1) {$self->{cmultiplyer} = 1E-09};	# nF
    if($self->{cc}->GetSelection == 2) {$self->{cmultiplyer} = 1E-06};	# uF
}

sub ChoiceFL {
    my($self, $event) = @_;
    if($self->{flc}->GetSelection == 0) {$self->{flmultiplyer} = 1};	# Hz
    if($self->{flc}->GetSelection == 1) {$self->{flmultiplyer} = 1E03};	# KHz
    if($self->{flc}->GetSelection == 2) {$self->{flmultiplyer} = 1E06};	# MHz
}

sub ChoiceFH {
    my($self, $event) = @_;
    if($self->{fhc}->GetSelection == 0) {$self->{fhmultiplyer} = 1};	# Hz
    if($self->{fhc}->GetSelection == 1) {$self->{fhmultiplyer} = 1E03};	# KHz
    if($self->{fhc}->GetSelection == 2) {$self->{fhmultiplyer} = 1E06};	# MHz
}

sub ChoiceSW {
    my($self, $event) = @_;
    if($self->{swc}->GetSelection == 0) {$self->{swmultiplyer} = 1};	# Hz
    if($self->{swc}->GetSelection == 1) {$self->{swmultiplyer} = 1E03};	# KHz
    if($self->{swc}->GetSelection == 2) {$self->{swmultiplyer} = 1E06};	# MHz
}

sub ChoiceXA {
    my($self, $event) = @_;
    if($self->{xscale}->GetSelection == 0) {$self->{xamultiplyer} = 1};		# Hz
    if($self->{xscale}->GetSelection == 1) {$self->{xamultiplyer} = 1E03};	# KHz
    if($self->{xscale}->GetSelection == 2) {$self->{xamultiplyer} = 1E06};	# MHz
}

sub ClearAll {
    my($self, $event) = @_;
    $self->{tc1}->SetValue(0);		# L = 0
    $self->{tc2}->SetValue(0);		# C = 0
}

sub Close {
    my($self, $event) = @_;
    $self->Destroy;
}

sub Graph {					# GD::Graph::lines Line Graph Module
    my($self, $xvalues, $yvalues) = @_;		# From GDGraph-1.45.tar.gz sample51.pl
    my @data = ( 				# Other graph formats are supported. See the pod.
        [(@{$xvalues}) ],
        [(@{$yvalues})],
    );

    my $xlskip = (int(@{$xvalues}) / 30) + 1;	# Only about 30 labels will fit on the x axis. Gotta skip some.
						# Labels still overwrite on occasions. Play with the scaling.

    my $my_graph = new GD::Graph::lines(600,400);
    my $xscale = $self->{xscale}->GetStringSelection;	# Hz, KHz, MHz

    $my_graph->set( 
	x_label => "Frequency($xscale)",
	y_label => 'Impedance(Ohms)',
	title => 'Impedance vs. Frequency',
	y_max_value => $self->{tc6}->GetValue,
	y_min_value => 0,
	y_tick_number => $self->{tc7}->GetValue,
	y_label_skip => 2,
	box_axis => 0,
	line_width => 3,
	transparent => 0,
        x_label_position => 1/2,
        x_label_skip => $xlskip,
    );

    my $gd = $my_graph->plot(\@data);
    
    #save_chart($my_graph, 'impedance');		# From sample51.pl not used in this configuration
    #system('eog /home/pete/Projects/perlprojects/RFdesign/impedance.gif');
    
    # Get the raw PNG data
    my $png = $gd->png;
    
    # Get a file handle and load it as a wxImage
    open my $fh, '<', \$png;
    my $img = Wx::Image->new($fh, &Wx::wxBITMAP_TYPE_PNG);
    close $fh;
    
    my $dialog = DisplayDialog->new($self, $img);
    $dialog->Centre;
    $dialog->ShowModal();
    $dialog->Destroy;
}

sub save_chart						# Separate sub because the sample51.pl was setup this way.
{							# Not used in this configuration
	my $chart = shift or die "Need a chart!";
	my $name = shift or die "Need a name!";
	local(*OUT);

	my $ext = $chart->export_format;

	open(OUT, ">$name.$ext") or 
		die "Cannot open $name.$ext for write: $!";
	binmode OUT;
	print OUT $chart->gd->$ext();
	close OUT;
}

1;
