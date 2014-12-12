//----------------------------------------------------------------------------------------------------
// SiOPM filter controlable
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;

import org.si.sion.module.SiOPMTable;
import org.si.sion.sequencer.SiMMLTable;
import org.si.utils.SLLint;


/** controlable filter base class. */
class SiCtrlFilterBase extends SiEffectBase
{
    public var cutoff(get, set) : Float;
    public var resonance(get, set) : Float;

    // variables
    //------------------------------------------------------------
    /** @private */private static var _incEnvelopTable : SLLint = null;
    /** @private */private static var _decEnvelopTable : SLLint = null;
    /** @private */private var _p0r : Float;
    /** @private */private var _p1r : Float;
    /** @private */private var _p0l : Float;
    /** @private */private var _p1l : Float;
    /** @private */private var _cutIndex : Int;
    /** @private */private var _res : Float;
    /** @private */private var _table : SiOPMTable;
    
    private var _ptrCut : SLLint;
    private var _ptrRes : SLLint;
    private var _lfoStep : Int;
    private var _lfoResidueStep : Int;
    
    
    
    
    // properties
    //------------------------------------------------------------
    /** cutoff */
    private function get_cutoff() : Float{
        return _cutIndex * 0.0078125;
    }
    private function set_cutoff(n : Float) : Float{
        _cutIndex = Math.floor(cutoff * 128);
        if (_cutIndex > 128)             _cutIndex = 128
        else if (_cutIndex < 0)             _cutIndex = 0;
        return n;
    }
    
    
    /** resonance */
    private function get_resonance() : Float{
        return _res;
    }
    private function set_resonance(n : Float) : Float{
        _res = resonance;
        if (_res > 1)             _res = 1
        else if (_res < 0)             _res = 0;
        return n;
    }
    
    
    
    
    // constructor
    //------------------------------------------------------------
    /** constructor */
    public function new()
    {
        super();
        if (_incEnvelopTable == null) {
            _incEnvelopTable = SLLint.allocList(129);
            _decEnvelopTable = SLLint.allocList(129);
            var ptrit : SLLint = _incEnvelopTable;
            var ptrdt : SLLint = _decEnvelopTable;
            for (i in 0...129){
                ptrit.i = i;
                ptrdt.i = 128 - i;
                ptrit = ptrit.next;
                ptrdt = ptrdt.next;
            }
        }
    }
    
    
    
    
    // operation
    //------------------------------------------------------------
    /** set parameters
     *  @param cut table index for cutoff(0-255). 255 to set no tables.
     *  @param res table index for resonance(0-255). 255 to set no tables.
     *  @param fps Envelop speed (0.001-1000)[Frame per second].
     */
    public function setParameters(cut : Int = 255, res : Int = 255, fps : Float = 20) : Void{
        _table = SiOPMTable.instance;
        var simml : SiMMLTable = SiMMLTable.instance;
        _ptrCut = (cut >= 0 && cut < 255 && (simml.getEnvelopTable(cut) != null)) ? simml.getEnvelopTable(cut).head : null;
        _ptrRes = (res >= 0 && res < 255 && (simml.getEnvelopTable(res) != null)) ? simml.getEnvelopTable(res).head : null;
        _cutIndex = ((_ptrCut != null)) ? _ptrCut.i : 128;
        _res = ((_ptrRes != null)) ? (_ptrRes.i * 0.007751937984496124) : 0;  // 0.007751937984496124=1/129  
        _lfoStep = Math.floor(44100 / fps);
        if (_lfoStep <= 44)             _lfoStep = 44;
        _lfoResidueStep = _lfoStep << 1;
    }
    
    
    /** control cutoff and resonance manualy. 
     *  @param cutoff cutoff(0-1).
     *  @param resonance resonance(0-1).
     */
    public function control(cutoff : Float, resonance : Float) : Void
    {
        _lfoStep = 2048;
        _lfoResidueStep = 4096;
        
        if (cutoff > 1)             cutoff = 1
        else if (cutoff < 0)             cutoff = 0;
        _cutIndex = Math.floor(cutoff * 128);
        
        if (resonance > 1)             resonance = 1
        else if (resonance < 0)             resonance = 0;
        _res = resonance;
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
        setParameters(((!Math.isNaN(args[0]))) ? Math.floor(args[0]) : 255,
                ((!Math.isNaN(args[1]))) ? Math.floor(args[1]) : 255,
                ((!Math.isNaN(args[2]))) ? Math.floor(args[2]) : 20);
    }
    
    
    /** @private */
    override public function prepareProcess() : Int
    {
        _lfoResidueStep = 0;
        _p0r = _p1r = _p0l = _p1l = 0;
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
            processLFO(buffer, i, istep);
            if (_ptrCut != null) {_ptrCut = _ptrCut.next;_cutIndex = ((_ptrCut != null)) ? _ptrCut.i : 128;
            }
            if (_ptrRes != null) {_ptrRes = _ptrRes.next;_res = ((_ptrRes != null)) ? (_ptrRes.i * 0.007751937984496124) : 0;
            }
            i += istep;
            istep = _lfoStep << 1;
        }
        processLFO(buffer, i, imax - i);
        _lfoResidueStep = istep - (imax - i);
        return channels;
    }
    
    
    /** @private */
    private function processLFO(buffer : Array<Float>, startIndex : Int, length : Int) : Void
    {
        
    }
}


