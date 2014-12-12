// Operator instance of FMSynth
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.synthesizers;


import org.si.sion.*;
import org.si.sion.module.SiOPMOperatorParam;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sound.SoundObject;


/** Operator instance of FMSynth */
class FMSynthOperator
{
    public var ws(get, set) : Int;
    public var ar(get, set) : Int;
    public var dr(get, set) : Int;
    public var sr(get, set) : Int;
    public var rr(get, set) : Int;
    public var sl(get, set) : Int;
    public var tl(get, set) : Int;
    public var ksr(get, set) : Int;
    public var ksl(get, set) : Int;
    public var mul(get, set) : Int;
    public var dt1(get, set) : Int;
    public var dt2(get, set) : Int;
    public var det(get, set) : Int;
    public var ams(get, set) : Int;
    public var ph(get, set) : Int;
    public var fn(get, set) : Int;
    public var mute(get, set) : Bool;
    public var ssgec(get, set) : Int;
    public var erst(get, set) : Bool;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    private var _owner : FMSynth;
    private var _opeIndex : Int;
    private var _param : SiOPMOperatorParam;
    
    
    
    
    // properties
    //----------------------------------------
    /** WS; wave shape [0-512]. */
    private function get_ws() : Int{return _param.pgType;
    }
    private function set_ws(i : Int) : Int{
        if (_param.pgType == i || i < 0 || i > 511)             return;
        _param.setPGType(i);
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** AR; attack rate [0-63]. */
    private function get_ar() : Int{return _param.ar;
    }
    private function set_ar(i : Int) : Int{
        if (_param.ar == i || i < 0 || i > 63)             return;
        _param.ar = i;
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** DR; decay rate [0-63]. */
    private function get_dr() : Int{return _param.dr;
    }
    private function set_dr(i : Int) : Int{
        if (_param.dr == i || i < 0 || i > 63)             return;
        _param.dr = i;
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** SR; sustain rate [0-63]. */
    private function get_sr() : Int{return _param.sr;
    }
    private function set_sr(i : Int) : Int{
        if (_param.sr == i || i < 0 || i > 63)             return;
        _param.sr = i;
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** RR; release rate [0-63]. */
    private function get_rr() : Int{return _param.rr;
    }
    private function set_rr(i : Int) : Int{
        if (_param.rr == i || i < 0 || i > 63)             return;
        _param.rr = i;
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** SL; sustain level [0-15]. */
    private function get_sl() : Int{return _param.sl;
    }
    private function set_sl(i : Int) : Int{
        if (_param.sl == i || i < 0 || i > 15)             return;
        _param.sl = i;
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** TL; total level [0-127]. */
    private function get_tl() : Int{return _param.tl;
    }
    private function set_tl(i : Int) : Int{
        if (_param.tl == i || i < 0 || i > 127)             return;
        _param.tl = i;
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** KSR; sustain level [0-3]. */
    private function get_ksr() : Int{return _param.ksr;
    }
    private function set_ksr(i : Int) : Int{
        if (_param.ksr == i || i < 0 || i > 3)             return;
        _param.ksr = i;
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** KSL; total level [0-3]. */
    private function get_ksl() : Int{return _param.ksl;
    }
    private function set_ksl(i : Int) : Int{
        if (_param.ksl == i || i < 0 || i > 3)             return;
        _param.ksl = i;
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** MUL; multiple [0-15]. */
    private function get_mul() : Int{return _param.mul;
    }
    private function set_mul(i : Int) : Int{
        if (_param.mul == i || i < 0 || i > 15)             return;
        _param.mul = i;
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** DT1; detune 1 (OPM/OPNA) [0-7]. */
    private function get_dt1() : Int{return _param.dt1;
    }
    private function set_dt1(i : Int) : Int{
        if (_param.dt1 == i || i < 0 || i > 7)             return;
        _param.dt1 = i;
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** DT2; detune 2 (OPM) [0-3]. */
    private function get_dt2() : Int{
        if (_param.detune <= 100)             return 0
        // 0
        else if (_param.detune <= 420)             return 1
        // 384
        // 500
        else if (_param.detune <= 550)             return 2;
        return 3;
    }
    private function set_dt2(i : Int) : Int{
        var dt2table : Array<Dynamic> = [0, 384, 500, 608];
        if (_param.detune == i || i < 0 || i > 3)             return;
        _param.detune = dt2table[i];
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** DET; detune (64 for 1halftone). */
    private function get_det() : Int{return _param.detune;
    }
    private function set_det(i : Int) : Int{
        if (_param.detune == i)             return;
        _param.detune = i;
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** AMS; Amp modulation shift [0-3]. */
    private function get_ams() : Int{return _param.ams;
    }
    private function set_ams(i : Int) : Int{
        if (_param.ams == i || i < 0 || i > 3)             return;
        _param.ams = i;
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** PH; Key on phase [0-255]. */
    private function get_ph() : Int{return _param.phase;
    }
    private function set_ph(i : Int) : Int{
        if (_param.phase == i || i < 0 || i > 255)             return;
        _param.phase = i;
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** FN; fixed note [0-127]. */
    private function get_fn() : Int{return _param.fixedPitch >> 6;
    }
    private function set_fn(i : Int) : Int{
        var fp : Int = i << 6;
        if (_param.fixedPitch == fp || i < 0 || i > 127)             return;
        _param.fixedPitch = fp;
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** mute; mute [t/f]. */
    private function get_mute() : Bool{return _param.mute;
    }
    private function set_mute(b : Bool) : Bool{
        if (_param.mute == b)             return;
        _param.mute = b;
        _owner._voiceUpdateNumber++;
        return b;
    }
    
    
    /** SSGEC; SSG type envelop control [0-17]. */
    private function get_ssgec() : Int{return _param.ssgec;
    }
    private function set_ssgec(i : Int) : Int{
        if (_param.ssgec == i || i < 0 || i > 17)             return;
        _param.ssgec = i;
        _owner._voiceUpdateNumber++;
        return i;
    }
    
    
    /** ERST; envelop reset on attack [t/f]. */
    private function get_erst() : Bool{return _param.erst;
    }
    private function set_erst(b : Bool) : Bool{
        if (_param.erst == b)             return;
        _param.erst = b;
        _owner._voiceUpdateNumber++;
        return b;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** Constructor, But you cannot create new instance of this class. */
    public function new(owner : FMSynth, opeIndex : Int)
    {
        _owner = owner;
        _opeIndex = opeIndex;
        _param = owner.voice.channelParam.operatorParam[opeIndex];
    }
    
    
    
    
    // operation
    //----------------------------------------
    /** Set all 15 FM parameters. The value of int.MIN_VALUE does not change.
     *  @param ar Attack rate [0-63].
     *  @param dr Decay rate [0-63].
     *  @param sr Sustain rate [0-63].
     *  @param rr Release rate [0-63].
     *  @param sl Sustain level [0-15].
     *  @param tl Total level [0-127].
     *  @param ksr Key scaling [0-3].
     *  @param ksl key scale level [0-3].
     *  @param mul Multiple [0-15].
     *  @param dt1 Detune 1 [0-7]. 
     *  @param detune Detune.
     *  @param ams Amplitude modulation shift [0-3].
     *  @param phase Phase [0-255].
     *  @param fixNote Fixed note number [0-127].
     */
    public function setAllParameters(ws : Int, ar : Int, dr : Int, sr : Int, rr : Int, sl : Int, tl : Int, ksr : Int, ksl : Int, mul : Int, dt1 : Int, detune : Int, ams : Int, phase : Int, fixNote : Int) : Void
    {
        if (ws != INT_MIN_VALUE)             _param.setPGType(ws & 511);
        if (ar != INT_MIN_VALUE)             _param.ar = ar & 63;
        if (dr != INT_MIN_VALUE)             _param.dr = dr & 63;
        if (sr != INT_MIN_VALUE)             _param.sr = sr & 63;
        if (rr != INT_MIN_VALUE)             _param.rr = rr & 63;
        if (sl != INT_MIN_VALUE)             _param.sl = sl & 15;
        if (tl != INT_MIN_VALUE)             _param.tl = tl & 127;
        if (ksr != INT_MIN_VALUE)             _param.ksr = ksr & 3;
        if (ksl != INT_MIN_VALUE)             _param.ksl = ksl & 3;
        if (mul != INT_MIN_VALUE)             _param.mul = mul & 15;
        if (dt1 != INT_MIN_VALUE)             _param.dt1 = dt1 & 7;
        if (detune != INT_MIN_VALUE)             _param.detune = detune;
        if (ams != INT_MIN_VALUE)             _param.ams = ams & 3;
        if (phase != INT_MIN_VALUE)             _param.phase = phase & 255;
        if (fixNote != INT_MIN_VALUE)             _param.fixedPitch = (fixNote & 127) << 6;
        _owner._voiceUpdateNumber++;
    }
}



