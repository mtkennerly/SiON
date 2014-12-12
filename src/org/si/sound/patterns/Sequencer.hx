//----------------------------------------------------------------------------------------------------
// Sequencer class
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.patterns;

import org.si.sound.patterns.MMLEvent;
import org.si.sound.patterns.MMLSequence;
import org.si.sound.patterns.SiMMLTrack;
import org.si.sound.patterns.SiONData;
import org.si.sound.patterns.SoundObject;

import org.si.sion.*;
import org.si.sion.sequencer.base.*;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sound.SoundObject;




/** The Sequencer class provides simple one track pattern player. */
class Sequencer
{
    public var frameCount(get, never) : Int;
    public var sequencePointer(get, set) : Int;
    public var mute(get, set) : Bool;
    public var note(get, never) : Int;
    public var velocity(get, never) : Int;
    public var gateTime(get, never) : Float;
    public var length(get, never) : Float;
    public var eventTriggerID(get, set) : Int;
    public var noteOnTriggerType(get, never) : Int;
    public var noteOffTriggerType(get, never) : Int;
    public var defaultNote(get, set) : Int;
    public var defaultVelocity(get, set) : Int;
    public var defaultLength(get, set) : Float;
    public var defaultGateTime(get, set) : Float;
    public var division(get, set) : Int;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    /** pattern note vector to play */
    public var pattern : Array<Note> = null;
    /** next pattern, the pattern property is replaced to this vector at the head of next segment @see pattern */
    public var nextPattern : Array<Note> = null;
    /** voice list referenced by Note.voiceIndex. @see org.si.sound.Note.voiceIndex */
    public var voiceList : Array<Dynamic> = null;
    
    
    /** @private [internal use] callback on every notes. function(Sequencer) : void */
    private var onEnterFrame : Function = null;
    /** @private [internal use] callback after every notes. function(Sequencer) : void */
    private var onExitFrame : Function = null;
    /** @private [internal use] callback on first beat of every segments. function(Sequencer) : void */
    private var onEnterSegment : Function = null;
    /** @private [internal use] Frame count in one segment */
    private var segmentFrameCount : Int;
    /** @private [internal use] Grid step in ticks */
    private var gridStep : Int;
    /** @private [internal use] portament */
    private var portament : Int;
    
    /** @private owner of this pattern sequencer */
    private var _owner : SoundObject;
    /** @private controlled track */
    private var _track : SiMMLTrack;
    /** @private MMLEvent.INTERNAL_WAIT. */
    private var _waitEvent : MMLEvent;
    /** @private check number of synthsizer update */
    private var _synthesizer_updateNumber : Int;
    
    /** @private Frame counter */
    private var _frameCounter : Int;
    /** @private playing pointer on the pattern */
    private var _sequencePointer : Int;
    /** @private initial value of _sequencePointer */
    private var _initialSequencePointer : Int;
    
    /** @private Default note */
    private var _defaultNote : Int;
    /** @private Default velocity */
    private var _defaultVelocity : Int;
    /** @private Default length */
    private var _defaultLength : Int;
    /** @private Default gate time */
    private var _defaultGateTime : Int;
    /** @private Current note */
    private var _currentNote : Note;
    /** @private Grid shift vectors */
    private var _currentGridShift : Int;
    /** @private Mute */
    private var _mute : Bool;
    
    /** @private [protected] Event trigger ID */
    private var _eventTriggerID : Int;
    /** @private [protected] note on trigger | (note off trigger &lt;&lt; 2) trigger type */
    private var _noteTriggerFlags : Int;
    
