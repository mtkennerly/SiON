// Analog "LIKE" Synthesizer
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.synthesizers;

import org.si.sound.synthesizers.BasicSynth;
import org.si.sound.synthesizers.SiOPMChannelFM;
import org.si.sound.synthesizers.SiOPMOperatorParam;

import org.si.sion.*;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sion.module.SiOPMChannelParam;
import org.si.sion.module.SiOPMOperatorParam;
import org.si.sion.module.SiOPMTable;
import org.si.sion.module.channels.SiOPMChannelFM;
import org.si.sound.SoundObject;


/** Analog "LIKE" Synthesizer 
 */
class AnalogSynth extends BasicSynth
{
    public var con(get, set) : Int;
    public var ws1(get, set) : Int;
    public var ws2(get, set) : Int;
    public var balance(get, set) : Float;
    public var vco2pitch(get, set) : Float;
    public var decayTime(get, set) : Float;
    public var sustainLevel(get, set) : Float;
    public var vcfAttackTime(get, set) : Float;
    public var vcfDecayTime(get, set) : Float;
    public var vcfPeakCutoff(get, set) : Float;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // constants
    //----------------------------------------
    /** nromal connection */
    public static inline var CONNECT_NORMAL : Int = 0;
    /** ring connection */
    public static inline var CONNECT_RING : Int = 1;
    /** sync connection */
    public static inline var CONNECT_SYNC : Int = 2;
    
    /** wave shape number of saw wave */
    public static var SAW : Int = SiOPMTable.PG_SAW_UP;
    /** wave shape number of square wave */
    public static var SQUARE : Int = SiOPMTable.PG_SQUARE;
    /** wave shape number of triangle wave */
    public static var TRIANGLE : Int = SiOPMTable.PG_TRIANGLE;
    /** wave shape number of sine wave */
    public static var SINE : Int = SiOPMTable.PG_SINE;
    /** wave shape number of noise wave */
    public static var NOISE : Int = SiOPMTable.PG_NOISE;
    
    
    
    
    // variables
    //----------------------------------------
    /** @private [protected] operator parameter for op0 */
    private var _opp0 : SiOPMOperatorParam;
    /** @private [protected] operator parameter for op1 */
    private var _opp1 : SiOPMOperatorParam;
    /** @private [protected] mixing balance of 2 oscillators.*/
    private var _intBalance : Int;
    
    
    
