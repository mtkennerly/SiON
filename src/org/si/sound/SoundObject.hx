//----------------------------------------------------------------------------------------------------
// Sound object
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound;

import openfl.errors.Error;
import org.si.sound.EffectChain;
import org.si.sound.EventDispatcher;
import org.si.sound.Fader;
import org.si.sound.SiONDriver;
import org.si.sound.SiONEvent;
import org.si.sound.SiONTrackEvent;
import org.si.sound.SiONVoice;
import org.si.sound.SoundObjectContainer;
import org.si.sound.VoiceReference;

import openfl.events.EventDispatcher;
import org.si.sion.*;
import org.si.sion.utils.Translator;
import org.si.sion.utils.Fader;
import org.si.sion.namespaces.SionInternal;
import org.si.sion.events.SiONEvent;
import org.si.sion.events.SiONTrackEvent;
import org.si.sion.effector.SiEffectBase;
import org.si.sion.module.SiOPMModule;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sound.namespaces.SoundObjectInternal;
import org.si.sound.core.EffectChain;
import org.si.sound.patterns.Sequencer;
import org.si.sound.events.SoundObjectEvent;
import org.si.sound.synthesizers.VoiceReference;
import org.si.sound.synthesizers.BasicSynth;
import org.si.sound.synthesizers.SynthesizerInternal;


/** @eventType org.si.sound.events.SoundObjectEvent.NOTE_ON_STREAM */
@:meta(Event(name="noteOnStream",type="org.si.sound.events.SoundObjectEvent"))

/** @eventType org.si.sound.events.SoundObjectEvent.NOTE_OFF_STREAM */
@:meta(Event(name="noteOffStream",type="org.si.sound.events.SoundObjectEvent"))

/** @eventType org.si.sound.events.SoundObjectEvent.NOTE_ON_FRAME */
@:meta(Event(name="noteOnFrame",type="org.si.sound.events.SoundObjectEvent"))

/** @eventType org.si.sound.events.SoundObjectEvent.NOTE_OFF_FRAME */
@:meta(Event(name="noteOffFrame",type="org.si.sound.events.SoundObjectEvent"))



/** The SoundObject class is the base class of all objects that operates sounds by SiONDriver.
 */
class SoundObject extends EventDispatcher
{
    public var driver(get, never) : SiONDriver;
    public var parent(get, never) : SoundObjectContainer;
    public var isPlaying(get, never) : Bool;
    public var note(get, set) : Int;
    public var voice(get, set) : SiONVoice;
    public var synthesizer(get, set) : VoiceReference;
    public var length(get, set) : Float;
    public var quantize(get, set) : Float;
    public var delay(get, set) : Float;
    public var coarseTune(get, set) : Int;
    public var fineTune(get, set) : Float;
    public var gateTime(get, set) : Float;
    public var eventMask(get, set) : Int;
    public var trackID(get, never) : Int;
    public var eventTriggerID(get, set) : Int;
    public var noteOnTriggerType(get, never) : Int;
    public var noteOffTriggerType(get, never) : Int;
    public var mute(get, set) : Bool;
    public var volume(get, set) : Float;
    public var pan(get, set) : Float;
    public var effectSend1(get, set) : Float;
    public var effectSend2(get, set) : Float;
    public var effectSend3(get, set) : Float;
    public var effectSend4(get, set) : Float;
    public var pitchBend(get, set) : Float;
    public var effectors(get, set) : Array<Dynamic>;

    // namespace
    //----------------------------------------
    
    
    
    
    
    
    // variables
    //----------------------------------------
    /** Name. */
    public var name : String;
    
    /** @private [protected] Base note of this sound */
    private var _note : Int;
    /** @private [protected] Synthesizer instance */
    private var _synthesizer : VoiceReference;
    /** @private [protected] Synthesizer instance to use SiONVoice  */
    private var _voiceReference : VoiceReference;
    /** @private [protected] Effect chain instance */
    private var _effectChain : EffectChain;
    /** @private [protected] track for noteOn() */
    private var _track : SiMMLTrack;
    /** @private [protected] tracks for sequenceOn() */
    private var _tracks : Array<SiMMLTrack>;
    /** @private [protected] Auto-fader to fade in/out. */
    private var _fader : Fader;
    /** @private [protected] Fader volume. */
    private var _faderVolume : Float;
    
