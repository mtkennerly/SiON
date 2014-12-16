//----------------------------------------------------------------------------------------------------
// Arpeggiator class
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound;

import org.si.sion.*;
import org.si.sion.utils.Scale;
import org.si.sound.patterns.Note;
import org.si.sound.patterns.Sequencer;


/** @eventType org.si.sound.events.SoundObjectEvent.ENTER_FRAME */
@:meta(Event(name="enterFrame",type="org.si.sound.events.SoundObjectEvent"))

/** @eventType org.si.sound.events.SoundObjectEvent.ENTER_SEGMENT */
@:meta(Event(name="enterSegment",type="org.si.sound.events.SoundObjectEvent"))


/** Arpeggiator provides monophonic arpeggio pattern sound. */
class Arpeggiator extends PatternSequencer
{
    public var scale(get, set) : Scale;
    public var scaleName(get, set) : String;
    public var scaleIndex(get, set) : Int;
    public var noteLength(get, set) : Float;
    public var pattern(get, set) : Array<Int>;
    public var changePatternOnNextSegment(get, set) : Bool;
    public var noteQuantize(get, set) : Int;

    // variables
    //----------------------------------------
    /** @private [protected] Table of notes on scale */
    private var _scale : Scale;
    /** @private [protected] scale index */
    private var _scaleIndex : Int;
    
    /** @private [protected] Current arpeggio pattern. */
    private var _currentPattern : Array<Int>;
    /** @private [protected] Next arpeggio pattern to change while playing. */
    private var _nextPattern : Array<Int>;
    /** @private [protected] Change bass line pattern at the head of segment. */
    private var _changePatternOnSegment : Bool;

    // properties
    //----------------------------------------
    /** change root note of the scale */
    override private function get_note() : Int {
        return _scale.rootNote;
    }
    override private function set_note(n : Int) : Int {
        _scale.rootNote = n;
        _scaleIndexUpdated();
        return n;
    }
    
    
    /** scale instance */
    private function get_scale() : Scale {
        return _scale;
    }
    private function set_scale(s : Scale) : Scale {
        _scale.copyFrom(s);
        _scaleIndexUpdated();
        return s;
    }
    
    
    /** specify scale by name */
    private function get_scaleName() : String {
        return _scale.name;
    }
    private function set_scaleName(str : String) : String {
        _scale.name = str;
        _scaleIndexUpdated();
        return str;
    }
    
    
    /** index on scale */
    private function get_scaleIndex() : Int {
        return _scaleIndex;
    }
    private function set_scaleIndex(i : Int) : Int {
        _scaleIndex = i;
        _note = _scale.getNote(i);
        _scaleIndexUpdated();
        return i;
    }
    
    
    /** note length in 16th beat. */
    private function get_noteLength() : Float {
        return _sequencer.defaultLength;
    }
    private function set_noteLength(l : Float) : Float {
        if (l < 0.25) l = 0.25
        else if (l > 16) l = 16;
        _sequencer.defaultLength = l;
        _sequencer.gridStep = Std.int(l * 120);
        return l;
    }
    
    
    /** Note index array of the arpeggio pattern. If the index is out of range, insert rest instead. */
    private function get_pattern() : Array<Int> {
        if (_currentPattern == null) return _nextPattern
        else return _currentPattern;
    }
    private function set_pattern(pat : Array<Int>) : Array<Int> {
        if (isPlaying && _changePatternOnSegment) _nextPattern = pat
        else _updateArpeggioPattern(pat);
        return pat;
    }
    
    
    /** True to change bass line pattern at the head of segment. @default true */
    private function get_changePatternOnNextSegment() : Bool {
        return _changePatternOnSegment;
    }
    private function set_changePatternOnNextSegment(b : Bool) : Bool {
        _changePatternOnSegment = b;
        return b;
    }
    
    
    /** [NOT RECOMENDED] Only for the compatibility before version 0.58, the getTime property can be used instead of this property. */
    private function get_noteQuantize() : Int {
        return Math.floor(gateTime * 8);
    }
    private function set_noteQuantize(q : Int) : Int {
        gateTime = q * 0.125;
        return q;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor 
     *  @param scale Arpaggio scale, org.si.sion.utils.Scale instance, scale name String or null is suitable.
     *  @param noteLength length for each note
     *  @param pattern Note index array of the arpeggio pattern. If the index is out of range, insert rest instead.
     *  @see org.si.sion.utils.Scale
     */
    public function new(scale : Dynamic = null, noteLength : Float = 2, pattern : Array<Int> = null)
    {
        super();
        name = "Arpeggiator";
        
        _scale = new Scale();
        if (Std.is(scale, Scale)) _scale.copyFrom(try cast(scale, Scale) catch(e:Dynamic) null)
        else if (Std.is(scale, String)) _scale.name = try cast(scale, String) catch(e:Dynamic) null;
        
        _nextPattern = null;
        _sequencer.defaultLength = 1;
        _sequencer.pattern = new Array<Note>();
        _sequencer.onEnterFrame = _onEnterFrame;
        _sequencer.onEnterSegment = _onEnterSegment;
        
        _updateArpeggioPattern(pattern);
    }
    

    // operations
    //----------------------------------------
    /** @private */
    override public function reset() : Void
    {
        super.reset();
        _scaleIndex = 0;
    }
    

    // internal
    //----------------------------------------
    /** @private [protected] call this after the update of note or scale index */
    private function _scaleIndexUpdated() : Void {
        var i : Int;
        var imax : Int = _sequencer.pattern.length;
        for (i in 0...imax) {
            _sequencer.pattern[i].note = _scale.getNote(_currentPattern[i] + _scaleIndex);
        }
    }
    
    
    // set arpeggio pattern
    private function _updateArpeggioPattern(indexPattern : Array<Int>) : Void {
        var i : Int;
        var imax : Int;
        var note : Int;
        var pattern : Array<Note>;
        
        _currentPattern = indexPattern;
        if (_currentPattern != null) {
            imax = _currentPattern.length;
            //_sequencer.pattern.length = imax;
            _sequencer.segmentFrameCount = imax;
            pattern = _sequencer.pattern;
            for (i in 0...imax){
                if (pattern[i] == null) pattern[i] = new Note();
                note = _scale.getNote(_currentPattern[i] + _scaleIndex);
                if (note >= 0 && note < 128) {
                    pattern[i].note = note;
                    pattern[i].velocity = -1;
                    pattern[i].length = Math.NaN;
                }
                else {
                    pattern[i].setRest();
                }
            }
        }
        else {
            _sequencer.pattern.splice(0, _sequencer.pattern.length);
            _sequencer.segmentFrameCount = 16;
        }
    }
    
    
    /** @private [protected] handler on enter segment */
    override private function _onEnterSegment(seq : Sequencer) : Void {
        if (_nextPattern != null) {
            _updateArpeggioPattern(_nextPattern);
            _nextPattern = null;
        }
        super._onEnterSegment(seq);
    }
}


