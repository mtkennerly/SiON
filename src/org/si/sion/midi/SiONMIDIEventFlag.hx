//----------------------------------------------------------------------------------------------------
// SiON MIDI internal namespace
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.midi;


class SiONMIDIEventFlag
{
    /** dispatch flag for SiONMIDIEvent.NOTE_ON */
    public static inline var NOTE_ON : Int = 1;
    /** dispatch flag for SiONMIDIEvent.NOTE_OFF */
    public static inline var NOTE_OFF : Int = 2;
    /** dispatch flag for SiONMIDIEvent.CONTROL_CHANGE*/
    public static inline var CONTROL_CHANGE : Int = 4;
    /** dispatch flag for SiONMIDIEvent.PROGRAM_CHANGE */
    public static inline var PROGRAM_CHANGE : Int = 8;
    /** dispatch flag for SiONMIDIEvent.PITCH_BEND */
    public static inline var PITCH_BEND : Int = 16;
    /** Flag for all */
    public static inline var ALL : Int = 31;

    public function new()
    {
    }
}