    /** @private [protected] Sound length uint in 16th beat, 0 sets inifinity length. @default 0. */
    private var _length : Float;
    /** @private [protected] Sound delay uint in 16th beat. @default 0. */
    private var _delay : Float;
    /** @private [protected] Synchronizing uint in 16th beat. (0:No synchronization, 1:sync.with 16th, 4:sync.with 4th). @default 0. */
    private var _quantize : Float;
    
    /** @private [protected] Note shift in half-tone unit. */
    private var _noteShift : Int;
    /** @private [protected] Pitch shift in half-tone unit. */
    private var _pitchShift : Float;
    /** @private [protected] gate ratio (value of 'q' command * 0.125) */
    private var _gateTime : Float;
    /** @private [protected] Event mask (value of '&#64;mask' command) */
    private var _eventMask : Float;
    /** @private [protected] Event trigger ID */
    private var _eventTriggerID : Int;
    /** @private [protected] note on trigger | (note off trigger &lt;&lt; 2) trigger type */
    private var _noteTriggerFlags : Int;
    /** @private [protected] listening note event trigger */
    private var _listeningFlags : Int;
    
    /** @private [protected] volumes for all streams */
    private var _volumes : Array<Int>;
    /** @private [protected] total panning of all ancestors */
    private var _pan : Float;
    /** @private [protected] total mute flag of all ancestors */
    private var _mute : Bool;
    /** @private [protected] Pitch bend in half-tone unit. */
    private var _pitchBend : Float;
    
    /** @private [protected] parent container */
    private var _parent : SoundObjectContainer;
    /** @private [protected] the depth of parent-child chain */
    private var _childDepth : Int;
    /** @private [protected] volume of this sound object */
    private var _thisVolume : Float;
    /** @private [protected] panning of this sound object */
    private var _thisPan : Float;
    /** @private [protected] mute flag of this sound object */
    private var _thisMute : Bool;
    
    /** @private [protected] track id. This value is asigned when its created. */
    private var _trackID : Int;
    
    
    
    
    // properties
    //----------------------------------------
    /** SiONDriver instrance to operate. this returns null when driver is not created. */
    private function get_driver() : SiONDriver{return SiONDriver.mutex;
    }
    
    /** parent container. */
    private function get_parent() : SoundObjectContainer{return _parent;
    }
    
    /** is playing ? */
    private function get_isPlaying() : Bool{return (_track != null);
    }
    
    
    /** Base note of this sound */
    private function get_note() : Int{return _note;
    }
    private function set_note(n : Int) : Int{_note = n;
        return n;
    }
    
    /** Voice data to play */
    private function get_voice() : SiONVoice{
        return _synthesizer_voice;
    }
    private function set_voice(v : SiONVoice) : SiONVoice{
        _voiceReference.voice = v;
        if (!isPlaying)             _synthesizer = _voiceReference;
        return v;
    }
    
    /** Synthesizer to generate sound */
    private function get_synthesizer() : VoiceReference{
        return _synthesizer;
    }
    private function set_synthesizer(s : VoiceReference) : VoiceReference{
        if (isPlaying)             throw new Error("SoundObject: Synthesizer should not be changed during playing.");
        _synthesizer = s || _voiceReference;
        return s;
    }
    
    /** Sound length in 16th beat, 0 sets inifinity length. @default 0. */
    private function get_length() : Float{return _length;
    }
    private function set_length(l : Float) : Float{_length = l;
        return l;
    }
    
    /** Synchronizing quantizing, uint in 16th beat. (0:No synchronization, 1:sync.with 16th, 4:sync.with 4th). @default 0. */
    private function get_quantize() : Float{return _quantize;
    }
    private function set_quantize(q : Float) : Float{_quantize = q;
        return q;
    }
    
