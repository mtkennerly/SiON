//----------------------------------------------------------------------------------------------------
// Bass sequencer class
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound;

import org.si.sound.BassSequencerPresetPattern;
import org.si.sound.Chord;
import org.si.sound.PatternSequencer;

import org.si.sion.*;
import org.si.sion.utils.Chord;
import org.si.sion.utils.Scale;
import org.si.sound.patterns.Note;
import org.si.sound.patterns.Sequencer;
import org.si.sound.patterns.BassSequencerPresetPattern;
import org.si.sound.namespaces.SoundObjectInternal;

/** @eventType org.si.sound.events.SoundObjectEvent.ENTER_FRAME */
@:meta(Event(name="enterFrame",type="org.si.sound.events.SoundObjectEvent"))

/** @eventType org.si.sound.events.SoundObjectEvent.ENTER_SEGMENT */
@:meta(Event(name="enterSegment",type="org.si.sound.events.SoundObjectEvent"))


/** Bass sequencer provides simple monophonic bass line. */
class BassSequencer extends PatternSequencer
{
    public var presetPattern(get, never) : BassSequencerPresetPattern;
    public var scale(get, set) : Scale;
    public var chordName(get, set) : String;
    public var patternNumberMax(get, never) : Int;
    public var patternNumber(get, set) : Int;
    public var pattern(get, set) : Array<Dynamic>;
    public var changePatternOnNextSegment(get, set) : Bool;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // static variables
    //----------------------------------------
    private static var _presetPattern : BassSequencerPresetPattern = null;
    private static var bassPatternList : Array<Dynamic>;
    
    
    
    
    // variables
    //----------------------------------------
    /** @private [protected] chord instance */
    private var _scale : Scale;
    /** @private [protected] Default chord instance, this is used when the name is specifyed */
    private var _defaultChord : Chord = new Chord();
    
    /** @private [protected] pettern. */
    private var _pattern : Array<Note>;
    /** @private [protected] Current length sequence pattern. */
    private var _currentPattern : Array<Dynamic>;
    /** @private [protected] Next length sequence pattern to change while playing. */
    private var _nextPattern : Array<Dynamic>;
    /** @private [protected] pettern number. */
    private var _patternNumber : Int;
    /** @private [protected] Change bass line pattern at the head of segment. */
    private var _changePatternOnSegment : Bool;
    
    
    
    // properties
    //----------------------------------------
    /** Preset voice list */
    //public function get presetVoice() : BassSequencerPresetVoice { return _presetVoice; }
    
    /** Preset pattern list */
    private function get_presetPattern() : BassSequencerPresetPattern{return _presetPattern;
    }
    
    
    /** Bass note of chord  */
    override private function get_note() : Int{return _scale.bassNote;
    }
    override private function set_note(n : Int) : Int{
        if (_scale != _defaultChord)             _defaultChord.copyFrom(_scale);
        _defaultChord.bassNote = n;
        _scale = _defaultChord;
        _updateBassNote();
        return n;
    }
    
    
    /** chord instance */
    private function get_scale() : Scale{return _scale;
    }
    private function set_scale(s : Scale) : Scale{
        _scale = s || _defaultChord;
        _updateBassNote();
        return s;
    }
    
    
    /** specify chord by name */
    private function get_chordName() : String{return _scale.name;
    }
    private function set_chordName(name : String) : String{
        _defaultChord.name = name;
        _scale = _defaultChord;
        _updateBassNote();
        return name;
    }
    
    
    /** maximum limit of bass line Pattern number */
    private function get_patternNumberMax() : Int{
        return bassPatternList.length;
    }
    
    
    /** bass line Pattern number */
    private function get_patternNumber() : Int{return _patternNumber;
    }
    private function set_patternNumber(n : Int) : Int{
        if (n < 0 || n >= bassPatternList.length)             return;
        _patternNumber = n;
        pattern = bassPatternList[n];
        return n;
    }
    
    
    /** Number Array of the sequence notes. If the value is 0, insert rest instead. */
    private function get_pattern() : Array<Dynamic>{return _currentPattern || _nextPattern;
    }
    private function set_pattern(pat : Array<Dynamic>) : Array<Dynamic>{
        if (isPlaying && _changePatternOnSegment) {
            _nextPattern = pat;
        }
        else {
            _currentPattern = pat;
            _updateBassNote();
        }
        return pat;
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
     *  @param scale Bassline scale or chord or chord name.
     *  @param patternNumber bass line pattern number
     *  @param changePatternOnSegment When this is true, pattern and chord are changed at the head of next segment.
     *  @see org.si.sion.utils.Scale
     */
    public function new(chord : Dynamic = null, patternNumber : Int = 6, changePatternOnSegment : Bool = true)
    {
        super();
        name = "BassSequencer";
        
        if (_presetPattern == null) {
            _presetPattern = new BassSequencerPresetPattern();
            bassPatternList = Reflect.field(_presetPattern, "bass");
        }
        
        _pattern = new Array<Note>();
        
        _changePatternOnSegment = false;
        if (Std.is(chord, String))             this.chordName = try cast(chord, String) catch(e:Dynamic) null
        else this.scale = try cast(chord, Chord) catch(e:Dynamic) null;
        this.patternNumber = patternNumber;
        _changePatternOnSegment = changePatternOnSegment;
        
        _sequencer.onEnterFrame = _onEnterFrame;
        _sequencer.onEnterSegment = _onEnterSegment;
    }
    
    
    /** @private [protected] */
    private function _updateBassNote() : Void
    {
        var i : Int;
        var imax : Int;
        var bn : Int = _scale.bassNote;
        if (_currentPattern != null) {
            imax = _currentPattern.length;
            _pattern.length = imax;
            for (imax){
                if (_pattern[i] == null)                     _pattern[i] = new Note();
                if (_currentPattern[i]) {
                    _pattern[i].note = _currentPattern[i].note - 33 + bn;
                    _pattern[i].velocity = _currentPattern[i].velocity;
                    _pattern[i].length = _currentPattern[i].length;
                }
                else {
                    _pattern[i].setRest();
                }
            }
        }
        else {
            _pattern.length = 16;
            for (16){
                if (_pattern[i] == null)                     _pattern[i] = new Note();
                _pattern[i].setRest();
            }
        }
        _sequencer.pattern = _pattern;
    }
    
    
    /** @private [protected] enter segment handler */
    override private function _onEnterSegment(seq : Sequencer) : Void
    {
        if (_nextPattern != null) {
            _currentPattern = _nextPattern;
            _nextPattern = null;
            _updateBassNote();
        }
        super._onEnterSegment(seq);
    }
}


