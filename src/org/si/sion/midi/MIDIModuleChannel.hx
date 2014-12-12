//----------------------------------------------------------------------------------------------------
// MIDI sound module operator
//  Copyright (c) 2011 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion.midi;


/** MIDI sound module channel */
class MIDIModuleChannel
{
    public var masterVolume(get, set) : Int;
    public var expression(get, set) : Int;

    // variables
    //--------------------------------------------------------------------------------
    /** active operator count of this channel */
    public var activeOperatorCount : Int;
    /** maximum operator limit of this channel */
    public var maxOperatorCount : Int;
    
    /** Drum mode. 0=normal part, 1~=drum part */
    public var drumMode : Int;
    /** Mute */
    public var mute : Bool;
    /** Program number (0-127) */
    public var programNumber : Int;
    /** Pannig (-64~63) */
    public var pan : Int;
    /** Modulation (0-127) */
    public var modulation : Int;
    /** Pitch bend value (-8192~8191) */
    public var pitchBend : Int;
    /** channel after touch (0-127) */
    public var channelAfterTouch : Int;
    /** Sustain pedal */
    public var sustainPedal : Bool;
    /** Portamento */
    public var portamento : Bool;
    /** Portamento time */
    public var portamentoTime : Int;
    /** Master fine tune (-64~63) */
    public var masterFineTune : Int;
    /** Master coarse tune (-64~63) */
    public var masterCoarseTune : Int;
    /** Pitch bend sensitivity */
    public var pitchBendSensitivity : Int;
    /** Modulation cycle time */
    public var modulationCycleTime : Int;
    
    /** event trigger ID */
    public var eventTriggerID : Int;
    /** dispatching event trigger type of NOTE_ON */
    public var eventTriggerTypeOn : Int;
    /** dispatching event trigger type of NOTE_OFF */
    public var eventTriggerTypeOff : Int;
    /** dispatching event flag of SiONMIDIEvent, conbination of SiONMIDIEventFlag */
    public var sionMIDIEventType : Int;
    
    /** bank number */
    public var bankNumber : Int;
    
    
    /** @private */
    @:allow(org.si.sion.midi)
    private var _sionVolumes : Array<Int> = new Array<Int>();
    /** @private */
    @:allow(org.si.sion.midi)
    private var _effectSendLevels : Array<Int> = new Array<Int>();
    
    private var _expression : Int;
    private var _masterVolume : Int;
    
    
    
    
    // properties
    //--------------------------------------------------------------------------------
    /** master volume (0-127) */
    private function get_masterVolume() : Int{return _masterVolume;
    }
    private function set_masterVolume(v : Int) : Int{_masterVolume = v;_updateVolumes();
        return v;
    }
    
    
    /** expression (0-127) */
    private function get_expression() : Int{return _expression;
    }
    private function set_expression(e : Int) : Int{_expression = e;_updateVolumes();
        return e;
    }
    
    
    // update all volumes of SiON tracks
    private function _updateVolumes() : Void{
        var v : Int = (_masterVolume * _expression + 64) >> 7;
        _sionVolumes[0] = _effectSendLevels[0] = v;
        for (i in 1...8){
            _sionVolumes[i] = (v * _effectSendLevels[i] + 64) >> 7;
        }
    }
    
    
    
    // constructor
    //--------------------------------------------------------------------------------
    /** @private */
    public function new()
    {
        mute = false;
        eventTriggerID = 0;
        eventTriggerTypeOn = 0;
        eventTriggerTypeOff = 0;
        sionMIDIEventType = SiONMIDIEventFlag.ALL;
        reset();
    }
    
    
    
    
    // operations
    //--------------------------------------------------------------------------------
    /** reset this channel */
    public function reset() : Void
    {
        activeOperatorCount = 0;
        maxOperatorCount = 1024;
        
        //mute = false;
        drumMode = 0;
        programNumber = 0;
        _expression = 127;
        _masterVolume = 64;
        pan = 0;
        modulation = 0;
        pitchBend = 0;
        channelAfterTouch = 0;
        sustainPedal = false;
        portamento = false;
        portamentoTime = 0;
        masterFineTune = 0;
        masterCoarseTune = 0;
        pitchBendSensitivity = 2;
        modulationCycleTime = 180;
        
        bankNumber = 0;
        
        _sionVolumes[0] = _masterVolume;
        _effectSendLevels[0] = _masterVolume;
        for (i in 1...8){
            _sionVolumes[i] = 0;
            _effectSendLevels[i] = 0;
        }
    }
    
    
    /** get effect send level 
     *  @param slotNumber effect slot number (1-8)
     *  @return effect send level
     */
    public function getEffectSendLevel(slotNumber : Int) : Int
    {
        return _effectSendLevels[slotNumber];
    }
    
    
    /** set effect send level 
     *  @param slotNumber effect slot number (1-8)
     *  @param level effect send level (0-127)
     */
    public function setEffectSendLevel(slotNumber : Int, level : Int) : Void
    {
        _effectSendLevels[slotNumber] = level;
        _sionVolumes[slotNumber] = (_effectSendLevels[0] * _effectSendLevels[slotNumber] + 64) >> 7;
    }
    
    
    /** set event trigger of this channel
     *  @param id Event trigger ID of this track. This value can be refered from SiONTrackEvent.eventTriggerID.
     *  @param noteOnType Dispatching event type at note on. 0=no events, 1=NOTE_ON_FRAME, 2=NOTE_ON_STREAM, 3=both.
     *  @param noteOffType Dispatching event type at note off. 0=no events, 1=NOTE_OFF_FRAME, 2=NOTE_OFF_STREAM, 3=both.
     *  @see org.si.sion.events.SiONTrackEvent
     */
    public function setEventTrigger(id : Int, noteOnType : Int = 1, noteOffType : Int = 0) : Void
    {
        eventTriggerID = id;
        eventTriggerTypeOn = noteOnType;
        eventTriggerTypeOff = noteOffType;
    }
}


