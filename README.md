#SiON
The SiON (pronounced as “scion”) is a software synthesizer library. It was originally written in AS3. This fork is a conversion to Haxe.

SiON provides simple sound synchronization with DisplayObject and an easy dynamic sound generation. You can generate various sounds without any mp3 files or wave data. The musical sequence is represented as Music Macro Language (a simple text data) or standard MIDI Files. It allows your final distribution to be very small.

For examples of what SiON can do, see https://sites.google.com/site/sioncenter/.

Some APIs have changed from the AS3 version. Get the haxe examples from https://github.com/gunnbr/SiON. These examples work on the desktop, on a touchscreen, and with joystick input.

###Current Status
* Playing music works. 
* Setting voices to the internal synthesizer instruments works.
* Synchronizing to display objects works.
* Fade in/out with the low pass filter works
* Android support does *not* work. (Seems better with a change that went into openfl on Jan. 26, 2015.)
* iOS support is untested.
