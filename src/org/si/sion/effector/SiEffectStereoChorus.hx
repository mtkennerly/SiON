//----------------------------------------------------------------------------------------------------
// SiOPM effect stereo chorus
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;

import openfl.errors.Error;

/** Stereo chorus effector. */
class SiEffectStereoChorus extends SiEffectBase
{
    // variables
    //------------------------------------------------------------
    private static inline var DELAY_BUFFER_BITS : Int = 12;
    private static var DELAY_BUFFER_FILTER : Int = (1 << DELAY_BUFFER_BITS) - 1;
    
    private var _delayBufferL : Array<Float>;private var _delayBufferR : Array<Float>;
    private var _pointerRead : Int;
    private var _pointerWrite : Int;
    private var _feedback : Float;
    private var _depth : Float;
    private var _wet : Float;
    
    private var _lfoPhase : Int;
    private var _lfoStep : Int;
    private var _lfoResidueStep : Int;
    private var _phaseInvert : Int;
    private var _phaseTable : Array<Int>;
    
    
    
    
    // constructor
    //------------------------------------------------------------
    /** constructor.
     *  @param delayTime delay time[ms]. maximum value is about 94.
     *  @param feedback feedback ratio(0-1).
     *  @param frequency frequency of chorus[Hz].
     *  @param depth depth of chorus.
     *  @param wet wet mixing level(0-1).
     */
    public function new(delayTime : Float = 20, feedback : Float = 0.2, frequency : Float = 4, depth : Float = 20, wet : Float = 0.5, invertPhase : Bool = true)
    {
        super();
        _delayBufferL = new Array<Float>();
        _delayBufferR = new Array<Float>();
        _phaseTable = new Array<Int>();
        
        _lfoPhase = 0;
        _lfoResidueStep = 0;
        _pointerRead = 0;
        setParameters(delayTime, feedback, frequency, depth, wet, invertPhase);
    }
    
    
    
    
    // operation
    //------------------------------------------------------------
    /** set parameter
     *  @param delayTime delay time[ms]. maximum value is about 94.
     *  @param feedback feedback ratio(0-1).
     *  @param frequency frequency of chorus[Hz].
     *  @param depth depth of chorus.
     *  @param wet wet mixing level(0-1).
     */
    public function setParameters(delayTime : Float = 20, feedback : Float = 0.2, frequency : Float = 4, depth : Float = 20, wet : Float = 0.5, invertPhase : Bool = true) : Void{
        if (frequency == 0 || depth == 0 || delayTime == 0)             throw new Error("SiEffectStereoChorus; frequency, depth or delay should not be 0.");
        var offset : Int = Math.floor(delayTime * 44.1);
        var tableSize : Int;
        var i : Int;
        var p : Float;
        var dp : Float;
        if (offset > DELAY_BUFFER_FILTER)             offset = DELAY_BUFFER_FILTER;
        _pointerWrite = (_pointerRead + offset) & DELAY_BUFFER_FILTER;
        _feedback = ((feedback >= 1)) ? 0.9990234375 : ((feedback <= -1)) ? -0.9990234375 : feedback;
        _depth = ((depth >= offset - 4)) ? (offset - 4) : depth;
        tableSize = Math.floor(_depth * 6.283185307179586);
        if (tableSize * frequency > 11025)  tableSize = Math.floor(11025 / frequency);
        if (_phaseTable.length > tableSize) _phaseTable.splice(tableSize, _phaseTable.length - tableSize);
        dp = 6.283185307179586 / tableSize;
        i = 0;
        p = 0;
        while (i < tableSize) {
            _phaseTable[i] = Math.floor(Math.sin(p) * _depth + 0.5);
            i++;
            p += dp;
        }
        _lfoStep = Math.floor(44100 / (tableSize * frequency));
        if (_lfoStep <= 4)             _lfoStep = 4;
        _lfoResidueStep = _lfoStep << 1;
        _wet = wet;
        _phaseInvert = ((invertPhase)) ? -1 : 1;
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
        setParameters(((!Math.isNaN(args[0]))) ? args[0] : 20,
                ((!Math.isNaN(args[1]))) ? (args[1] * 0.01) : 0.2,
                ((!Math.isNaN(args[2]))) ? args[2] : 4,
                ((!Math.isNaN(args[3]))) ? args[3] : 20,
                ((!Math.isNaN(args[4]))) ? (args[4] * 0.01) : 0.5,
                ((!Math.isNaN(args[5]))) ? (args[5] != 0) : true);
    }
    
    
    /** @private */
    override public function prepareProcess() : Int
    {
        _lfoPhase = 0;
        _lfoResidueStep = 0;
        _pointerRead = 0;
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
        var imax : Int;
        var istep : Int;
        var c : Float;
        var s : Float;
        var l : Float;
        var r : Float;
        istep = _lfoResidueStep;
        imax = startIndex + length;
        i = startIndex;
        while (i < imax - istep){
            _processLFO(buffer, i, istep);
            if (++_lfoPhase == _phaseTable.length)                 _lfoPhase = 0;
            i += istep;
            istep = _lfoStep << 1;
        }
        _processLFO(buffer, i, imax - i);
        _lfoResidueStep = istep - (imax - i);
        return channels;
    }
    
    
    // process inside
    private function _processLFO(buffer : Array<Float>, startIndex : Int, length : Int) : Void
    {
        var i : Int;
        var n : Float;
        var m : Float;
        var p : Int;
        var imax : Int = startIndex + length;
        var delayL : Int = _phaseTable[_lfoPhase];
        var delayR : Int = _phaseTable[_lfoPhase] * _phaseInvert;
        var dry : Float = 1 - _wet;
        i = startIndex;
        while (i < imax){
            p = (_pointerRead + delayL) & DELAY_BUFFER_FILTER;
            n = _delayBufferL[p];
            m = buffer[i] - n * _feedback;
            _delayBufferL[_pointerWrite] = m;
            buffer[i] *= dry;
            buffer[i] += n * _wet;i++;
            p = (_pointerRead + delayR) & DELAY_BUFFER_FILTER;
            n = _delayBufferR[p];
            m = buffer[i] - n * _feedback;
            _delayBufferR[_pointerWrite] = m;
            buffer[i] *= dry;
            buffer[i] += n * _wet;i++;
            _pointerWrite = (_pointerWrite + 1) & DELAY_BUFFER_FILTER;
            _pointerRead = (_pointerRead + 1) & DELAY_BUFFER_FILTER;
        }
    }
}


