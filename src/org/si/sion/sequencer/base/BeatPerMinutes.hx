//----------------------------------------------------------------------------------------------------
// Beat per minutes data
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.base;


/** Beat per minutes class, Calculates BPM-releated numbers automatically. */
class BeatPerMinutes
{
    public var bpm(get, never) : Float;
    public var sampleRate(get, never) : Int;

    /** 16th beat per sample */
    public var beat16PerSample : Float;
    /** sample per 16th beat */
    public var samplePerBeat16 : Float;
    /** tick per sample */
    public var tickPerSample : Float;
    /** @private [internal] sample per tick in FIXED unit. */
    @:allow(org.si.sion.sequencer.base)
    private var _samplePerTick : Float;
    // beat per minutes
    private var _bpm : Float = 0;
    // sample rate
    private var _sampleRate : Int = 0;
    // tick resolution
    private var _resolution : Int;
    
    
    /** beat per minute. */
    private function get_bpm() : Float{
        return _bpm;
    }
    
    /** sampling rate */
    private function get_sampleRate() : Int{
        return _sampleRate;
    }
    
    
    /** constructor. */
    public function new(bpm : Float, sampleRate : Int, resolution : Int = 1920)
    {
        _resolution = resolution;
        update(bpm, sampleRate);
    }
    
    
    /** update */
    public function update(beatPerMinutes : Float, sampleRate : Int) : Bool{
        if (beatPerMinutes < 1)             beatPerMinutes = 1
        else if (beatPerMinutes > 511)             beatPerMinutes = 511;
        if (beatPerMinutes != _bpm || sampleRate != _sampleRate) {
            _bpm = beatPerMinutes;
            _sampleRate = sampleRate;
            tickPerSample = _resolution * _bpm / (_sampleRate * 240);
            beat16PerSample = _bpm / (_sampleRate * 15);  // 60/4  
            samplePerBeat16 = 1 / beat16PerSample;
            _samplePerTick = Math.floor((1 / tickPerSample) * (1 << MMLSequencer.FIXED_BITS));
            return true;
        }
        return false;
    }
}



