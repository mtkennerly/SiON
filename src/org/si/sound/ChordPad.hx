//----------------------------------------------------------------------------------------------------
// Polyphonic chord pad synthesizer
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound;

import openfl.errors.Error;
import org.si.sound.MultiTrackSoundObject;
import org.si.sound.SiMMLTrack;
import org.si.sound.SiONData;

import org.si.sion.SiONData;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sion.utils.Chord;
import org.si.sound.patterns.Note;
import org.si.sound.patterns.Sequencer;


/** @eventType org.si.sound.events.SoundObjectEvent.ENTER_FRAME */
@:meta(Event(name="enterFrame",type="org.si.sound.events.SoundObjectEvent"))

/** @eventType org.si.sound.events.SoundObjectEvent.ENTER_SEGMENT */
@:meta(Event(name="enterSegment",type="org.si.sound.events.SoundObjectEvent"))


/** Chord pad provides polyphonic synthesizer controled by chord and rhythm pattern. */
class ChordPad extends MultiTrackSoundObject
{
    public var operators(get, never) : Array<Sequencer>;
    public var operatorCount(get, never) : Int;
    public var chord(get, set) : Chord;
    public var chordName(get, set) : String;
    public var voiceMode(get, set) : Int;
    public var noteLength(get, set) : Float;
    public var pattern(get, set) : Array<Dynamic>;
    public var changePatternOnSegment(get, set) : Bool;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // constants
    //----------------------------------------
    /** closed voicing mode [o5c,o5e,o5g,o5b,o6e,o6g] for CM7 @see voiceMode */
    public static inline var CLOSED : Int = 0x543210;
    
    /** opened voicing mode [o5c,o5g,o5b,o6e,o6g,o6b] for CM7 @see voiceMode */
    public static inline var OPENED : Int = 0x654320;
    
    /** middle-position voicing mode [o5e,o5g,o5b,o6e,o6g,o6b] for CM7 @see voiceMode */
    public static inline var MIDDLE : Int = 0x654321;
    
    /** high-position voicing mode [o5g,o5b,o6e,o6g,o6b,o7e] for CM7 @see voiceMode */
    public static inline var HIGH : Int = 0x765432;
    
    /** opened high-position voicing mode [o5g,o6e,o6g,o6b,o7e,o7g] for CM7 @see voiceMode */
    public static inline var OPENED_HIGH : Int = 0x876542;
    
    
    
    
    // variables
    //----------------------------------------
    /** @private [protected] Monophonic sequencers */
    private var _operators : Array<Sequencer>;
    
    /** @private [protected] Sequence data */
    private var _data : SiONData;
    
    /** @private [protected] chord instance */
    private var _chord : Chord;
    /** @private [protected] Default chord instance, this is used when the name is specifyed */
    private var _defaultChord : Chord = new Chord();
    /** @private [protected] chord notes index */
    private var _noteIndexes : Int;
    
    /** @private [protected] Note pattern */
    private var _pattern : Array<Note>;
    /** @private [protected] Current length sequence pattern. */
    private var _currentPattern : Array<Dynamic>;
    /** @private [protected] Next length sequence pattern to change while playing. */
    private var _nextPattern : Array<Dynamic>;
    /** @private [protected] Change bass line pattern at the head of segment. */
    private var _changePatternOnSegment : Bool;
    
    
    
    
    // properties
    //----------------------------------------
    /** list of monophonic operators */
    private function get_operators() : Array<Sequencer>{return operators;
    }
    
