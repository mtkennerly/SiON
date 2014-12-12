//----------------------------------------------------------------------------------------------------
// Flash Media Sound player class
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound;

import openfl.errors.Error;
import org.si.sound.Event;
import org.si.sound.FlashSoundPlayerEvent;
import org.si.sound.IOErrorEvent;
import org.si.sound.PatternSequencer;
import org.si.sound.ProgressEvent;
import org.si.sound.SamplerSynth;
import org.si.sound.SiONVoice;
import org.si.sound.Sound;
import org.si.sound.SoundLoaderContext;
import org.si.sound.URLRequest;
import org.si.sound.VoiceReference;

import openfl.events.Event;
import openfl.events.ProgressEvent;
import openfl.events.IOErrorEvent;
import openfl.net.URLRequest;
import openfl.media.Sound;
import openfl.media.SoundLoaderContext;
import org.si.sion.*;
//import org.si.sion.sequencer.base.*;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sound.synthesizers.*;
import org.si.sound.events.FlashSoundPlayerEvent;




/** @eventType flash.events.Event */
@:meta(Event(name="fspComplete",type="org.si.sound.events.FlashSoundPlayerEvent"))

/** @eventType flash.events.Event */
@:meta(Event(name="open",type="flash.events.Event"))

/** @eventType flash.events.Event */
@:meta(Event(name="id3",type="flash.events.Event"))

/** @eventType flash.events.IOErrorEvent */
@:meta(Event(name="ioError",type="flash.events.IOErrorEvent"))

/** @eventType flash.events.ProgressEvent */
@:meta(Event(name="progress",type="flash.events.ProgressEvent"))



/** FlashSoundPlayer provides advanced operations of Sound class (in flash media package). */
class FlashSoundPlayer extends PatternSequencer
{
    public var soundData(get, set) : Sound;
    public var isSoundDataAvailable(get, never) : Bool;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    /** @private [protected] sound instance to play */
    private var _soundData : Sound = null;
    
    /** @private [protected] is sound data available to play ? */
    private var _isSoundDataAvailable : Bool;
    
    /** @private [protected] synthsizer to play sound */
    private var _flashSoundOperator : SamplerSynth;
    
    /** @private [protected] playing mode, 0=stopped, 1=wait for loading, 2=play as single note, 3=play by pattern sequencer */
    private var _playingMode : Int;
    
    /** @private [protected] waiting loading event count */
    private var _createdEventCount : Int;
    
    /** @private [protected] completed loading event count */
    private var _completedEventCount : Int;
    
    
    
    // properties
    //----------------------------------------
    /** the Sequencer instance belonging to this PatternSequencer, where the sequence pattern appears. */
    private function get_soundData() : Sound{return _soundData;
    }
    private function set_soundData(s : Sound) : Sound{
        _soundData = s;
        if (_soundData == null || (_soundData.bytesTotal > 0 && _soundData.bytesLoaded == _soundData.bytesTotal))             _setSoundData(_soundData)
        else _addLoadingJob(_soundData);
        return s;
    }
    
    /** is playing ? */
    override private function get_isPlaying() : Bool{return (_playingMode != 0);
    }
    
