//----------------------------------------------------------------------------------------------------
// MIDI sound module
//  Copyright (c) 2011 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion.midi;

import org.si.sion.*;

import org.si.sion.effector.*;
import org.si.sion.events.SiONMIDIEvent;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sion.module.SiOPMWaveSamplerTable;
import org.si.sion.module.channels.SiOPMChannelBase;
import org.si.sion.utils.SiONPresetVoice;
import openfl.utils.ByteArray;


/** MIDI sound module */
class MIDIModule
{
    public var polyphony(get, set) : Int;
    public var midiChannelCount(get, set) : Int;
    public var freeOperatorCount(get, never) : Int;
    public var activeOperatorCount(get, never) : Int;
    public var portNumber(get, set) : Int;
    public var systemExclusiveMode(get, set) : String;

    // constant
    //--------------------------------------------------------------------------------
    /** General MIDI mode */
    public static inline var GM_MODE : String = "GMmode";
    /** Roland GS system exclusive mode */
    public static inline var GS_MODE : String = "GSmode";
    /** YAMAHA XG system exclusive mode */
    public static inline var XG_MODE : String = "XGmode";
    
    
    
    // variables
    //--------------------------------------------------------------------------------
    /** voice set for GM 128 voices. */
    public var voiceSet : Array<SiONVoice>;
    /** voice set for drum track. */
    public var drumVoiceSet : Array<SiONVoice>;
    /** MIDI channels */
    public var midiChannels : Array<MIDIModuleChannel>;
    
    /** NRPN callback, should be function(channelNum:int, nrpn:int, dataEntry:int) : void. */
    public var onNRPN : Function = null;
    /** System exclusize callback, should be function(channelNum:int, bytes:ByteArray) : void. */
    public var onSysEx : Function = null;
    /** Finish sequence callback, should be function() : void. */
    public var onFinishSequence : Function = null;
    
    // core --------------------
    private var _sionDriver : SiONDriver = null;
    private var _polyphony : Int;
    // operators --------------------
    private var _freeOperators : MIDIModuleOperator;
    private var _activeOperators : MIDIModuleOperator;
    // drum track related --------------------
    private var _drumExclusiveGroupID : Array<Int>;
    private var _drumExclusiveOperator : Array<MIDIModuleOperator>;
    private var _drumNoteOffAvailable : Array<Int>;
    // effector related --------------------
    private var _effectorSet : Array<Array<Dynamic>>;
    // MIDI event related --------------------
    private var _dataEntry : Int;
    private var _rpnNumber : Int;
    private var _isNRPN : Bool;
    private var _portOffset : Int;
    private var _portNumber : Int;
    private var _systemExclusiveMode : String;
    // others --------------------
    private var _dispatchFlags : Int = 0;
    
    
    // properties
    //--------------------------------------------------------------------------------
    /** polyphony */
    private function get_polyphony() : Int{return _polyphony;
    }
    private function set_polyphony(poly : Int) : Int{
        _polyphony = poly;
        return poly;
    }
    /** MIDI channel count, port number is reset when channel count is changed. */
    private function get_midiChannelCount() : Int{return midiChannels.length;
    }
    private function set_midiChannelCount(count : Int) : Int{
        midiChannels.length = count;
        for (ch in 0...count){
            if (!midiChannels[ch])                 midiChannels[ch] = new MIDIModuleChannel();
            midiChannels[ch].eventTriggerID = ch;
        }
        _portOffset = 0;
        return count;
    }
    /** free operator count */
    private function get_freeOperatorCount() : Int{return _freeOperators.length;
    }
    /** active operator count */
    private function get_activeOperatorCount() : Int{return _activeOperators.length;
    }
    /** port number */
    private function get_portNumber() : Int{return _portNumber;
    }
    private function set_portNumber(portNum : Int) : Int{
        _portNumber = portNum;
        if (midiChannels.length > (portNum << 4) + 15)             _portOffset = portNum << 4
        else _portOffset = (midiChannels.length - 15) >> 4;
        return portNum;
    }
    /** System exclusive mode */
    private function get_systemExclusiveMode() : String{return _systemExclusiveMode;
    }
    private function set_systemExclusiveMode(mode : String) : String{
        _systemExclusiveMode = mode;
        return mode;
    }
    
    
    
    
    
