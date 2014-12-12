//----------------------------------------------------------------------------------------------------
// Class for play drum tracks
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound;

import openfl.errors.Error;
import org.si.sound.DrumMachinePresetPattern;
import org.si.sound.DrumMachinePresetVoice;
import org.si.sound.MultiTrackSoundObject;

import org.si.sion.SiONData;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sound.namespaces.SoundObjectInternal;
import org.si.sound.synthesizers.DrumMachinePresetVoice;
import org.si.sound.patterns.DrumMachinePresetPattern;
import org.si.sound.patterns.Sequencer;
import org.si.sound.patterns.Note;
import org.si.sound.events.SoundObjectEvent;

/** @eventType org.si.sound.events.SoundObjectEvent.ENTER_FRAME */
@:meta(Event(name="enterFrame",type="org.si.sound.events.SoundObjectEvent"))

/** @eventType org.si.sound.events.SoundObjectEvent.ENTER_SEGMENT */
@:meta(Event(name="enterSegment",type="org.si.sound.events.SoundObjectEvent"))


/** Drum machinie provides independent bass drum, snare drum and hihat symbals tracks. */
class DrumMachine extends MultiTrackSoundObject
{
    public var presetVoice(get, never) : DrumMachinePresetVoice;
    public var presetPattern(get, never) : DrumMachinePresetPattern;
    public var bassPatternNumberMax(get, never) : Int;
    public var snarePatternNumberMax(get, never) : Int;
    public var hihatPatternNumberMax(get, never) : Int;
    public var bassVoiceNumberMax(get, never) : Int;
    public var snareVoiceNumberMax(get, never) : Int;
    public var hihatVoiceNumberMax(get, never) : Int;
    public var bass(get, never) : Sequencer;
    public var snare(get, never) : Sequencer;
    public var hihat(get, never) : Sequencer;
    public var bassPattern(get, set) : Array<Note>;
    public var snarePattern(get, set) : Array<Note>;
    public var hihatPattern(get, set) : Array<Note>;
    public var bassPatternNumber(get, set) : Int;
    public var snarePatternNumber(get, set) : Int;
    public var hihatPatternNumber(get, set) : Int;
    public var bassVoiceNumber(get, set) : Int;
    public var snareVoiceNumber(get, set) : Int;
    public var hihatVoiceNumber(get, set) : Int;
    public var bassVolume(get, set) : Float;
    public var snareVolume(get, set) : Float;
    public var hihatVolume(get, set) : Float;
    public var changePatternOnNextSegment(get, set) : Bool;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // static variables
    //----------------------------------------
    private static var _presetVoice : DrumMachinePresetVoice = null;
    private static var _presetPattern : DrumMachinePresetPattern = null;
    
    
    
    
    // variables
    //----------------------------------------
    /** @private [protected] bass drum pattern sequencer */
    private var _bass : Sequencer;
    /** @private [protected] snare drum pattern sequencer */
    private var _snare : Sequencer;
    /** @private [protected] hi-hat cymbal pattern sequencer */
    private var _hihat : Sequencer;
    
    /** @private [protected] Sequence data */
    private var _data : SiONData;
    
    /** @private [protected] bass drum pattern number */
    private var _bassPatternNumber : Int;
    /** @private [protected] snare drum pattern number */
    private var _snarePatternNumber : Int;
    /** @private [protected] hi-hat cymbal pattern number */
    private var _hihatPatternNumber : Int;
    /** @private [protected] bass drum voice number */
    private var _bassVoiceNumber : Int;
    /** @private [protected] snare drum voice number */
    private var _snareVoiceNumber : Int;
    /** @private [protected] hi-hat cymbal voice number */
    private var _hihatVoiceNumber : Int;
    /** @private [protected] Change bass line pattern at the head of segment. */
    private var _changePatternOnSegment : Bool;
    
    // preset pattern list
    private static var bassPatternList : Array<Dynamic>;
    private static var snarePatternList : Array<Dynamic>;
    private static var hihatPatternList : Array<Dynamic>;
    private static var percusPatternList : Array<Dynamic>;
    private static var bassVoiceList : Array<Dynamic>;
    private static var snareVoiceList : Array<Dynamic>;
    private static var hihatVoiceList : Array<Dynamic>;
    private static var percusVoiceList : Array<Dynamic>;
    
    
    
    // properties
    //----------------------------------------
    /** Preset voices */
    private function get_presetVoice() : DrumMachinePresetVoice{return _presetVoice;
    }
    
    /** Preset patterns */
    private function get_presetPattern() : DrumMachinePresetPattern{return _presetPattern;
    }
    
