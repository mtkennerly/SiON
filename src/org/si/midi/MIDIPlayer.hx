//----------------------------------------------------------------------------------------------------
// MIDI file player class
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.midi;

import org.si.midi.Event;
import org.si.midi.SMFData;
import org.si.midi.SiONDriver;
import org.si.midi.SiONEvent;
import org.si.midi.URLRequest;

import openfl.events.*;
import openfl.net.*;
import org.si.sion.*;
import org.si.sion.midi.*;
import org.si.sion.events.*;


/** MIDI player */
class MIDIPlayer
{
    public static var position(get, set) : Float;
    public var volume(get, set) : Float;
    public static var tempo(get, never) : Float;
    public static var cpuLoading(get, never) : Float;
    public static var isPaused(get, never) : Bool;
    public static var isPlaying(get, never) : Bool;
    public static var driver(get, never) : SiONDriver;

    // variables
    //----------------------------------------
    private static var _cache : Dynamic = { };
    private static var _driver : SiONDriver = null;
    private static var _nextData : SMFData = null;
    private static var _fadeOut : Bool = false;
    
    
    
    // properties
    //----------------------------------------
    /** Playing position [sec] */
    private static function get_position() : Float{return driver.position * 0.001;
    }
    private static function set_position(pos : Float) : Float{driver.position = pos * 1000;
        return pos;
    }
    
    /** Playing volume [0-1] */
    private function get_volume() : Float{return driver.volume;
    }
    private function set_volume(v : Float) : Float{driver.volume = v;
        return v;
    }
    
    
    /** tempo */
    private static function get_tempo() : Float{return driver.bpm;
    }
    
    /** CPU loading [%] */
    private static function get_cpuLoading() : Float{return driver.processTime * 0.1;
    }
    
    /** Is paused ? */
    private static function get_isPaused() : Bool{return driver.isPaused;
    }
    
    /** Is playing ? */
    private static function get_isPlaying() : Bool{return driver.isPlaying;
    }
    
    
    /** SiON driver to play */
    private static function get_driver() : SiONDriver{
        if (_driver == null) {
            _driver = SiONDriver.mutex || new SiONDriver(4096);
        }
        return _driver;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** @private */
    public function new()
    {
    }
    
    
    
    
    // operations
    //----------------------------------------
    /** play MIDI file
     *  @param url MIDI file's URL
     *  @param fadeInTime fade in time [second]
     *  @return SMFData object to play
     */
    public static function play(url : String, fadeInTime : Float = 0) : SMFData
    {
        var smfData : SMFData = load(url);
        if (smfData.isAvailable)             _play(smfData)
        else smfData.addEventListener(Event.COMPLETE, _waitAndPlay);
        driver.fadeIn(fadeInTime);
        return smfData;
    }
    
    
    /** stop
     *  @param fadeOutTime fade out time [second]
     */
    public static function stop(fadeOutTime : Float = 0) : Void
    {
        if (fadeOutTime > 0) {
            _fadeOut = true;
            driver.fadeOut(fadeOutTime);
            driver.addEventListener(SiONEvent.FADE_OUT_COMPLETE, _stopWithFadeOut);
        }
        else {
            driver.stop();
        }
    }
    
    
    /** pause
     *  @param fadeOutTime fade out time [second]
     */
    public static function pause(fadeOutTime : Float = 0) : Void
    {
        if (fadeOutTime > 0) {
            driver.fadeOut(fadeOutTime);
            driver.addEventListener(SiONEvent.FADE_OUT_COMPLETE, _pauseWithFadeOut);
        }
        else {
            driver.pause();
        }
    }
    
    
    /** resume pausing
     *  @param fadeInTime fade in time [second]
     */
    public static function resume(fadeInTime : Float = 0) : Void
    {
        if (fadeInTime > 0)             driver.fadeIn(fadeInTime);
        driver.resume();
    }
    
    
    /** load MIDI file without sounding 
     *  @param url MIDI file's URL
     *  @return SMFData object to load
     */
    public static function load(url : String) : SMFData
    {
        var smfData : SMFData = Reflect.field(_cache, url);
        if (smfData == null) {
            smfData = new SMFData();
            smfData.load(new URLRequest(url));
            Reflect.setField(_cache, url, smfData);
        }
        return smfData;
    }
    
    
    
    
    // handler
    //----------------------------------------
    private static function _play(smfData : SMFData) : Void
    {
        if (isPlaying && _fadeOut) {
            _nextData = smfData;
            driver.addEventListener(SiONEvent.STREAM_STOP, _playNextData);
        }
        else {
            driver.play(smfData);
        }
    }
    
    
    private static function _waitAndPlay(e : Event) : Void
    {
        _play(cast((e.target), SMFData));
    }
    
    
    private static function _pauseWithFadeOut(e : SiONEvent) : Void
    {
        driver.removeEventListener(SiONEvent.FADE_OUT_COMPLETE, _pauseWithFadeOut);
        driver.pause();
    }
    
    
    private static function _stopWithFadeOut(e : SiONEvent) : Void
    {
        _fadeOut = false;
        driver.removeEventListener(SiONEvent.FADE_OUT_COMPLETE, _stopWithFadeOut);
        driver.stop();
    }
    
    
    private static function _playNextData(e : SiONEvent) : Void
    {
        driver.removeEventListener(SiONEvent.STREAM_STOP, _playNextData);
        if (_nextData.isAvailable)             _play(_nextData)
        else _nextData.addEventListener(Event.COMPLETE, _waitAndPlay);
        _nextData = null;
    }
}