    /** Number of monophonic operators */
    private function get_operatorCount() : Int{return operators.length;
    }
    
    
    /** root note of current chord @default 60 */
    override private function get_note() : Int{return _chord.rootNote;
    }
    override private function set_note(n : Int) : Int{
        if (_chord != _defaultChord)             _defaultChord.copyFrom(_chord);
        _defaultChord.rootNote = n;
        _chord = _defaultChord;
        _updateChordNotes();
        return n;
    }
    
    
    /** chord instance @default Chord("C") */
    private function get_chord() : Chord{return _chord;
    }
    private function set_chord(c : Chord) : Chord{
        if (c == null)             _chord = _defaultChord;
        _chord = c;
        _updateChordNotes();
        return c;
    }
    
    
    /** specify chord by name @default "C" */
    private function get_chordName() : String{return _chord.name;
    }
    private function set_chordName(name : String) : String{
        _defaultChord.name = name;
        _chord = _defaultChord;
        _updateChordNotes();
        return name;
    }
    
    
    /** voicing mode @default CLOSED */
    private function get_voiceMode() : Int{return _noteIndexes;
    }
    private function set_voiceMode(m : Int) : Int{
        _noteIndexes = m;
        _updateChordNotes();
        return m;
    }
    
    
    /** note length in 16th beat. */
    private function get_noteLength() : Float{return _operators[0].defaultLength;
    }
    private function set_noteLength(l : Float) : Float{
        if (l < 0.25)             l = 0.25
        else if (l > 16)             l = 16;
        for (i in 0...operatorCount){
            _operators[i].defaultLength = l;
            _operators[i].gridStep = l * 120;
        }
        return l;
    }
    
    
    /** Number Array of the sequence notes' length. If the value is 0, insert rest instead. */
    private function get_pattern() : Array<Dynamic>{return _currentPattern || _nextPattern;
    }
    private function set_pattern(pat : Array<Dynamic>) : Array<Dynamic>{
        if (isPlaying && _changePatternOnSegment)             _nextPattern = pat
        else _updateSequencePattern(pat);
        return pat;
    }
    
    
    /** True to change bass line pattern at the head of segment. @default true */
    private function get_changePatternOnSegment() : Bool{return _changePatternOnSegment;
    }
    private function set_changePatternOnSegment(b : Bool) : Bool{
        _changePatternOnSegment = b;
        return b;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor 
     *  @param chord org.si.sion.utils.Chord, chord name String or null is suitable.
     *  @param operatorCount Number of monophonic operators (1-6).
     *  @param voiceMode Voicing mode.
     *  @param pattern Number Array of the sequence notes' length. If the value is 0, insert rest instead.
     *  @param changePatternOnSegment When this is true, pattern and chord are changed at the head of next segment.
     */
    public function new(chord : Dynamic = null, operatorCount : Int = 3, voiceMode : Int = CLOSED, pattern : Array<Dynamic> = null, changePatternOnSegment : Bool = true)
    {
        super("ChordPad");
        
        if (operatorCount < 1 || operatorCount > 6)             throw new Error("ChordPad; Number of operators should be in the range of 1 - 6.");
        
        _data = new SiONData();
        _operators = new Array<Sequencer>();
        _noteIndexes = voiceMode;
        
        var defaultVelocity : Int = 256 / operatorCount;
        if (defaultVelocity > 128)             defaultVelocity = 128;
        for (i in 0...operatorCount){
            _operators[i] = new Sequencer(this, _data, 60, defaultVelocity, 1);
        }
        
        if (Std.is(chord, Chord)) {
            _chord = try cast(chord, Chord) catch(e:Dynamic) null;
        }
        else {
            _chord = _defaultChord;
            if (Std.is(chord, String)) {
                _chord.name = try cast(chord, String) catch(e:Dynamic) null;
            }
        }
        
        _nextPattern = null;
        _pattern = new Array<Note>();
        _changePatternOnSegment = changePatternOnSegment;
        
        _updateChordNotes();
        _updateSequencePattern(pattern);
    }
    
    
    
    
    // configure
    //----------------------------------------
    
    
    
    
    // operations
    //----------------------------------------
    /** play drum sequence */
    override public function play() : Void
    {
        var i : Int;
        var imax : Int = _operators.length;
        var opn : Int;
        stop();
        _tracks = _sequenceOn(_data, false, false);
        if (_tracks && _tracks.length == imax) {
            _synthesizer._registerTracks(_tracks);
            for (imax){
                if (_tracks[opn].trackNumber > _tracks[i].trackNumber)                     opn = i;
                _operators[i].play(_tracks[i]);
            }
            _operators[opn].onEnterFrame = _onEnterFrame;
            _operators[opn].onEnterSegment = _onEnterSegment;
        }
        else {
            throw new Error("unknown error");
        }
    }
    
    
    /** stop sequence */
    override public function stop() : Void
    {
        if (_tracks) {
            for (i in 0..._operators.length){
                _operators[i].stop();
                _operators[i].onEnterFrame = null;
                _operators[i].onEnterSegment = null;
            }
            _synthesizer._unregisterTracks(_tracks[0], _tracks.length);
            for (t/* AS3HX WARNING could not determine type for var: t exp: EIdent(_tracks) type: null */ in _tracks)t.setDisposable();
            _tracks = null;
            _sequenceOff(false);
        }
        _stopEffect();
    }
    
    
    
    
    // internals
    //----------------------------------------
    /** @private [protected] update chord notes */
    private function _updateChordNotes() : Void
    {
        var i : Int;
        var imax : Int = _operators.length;
        var noteIndex : Int;
        for (imax){
            _operators[i].defaultNote = _chord.getNote((_noteIndexes >> (i << 2)) & 15);
        }
    }
    
    
    /** @private [protected] update sequence pattern */
    private function _updateSequencePattern(lengthPattern : Array<Dynamic>) : Void
    {
        var i : Int;
        var imax : Int;
        
        _currentPattern = lengthPattern;
        if (_currentPattern != null) {
            imax = _currentPattern.length;
            _pattern.length = imax;
            for (imax){
                if (_pattern[i] == null)                     _pattern[i] = new Note();
                if (lengthPattern[i] == 0)                     _pattern[i].setRest()
                else _pattern[i].setNote(-1, -1, _currentPattern[i]);
            }
            imax = _operators.length;
            for (imax){
                _operators[i].pattern = _pattern;
            }
        }
        else {
            for (imax){
                _operators[i].pattern = null;
            }
        }
    }
    
    
    /** @private [protected] on enter segment */
    override private function _onEnterSegment(seq : Sequencer) : Void
    {
        if (_nextPattern != null) {
            _updateSequencePattern(_nextPattern);
            _nextPattern = null;
        }
        super._onEnterSegment(seq);
    }
}


