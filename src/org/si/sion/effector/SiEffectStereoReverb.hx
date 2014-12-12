//----------------------------------------------------------------------------------------------------
// SiOPM effect stereo reverb
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;


/** Stereo reverb effector. */
class SiEffectStereoReverb extends SiEffectBase
{
    // variables
    //------------------------------------------------------------
    private static inline var DELAY_BUFFER_BITS : Int = 13;
    private static var DELAY_BUFFER_FILTER : Int = (1 << DELAY_BUFFER_BITS) - 1;
    
    private var _delayBufferL : Array<Float>;private var _delayBufferR : Array<Float>;
    private var _pointerRead0 : Int;private var _pointerRead1 : Int;private var _pointerRead2 : Int;
    private var _pointerWrite : Int;
    private var _feedback0 : Float;private var _feedback1 : Float;private var _feedback2 : Float;
    private var _wet : Float;
    
    
    
    
    // constructor
    //------------------------------------------------------------
    /** constructor
     *  @param delay1 long delay(0-1).
     *  @param delay2 short delay(0-1).
     *  @param feedback feedback decay(-1-1). Negative value to invert phase.
     *  @param wet mixing level(0-1).
     */
    public function new(delay1 : Float = 0.7, delay2 : Float = 0.4, feedback : Float = 0.8, wet : Float = 0.3)
    {
        super();
        _delayBufferL = new Array<Float>();
        _delayBufferR = new Array<Float>();
        setParameters(delay1, delay2, feedback, wet);
    }
    
    
    
    
    // operation
    //------------------------------------------------------------
    /** set parameters
     *  @param delay1 long delay(0-1).
     *  @param delay2 short delay(0-1).
     *  @param feedback feedback decay(-1-1). Negative value to invert phase.
     *  @param wet mixing level(0-1).
     */
    public function setParameters(delay1 : Float = 0.7, delay2 : Float = 0.4, feedback : Float = 0.8, wet : Float = 0.3) : Void
    {
        if (delay1 < 0.01)             delay1 = 0.01
        else if (delay1 > 0.99)             delay1 = 0.99;
        if (delay2 < 0.01)             delay2 = 0.01
        else if (delay2 > 0.99)             delay2 = 0.99;
        _pointerWrite = (_pointerRead0 + DELAY_BUFFER_FILTER) & DELAY_BUFFER_FILTER;
        _pointerRead1 = Math.floor(_pointerRead0 + DELAY_BUFFER_FILTER * (1 - delay1)) & DELAY_BUFFER_FILTER;
        _pointerRead2 = Math.floor(_pointerRead0 + DELAY_BUFFER_FILTER * (1 - delay2)) & DELAY_BUFFER_FILTER;
        if (feedback > 0.99)             feedback = 0.99
        else if (feedback < -0.99)             feedback = -0.99;
        _feedback0 = feedback * 0.2;
        _feedback1 = feedback * 0.3;
        _feedback2 = feedback * 0.5;
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
        setParameters(((!Math.isNaN(args[0]))) ? (args[0] * 0.01) : 0.7,
                ((!Math.isNaN(args[1]))) ? (args[1] * 0.01) : 0.4,
                ((!Math.isNaN(args[2]))) ? (args[2] * 0.01) : 0.8,
                ((!Math.isNaN(args[3]))) ? (args[3] * 0.01) : 1);
    }
    
    
    /** @private */
    override public function prepareProcess() : Int
    {
        var i : Int;
        var imax : Int = 1 << DELAY_BUFFER_BITS;
        for (i in 0...imax) {
            _delayBufferL[i] = _delayBufferR[i] = 0;
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
        var m : Float;
        var imax : Int = startIndex + length;
        var dry : Float = 1 - _wet;
        i = startIndex;
        while (i < imax){
            n = _delayBufferL[_pointerRead0] * _feedback0;
            n += _delayBufferL[_pointerRead1] * _feedback1;
            n += _delayBufferL[_pointerRead2] * _feedback2;
            _delayBufferL[_pointerWrite] = buffer[i] - n;
            buffer[i] *= dry;
            buffer[i] += n * _wet;i++;
            n = _delayBufferR[_pointerRead0] * _feedback0;
            n += _delayBufferR[_pointerRead1] * _feedback1;
            n += _delayBufferR[_pointerRead2] * _feedback2;
            _delayBufferR[_pointerWrite] = buffer[i] - n;
            buffer[i] *= dry;
            buffer[i] += n * _wet;i++;
            _pointerWrite = (_pointerWrite + 1) & DELAY_BUFFER_FILTER;
            _pointerRead0 = (_pointerRead0 + 1) & DELAY_BUFFER_FILTER;
            _pointerRead1 = (_pointerRead1 + 1) & DELAY_BUFFER_FILTER;
            _pointerRead2 = (_pointerRead2 + 1) & DELAY_BUFFER_FILTER;
        }
        return channels;
    }
}