    /** maximum value of basePatternNumber */private function get_bassPatternNumberMax() : Int{return bassPatternList.length;
    }
    /** maximum value of snarePatternNumber */private function get_snarePatternNumberMax() : Int{return snarePatternList.length;
    }
    /** maximum value of hihatPatternNumber */private function get_hihatPatternNumberMax() : Int{return hihatPatternList.length;
    }
    /** maximum value of baseVoiceNumber */private function get_bassVoiceNumberMax() : Int{return bassVoiceList.length >> 1;
    }
    /** maximum value of snareVoiceNumber */private function get_snareVoiceNumberMax() : Int{return snareVoiceList.length >> 1;
    }
    /** maximum value of hihatVoiceNumber */private function get_hihatVoiceNumberMax() : Int{return hihatVoiceList.length >> 1;
    }
    
    
    /** Sequencer object of bass drum */
    private function get_bass() : Sequencer{return _bass;
    }
    /** Sequencer object of snare drum */
    private function get_snare() : Sequencer{return _snare;
    }
    /** Sequencer object of hihat symbal */
    private function get_hihat() : Sequencer{return _hihat;
    }
    
    /** Sequence pattern of bass drum */
    private function get_bassPattern() : Array<Note>{return _bass.pattern || _bass.nextPattern;
    }
    private function set_bassPattern(pat : Array<Note>) : Array<Note>{
        if (isPlaying && _changePatternOnSegment)             _bass.nextPattern = pat
        else _bass.pattern = pat;
        return pat;
    }
    /** Sequence pattern of snare drum */
    private function get_snarePattern() : Array<Note>{return _snare.pattern || _snare.nextPattern;
    }
    private function set_snarePattern(pat : Array<Note>) : Array<Note>{
        if (isPlaying && _changePatternOnSegment)             _snare.nextPattern = pat
        else _snare.pattern = pat;
        return pat;
    }
    /** Sequence pattern of hihat symbal */
    private function get_hihatPattern() : Array<Note>{return _hihat.pattern || _hihat.nextPattern;
    }
    private function set_hihatPattern(pat : Array<Note>) : Array<Note>{
        if (isPlaying && _changePatternOnSegment)             _hihat.nextPattern = pat
        else _hihat.pattern = pat;
        return pat;
    }
    
    /** bass drum pattern number. */
    private function get_bassPatternNumber() : Int{return _bassPatternNumber;
    }
    private function set_bassPatternNumber(index : Int) : Int{
        if (index < 0 || index >= bassPatternList.length)             return;
        _bassPatternNumber = index;
        bassPattern = bassPatternList[index];
        return index;
    }
    
    
    /** snare drum pattern number. */
    private function get_snarePatternNumber() : Int{return _snarePatternNumber;
    }
    private function set_snarePatternNumber(index : Int) : Int{
        if (index < 0 || index >= snarePatternList.length)             return;
        _snarePatternNumber = index;
        if (_changePatternOnSegment)             snare.nextPattern = snarePatternList[index]
        else snare.pattern = snarePatternList[index];
        return index;
    }
    
    
    /** hi-hat cymbal pattern number. */
    private function get_hihatPatternNumber() : Int{return _hihatPatternNumber;
    }
    private function set_hihatPatternNumber(index : Int) : Int{
        if (index < 0 || index >= hihatPatternList.length)             return;
        _hihatPatternNumber = index;
        if (_changePatternOnSegment)             hihat.nextPattern = hihatPatternList[index]
        else hihat.pattern = hihatPatternList[index];
        return index;
    }
    
    
    /** bass drum pattern number. */
    private function get_bassVoiceNumber() : Int{return _bassVoiceNumber >> 1;
    }
    private function set_bassVoiceNumber(index : Int) : Int{
        index <<= 1;
        if (index < 0 || index >= bassVoiceList.length)             return;
        _bassVoiceNumber = index;
        bass.voiceList = [bassVoiceList[index], bassVoiceList[index + 1]];
        return index;
    }
    
    
    /** snare drum pattern number. */
    private function get_snareVoiceNumber() : Int{return _snareVoiceNumber >> 1;
    }
    private function set_snareVoiceNumber(index : Int) : Int{
        index <<= 1;
        if (index < 0 || index >= snareVoiceList.length)             return;
        _snareVoiceNumber = index;
        snare.voiceList = [snareVoiceList[index], snareVoiceList[index + 1]];
        return index;
    }
    
    
    /** hi-hat cymbal pattern number. */
    private function get_hihatVoiceNumber() : Int{return _hihatVoiceNumber >> 1;
    }
    private function set_hihatVoiceNumber(index : Int) : Int{
        index <<= 1;
        if (index < 0 || index >= hihatVoiceList.length)             return;
        _hihatVoiceNumber = index;
        hihat.voiceList = [hihatVoiceList[index], hihatVoiceList[index + 1]];
        return index;
    }
    
    /** bass drum volume (0-1) */
    private function get_bassVolume() : Float{return _bass.defaultVelocity * 0.00392156862745098;
    }
    private function set_bassVolume(n : Float) : Float{
        if (n < 0)             n = 0
        else if (n > 1)             n = 1;
        _bass.defaultVelocity = n * 255;
        return n;
    }
    
    /** snare drum volume (0-1) */
    private function get_snareVolume() : Float{return _snare.defaultVelocity * 0.00392156862745098;
    }
    private function set_snareVolume(n : Float) : Float{
        if (n < 0)             n = 0
        else if (n > 1)             n = 1;
        _snare.defaultVelocity = n * 255;
        return n;
    }
    