    // properties
    //----------------------------------------
    /** connection algorism of 2 oscillators */
    private function get_con() : Int{return _voice.channelParam.alg;
    }
    private function set_con(c : Int) : Int{
        _voice.channelParam.alg = ((c < 0 || c > 2)) ? 0 : c;
        _voiceUpdateNumber++;
        return c;
    }
    
    
    /** wave shape of 1st oscillator */
    private function get_ws1() : Int{return _opp0.pgType;
    }
    private function set_ws1(ws : Int) : Int{
        _opp0.pgType = ws & SiOPMTable.PG_FILTER;
        _opp0.ptType = ((ws == NOISE)) ? SiOPMTable.PT_PCM : SiOPMTable.PT_OPM;
        var i : Int;
        var imax : Int = _tracks.length;
        var ch : SiOPMChannelFM;
        for (imax){
            ch = try cast(_tracks[i].channel, SiOPMChannelFM) catch(e:Dynamic) null;
            if (ch != null) {
                ch.operator[0].pgType = _opp0.pgType;
                ch.operator[0].ptType = _opp0.ptType;
            }
        }
        return ws;
    }
    
    
    /** wave shape of 2nd oscillator */
    private function get_ws2() : Int{return _opp1.pgType;
    }
    private function set_ws2(ws : Int) : Int{
        _opp1.pgType = ws & SiOPMTable.PG_FILTER;
        _opp1.ptType = ((ws == NOISE)) ? SiOPMTable.PT_PCM : SiOPMTable.PT_OPM;
        var i : Int;
        var imax : Int = _tracks.length;
        var ch : SiOPMChannelFM;
        for (imax){
            ch = try cast(_tracks[i].channel, SiOPMChannelFM) catch(e:Dynamic) null;
            if (ch != null) {
                ch.operator[1].pgType = _opp1.pgType;
                ch.operator[1].ptType = _opp1.ptType;
            }
        }
        return ws;
    }
    
    
    /** mixing balance of 2 oscillators (0-1), 0=1st only, 0.5=same volume, 1=2nd only. */
    private function get_balance() : Float{return (_intBalance + 64) * 0.0078125;
    }
    private function set_balance(b : Float) : Float{
        _intBalance = Math.floor(b * 128) - 64;
        if (_intBalance > 64)             _intBalance = 64
        else if (_intBalance < -64)             _intBalance = -64;
        var tltable : Array<Int> = SiOPMTable.instance.eg_lv2tlTable;
        _opp0.tl = tltable[64 - _intBalance];
        _opp1.tl = tltable[_intBalance + 64];
        var i : Int;
        var imax : Int = _tracks.length;
        var ch : SiOPMChannelFM;
        for (imax){
            ch = try cast(_tracks[i].channel, SiOPMChannelFM) catch(e:Dynamic) null;
            if (ch != null) {
                ch.operator[0].tl = _opp0.tl;
                ch.operator[1].tl = _opp1.tl;
            }
        }
        return b;
    }
    
    
    /** pitch difference in osc1 and 2. 1 = halftone. */
    private function get_vco2pitch() : Float{return (_opp1.detune - _opp0.detune) * 0.015625;
    }
    private function set_vco2pitch(p : Float) : Float{
        _opp1.detune = _opp0.detune + Math.floor(p * 64);
        var i : Int;
        var imax : Int = _tracks.length;
        var ch : SiOPMChannelFM;
        for (imax){
            ch = try cast(_tracks[i].channel, SiOPMChannelFM) catch(e:Dynamic) null;
            if (ch != null) {
                ch.operator[1].detune = _opp1.detune;
            }
        }
        return p;
    }
    
    
    
    /** VCA attack time [0-1], This value is not linear. */
    override private function get_attackTime() : Float{return ((_opp0.ar > 48)) ? 0 : (1 - _opp0.ar * 0.020833333333333332);
    }
    override private function set_attackTime(n : Float) : Float{
        _opp0.ar = ((n == 0)) ? 63 : ((1 - n) * 48);
        _voiceUpdateNumber++;
        return n;
    }
    
    /** VCA decay time [0-1], This value is not linear. */
    private function get_decayTime() : Float{return ((_opp0.dr > 48)) ? 0 : (1 - _opp0.dr * 0.020833333333333332);
    }
    private function set_decayTime(n : Float) : Float{
        _opp0.dr = ((n == 0)) ? 63 : ((1 - n) * 48);
        _voiceUpdateNumber++;
        return n;
    }
    
    /** VCA sustain level [0-1], This value is not linear. */
    private function get_sustainLevel() : Float{return ((_opp0.sl == 15)) ? 0 : (1 - _opp0.sl * 0.06666666666666666);
    }
    private function set_sustainLevel(n : Float) : Float{
        _opp0.sl = ((n == 0)) ? 15 : ((1 - n) * 15);
        _voiceUpdateNumber++;
        return n;
    }
    
