//----------------------------------------------------------------------------------------------------
// SiOPM effect stereo auto pan
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;

import org.si.utils.SLLNumber;


/** Stereo auto pan. */
class SiEffectAutoPan extends SiEffectBase
{
    // variables
    //------------------------------------------------------------
    private var _stereo : Bool;
    
    private var _lfoStep : Int;
    private var _lfoResidueStep : Int;
    private var _pL : SLLNumber;private var _pR : SLLNumber;
    
    
    
    
    // constructor
    //------------------------------------------------------------
    /** constructor
     *  @param frequency rotation frequency(Hz).
     *  @param width stereo width(0-1). 0 sets as auto pan with keeping stereo.
     */
    public function new(frequency : Float = 1, width : Float = 1)
    {
        super();
        _pL = SLLNumber.allocRing(256);
        _lfoResidueStep = 0;
        setParameters(frequency, width);
    }
    
    
    
    
    // operations
    //------------------------------------------------------------
    /** set parameter
     *  @param frequency rotation frequency(Hz).
     *  @param width stereo width(0-1). 0 sets as auto pan with keeping stereo.
     */
    public function setParameters(frequency : Float = 1, width : Float = 1) : Void
    {
        var i : Int;
        frequency *= 0.5;
        _lfoStep = Math.floor(172.265625 / frequency);  //44100/256
        if (_lfoStep <= 4)             _lfoStep = 4;
        _stereo = false;
        if (width == 0) {
            width = 1;
            _stereo = true;
        }

        // volume table
        width *= 0.01227184630308513;  // pi/256
        for (i in 0...128) {
            _pL.n = Math.sin(1.5707963267948965 + i * width);
            _pL = _pL.next;
        }

        // _pR phase shift
        _pR = _pL;
        for (i in 0...128) {
            _pR = _pR.next;
        }
    }
    
    
    // overrided funcitons
    //------------------------------------------------------------
    /** @private */
    override public function initialize() : Void
    {
        _lfoResidueStep = 0;
        setParameters();
    }
    
    
    /** @private */
    override public function mmlCallback(args : Array<Float>) : Void
    {
        setParameters(((!Math.isNaN(args[0]))) ? args[0] : 1,
                ((!Math.isNaN(args[1]))) ? args[1] * 0.01 : 1);
    }
    
    
    /** @private */
    override public function prepareProcess() : Int
    {
        return ((_stereo)) ? 2 : 1;
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
        var proc : Array<Float>->Int->Int->Void = _stereo ? processLFOstereo : processLFOmono;
        istep = _lfoResidueStep;
        imax = startIndex + length;
        i = startIndex;
        while (i < imax - istep){
            proc(buffer, i, istep);
            i += istep;
            istep = _lfoStep << 1;
        }
        proc(buffer, i, imax - i);
        _lfoResidueStep = istep - (imax - i);
        return 2;
    }
    
    
    /** @private */
    public function processLFOmono(buffer : Array<Float>, startIndex : Int, length : Int) : Void
    {
        var c : Float = _pL.n;
        var s : Float = _pR.n;
        var i : Int;
        var l : Float;
        var imax : Int = startIndex + length;
        i = startIndex;
        while (i < imax){
            l = buffer[i];
            buffer[i] = l * c;i++;
            buffer[i] = l * s;i++;
        }
        _pL = _pL.next;
        _pR = _pR.next;
    }
    
    
    public function processLFOstereo(buffer : Array<Float>, startIndex : Int, length : Int) : Void
    {
        var c : Float = _pL.n;
        var s : Float = _pR.n;
        var i : Int;
        var l : Float;
        var r : Float;
        var imax : Int = startIndex + length;
        i = startIndex;
        while (i < imax){
            l = buffer[i];
            r = buffer[i + 1];
            buffer[i] = l * c - r * s;
            buffer[i + 1] = l * s + r * c;
            i += 2;
        }
        _pL = _pL.next;
        _pR = _pR.next;
    }
}