    /** hihat symbal volume (0-1) */
    private function get_hihatVolume() : Float{return _hihat.defaultVelocity * 0.00392156862745098;
    }
    private function set_hihatVolume(n : Float) : Float{
        if (n < 0)             n = 0
        else if (n > 1)             n = 1;
        _hihat.defaultVelocity = n * 255;
        return n;
    }
    
    
    /** True to change bass line pattern at the head of segment. @default true */
    private function get_changePatternOnNextSegment() : Bool{return _changePatternOnSegment;
    }
    private function set_changePatternOnNextSegment(b : Bool) : Bool{
        _changePatternOnSegment = b;
        return b;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor 
     *  @param bassPatternNumber bass drum pattern number
     *  @param snarePatternNumber snare drum pattern number
     *  @param hihatPatternNumber hihat symbal pattern number
     *  @param bassVoiceNumber bass drum voice number
     *  @param snareVoiceNumber snare drum voice number
     *  @param hihatVoiceNumber hihat symbal voice number
     */
    public function new(bassPatternNumber : Int = 0, snarePatternNumber : Int = 8, hihatPatternNumber : Int = 0, bassVoiceNumber : Int = 0, snareVoiceNumber : Int = 0, hihatVoiceNumber : Int = 0)
    {
        if (_presetVoice == null) {
            _presetVoice = new DrumMachinePresetVoice();
            _presetPattern = new DrumMachinePresetPattern();
            bassPatternList = Reflect.field(_presetPattern, "bass");
            snarePatternList = Reflect.field(_presetPattern, "snare");
            hihatPatternList = Reflect.field(_presetPattern, "hihat");
            percusPatternList = Reflect.field(_presetPattern, "percus");
            bassVoiceList = Reflect.field(_presetVoice, "bass");
            snareVoiceList = Reflect.field(_presetVoice, "snare");
            hihatVoiceList = Reflect.field(_presetVoice, "hihat");
            percusVoiceList = Reflect.field(_presetVoice, "percus");
        }
        
        super("DrumMachine");
        
        _data = new SiONData();
        _bass = new Sequencer(this, _data, 36, 255, 1);
        _snare = new Sequencer(this, _data, 68, 160, 1);
        _hihat = new Sequencer(this, _data, 68, 128, 1);
        this.bassVoiceNumber = bassVoiceNumber;
        this.snareVoiceNumber = snareVoiceNumber;
        this.hihatVoiceNumber = hihatVoiceNumber;
        _changePatternOnSegment = true;
        
        setPatternNumbers(bassPatternNumber, snarePatternNumber, hihatPatternNumber);
    }
    
    
    
    
    // operation
    //----------------------------------------
    /** play drum sequence */
    override public function play() : Void
    {
        var tn : Int;
        var seq : Sequencer;
        
        stop();
        _tracks = _sequenceOn(_data, false, false);
        if (_tracks && _tracks.length == 3) {
            _synthesizer._registerTracks(_tracks);
            _bass.play(_tracks[0]);
            _snare.play(_tracks[1]);
            _hihat.play(_tracks[2]);
            if (_tracks[0].trackNumber < _tracks[1].trackNumber) {
                tn = ((_tracks[0].trackNumber < _tracks[2].trackNumber)) ? 0 : 2;
            }
            else {
                tn = ((_tracks[1].trackNumber < _tracks[2].trackNumber)) ? 1 : 2;
            }
            switch (tn)
            {
                case 0:seq = _bass;
                case 1:seq = _snare;
                default:seq = _hihat;
            }
            seq.onEnterFrame = _onEnterFrame;
            seq.onEnterSegment = _onEnterSegment;
        }
        else {
            throw new Error("unknown error");
        }
    }
    
    
    /** stop sequence */
    override public function stop() : Void
    {
        if (_tracks) {
            _bass.stop();
            _snare.stop();
            _hihat.stop();
            _synthesizer._unregisterTracks(_tracks[0], _tracks.length);
            for (t/* AS3HX WARNING could not determine type for var: t exp: EIdent(_tracks) type: null */ in _tracks)t.setDisposable();
            _tracks = null;
            _sequenceOff(false);
            _bass.onEnterFrame = null;
            _snare.onEnterFrame = null;
            _hihat.onEnterFrame = null;
            _bass.onEnterSegment = null;
            _snare.onEnterSegment = null;
            _hihat.onEnterSegment = null;
        }
        _stopEffect();
    }
    
    
    
    
    // configure
    //----------------------------------------
    /** Set all pattern indeces 
     *  @param bassPatternNumber bass drum pattern index
     *  @param snarePatternNumber snare drum pattern index
     *  @param hihatPatternNumber hihat symbal pattern index
     */
    public function setPatternNumbers(bassPatternNumber : Int, snarePatternNumber : Int, hihatPatternNumber : Int) : DrumMachine
    {
        this.bassPatternNumber = bassPatternNumber;
        this.snarePatternNumber = snarePatternNumber;
        this.hihatPatternNumber = hihatPatternNumber;
        return this;
    }
}