    /** is sound data available to play ? */
    private function get_isSoundDataAvailable() : Bool{return _isSoundDataAvailable;
    }
    
    
    /** Voice data to play, You cannot change the voice of this sound object. */
    override private function get_voice() : SiONVoice{return _synthesizer_voice;
    }
    override private function set_voice(v : SiONVoice) : SiONVoice{
        throw new Error("FlashSoundPlayer; You cannot change voice of this sound object.");
        return v;
    }
    
    
    /** Synthesizer to generate sound, You cannot change the synthesizer of this sound object */
    override private function get_synthesizer() : VoiceReference{return _synthesizer;
    }
    override private function set_synthesizer(s : VoiceReference) : VoiceReference{
        throw new Error("FlashSoundPlayer; You cannot change synthesizer of this sound object.");
        return s;
    }
    
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor 
     *  @param soundData flash.media.Sound instance to control.
     */
    public function new(soundData : Sound = null)
    {
        super(68, 128, 0);
        name = "FlashSoundPlayer";
        _isSoundDataAvailable = false;
        _playingMode = 0;
        _flashSoundOperator = new SamplerSynth();
        _synthesizer = _flashSoundOperator;
        _createdEventCount = 0;
        _completedEventCount = 0;
        this.soundData = soundData;
    }
    
    
    
    
    // operations
    //----------------------------------------
    /** start sequence */
    override public function play() : Void
    {
        _playingMode = 1;
        if (_isSoundDataAvailable)             _playSound();
    }
    
    
    /** stop sequence */
    override public function stop() : Void
    {
        switch (_playingMode)
        {
            case 2:
                if (_track) {
                    _synthesizer._unregisterTracks(_track);
                    _track.setDisposable();
                    _track = null;
                    _noteOff(-1, false);
                }
                _stopEffect();
            case 3:
                super.stop();
        }
        _playingMode = 0;
    }
    
    
    /** load sound from url, this method is the simplificaion of setSoundData(new Sound(url, context)).
     *  @private url same as Sound.load
     *  @private context same as Sound.load
     */
    public function load(url : URLRequest, context : SoundLoaderContext = null) : Void
    {
        _soundData = new Sound(url, context);
        _addLoadingJob(_soundData);
    }
    
    
    /** Set flash sound instance with key range.
     *  @param sound Sound instance to assign
     *  @param keyRangeFrom Assigning key range starts from
     *  @param keyRangeTo Assigning key range ends at. -1 to set only at the key of argument "keyRangeFrom".
     *  @param startPoint slicing point to start data.
     *  @param endPoint slicing point to end data. The negative value plays whole data.
     *  @param loopPoint slicing point to repeat data. -1 means no repeat
     */
    public function setSoundData(sound : Sound, keyRangeFrom : Int = 0, keyRangeTo : Int = 127, startPoint : Int = 0, endPoint : Int = -1, loopPoint : Int = -1) : Void
    {
        if (sound.bytesLoaded == sound.bytesTotal)             _setSoundData(sound, keyRangeFrom, keyRangeTo, startPoint, endPoint, loopPoint)
        else _addLoadingJob(sound, keyRangeFrom, keyRangeTo, startPoint, endPoint, loopPoint);
    }
    
    
    
    
    // internal
    //----------------------------------------
    private function _setSoundData(sound : Sound, keyRangeFrom : Int = 0, keyRangeTo : Int = 127, startPoint : Int = 0, endPoint : Int = -1, loopPoint : Int = -1) : Void
    {
        _isSoundDataAvailable = true;
        _flashSoundOperator.setSample(sound, false, keyRangeFrom, keyRangeTo).substring(startPoint, endPoint, loopPoint);
        if (_createdEventCount == _completedEventCount && _playingMode == 1)             _playSound();
    }
    
    
    private function _playSound() : Void
    {
        if (_sequencer.pattern != null) {
            // play by PatternSequencer
            _playingMode = 3;
            super.play();
        }
        else {
            // play as single note
            _playingMode = 2;
            stop();
            _track = _noteOn(_note, false);
            if (_track)                 _synthesizer._registerTrack(_track);
        }
    }
    
    
    private function _addLoadingJob(sound : Sound, keyRangeFrom : Int = 0, keyRangeTo : Int = 127, startPoint : Int = 0, endPoint : Int = -1, loopPoint : Int = -1) : Void
    {
        var event : FlashSoundPlayerEvent = new FlashSoundPlayerEvent(sound, _onComplete, _onError, keyRangeFrom, keyRangeTo, startPoint, endPoint, loopPoint);
        _createdEventCount++;
        sound.addEventListener(Event.ID3, _onID3);
        sound.addEventListener(Event.OPEN, _onOpen);
        sound.addEventListener(ProgressEvent.PROGRESS, _onProgress);
    }
    
    
    private function _removeAllEventListeners(event : FlashSoundPlayerEvent) : Void
    {
        _completedEventCount++;
        event._sound.removeEventListener(Event.ID3, _onID3);
        event._sound.removeEventListener(Event.OPEN, _onOpen);
        event._sound.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
    }
    
    
    private function _onComplete(event : FlashSoundPlayerEvent) : Void
    {
        _removeAllEventListeners(event);
        dispatchEvent(event);
        _setSoundData(event._sound, event._keyRangeFrom, event._keyRangeTo, event._startPoint, event._endPoint, event._loopPoint);
    }
    
    
    private function _onError(event : FlashSoundPlayerEvent) : Void
    {
        _removeAllEventListeners(event);
        dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "IOError during loading Sound."));
    }
    
    
    private function _onID3(event : Event) : Void
    {
        dispatchEvent(new Event(Event.ID3));
    }
    
    
    private function _onOpen(event : Event) : Void
    {
        dispatchEvent(new Event(Event.OPEN));
    }
    
    
    private function _onProgress(event : ProgressEvent) : Void
    {
        dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _completedEventCount, _createdEventCount));
    }
}