    /** VCA release time [0-1], This value is not linear. */
    override private function get_releaseTime() : Float{return ((_opp0.rr > 48)) ? 0 : (1 - _opp0.rr * 0.020833333333333332);
    }
    override private function set_releaseTime(n : Float) : Float{
        _opp0.rr = ((n == 0)) ? 63 : ((1 - n) * 48);
        _voiceUpdateNumber++;
        return n;
    }
    
    
    /** @private */
    override private function get_cutoff() : Float{return _voice.channelParam.fdc2 * 0.0078125;
    }
    override private function set_cutoff(n : Float) : Float{
        _voice.channelParam.fdc2 = n * 128;
        _voiceUpdateNumber++;
        return n;
    }
    
    
    /** VCF attack time [0-1], This value is not linear. */
    private function get_vcfAttackTime() : Float{return (1 - _voice.channelParam.far * 0.015873015873015872);
    }
    private function set_vcfAttackTime(n : Float) : Float{
        _voice.channelParam.far = (1 - n) * 63;
        _voiceUpdateNumber++;
        return n;
    }
    
    
    /** VCF decay time [0-1], This value is not linear. */
    private function get_vcfDecayTime() : Float{return (1 - _voice.channelParam.fdr1 * 0.015873015873015872);
    }
    private function set_vcfDecayTime(n : Float) : Float{
        _voice.channelParam.fdr1 = (1 - n) * 63;
        _voiceUpdateNumber++;
        return n;
    }
    
    
    /** VCF peak cutoff [0-1]. */
    private function get_vcfPeakCutoff() : Float{return _voice.channelParam.fdc1 * 0.0078125;
    }
    private function set_vcfPeakCutoff(n : Float) : Float{
        _voice.channelParam.fdc1 = n * 128;
        _voiceUpdateNumber++;
        return n;
    }
    
    
    
    // constructor
    //----------------------------------------
    /** constructor 
     *  @param connectionType Connection type, 0=normal, 1=ring, 2=sync.
     *  @param ws1 Wave shape for osc1.
     *  @param ws2 Wave shape for osc2.
     *  @param balance mixing balance of 2 osccilators (0-1), 0=1st only, 0.5=same volume, 1=2nd only.
     *  @param vco2pitch pitch difference in osc1 and 2. 1 for halftone.
     */
    public function new(connectionType : Int = 0, ws1 : Int = 1, ws2 : Int = 1, balance : Float = 0.5, vco2pitch : Float = 0.1)
    {
        super();
        _intBalance = Math.floor(balance * 128) - 64;
        if (_intBalance > 64)             _intBalance = 64
        else if (_intBalance < -64)             _intBalance = -64;
        _voice.setAnalogLike(connectionType, ws1, ws2, _intBalance, vco2pitch * 64);
        _opp0 = _voice.channelParam.operatorParam[0];
        _opp1 = _voice.channelParam.operatorParam[1];
        _voice.channelParam.cutoff = 0;
        _voice.channelParam.far = 63;
        _voice.channelParam.fdr1 = 63;
        _voice.channelParam.fdc1 = 128;
        _voice.channelParam.fdc2 = 128;
    }
    
    
    
    
    // operation
    //----------------------------------------
    /** set VCA envelope. This provide basic ADSR envelop.
     *  @param attackTime attack time [0-1]. This value is not linear.
     *  @param decayTime decay time [0-1]. This value is not linear.
     *  @param sustainLevel sustain level [0-1]. This value is not linear.
     *  @param releaseTime release time [0-1]. This value is not linear.
     *  @return this instance
     */
    public function setVCAEnvelop(attackTime : Float, decayTime : Float, sustainLevel : Float, releaseTime : Float) : AnalogSynth
    {
        _opp0.ar = ((attackTime == 0)) ? 63 : ((1 - attackTime) * 48);
        _opp0.dr = ((decayTime == 0)) ? 63 : ((1 - decayTime) * 48);
        _opp0.sr = 0;
        _opp0.rr = ((releaseTime == 0)) ? 63 : ((1 - releaseTime) * 48);
        _opp0.sl = (1 - sustainLevel) * 15;
        _voiceUpdateNumber++;
        return this;
    }
    
    
    /** set VCF envelope, This is a simplification of BasicSynth.setLPFEnvelop().
     *  @param cutoff cutoff frequency[0-1].
     *  @param resonanse resonanse[0-1].
     *  @param attackTime attack time [0-1]. This value is not linear.
     *  @param decayTime decay time [0-1]. This value is not linear.
     *  @param peakCutoff 
     *  @return this instance
     */
    public function setVCFEnvelop(cutoff : Float = 1, resonance : Float = 0, attackTime : Float = 0, decayTime : Float = 0, peakCutoff : Float = 1) : AnalogSynth
    {
        setLPFEnvelop(0, resonance, ((1 - attackTime) * 63), ((1 - decayTime) * 63), 0, 0, peakCutoff, cutoff, cutoff, cutoff);
        return this;
    }
}



