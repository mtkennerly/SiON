//----------------------------------------------------------------------------------------------------
// MIDI sound module
//  Copyright (c) 2011 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion.midi;

import openfl.utils.ByteArray;
import org.si.sion.SiONData;
import org.si.sion.sequencer.base.MMLEvent;


/** Standard MIDI File converter */
class SiONDataConverterSMF extends SiONData
{
    public var smfData(get, set) : SMFData;
    public var midiModule(get, set) : MIDIModule;

    // variables
    //--------------------------------------------------------------------------------
    /** use MIDI modules effector */
    public var useMIDIModuleEffector : Bool = true;
    
    private var _smfData : SMFData = null;
    private var _module : MIDIModule = null;
    private var _waitEvent : MMLEvent;
    private var _executors : Array<SMFExecutor> = new Array<SMFExecutor>();
    private var _resolutionRatio : Float = 1;
    
    
    
    // properties
    //--------------------------------------------------------------------------------
    /** Standard MIDI file data to play */
    private function get_smfData() : SMFData{return _smfData;
    }
    private function set_smfData(data : SMFData) : SMFData{
        _smfData = data;
        if (_smfData != null) {
            bpm = _smfData.bpm;
            _resolutionRatio = 1920 / _smfData.resolution;
        }
        else {
            bpm = 120;
            _resolutionRatio = 1;
        }
        return data;
    }
    
    
    /** MIDI sound module object to play */
    private function get_midiModule() : MIDIModule{return _module;
    }
    private function set_midiModule(module : MIDIModule) : MIDIModule{_module = module;
        return module;
    }
    
    
    
    
    
    // constructor
    //--------------------------------------------------------------------------------
    /** Pass SMFData and MIDIModule */
    public function new(smfData : SMFData = null, midiModule : MIDIModule = null)
    {
        super();
        _smfData = smfData;
        _module = midiModule;
        
        if (_smfData != null) {
            bpm = _smfData.bpm;
            _resolutionRatio = 1920 / _smfData.resolution;
        }
        else {
            bpm = 120;
            _resolutionRatio = 1;
        }
        
        globalSequence.initialize();
        globalSequence.appendNewCallback(_onMIDIInitialize, 0);
        globalSequence.appendNewEvent(MMLEvent.REPEAT_ALL, 0);
        globalSequence.appendNewCallback(_onMIDIEventCallback, 0);
        _waitEvent = globalSequence.appendNewEvent(MMLEvent.GLOBAL_WAIT, 0, 0);
    }
    
    
    
    
    // operations
    //--------------------------------------------------------------------------------
    private function _onMIDIInitialize(data : Int) : MMLEvent
    {
        var i : Int;
        var imax : Int;
        
        // initialize module
        _module._initialize(useMIDIModuleEffector);
        
        // initialize executors
        _executors.length = imax = _smfData.tracks.length;
        for (imax){
            if (!_executors[i])                 _executors[i] = new SMFExecutor();
            _executors[i]._initialize(_smfData.tracks[i], _module);
        }  // initialize interval  
        
        
        
        _waitEvent.length = 0;
        
        return null;
    }
    
    
    private function _onMIDIEventCallback(data : Int) : MMLEvent
    {
        var i : Int;
        var imax : Int = _executors.length;
        var exec : SMFExecutor;
        var seq : Array<SMFEvent>;
        var ticks : Int;
        var deltaTime : Int;
        var minDeltaTime : Int;
        ticks = _waitEvent.length / _resolutionRatio;
        minDeltaTime = _executors[0]._execute(ticks);
        for (imax){
            deltaTime = _executors[i]._execute(ticks);
            if (minDeltaTime > deltaTime)                 minDeltaTime = deltaTime;
        }
        if (minDeltaTime == 65536)             _module._onFinishSequence();
        _waitEvent.length = minDeltaTime * _resolutionRatio;
        return null;
    }
}



