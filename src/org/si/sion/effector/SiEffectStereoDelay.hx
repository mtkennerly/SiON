//----------------------------------------------------------------------------------------------------
// SiOPM effect stereo long delay
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;


/** Stereo long delay effector. The delay time is from 1[ms] to about 1.5[sec]. */
class SiEffectStereoDelay extends SiEffectBase
{
    // variables
    //------------------------------------------------------------
    private static inline var DELAY_BUFFER_BITS : Int = 16;
    private static var DELAY_BUFFER_FILTER : Int = (1 << DELAY_BUFFER_BITS) - 1;
    
    private var _delayBuffer : Array<Array<Float>>;
    private var _pointerRead : Int;
    private var _pointerWrite : Int;
    private var _feedback : Float;
    private var _readBufferL : Array<Float>;
    private var _readBufferR : Array<Float>;
    private var _wet : Float;
    
    
    
    
    // constructor
    //------------------------------------------------------------
    /** constructor 
     *  @param delayTime delay time[ms]. maximum value is about 1500.
     *  @param feedback feedback decay(-1-1). Negative value to invert phase.
     *  @param isCross stereo crossing delay.
     *  @param wet mixing level(0-1).
     */
    public function new(delayTime : Float = 250, feedback : Float = 0.25, isCross : Bool = false, wet : Float = 0.25)
    {
        super();
        _delayBuffer = new Array<Array<Float>>();
        _delayBuffer[0] = new Array<Float>();
        _delayBuffer[1] = new Array<Float>();
        setParameters(delayTime, feedback, isCross, wet);
    }
    
    
    
    
    // operation
    //------------------------------------------------------------
    /** set parameters
     *  @param delayTime delay time[ms]. maximum value is about 1500.
     *  @param feedback feedback decay(-1-1). Negative value to invert phase.
     *  @param isCross stereo crossing delay.
     *  @param wet mixing level(0-1).
     */
    public function setParameters(delayTime : Float = 250, feedback : Float = 0.25, isCross : Bool = false, wet : Float = 0.25) : Void
    {
        var offset : Int = Math.floor(delayTime * 44.1);
        var cross : Int = ((isCross)) ? 1 : 0;
        if (offset > DELAY_BUFFER_FILTER)             offset = DELAY_BUFFER_FILTER;
        _pointerWrite = (_pointerRead + offset) & DELAY_BUFFER_FILTER;
        _feedback = ((feedback >= 1)) ? 0.9990234375 : ((feedback <= -1)) ? -0.9990234375 : feedback;
        _readBufferL = _delayBuffer[cross];
        _readBufferR = _delayBuffer[1 - cross];
        _wet = wet;
    }
    
    
    
    
    // overrided funcitons
    //------------------------------------------------------------
    /** @private */
    override public function initialize() : Void
    {
        setParameters();
    }
    
    
    /** @private */
    override public function mmlCallback(args : Array<Float>) : Void
    {
        setParameters(((!Math.isNaN(args[0]))) ? args[0] : 250,
                ((!Math.isNaN(args[1]))) ? (args[1] * 0.01) : 0.25,
                (args[2] == 1),
                ((!Math.isNaN(args[3]))) ? (args[3] * 0.01) : 1);
    }
    
    
    /** @private */
    override public function prepareProcess() : Int
    {
        var i : Int;
        var imax : Int = 1 << DELAY_BUFFER_BITS;
        var buf0 : Array<Float> = _delayBuffer[0];
        var buf1 : Array<Float> = _delayBuffer[1];
        for (i in 0...imax) {
            buf0[i] = buf1[i] = 0;
        }
        return 2;
    }
    
    
    /** @private */
    override public function process(channels : Int, buffer : Array<Float>, startIndex : Int, length : Int) : Int
    {
        startIndex <<= 1;
        length <<= 1;
        var i : Int;
        var n : Float;
        var imax : Int = startIndex + length;
        var writeBufferL : Array<Float> = _delayBuffer[0];
        var writeBufferR : Array<Float> = _delayBuffer[1];
        var dry : Float = 1 - _wet;
        i = startIndex;
        while (i < imax){
            n = _readBufferL[_pointerRead];
            writeBufferL[_pointerWrite] = buffer[i] - n * _feedback;
            buffer[i] *= dry;
            buffer[i] += n * _wet;i++;
            n = _readBufferR[_pointerRead];
            writeBufferR[_pointerWrite] = buffer[i] - n * _feedback;
            buffer[i] *= dry;
            buffer[i] += n * _wet;i++;
            _pointerWrite = (_pointerWrite + 1) & DELAY_BUFFER_FILTER;
            _pointerRead = (_pointerRead + 1) & DELAY_BUFFER_FILTER;
        }
        return channels;
    }
}