    /** @private Grid shift pattern */
    private var _gridShiftPattern : Array<Int>;
    
    
    
    
    // properties
    //----------------------------------------
    /** current frame count, -1 means waiting for start */
    private function get_frameCount() : Int{return _frameCounter;
    }
    
    
    /** sequence pointer, -1 means waiting for start */
    private function get_sequencePointer() : Int{return _sequencePointer;
    }
    private function set_sequencePointer(p : Int) : Int{
        if (_track != null) {
            _sequencePointer = p - 1;
            _frameCounter = p % segmentFrameCount;
            if (_sequencePointer >= 0) {
                if (_sequencePointer >= pattern.length)                     _sequencePointer %= pattern.length;
                _currentNote = pattern[_sequencePointer];
            }
        }
        else {
            _initialSequencePointer = p - 1;
        }
        return p;
    }
    
    
    /** mute */
    private function get_mute() : Bool{return _mute;
    }
    private function set_mute(b : Bool) : Bool{_mute = b;
        return b;
    }
    
    
    /** curent note number (0-127) */
    private function get_note() : Int{
        if (_currentNote == null || _currentNote.note < 0)             return _defaultNote;
        return _currentNote.note;
    }
    
    
    /** curent note's velocity (minimum:0 - maximum:255, the value over 128 makes distotion). */
    private function get_velocity() : Int{
        if (_currentNote == null || _mute)             return 0;
        if (_currentNote.velocity < 0)             return _defaultVelocity;
        return _currentNote.velocity;
    }
    
    
    /** curent note's gate time (0-1). */
    private function get_gateTime() : Float{
        if (_currentNote == null || Math.isNaN(_currentNote.gateTime))             return _defaultGateTime;
        return _currentNote.gateTime;
    }
    
    
    /** curent note's length. */
    private function get_length() : Float{
        if (_currentNote == null || Math.isNaN(_currentNote.length))             return _defaultLength;
        return _currentNote.length;
    }
    
    
    /** Track event trigger ID */
    private function get_eventTriggerID() : Int{return _eventTriggerID;
    }
    private function set_eventTriggerID(id : Int) : Int{_eventTriggerID = id;
        return id;
    }
    /** Track note on trigger type */
    private function get_noteOnTriggerType() : Int{return _noteTriggerFlags & 3;
    }
    /** Track note off trigger type */
    private function get_noteOffTriggerType() : Int{return _noteTriggerFlags >> 2;
    }
    
    
    /** default note (0-127), this value is refered when the Note's note property is under 0 (ussualy -1). */
    private function get_defaultNote() : Int{return _defaultNote;
    }
    private function set_defaultNote(n : Int) : Int{_defaultNote = ((n < 0)) ? 0 : ((n > 127)) ? 127 : n;
        return n;
    }
    
    
    /** default velocity (minimum:0 - maximum:255, the value over 128 makes distotion), this value is refered when the Note's velocity property is under 0 (ussualy -1). */
    private function get_defaultVelocity() : Int{return _defaultVelocity;
    }
    private function set_defaultVelocity(v : Int) : Int{_defaultVelocity = ((v < 0)) ? 0 : ((v > 255)) ? 255 : v;
        return v;
    }
    
    
    /** default length, this value is refered when the Note's length property is Number.NaN. */
    private function get_defaultLength() : Float{return _defaultLength;
    }
    private function set_defaultLength(l : Float) : Float{_defaultLength = ((l < 0)) ? 0 : l;
        return l;
    }
    
    
    /** default gate time, this value is refered when the Note's gate time property is Number.NaN. */
    private function get_defaultGateTime() : Float{return _defaultGateTime;
    }
    private function set_defaultGateTime(g : Float) : Float{_defaultGateTime = ((g < 0)) ? 0 : ((g > 1)) ? 1 : g;
        return g;
    }
    
    
    /** Frame divition of 1 measure. Set 16 to play notes in 16th beats. */
    private function get_division() : Int{
        var step : Int = Math.floor(1920 / segmentFrameCount);
        return ((step == gridStep)) ? segmentFrameCount : 0;
    }
    private function set_division(d : Int) : Int{
        segmentFrameCount = d;
        gridStep = 1920 / d;
        return d;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** @private constructor. you should not create new PatternSequencer in your own codes. */
    public function new(owner : SoundObject, data : SiONData, defaultNote : Int = 60, defaultVelocity : Int = 128, defaultLength : Float = 0, defaultGateTime : Float = 0.75, gridShiftPattern : Array<Int> = null)
    {
        _owner = owner;
        pattern = null;
        voiceList = null;
        onEnterSegment = null;
        onEnterFrame = null;
        
        // initialize
        segmentFrameCount = 16;  // 16 count in one segment  
        gridStep = 120;  // 16th beat (1920/16)  
        portament = 0;
        _frameCounter = -1;
        _sequencePointer = -1;
        _initialSequencePointer = -1;
        _defaultNote = defaultNote;
        _defaultVelocity = defaultVelocity;
        _defaultLength = defaultLength;
        _defaultGateTime = defaultGateTime;
        _currentNote = null;
        _currentGridShift = 0;
        _gridShiftPattern = gridShiftPattern;
        _mute = false;
        _eventTriggerID = 0;
        _noteTriggerFlags = 0;
        
        // create internal sequence
        var seq : MMLSequence = data.appendNewSequence();
        seq.initialize();
        seq.appendNewEvent(MMLEvent.REPEAT_ALL, 0);
        seq.appendNewCallback(_onEnterFrame, 0);
        _waitEvent = seq.appendNewEvent(MMLEvent.INTERNAL_WAIT, 0, gridStep);
    }
    
    
    
    
    // operations
    //----------------------------------------
    /** @private [internal use] */
    private function play(track : SiMMLTrack) : SiMMLTrack
    {
        _synthesizer_updateNumber = _owner_voiceUpdateNumber;
        _track = track;
        _track.setPortament(portament);
        _track.setEventTrigger(_eventTriggerID, _noteTriggerFlags & 3, _noteTriggerFlags >> 2);
        _sequencePointer = _initialSequencePointer;
        _frameCounter = ((_initialSequencePointer == -1)) ? -1 : (_initialSequencePointer % segmentFrameCount);
        _currentGridShift = 0;
        if (pattern != null && pattern.length > 0)             _currentNote = pattern[0];
        return track;
    }
    
    
    /** @private [internal use] */
    private function stop() : Void
    {
        
    }
    
    
    /** @private [internal use] set portament */
    private function setPortament(p : Int) : Int
    {
        portament = p;
        if (portament < 0)             portament = 0;
        if (_track != null)             _track.setPortament(portament);
        return portament;
    }
    
    
    
    
    // internal
    //----------------------------------------
    /** @private internal callback on every beat */
    private function _onEnterFrame(trackNumber : Int) : MMLEvent
    {
        var vel : Int;
        var patternLength : Int;
        
        // increment frame counter
        if (++_frameCounter == segmentFrameCount)             _frameCounter = 0  // segment oprations  ;
        
        
        
        if (_frameCounter == 0)             _onEnterSegment()  // pattern sequencer  ;
        
        
        
        patternLength = ((pattern != null)) ? pattern.length : 0;
        
        if (patternLength > 0) {
            // increment pointer
            if (++_sequencePointer >= patternLength)                 _sequencePointer %= patternLength  // get current Note from pattern  ;
            
            
            
            _currentNote = pattern[_sequencePointer];
            
            // callback on enter frame
            if (onEnterFrame != null)                 onEnterFrame(this)  // get current velocity, note on when velocity > 0  ;
            
            
            
            vel = velocity;
            if (vel > 0) {
                // change voice
                if (voiceList != null && _currentNote != null && _currentNote.voiceIndex >= 0) {
                    _owner.voice = voiceList[_currentNote.voiceIndex];
                }  // update owners track voice when synthesizer is updated  
                
                if (_synthesizer_updateNumber != _owner_voiceUpdateNumber) {
                    _owner_voice.updateTrackVoice(_track);
                    _synthesizer_updateNumber = _owner_voiceUpdateNumber;
                }  // change track velocity & gate time  
                
                
                
                _track.velocity = vel;
                _track.quantRatio = gateTime;
                
                // note on
                _track.setNote(note, SiONDriver.mutex.sequencer.calcSampleLength(length), (portament > 0));
            }  // set length of rest event  
            
            
            
            if (_gridShiftPattern != null) {
                var diff : Int = _gridShiftPattern[_frameCounter] - _currentGridShift;
                _waitEvent.length = gridStep + diff;
                _currentGridShift += diff;
            }
            else {
                _waitEvent.length = gridStep;
            }  // callback on exit frame  
            
            
            
            if (onExitFrame != null)                 onExitFrame(this);
        }
        
        return null;
    }
    
    
    /** @private internal callback on first beat of every segments */
    private function _onEnterSegment() : Void
    {
        // callback on enter segment
        if (onEnterSegment != null)             onEnterSegment(this)  // replace pattern  ;
        
        if (nextPattern != null) {
            pattern = nextPattern;
            nextPattern = null;
        }
    }
}



