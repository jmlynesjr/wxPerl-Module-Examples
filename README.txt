wxPerl Repository for examples not directly related to the wxBook or greatly expanded from it.
----------------------------------------------------------------------------------------------

Updated July 2, 2013

These modules replace any similar programs in the wxPerl-wxBook repository.
Many of these are implemented as modules/classes and derived classes
some using Class::Accessor::Fast. I hope these are of assistance to you.


AlarmClock 	LCD Alarm Clock
		AudiableAlarm.pm	- Uses wxMediaControl to play an MP3 file as a wakeup tune
		LCDAlarmClock1.pl	- Uses LCDdisplayClock1.pm(see below) as a basic clock
		LCDAlarmClockDialog.pm	- Custom Dialog with validator
		LCDAlarmClockDialog.pl	- Test driver for the custom dialog

Angular Meter 	Draws a Round Panel Meter
		AngularMeter1.pm	- Creates a round panel meter
		AM1.pl			- Creates and displays multiple round panel meters
					    Animated with simulated(random) data

ClassAccessor	Class::Accessor::Fast Module Example
		CATest.pl		- Shows how to use Class::Accessor::Fast

LCDdisplay	7 Segment LCD Display
		LCDdisplay1.pm		- Draws a 7 Segment LCD Display(0-F and a few special characters)
		LCDdisplayClock1.pm	- Derived Class from LCDdisplay1.pm that implements a clock
		LCDClock1.pl		- Uses above modules to demonstrate an LCD clock

LinearMeter	Draws a Linear Panel Meter
		LinearMeter4.pm		- Creates a linear panel meter
		LM4.pl			- Creates and displays multiple linear panel meters
					    Animated with simulated(random) data

Process Control	Combines Round and Linear meters on a single display
		PC1.pl			- Uses AngularMeter1.pm and LinearMeter4.pm to
					  draw 4 linear and 2 round meters
					  Animated with simulated(random) data

NewWxApp	Basic Structure for a wxPerl Application
		NewWxApp.pl		- Basic wxPerl application using Class::Accessor

TheBridge	Draft Document concerning creating wxPerl applications
		TheBridge		- Collection of documents, emails, and writings on
					  creating a wxPerl application
LED Panel	LED 5x7 Dot Matrix Display Panel
		LedPanelApp.pl		- Draws 7 LED Dot Matrix Displays
		LedPanelDisplay.pm	- Creates displays
		LedPanelMatrix.pm	- Creates matricies
		LedPanelColourTbl.pm	- Defines color pallets
		LedPanelCtbl.pm		- Defines 5x7 format characters

Virtual List	Virtual List Control Subclass Example
		VirtualListCtrl.pl

ListCtrl	List Control Experiment in Formatting the Column Headers - font and color
		ListCtrl3.pl

Grid		Grid Control Expansion of the wxBook Example - fonts, colors, sizes, modes, appends, etc
		Grid.pl

wxGridTable	"Virtual" Grid Control example with customized column and row headers - fonts, colors, text, etc.
		Needs to be expanded with methods to load the grid from an SQL database.
		wxGridTable.pl

ImpedanceGraph2 wxPerl Integration with GD::Graph Example.
		ImpedanceGraph2.pl




