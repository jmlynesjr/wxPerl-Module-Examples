wxPerl Repository for examples not directly related to the wxBook.
------------------------------------------------------------------

Updated February 14, 2013

These modules replace any similar programs in the wxPerl-wxBook repository.
All of these are implemented as modules/classes and derived classes
using Class::Accessor::Fast. I hope these are of assistance to you.


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

