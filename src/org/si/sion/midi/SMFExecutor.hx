//----------------------------------------------------------------------------------------------------
// Standard MIDI File player class
//  Copyright (c) 2011 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion.midi;

import org.si.sion.midi.SMFTrack;

import openfl.utils.ByteArray;
import org.si.sion.SiONDriver;


/** Standard MIDI File executor */
class SMFExecutor
{
    // variables
    //--------------------------------------------------------------------------------
    private var _pointer : Int = 0;
    private var _residueTicks : Int = 0;
    private var _track : SMFTrack = null;
    private var _module : MIDIModule = null;
    
    
    
    
    // properties
    //--------------------------------------------------------------------------------
    
    
    
    
    // constructor
    //--------------------------------------------------------------------------------
    public function new()
    {
        
    }
    
    
    
    
    // operations
    //--------------------------------------------------------------------------------
    /** @private */
    @:allow(org.si.sion.midi)
    private function _initialize(track : SMFTrack, module : MIDIModule) : Void
    {
        _track = track;
        _module = module;
        _pointer = 0;
        _residueTicks = ((_track.sequence.length > 0)) ? _track.sequence[0].deltaTime : -1;
    }
    
    
    /** @private */
    @:allow(org.si.sion.midi)
    private function _execute(ticks : Int) : Int
    {
        if (_residueTicks == -1)             return 65536;
        
        var event : SMFEvent = _track.sequence[_pointer];
        var channel : Int;
        var v : Int;
        
        while (ticks >= _residueTicks){
            ticks -= _residueTicks;
            channel = event.type & 15;
            
            if (event.type & 0xff00) {
                // META event
                var _sw2_ = (event.type);                

                switch (_sw2_)
                {
                    case SMFEvent.META_TEMPO:
                        SiONDriver.mutex.bpm = event.value;
                    case SMFEvent.META_PORT:
                        _module.portNumber = event.value;
                    case SMFEvent.META_TRACK_END:
                        _residueTicks = -1;
                        return 65536;
                }
            }
            else {
                // MIDI event
                var _sw3_ = (event.type & 0xf0);                

                switch (_sw3_)
                {
                    case SMFEvent.PROGRAM_CHANGE:
                        _module.programChange(channel, event.value);
                    case SMFEvent.CHANNEL_PRESSURE:
                        _module.channelAfterTouch(channel, event.value);
                    case SMFEvent.NOTE_OFF:
                        _module.noteOff(channel, event.note, event.velocity);
                    case SMFEvent.NOTE_ON:
                        v = event.velocity;
                        if (v > 0)                             _module.noteOn(channel, event.note, v)
                        else _module.noteOff(channel, event.note, v);
                    //case SMFEvent.KEY_PRESSURE:
                    case SMFEvent.CONTROL_CHANGE:
                        _module.controlChange(channel, event.value >> 16, event.value & 0x7f);
                    case SMFEvent.PITCH_BEND:
                        _module.pitchBend(channel, event.value);
                    case SMFEvent.SYSTEM_EXCLUSIVE:
                        _module.systemExclusive(channel, event.byteArray);
                }
            }  // increment pointer  
            
            
            
            if (++_pointer == _track.sequence.length) {
                _residueTicks = -1;
                return 65536;
            }
            event = _track.sequence[_pointer];
            _residueTicks = event.deltaTime;
        }
        
        _residueTicks -= ticks;
        return _residueTicks;
    }
}