    // constructor
    //--------------------------------------------------------------------------------
    /** MIDI sound module emulator
     *  @param polyphony polyphony
     *  @param midiChannelCount MIDI channel count
     */
    public function new(polyphony : Int = 32, midiChannelCount : Int = 16, systemExclusiveMode : String = "")
    {
        var slot : Int;
        var i : Int;
        
        // allocation
        _systemExclusiveMode = systemExclusiveMode;
        _polyphony = polyphony;
        _freeOperators = new MIDIModuleOperator(null);
        _activeOperators = new MIDIModuleOperator(null);
        midiChannels = new Array<MIDIModuleChannel>();
        
        voiceSet = new Array<SiONVoice>();
        drumVoiceSet = new Array<SiONVoice>();
        _drumExclusiveGroupID = new Array<Int>();
        _drumExclusiveOperator = new Array<MIDIModuleOperator>();
        _drumNoteOffAvailable = new Array<Int>();
        _effectorSet = new Array<Array<Dynamic>>();
        for (8){_effectorSet[slot] = null;
        }
        
        // initialize
        _effectorSet[1] = [new SiEffectStereoReverb(0.7, 0.4, 0.8, 1)];
        _effectorSet[2] = [new SiEffectStereoChorus(20, 0.1, 4, 20, 1)];
        _effectorSet[3] = [new SiEffectStereoDelay(250, 0.25, false, 1)];
        setDrumExclusiveGroup(1, [42, 44, 46]);  // hi-hat group  
        setDrumExclusiveGroup(2, [80, 81]);  // triangle group  
        enableDrumNoteOff([71, 72]);  // samba whistle  
        
        // alloc channels
        this.midiChannelCount = midiChannelCount;
        
        // load preset voices
        var preset : SiONPresetVoice = SiONPresetVoice.mutex;
        if (preset == null || !Reflect.field(preset, "svmidi") || !Reflect.field(preset, "svmidi.drum")) {
            preset = new SiONPresetVoice(SiONPresetVoice.INCLUDE_WAVETABLE | SiONPresetVoice.INCLUDE_SINGLE_DRUM);
        }
        for (128){
            voiceSet[i] = Reflect.field(preset, "svmidi")[i];
        }
        for (60){
            drumVoiceSet[i + 24] = Reflect.field(preset, "svmidi.drum")[i];
        }
    }
    
    
    
    
    // operations
    //--------------------------------------------------------------------------------
    /** @private this function is called first of all sequences */
    @:allow(org.si.sion.midi)
    private function _initialize(useMIDIModuleEffector : Bool) : Bool
    {
        var i : Int;
        var ope : MIDIModuleOperator;
        _sionDriver = SiONDriver.mutex;
        if (_sionDriver == null)             return false;
        
        resetAllChannels();
        _freeOperators.clear();
        _activeOperators.clear();
        for (_polyphony){
            _freeOperators.push(new MIDIModuleOperator(_sionDriver.newUserControlableTrack(i)));
        }
        for (16){
            _drumExclusiveOperator[i] = null;
        }
        
        _dataEntry = 0;
        _rpnNumber = 0;
        _isNRPN = false;
        _portOffset = 0;
        
        if (useMIDIModuleEffector) {
            for (8){
                if (_effectorSet[i])                     _sionDriver.effector.setEffectorList(i, _effectorSet[i]);
            }
        }
        
        _dispatchFlags = _sionDriver_checkMIDIEventListeners();
        
        return true;
    }
    
    
    /** Set drum voice by sampler table 
     *  @param table sampler table class, ussualy get from SiONSoundFont
     *  @see SiONSoundFont
     */
    public function setDrumSamplerTable(table : SiOPMWaveSamplerTable) : Void
    {
        var voice : SiONVoice = new SiONVoice();
        var i : Int;
        voice.setSamplerTable(table);
        for (128){drumVoiceSet[i] = voice;
        }
    }
    
    
    /** set exclusive drum voice. Voice that has same groupID stops each other when it sounds.
     *  @param groupID 0 means no group. 1-15 are available.
     *  @param voiceNumbers list of voice number that have same groupID
     */
    public function setDrumExclusiveGroup(groupID : Int, voiceNumbers : Array<Dynamic>) : Void
    {
        for (i in 0...voiceNumbers.length){_drumExclusiveGroupID[voiceNumbers[i]] = groupID;
        }
    }
    
    
    /** set default effector set.
     *  @param slot slot to set
     *  @param effectorList Array of inherit class of SiEffectBase
     */
    public function setDefaultEffector(slot : Int, effectorList : Array<Dynamic>) : Void
    {
        _effectorSet[slot] = effectorList;
    }
    
    
    /** enable drum note off. default value is false
     *  @param voiceNumbers list of voice number that enables note off
     */
    public function enableDrumNoteOff(voiceNumbers : Array<Dynamic>, enable : Bool = true) : Void
    {
        for (i in 0...voiceNumbers.length){_drumNoteOffAvailable[voiceNumbers[i]] = ((enable)) ? 1 : 0;
        }
    }
    
    
    /** reset all channels */
    public function resetAllChannels() : Void
    {
        for (ch in 0...midiChannels.length){
            midiChannels[ch].reset();
            if ((ch & 15) == 9)                 midiChannels[ch].drumMode = 1;
        }
    }
    
    
    /** note on */
    public function noteOn(channelNum : Int, note : Int, velocity : Int = 64) : Void
    {
        channelNum += _portOffset;
        var midiChannel : MIDIModuleChannel = midiChannels[channelNum];
        var voice : SiONVoice;
        var ope : MIDIModuleOperator;
        var track : SiMMLTrack;
        var channel : SiOPMChannelBase;
        var drumExcID : Int = 0;
        var sionTrackNote : Int = note;
        
        if (!midiChannel.mute) {
            
            // get operator
            if (midiChannel.activeOperatorCount >= midiChannel.maxOperatorCount) {
                ope = _activeOperators.next;
                while (ope != _activeOperators){
                    if (ope.channel == channelNum) {
                        _activeOperators.remove(ope);
                        break;
                    }
                    ope = ope.next;
                }
            }
            else {
                ope = _freeOperators.shift() || _activeOperators.shift();
            }
            
            if (ope.isNoteOn) {
                ope.sionTrack.dispatchEventTrigger(false);
                midiChannels[ope.channel].activeOperatorCount--;
            }  // voice setting  
            
            
            
            if (midiChannel.drumMode == 0) {
                if (ope.programNumber != midiChannel.programNumber) {
                    ope.programNumber = midiChannel.programNumber;
                    voice = voiceSet[ope.programNumber];
                    if (voice != null) {
                        ope.sionTrack.quantRatio = 1;
                        voice.updateTrackVoice(ope.sionTrack);
                    }
                    else {
                        _freeOperators.push(ope);
                        return;
                    }
                }
            }
            else {
                ope.programNumber = -1;
                voice = drumVoiceSet[note];
                if (voice != null) {
                    drumExcID = _drumExclusiveGroupID[note];
                    sionTrackNote = ((voice.preferableNote == -1)) ? 60 : voice.preferableNote;
                    if (drumExcID > 0) {
                        var excOpe : MIDIModuleOperator = _drumExclusiveOperator[drumExcID];
                        if (excOpe != null && excOpe.drumExcID == drumExcID) {
                            if (excOpe.isNoteOn)                                 _noteOffOperator(excOpe);
                            excOpe.sionTrack.keyOff(0, true);
                        }
                        _drumExclusiveOperator[drumExcID] = ope;
                    }
                    ope.sionTrack.quantRatio = 1;
                    voice.updateTrackVoice(ope.sionTrack);
                }
                else {
                    _freeOperators.push(ope);
                    return;
                }
            }  // operator settings  
            
            
            
            track = ope.sionTrack;
            channel = track.channel;
            
            track.noteShift = midiChannel.masterCoarseTune;
            track.pitchShift = midiChannel.masterFineTune;
            track.pitchBend = (midiChannel.pitchBend * midiChannel.pitchBendSensitivity) >> 7;  //(*64/8192)  
            track.setPortament(midiChannel.portamentoTime);
            track.setEventTrigger(midiChannel.eventTriggerID, midiChannel.eventTriggerTypeOn, midiChannel.eventTriggerTypeOff);
            track.velocity = (velocity * 1.5) + 64;
            channel.setAllStreamSendLevels(midiChannel._sionVolumes);
            channel.pan = midiChannel.pan;
            channel.setLFOCycleTime(midiChannel.modulationCycleTime);
            channel.setPitchModulation(midiChannel.modulation >> 2);  // width = 32  
            channel.setAmplitudeModulation(midiChannel.channelAfterTouch >> 2);  // width = 32  
            track.keyOn(sionTrackNote);
            
            ope.isNoteOn = true;
            ope.note = note;
            ope.channel = channelNum;
            ope.drumExcID = drumExcID;
            _activeOperators.push(ope);
            midiChannel.activeOperatorCount++;
        }  // if (!midiChannel.mute)  
        
        if (_dispatchFlags & midiChannel.sionMIDIEventType & SiONMIDIEventFlag.NOTE_ON != 0) {
            _sionDriver_dispatchMIDIEvent(SiONMIDIEvent.NOTE_ON, track, channelNum, note, velocity);
        }
    }
    
    
    /** note off */
    public function noteOff(channelNum : Int, note : Int, velocity : Int = 0) : Void
    {
        channelNum += _portOffset;
        
        var ope : MIDIModuleOperator;
        var i : Int = 0;
        ope = _activeOperators.next;
        while (ope != _activeOperators){
            if (ope.note == note && ope.channel == channelNum && ope.isNoteOn) {
                _noteOffOperator(ope);
                return;
            }
            ope = ope.next;
        }
    }
    
    
    private function _noteOffOperator(ope : MIDIModuleOperator) : Void
    {
        var channelNum : Int = ope.channel;
        var note : Int = ope.note;
        var midiChannel : MIDIModuleChannel = midiChannels[channelNum];
        if (!midiChannel.mute) {
            if (midiChannel.sustainPedal)                 ope.sionTrack.dispatchEventTrigger(false)
            else if (midiChannel.drumMode == 0 || _drumNoteOffAvailable[note])                 ope.sionTrack.keyOff();
            ope.isNoteOn = false;
            ope.note = -1;
            ope.channel = -1;
            midiChannel.activeOperatorCount--;
            _activeOperators.remove(ope);
            _freeOperators.push(ope);
        }
        
        if (_dispatchFlags & midiChannel.sionMIDIEventType & SiONMIDIEventFlag.NOTE_OFF != 0) {
            _sionDriver_dispatchMIDIEvent(SiONMIDIEvent.NOTE_OFF, ope.sionTrack, channelNum, note, 0);
        }
    }
    
    
    /** program change */
    public function programChange(channelNum : Int, programNumber : Int) : Void
    {
        channelNum += _portOffset;
        var midiChannel : MIDIModuleChannel = midiChannels[channelNum];
        midiChannel.programNumber = programNumber;
        
        if (_dispatchFlags & midiChannel.sionMIDIEventType & SiONMIDIEventFlag.PROGRAM_CHANGE != 0) {
            _sionDriver_dispatchMIDIEvent(SiONMIDIEvent.PROGRAM_CHANGE, null, channelNum, 0, programNumber);
        }
    }
    
    
    /** channel after touch */
    public function channelAfterTouch(channelNum : Int, value : Int) : Void
    {
        channelNum += _portOffset;
        var midiChannel : MIDIModuleChannel = midiChannels[channelNum];
        midiChannel.channelAfterTouch = value;
        
        var ope : MIDIModuleOperator = _activeOperators.next;
        while (ope != _activeOperators){
            if (ope.channel == channelNum) {
                ope.sionTrack.channel.setAmplitudeModulation(midiChannel.channelAfterTouch >> 2);
            }
            ope = ope.next;
        }
    }
    
    
    /** pitch bned */
    public function pitchBend(channelNum : Int, bend : Int) : Void
    {
        channelNum += _portOffset;
        var midiChannel : MIDIModuleChannel = midiChannels[channelNum];
        midiChannel.pitchBend = bend;
        
        var ope : MIDIModuleOperator = _activeOperators.next;
        while (ope != _activeOperators){
            if (ope.channel == channelNum) {
                ope.sionTrack.pitchBend = (midiChannel.pitchBend * midiChannel.pitchBendSensitivity) >> 7;
            }
            ope = ope.next;
        }
        if (_dispatchFlags & midiChannel.sionMIDIEventType & SiONMIDIEventFlag.PITCH_BEND != 0) {
            _sionDriver_dispatchMIDIEvent(SiONMIDIEvent.PITCH_BEND, null, channelNum, 0, bend);
        }
    }
    
    
    /** control change */
    public function controlChange(channelNum : Int, controlerNumber : Int, data : Int) : Void
    {
        channelNum += _portOffset;
        var midiChannel : MIDIModuleChannel = midiChannels[channelNum];
        
        switch (controlerNumber)
        {
            case SMFEvent.CC_BANK_SELECT_MSB:
                midiChannel.bankNumber = (data & 0x7f) << 7;
                // XG USE_FOR_RYTHM_PART support
                if (_systemExclusiveMode == XG_MODE) {
                    if ((data & 0x7f) == 127)                         midiChannel.drumMode = 1
                    else if (channelNum != 9)                         midiChannel.drumMode = 0;
                }
            case SMFEvent.CC_BANK_SELECT_LSB:
                midiChannel.bankNumber |= data & 0x7f;
            
            case SMFEvent.CC_MODULATION:
                midiChannel.modulation = data;
                $(function(ope : MIDIModuleOperator) : Void{ope.sionTrack.channel.setPitchModulation(midiChannel.modulation >> 2);
                        });
            case SMFEvent.CC_PORTAMENTO_TIME:
                midiChannel.portamentoTime = data;
                $(function(ope : MIDIModuleOperator) : Void{ope.sionTrack.setPortament(midiChannel.portamentoTime);
                        });
            
            case SMFEvent.CC_VOLUME:
                midiChannel.masterVolume = data;
                $(function(ope : MIDIModuleOperator) : Void{ope.sionTrack.channel.setAllStreamSendLevels(midiChannel._sionVolumes);
                        });
            //case SMFEvent.CC_BALANCE:
            case SMFEvent.CC_PANPOD:
                midiChannel.pan = data - 64;
                $(function(ope : MIDIModuleOperator) : Void{ope.sionTrack.channel.pan = midiChannel.pan;
                        });
            case SMFEvent.CC_EXPRESSION:
                midiChannel.expression = data;
                $(function(ope : MIDIModuleOperator) : Void{ope.sionTrack.channel.setAllStreamSendLevels(midiChannel._sionVolumes);
                        });
            
            case SMFEvent.CC_SUSTAIN_PEDAL:
                midiChannel.sustainPedal = (data > 64);
            case SMFEvent.CC_PORTAMENTO:
                midiChannel.portamento = (data > 64);
            //case SMFEvent.CC_SOSTENUTO_PEDAL:
            //case SMFEvent.CC_SOFT_PEDAL:
            //case SMFEvent.CC_RESONANCE:
            //case SMFEvent.CC_RELEASE_TIME:
            //case SMFEvent.CC_ATTACK_TIME:
            //case SMFEvent.CC_CUTOFF_FREQ:
            //case SMFEvent.CC_DECAY_TIME:
            //case SMFEvent.CC_PROTAMENTO_CONTROL:
            case SMFEvent.CC_REVERB_SEND:
                midiChannel.setEffectSendLevel(1, data);
                $(function(ope : MIDIModuleOperator) : Void{ope.sionTrack.channel.setAllStreamSendLevels(midiChannel._sionVolumes);
                        });
            case SMFEvent.CC_CHORUS_SEND:
                midiChannel.setEffectSendLevel(2, data);
                $(function(ope : MIDIModuleOperator) : Void{ope.sionTrack.channel.setAllStreamSendLevels(midiChannel._sionVolumes);
                        });
            case SMFEvent.CC_DELAY_SEND:
                midiChannel.setEffectSendLevel(3, data);
                $(function(ope : MIDIModuleOperator) : Void{ope.sionTrack.channel.setAllStreamSendLevels(midiChannel._sionVolumes);
                        });
            
            case SMFEvent.CC_NRPN_MSB:_rpnNumber = (data & 0x7f) << 7;
            case SMFEvent.CC_NRPN_LSB:_rpnNumber |= (data & 0x7f);_isNRPN = true;
            case SMFEvent.CC_RPN_MSB:_rpnNumber = (data & 0x7f) << 7;
            case SMFEvent.CC_RPN_LSB:_rpnNumber |= (data & 0x7f);_isNRPN = false;
            case SMFEvent.CC_DATA_ENTRY_MSB:
                _dataEntry = (data & 0x7f) << 7;
                if (!_isNRPN)                     _onRPN(midiChannel)
                else if (onNRPN != null)                     onNRPN(channelNum, _rpnNumber, _dataEntry);
            case SMFEvent.CC_DATA_ENTRY_LSB:
                _dataEntry |= (data & 0x7f);
                if (!_isNRPN)                     _onRPN(midiChannel)
                else if (onNRPN != null)                     onNRPN(channelNum, _rpnNumber, _dataEntry);
        }
        
        if (_dispatchFlags & midiChannel.sionMIDIEventType & SiONMIDIEventFlag.CONTROL_CHANGE != 0) {
            _sionDriver_dispatchMIDIEvent(SiONMIDIEvent.CONTROL_CHANGE, null, channelNum, controlerNumber, data);
        }
        
        function $(func : Function) : Void{
            var ope : MIDIModuleOperator = _activeOperators.next;
            while (ope != _activeOperators){
                if (ope.channel == channelNum)                     func(ope);
                ope = ope.next;
            }
        };
    }
    
    
    /** system exclusive */
    public function systemExclusive(channelNum : Int, bytes : ByteArray) : Void
    {
        if (checkByteArray(bytes, _GM_RESET, 0)) {_systemExclusiveMode = GM_MODE;resetAllChannels();
        }
        else if (checkByteArray(bytes, _GS_RESET, 0)) {_systemExclusiveMode = GS_MODE;resetAllChannels();
        }
        else if (checkByteArray(bytes, _XG_RESET, 0)) {_systemExclusiveMode = XG_MODE;resetAllChannels();
        }
        else if (checkByteArray(bytes, _GS_EXIT, 0)) {_systemExclusiveMode = "";
        }
        // GS USE_FOR_RYTHM_PART support
        else if (_systemExclusiveMode == GS_MODE) {
            if (checkByteArray(bytes, _GS_UFRP_CMD, 0)) {
                var trackNum : Int = bytes.readUnsignedByte();
                var c0x15 : Int = bytes.readUnsignedByte();
                var mapNum : Int = bytes.readUnsignedByte();
                if ((trackNum & 0xf0) != 0x10 || c0x15 != 0x15 || mapNum > 2)                     return;
                trackNum = (trackNum & 15) + _portOffset;
                if (trackNum < midiChannels.length)                     midiChannels[trackNum].drumMode = mapNum;
            }
        }
        if (onSysEx != null)             onSysEx(channelNum, bytes);
    }
    private static var _GM_RESET : Array<Dynamic> = [0xf0, 0x7e, 0x7f, 0x09, 0x01, 0xf7];
    private static var _GS_RESET : Array<Dynamic> = [0xf0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7f, 0x00, 0x41, 0xf7];
    private static var _GS_EXIT : Array<Dynamic> = [0xf0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7f, 0x7f, 0x41, 0xf7];
    private static var _XG_RESET : Array<Dynamic> = [0xf0, 0x43, 0x10, 0x4c, 0x00, 0x00, 0x7e, 0x00, 0xf7];
    private static var _GS_UFRP_CMD : Array<Dynamic> = [0xf0, 0x41, 0x10, 0x42, 0x12, 0x40];
    
    
    /** check ByteArray pattern by usigned byte */
    public static function checkByteArray(bytes : ByteArray, checkPattern : Array<Dynamic>, position : Int = -1) : Bool
    {
        if (position != -1)             bytes.position = position;
        var i : Int;
        var imax : Int = checkPattern.length;
        for (imax){
            var ch : Int = bytes.readUnsignedByte();
            if (checkPattern[i] != ch)                 return false;
        }
        return true;
    }
    
    
    /** @private */
    @:allow(org.si.sion.midi)
    private function _onFinishSequence() : Void
    {
        if (onFinishSequence != null)             onFinishSequence();
    }
    
    
    
    private function _onRPN(midiChannel : MIDIModuleChannel) : Void
    {
        switch (_rpnNumber)
        {
            case SMFEvent.RPN_PITCHBEND_SENCE:
                midiChannel.pitchBendSensitivity = _dataEntry >> 7;
            case SMFEvent.RPN_FINE_TUNE:
                midiChannel.masterFineTune = (_dataEntry >> 7) - 64;
            case SMFEvent.RPN_COARSE_TUNE:
                midiChannel.masterCoarseTune = (_dataEntry >> 7) - 64;
        }
    }
}