    /** Sound delay, uint in 16th beat. @default 0. */
    private function get_delay() : Float{return _delay;
    }
    private function set_delay(d : Float) : Float{_delay = d;
        return d;
    }
    
    
    
    /** Master coarse tuning, 1 for half-tone. */
    private function get_coarseTune() : Int{return _noteShift;
    }
    private function set_coarseTune(n : Int) : Int{
        _noteShift = n;
        if (_track != null)             _track.noteShift = _noteShift;
        return n;
    }
    /** Master fine tuning, 1 for half-tone, you can specify fineTune&lt;-1 or fineTune&gt;1. */
    private function get_fineTune() : Float{return _pitchShift * 0.015625;
    }
    private function set_fineTune(p : Float) : Float{
        _pitchShift = p;
        if (_track != null)             _track.pitchShift = _pitchShift * 64;
        return p;
    }
    /** Track gate time (0:Minimum - 1:Maximum). (value of 'q' command * 0.125) */
    private function get_gateTime() : Float{return _gateTime;
    }
    private function set_gateTime(g : Float) : Float{
        _gateTime = ((g < 0)) ? 0 : ((g > 1)) ? 1 : g;
        if (_track != null)             _track.quantRatio = _gateTime;
        return g;
    }
    /** Track event mask. (value of '&#64;mask' command) */
    private function get_eventMask() : Int{return _eventMask;
    }
    private function set_eventMask(m : Int) : Int{
        _eventMask = m;
        if (_track != null)             _track.eventMask = _eventMask;
        return m;
    }
    /** Track id */
    private function get_trackID() : Int{return _trackID;
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
    
    
    /** Channel mute, this property can control track after play(). */
    private function get_mute() : Bool{return _thisMute;
    }
    private function set_mute(m : Bool) : Bool{
        _thisMute = m;
        _updateMute();
        if (_track != null)             _track.channel.mute = _mute;
        return m;
    }
    /** Channel volume (0:Minimum - 1:Maximum), this property can control track after play(). */
    private function get_volume() : Float{return _thisVolume;
    }
    private function set_volume(v : Float) : Float{
        _thisVolume = v;
        _updateVolume();
        _limitVolume();
        _updateStreamSend(0, _volumes[0] * 0.0078125);
        return v;
    }
    /** Channel panning (-1:Left - 0:Center - +1:Right), this property can control track after play(). */
    private function get_pan() : Float{return _thisPan;
    }
    private function set_pan(p : Float) : Float{
        _thisPan = p;
        _updatePan();
        _limitPan();
        if (_track != null)             _track.channel.pan = _pan * 64;
        return p;
    }
    
    
    /** Channel effect send level for slot 1 (0:Minimum - 1:Maximum), this property can control track after play(). */
    private function get_effectSend1() : Float{return _volumes[1] * 0.0078125;
    }
    private function set_effectSend1(v : Float) : Float{
        v = ((v < 0)) ? 0 : ((v > 1)) ? 1 : v;
        _volumes[1] = v * 128;
        _updateStreamSend(1, v);
        return v;
    }
    /** Channel effect send level for slot 2 (0:Minimum - 1:Maximum), this property can control track after play(). */
    private function get_effectSend2() : Float{return _volumes[2] * 0.0078125;
    }
    private function set_effectSend2(v : Float) : Float{
        v = ((v < 0)) ? 0 : ((v > 1)) ? 1 : v;
        _volumes[2] = v * 128;
        _updateStreamSend(2, v);
        return v;
    }
    /** Channel effect send level for slot 3 (0:Minimum - 1:Maximum), this property can control track after play(). */
    private function get_effectSend3() : Float{return _volumes[3] * 0.0078125;
    }
    private function set_effectSend3(v : Float) : Float{
        v = ((v < 0)) ? 0 : ((v > 1)) ? 1 : v;
        _volumes[3] = v * 128;
        _updateStreamSend(3, v);
        return v;
    }
    /** Channel effect send level for slot 4 (0:Minimum - 1:Maximum), this property can control track after play(). */
    private function get_effectSend4() : Float{return _volumes[4] * 0.0078125;
    }
    private function set_effectSend4(v : Float) : Float{
        v = ((v < 0)) ? 0 : ((v > 1)) ? 1 : v;
        _volumes[4] = v * 128;
        _updateStreamSend(4, v);
        return v;
    }
    /** Channel pitch bend, 1 for halftone, this property can control track after play(). */
    private function get_pitchBend() : Float{return _pitchBend;
    }
    private function set_pitchBend(p : Float) : Float{
        _pitchBend = p;
        if (_track != null)             _track.pitchBend = p * 64;
        return p;
    }
    
    
    /** Array of SiEffectBase to modify this sound object's output. */
    private function get_effectors() : Array<Dynamic>{
        return ((_effectChain != null)) ? _effectChain.effectList : null;
    }
    private function set_effectors(effectList : Array<Dynamic>) : Array<Dynamic>{
        if (_effectChain != null) {
            _effectChain.effectList = effectList;
        }
        else {
            if (effectList != null && effectList.length > 0) {
                _effectChain = EffectChain.alloc(effectList);
            }
        }
        return effectList;
    }
    
    
    // counter to asign unique track id
    private static var _uniqueTrackID : Int = 0;
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor. */
    public function new(name : String = null, synth : VoiceReference = null)
    {
        super();
        this.name = name || "";
        _parent = null;
        _childDepth = 0;
        _voiceReference = new VoiceReference();
        _synthesizer = synth || _voiceReference;
        _effectChain = null;
        _track = null;
        _tracks = null;
        _fader = new Fader(null, 1);
        _volumes = new Array<Int>();
        _faderVolume = 1;
        
        _note = 60;
        _length = 0;
        _delay = 0;
        _quantize = 1;
        
        _volumes[0] = 64;
        for (i in 1...SiOPMModule.STREAM_SEND_SIZE){_volumes[i] = 0;
        }
        _pan = 0;
        _mute = false;
        _pitchBend = 0;
        
        _gateTime = 0.75;
        _noteShift = 0;
        _pitchShift = 0;
        _eventMask = 0;
        _eventTriggerID = 0;
        _noteTriggerFlags = 0;
        _listeningFlags = 0;
        
        _thisVolume = 0.5;
        _thisPan = 0;
        _thisMute = false;
        
        _trackID = (_uniqueTrackID & 0x7fff) | 0x8000;
        _uniqueTrackID++;
    }
    
    
    
    
    // settings
    //----------------------------------------
    /** Reset */
    public function reset() : Void
    {
        stop();
        
        _note = 60;
        _length = 0;
        _delay = 0;
        _quantize = 1;
        
        _fader.setFade(null, 1);
        _effectChain = null;
        _volumes[0] = 64;
        for (i in 1...SiOPMModule.STREAM_SEND_SIZE){_volumes[i] = 0;
        }
        _faderVolume = 1;
        _pan = 0;
        _mute = false;
        _pitchBend = 0;
        
        _gateTime = 0.75;
        _noteShift = 0;
        _pitchShift = 0;
        _eventMask = 0;
        _eventTriggerID = 0;
        _noteTriggerFlags = 0;
        _listeningFlags = 0;
        
        _thisVolume = 0.5;
        _thisPan = 0;
        _thisMute = false;
    }
    
    
    /** Set volume by index.
     *  @param slot streaming slot number.
     *  @param volume volume (0:Minimum - 1:Maximum).
     */
    public function setVolume(slot : Int, volume : Float) : Void
    {
        _volumes[slot] = ((volume < 0)) ? 0 : ((volume > 1)) ? 128 : (volume * 128);
    }
    
    
    /** Set fading in. 
     *  @param time fading time[sec].
     */
    public function fadeIn(time : Float) : Void
    {
        var drv : SiONDriver = driver;
        if (drv != null) {
            if (!_fader.isActive) {
                drv.addEventListener(SiONEvent.STREAM, _onStream);
                drvforceDispatchStreamEvent();
            }
            _fader.setFade(_fadeVolume, 0, 1, time * drv.sampleRate / drv.bufferLength);
        }
    }
    
    
    /** Set fading out.
     *  @param time fading time[sec].
     */
    public function fadeOut(time : Float) : Void
    {
        var drv : SiONDriver = driver;
        if (drv != null) {
            if (!_fader.isActive) {
                drv.addEventListener(SiONEvent.STREAM, _onStream);
                drvforceDispatchStreamEvent();
            }
            _fader.setFade(_fadeVolume, 1, 0, time * drv.sampleRate / drv.bufferLength);
        }
    }
    
    
    
    
    // operations
    //----------------------------------------
    /** Play sound. */
    public function play() : Void
    {
        stop();
        _track = _noteOn(_note, false);
        if (_track != null)             _synthesizer._registerTrack(_track);
    }
    
    
    /** Stop sound. */
    public function stop() : Void
    {
        if (_track != null) {
            _synthesizer._unregisterTracks(_track);
            _track.setDisposable();
            _track = null;
            _noteOff(-1, false);
        }
        _stopEffect();
    }
    
    
    
    
    // operations
    //----------------------------------------
    /** @private [protected] driver.noteOn.
     *  @param note playing note
     *  @param isDisposable disposable flag.
     *  @return playing track
     */
    private function _noteOn(note : Int, isDisposable : Bool) : SiMMLTrack
    {
        if (driver == null)             return null;
        var voice : SiONVoice = _synthesizer_voice;
        var topEC : EffectChain = _topEffectChain();
        var track : SiMMLTrack = driver.noteOn(note, voice, _length, _delay, _quantize, _trackID, isDisposable);
        _addNoteEventListeners();
        if (_effectChain != null) {
            _effectChain._activateLocalEffect(_childDepth);
            _effectChain.setAllStreamSendLevels(_volumes);
        }
        if (topEC != null) {
            track.channel.masterVolume = 128;
            track.channel.setStreamBuffer(0, topEC.streamingBuffer);
        }
        else {
            track.channel.setAllStreamSendLevels(_volumes);
        }
        track.channel.pan = _pan * 64;
        track.channel.mute = _mute;
        track.pitchBend = _pitchBend * 64;
        track.noteShift = _noteShift;
        track.pitchShift = _pitchShift * 64;
        if (voice != null && Math.isNaN(voice.defaultGateTime))             track.quantRatio = _gateTime;
        return track;
    }
    
    
    /** @private [protected] driver.noteOff()
     *  @param stopWithReset stop sound wit resetting channels process
     *  @return stopped track list
     */
    private function _noteOff(note : Int, stopWithReset : Bool = true) : Array<SiMMLTrack>
    {
        if (driver == null)             return null;
        _removeNoteEventListeners();
        //if (_effectChain) _effectChain._inactivateLocalEffect();
        return driver.noteOff(note, _trackID, _delay, _quantize, stopWithReset);
    }
    
    
    /** @private [protected] driver.sequenceOn()
     *  @param data sequence data
     *  @param isDisposable disposable flag
     *  @param applyLength
     *  @return vector of playing tracks
     */
    private function _sequenceOn(data : SiONData, isDisposable : Bool, applyLength : Bool = true) : Array<SiMMLTrack>
    {
        if (driver == null)             return null;
        var len : Float = ((applyLength)) ? _length : 0;
        var voice : SiONVoice = _synthesizer_voice;
        var topEC : EffectChain = _topEffectChain();
        var list : Array<SiMMLTrack> = driver.sequenceOn(data, voice, len, _delay, _quantize, _trackID, isDisposable);
        var track : SiMMLTrack;
        var ps : Int = _pitchShift * 64;
        var pb : Int = _pitchBend * 64;
        _addNoteEventListeners();
        if (_effectChain != null) {
            _effectChain._activateLocalEffect(_childDepth);
            _effectChain.setAllStreamSendLevels(_volumes);
        }
        for (track in list){
            if (topEC != null) {
                track.channel.masterVolume = 128;
                track.channel.setStreamBuffer(0, topEC.streamingBuffer);
            }
            else {
                track.channel.setAllStreamSendLevels(_volumes);
            }
            track.channel.pan = _pan * 64;
            track.channel.mute = _mute;
            track.pitchBend = pb;
            track.noteShift = _noteShift;
            track.pitchShift = ps;
            track.setEventTrigger(_eventTriggerID, _noteTriggerFlags & 3, _noteTriggerFlags >> 2);
            if (voice != null && Math.isNaN(voice.defaultGateTime))                 track.quantRatio = _gateTime;
        }
        return list;
    }
    
    
    /** @private [protected] driver.sequenceOff()
     *  @param stopWithReset stop sound wit resetting channels process
     *  @return stopped track list
     */
    private function _sequenceOff(stopWithReset : Bool = true) : Array<SiMMLTrack>
    {
        if (driver == null)             return null;
        _removeNoteEventListeners();
        //if (_effectChain) _effectChain._inactivateLocalEffect();
        return driver.sequenceOff(_trackID, 0, _quantize, stopWithReset);
    }
    
    
    /** @private [protected] free effect chain if the effect list is empty */
    private function _stopEffect() : Void
    {
        if (_effectChain != null && _effectChain.effectList.length == 0) {
            _effectChain.free();
            _effectChain = null;
        }
    }
    
    
    /** @private [protected] update stream send level */
    private function _updateStreamSend(streamNum : Int, level : Float) : Void{
        if (_track != null) {
            if (_effectChain != null)                 _effectChain.setStreamSend(streamNum, level)
            else _track.channel.setStreamSend(streamNum, level);
        }
    }
    
    
    /** @private [protected] add event trigger listeners */
    private function _addNoteEventListeners() : Void{
        if (_listeningFlags != 0)             return;
        var drv : SiONDriver = driver;
        _noteTriggerFlags = 0;
        if (hasEventListener(SoundObjectEvent.NOTE_ON_FRAME)) {
            drv.addEventListener(SiONTrackEvent.NOTE_ON_FRAME, _onTrackEvent);
            _noteTriggerFlags |= 1;
        }
        if (hasEventListener(SoundObjectEvent.NOTE_ON_STREAM)) {
            drv.addEventListener(SiONTrackEvent.NOTE_ON_STREAM, _onTrackEvent);
            _noteTriggerFlags |= 2;
        }
        if (hasEventListener(SoundObjectEvent.NOTE_OFF_FRAME)) {
            drv.addEventListener(SiONTrackEvent.NOTE_OFF_FRAME, _onTrackEvent);
            _noteTriggerFlags |= 4;
        }
        if (hasEventListener(SoundObjectEvent.NOTE_OFF_STREAM)) {
            drv.addEventListener(SiONTrackEvent.NOTE_OFF_STREAM, _onTrackEvent);
            _noteTriggerFlags |= 8;
        }
        _listeningFlags = _noteTriggerFlags;
    }
    
    
    /** @private [protected] remove event trigger listeners */
    private function _removeNoteEventListeners() : Void{
        if (_listeningFlags == 0)             return;
        var drv : SiONDriver = driver;
        if ((_listeningFlags & 1) != 0)             drv.removeEventListener(SiONTrackEvent.NOTE_ON_FRAME, _onTrackEvent);
        if ((_listeningFlags & 2) != 0)             drv.removeEventListener(SiONTrackEvent.NOTE_ON_STREAM, _onTrackEvent);
        if ((_listeningFlags & 4) != 0)             drv.removeEventListener(SiONTrackEvent.NOTE_OFF_FRAME, _onTrackEvent);
        if ((_listeningFlags & 8) != 0)             drv.removeEventListener(SiONTrackEvent.NOTE_OFF_STREAM, _onTrackEvent);
        _listeningFlags = 0;
    }
    
    
    /** @private [protected] handler for note event */
    private function _onTrackEvent(e : SiONTrackEvent) : Void{
        if (e.track.trackID == _trackID) {
            dispatchEvent(new SoundObjectEvent(e.type, this, e));
        }
    }
    
    
    
    // internals
    //----------------------------------------
    // top effect chain
    private function _topEffectChain() : EffectChain
    {
        return _effectChain || (((_parent != null)) ? _parent._topEffectChain() : null);
    }
    
    
    /** @private [internal use] */
    @:allow(org.si.sound)
    private function _setParent(parent : SoundObjectContainer) : Void
    {
        if (_parent != null)             _parent.removeChild(this);
        _parent = parent;
        _updateChildDepth();
        _updateMute();
        _updateVolume();
        _limitVolume();
        _updatePan();
        _limitPan();
    }
    
    
    /** @private [internal use] */
    @:allow(org.si.sound)
    private function _updateChildDepth() : Void
    {
        _childDepth = ((parent != null)) ? (parent._childDepth + 1) : 0;
    }
    
    
    /** @private [internal use] */
    @:allow(org.si.sound)
    private function _updateMute() : Void
    {
        if (_parent != null)             _mute = _parent._mute || _thisMute
        else _mute = _thisMute;
    }
    
    
    /** @private [internal use] */
    @:allow(org.si.sound)
    private function _updateVolume() : Void
    {
        if (_parent != null)             _volumes[0] = _parent._volumes[0] * _thisVolume * _faderVolume
        else _volumes[0] = _thisVolume * _faderVolume * 128;
    }
    
    
    /** @private [internal use] */
    @:allow(org.si.sound)
    private function _limitVolume() : Void
    {
        if (_volumes[0] < 0)             _volumes[0] = 0
        else if (_volumes[0] > 128)             _volumes[0] = 128;
    }
    
    
    /** @private [internal use] */
    @:allow(org.si.sound)
    private function _updatePan() : Void
    {
        if (_parent != null)             _pan = (_parent._pan + _thisPan) * 0.5
        else _pan = _thisPan;
    }
    
    
    /** @private [internal use] */
    @:allow(org.si.sound)
    private function _limitPan() : Void
    {
        if (_pan < -1)             _pan = -1
        else if (_pan > 1)             _pan = 1;
    }
    
    
    /** @private [protected] Handler for SiONEvent.STREAM */
    private function _onStream(e : SiONEvent) : Void
    {
        if (_fader.execute()) {
            driver.removeEventListener(SiONEvent.STREAM, _onStream);
            driverforceDispatchStreamEvent(false);
        }
    }
    
    
    /** @private [protected] call from fader */
    private function _fadeVolume(v : Float) : Void
    {
        _faderVolume = v;
        _updateVolume();
        _updateStreamSend(0, _volumes[0] * 0.0078125);
    }
    
    
    /** @private [protected] on enter frame */
    private function _onEnterFrame(seq : Sequencer) : Void
    {
        if (hasEventListener("soundObjectEnterFrame")) {
            var event : SoundObjectEvent = new SoundObjectEvent("soundObjectEnterFrame", this, null);
            event._note = note;
            event._eventTriggerID = _eventTriggerID;
            dispatchEvent(event);
        }
    }
    
    
    /** @private [protected] on enter segment */
    private function _onEnterSegment(seq : Sequencer) : Void
    {
        if (hasEventListener("soundObjectEnterSegment")) {
            var event : SoundObjectEvent = new SoundObjectEvent("soundObjectEnterSegment", this, null);
            event._eventTriggerID = _eventTriggerID;
            dispatchEvent(event);
        }
    }
    
    
    
    
    // errors
    //----------------------------------------
    /** @private [protected] not available */
    private function _errorNotAvailable(str : String) : Error
    {
        return new Error("SoundObject; " + str + " method is not available in this object.");
    }
    
    
    /** @private [protected] Cannot change */
    private function _errorCannotChange(str : String) : Error
    {
        return new Error("SoundObject; You can not change " + str + " property in this object.");
    }
}



