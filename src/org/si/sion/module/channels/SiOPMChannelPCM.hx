//----------------------------------------------------------------------------------------------------
// SiOPM FM channel.
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module.channels;

import org.si.sion.namespaces.SionInternal;
import org.si.utils.SLLNumber;
import org.si.utils.SLLint;
import org.si.sion.module.*;


/** PCM channel
 */
class SiOPMChannelPCM extends SiOPMChannelBase
{
    // variables
    //--------------------------------------------------
    /** eg_out threshold to check idling */private static var idlingThreshold : Int = 5120;  // = 256(resolution)*10(2^10=1024)*2(p/n) = volume<1/1024  
    
    // Operators
    /** operator for layer0 */public var operator : SiOPMOperator;
    
    // Parameters
    /** pcm table */private var _pcmTable : SiOPMWavePCMTable;
    /** for stereo filter */private var _filterVriables2 : Array<Float>;
    
    // modulation
    /** am depth */private var _am_depth : Int;  // = chip.amd<<(ams-1)  
    /** am output level */private var _am_out : Int;
    /** pm depth */private var _pm_depth : Int;  // = chip.pmd<<(pms-1)  
    /** pm output level */private var _pm_out : Int;
    
    
    // tone generator setting
    /** ENV_TIMER_INITIAL * freq_ratio */private var _eg_timer_initial : Int;
    /** LFO_TIMER_INITIAL * freq_ratio */private var _lfo_timer_initial : Int;
    
    /** register map type */
    private var registerMapType : Int;
    private var registerMapChannel : Int;
    
    // pitch shift for sampling point
    private var _samplePitchShift : Int;
    // volunme of current note
    private var _sampleVolume : Float;
    // pan of current note
    private var _samplePan : Int;
    // output pipe for stereo
    private var _outPipe2 : SLLint;
    // waveFixedBits for PCM
    private static inline var PCM_waveFixedBits : Int = 11;  // <= Should be 11, This is adhoc solution !  

    private static inline var INT_MIN_VALUE = -2147483648;



    // toString
    //--------------------------------------------------
    /** Output parameters. */
    public function toString() : String
    {
        var str : String = "SiOPMChannelPCM : \n";
        function dlr2(p : String, i : Dynamic, q : String, j : Dynamic) : Void{str += "  " + p + "=" + Std.string(i) + " / " + q + "=" + Std.string(j) + "\n";
        };
        dlr2("vol", _volumes[0], "pan", _pan - 64);
        str += Std.string(operator) + "\n";
        return str;
    }
    
    
    
    
    // constructor
    //--------------------------------------------------
    /** constructor */
    public function new(chip : SiOPMModule)
    {
        super(chip);
        
        operator = new SiOPMOperator(chip);
        _filterVriables2 = new Array<Float>();
        
        initialize(null, 0);
    }
    
    
    
    
    // Chip settings
    //--------------------------------------------------
    /** set chip "PSEUDO" frequency ratio by [%]. 100 means 3.56MHz. This value effects only for envelop and lfo speed. */
    override public function setFrequencyRatio(ratio : Int) : Void
    {
        _freq_ratio = ratio;
        var r : Float = ((ratio != 0)) ? (100 / ratio) : 1;
        _eg_timer_initial = Math.floor(SiOPMTable.ENV_TIMER_INITIAL * r);
        _lfo_timer_initial = Math.floor(SiOPMTable.LFO_TIMER_INITIAL * r);
    }
    
    
    
    
    // LFO settings
    //--------------------------------------------------
    /** initialize low frequency oscillator. and stop lfo
     *  @param waveform LFO waveform. 0=saw, 1=pulse, 2=triangle, 3=noise. -1 to set customized wave table
     *  @param customWaveTable customized wave table, the length is 256 and the values are limited in the range of 0-255. This argument is available when waveform=-1.
     */
    override public function initializeLFO(waveform : Int, customWaveTable : Array<Int> = null) : Void
    {
        super.initializeLFO(waveform, customWaveTable);
        _lfoSwitch(false);
        _am_depth = 0;
        _pm_depth = 0;
        _am_out = 0;
        _pm_out = 0;
        _pcmTable = null;
        operator.detune2 = 0;
    }
    
    
    /** Amplitude modulation.
     *  @param depth depth = (ams) ? (amd &lt;&lt; (ams-1)) : 0;
     */
    override public function setAmplitudeModulation(depth : Int) : Void
    {
        _am_depth = depth << 2;
        _am_out = (_lfo_waveTable[_lfo_phase] * _am_depth) >> 7 << 3;
        _lfoSwitch(_pm_depth != 0 || _am_depth > 0);
    }
    
    
    /** Pitch modulation.
     *  @param depth depth = (pms&lt;6) ? (pmd &gt;&gt; (6-pms)) : (pmd &lt;&lt; (pms-5));
     */
    override public function setPitchModulation(depth : Int) : Void
    {
        _pm_depth = depth;
        _pm_out = (((_lfo_waveTable[_lfo_phase] << 1) - 255) * _pm_depth) >> 8;
        _lfoSwitch(_pm_depth != 0 || _am_depth > 0);
        if (_pm_depth == 0) {
            operator.detune2 = 0;
        }
    }
    
    
    /** @private [protected] lfo on/off */
    private function _lfoSwitch(sw : Bool) : Void
    {
        _lfo_on = sw ? 1 : 0;
        _lfo_timer_step = ((sw)) ? _lfo_timer_step_ : 0;
    }
    
    
    
    
    // parameter setting
    //--------------------------------------------------
    /** Set by SiOPMChannelParam. 
     *  @param param SiOPMChannelParam.
     *  @param withVolume Set volume when its true.
     *  @param withModulation Set modulation when its true.
     */
    override public function setSiOPMChannelParam(param : SiOPMChannelParam, withVolume : Bool, withModulation : Bool = true) : Void
    {
        var i : Int;
        if (param.opeCount == 0)             return;
        
        if (withVolume) {
            var imax : Int = SiOPMModule.STREAM_SEND_SIZE;
            for (i in 0...imax) {
                _volumes[i] = param.volumes[i];
            }
            for (i in 0...imax) {
                if (_volumes[i] > 0) _hasEffectSend = true;
            }
            _pan = param.pan;
        }
        setFrequencyRatio(param.fratio);
        setAlgorism(param.opeCount, param.alg);
        //setFeedBack(param.fb, param.fbc);
        if (withModulation) {
            initializeLFO(param.lfoWaveShape);
            _lfo_timer = ((param.lfoFreqStep > 0)) ? 1 : 0;
            _lfo_timer_step_ = _lfo_timer_step = param.lfoFreqStep;
            setAmplitudeModulation(param.amd);
            setPitchModulation(param.pmd);
        }
        filterType = param.filterType;
        setSVFilter(param.cutoff, param.resonance, param.far, param.fdr1, param.fdr2, param.frr, param.fdc1, param.fdc2, param.fsc, param.frc);
        operator.setSiOPMOperatorParam(param.operatorParam[0]);
    }
    
    
    /** Get SiOPMChannelParam.
     *  @param param SiOPMChannelParam.
     */
    override public function getSiOPMChannelParam(param : SiOPMChannelParam) : Void
    {
        var i : Int;
        var imax : Int = SiOPMModule.STREAM_SEND_SIZE;
        for (i in 0...imax){
            param.volumes[i] = _volumes[i];
        }
        param.pan = _pan;
        param.fratio = _freq_ratio;
        param.opeCount = 1;
        param.alg = 0;
        param.fb = 0;
        param.fbc = 0;
        param.lfoWaveShape = _lfo_waveShape;
        param.lfoFreqStep = _lfo_timer_step_;
        param.amd = _am_depth;
        param.pmd = _pm_depth;
        operator.getSiOPMOperatorParam(param.operatorParam[0]);
    }
    
    
    /** Set sound by 14 basic params. The value of int.MIN_VALUE means not to change.
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
    public function setSiOPMParameters(ar : Int, dr : Int, sr : Int, rr : Int, sl : Int, tl : Int, ksr : Int, ksl : Int, mul : Int, dt1 : Int, detune : Int, ams : Int, phase : Int, fixNote : Int) : Void
    {
        var ope : SiOPMOperator = operator;
        if (ar      != INT_MIN_VALUE) ope.ar = ar;
        if (dr      != INT_MIN_VALUE) ope.dr = dr;
        if (sr      != INT_MIN_VALUE) ope.sr = sr;
        if (rr      != INT_MIN_VALUE) ope.rr = rr;
        if (sl      != INT_MIN_VALUE) ope.sl = sl;
        if (tl      != INT_MIN_VALUE) ope.tl = tl;
        if (ksr     != INT_MIN_VALUE) ope.ks = ksr;
        if (ksl     != INT_MIN_VALUE) ope.ksl = ksl;
        if (mul     != INT_MIN_VALUE) ope.mul = mul;
        if (dt1     != INT_MIN_VALUE) ope.dt1 = dt1;
        if (detune  != INT_MIN_VALUE) ope.detune = detune;
        if (ams     != INT_MIN_VALUE) ope.ams = ams;
        if (phase   != INT_MIN_VALUE) ope.keyOnPhase = phase;
        if (fixNote != INT_MIN_VALUE) ope.fixedPitchIndex = fixNote << 6;
    }
    
    
    /** Set wave data. (called from setType())
     *  @param pcmData SiOPMWavePCMTable to set.
     */
    override public function setWaveData(waveData : SiOPMWaveBase) : Void
    {
        var pcm : SiOPMWavePCMData;
        if (Std.is(waveData, SiOPMWavePCMTable)) {
            _pcmTable = try cast(waveData, SiOPMWavePCMTable) catch(e:Dynamic) null;
            pcm = _pcmTable._table[60];
        }
        else {
            _pcmTable = null;
            pcm = try cast(waveData, SiOPMWavePCMData) catch(e:Dynamic) null;
        }
        if (pcm != null)             _samplePitchShift = pcm.samplingPitch - 4416;
        operator.setPCMData(pcm);
    }
    
    
    /** set channel number (2nd argument of %) */
    override public function setChannelNumber(channelNum : Int) : Void
    {
        registerMapChannel = channelNum;
    }
    
    
    /** set register */
    override public function setRegister(addr : Int, data : Int) : Void
    {
        
    }
    
    
    
    
    // interfaces
    //--------------------------------------------------
    /** Set algorism (&#64;al) 
     *  @param cnt Operator count.
     *  @param alg Algolism number of the operator's connection.
     */
    override public function setAlgorism(cnt : Int, alg : Int) : Void
    {
        
    }
    
    
    /** Set feedback(&#64;fb). Do nothing. 
     *  @param fb Feedback level. Ussualy in the range of 0-7.
     *  @param fbc Feedback connection. Operator index which feeds back its output.
     */
    override public function setFeedBack(fb : Int, fbc : Int) : Void
    {
        
    }
    
    
    /** Set parameters (&#64; command). */
    override public function setParameters(param : Array<Int>) : Void
    {
        setSiOPMParameters(param[1], param[2], param[3], param[4], param[5],
                param[6], param[7], param[8], param[9], param[10],
                param[11], param[12], param[13], param[14]);
    }
    
    
    /** pgType and ptType (&#64;). call from SiMMLChannelSetting.selectTone() */
    override public function setType(pgType : Int, ptType : Int) : Void
    {
        var pcmTable : SiOPMWavePCMTable = _table.getPCMData(pgType);
        if (pcmTable != null) {
            setWaveData(pcmTable);
        }
        else {
            _samplePitchShift = 0;
            operator.setPCMData(null);
        }
    }
    
    
    /** Attack rate */
    override public function setAllAttackRate(ar : Int) : Void
    {
        operator.ar = ar;
    }
    
    
    /** Release rate (s) */
    override public function setAllReleaseRate(rr : Int) : Void
    {
        operator.rr = rr;
    }
    
    
    
    
    // interfaces
    //--------------------------------------------------
    /** pitch = (note &lt;&lt; 6) | (kf &amp; 63) [0,8191] */
    override private function get_pitch() : Int{
        return operator.pitchIndex + _samplePitchShift;
    }
    override private function set_pitch(p : Int) : Int{
        if (_pcmTable != null) {
            var note : Int = p >> 6;
            var pcm : SiOPMWavePCMData = _pcmTable._table[note];
            if (pcm != null) {
                _samplePitchShift = pcm.samplingPitch - 4416;  //69*64  
                _sampleVolume = _pcmTable._volumeTable[note];
                _samplePan = _pcmTable._panTable[note];
            }
            operator.setPCMData(pcm);
        }
        operator.pitchIndex = p - _samplePitchShift;
        return p;
    }
    
    /** active operator index (i) */
    override private function set_activeOperatorIndex(i : Int) : Int{
        
        return i;
    }
    
    /** release rate (&#64;rr) */
    override private function set_rr(i : Int) : Int{operator.rr = i;
        return i;
    }
    
    /** total level (&#64;tl) */
    override private function set_tl(i : Int) : Int{operator.tl = i;
        return i;
    }
    
    /** fine multiple (&#64;ml) */
    override private function set_fmul(i : Int) : Int{operator.fmul = i;
        return i;
    }
    
    /** phase  (&#64;ph) */
    override private function set_phase(i : Int) : Int{operator.keyOnPhase = i;
        return i;
    }
    
    /** detune (&#64;dt) */
    override private function set_detune(i : Int) : Int{operator.detune = i;
        return i;
    }
    
    /** fixed pitch (&#64;fx) */
    override private function set_fixedPitch(i : Int) : Int{operator.fixedPitchIndex = i;
        return i;
    }
    
    /** ssgec (&#64;se) */
    override private function set_ssgec(i : Int) : Int{operator.ssgec = i;
        return i;
    }
    
    /** envelop reset (&#64;er) */
    override private function set_erst(b : Bool) : Bool{operator.erst = b;
        return b;
    }
    
    
    
    
    // volume controls
    //--------------------------------------------------
    /** update all tl offsets of final carriors */
    override public function offsetVolume(expression : Int, velocity : Int) : Void
    {
        var i : Int;
        var ope : SiOPMOperator;
        var tl : Int;
        var x : Int = expression << 1;
        tl = _expressionTable[x] + _veocityTable[velocity];
        operator._tlOffset(tl);
    }
    
    
    
    
    // operation
    //--------------------------------------------------
    /** Initialize. */
    override public function initialize(prev : SiOPMChannelBase, bufferIndex : Int) : Void
    {
        // initialize operators
        operator.initialize();
        _isNoteOn = false;
       registerMapType = 0;
       registerMapChannel = 0;
        _outPipe2 = _chip.getPipe(3, bufferIndex);
        _filterVriables2[0] = _filterVriables2[1] = _filterVriables2[2] = 0;
        _samplePitchShift = 0;
        _sampleVolume = 1;
        _samplePan = 0;
        
        // initialize sound channel
        super.initialize(prev, bufferIndex);
    }
    
    
    /** Reset. */
    override public function reset() : Void
    {
        // reset all operators
        operator.reset();
        _isNoteOn = false;
        _isIdling = true;
    }
    
    
    /** Note on. */
    override public function noteOn() : Void
    {
        // operator note on
        operator.noteOn();
        _isNoteOn = true;
        _isIdling = false;
        super.noteOn();
    }
    
    
    /** Note off. */
    override public function noteOff() : Void
    {
        // operator note off
        operator.noteOff();
        _isNoteOn = false;
        super.noteOff();
    }
    
    
    /** Prepare buffering */
    override public function resetChannelBufferStatus() : Void
    {
        _bufferIndex = 0;
        
        // check idling flag
        _isIdling = operator._eg_out > idlingThreshold && operator._eg_state != SiOPMOperator.EG_ATTACK;
    }
    
    
    /** Buffering */
    override public function buffer(len : Int) : Void
    {
        if (_isIdling) {
            _nop(len);
        }
        else {
            _proc(len, operator, false, true);
        }
        _bufferIndex += len;
    }
    
    
    
    /** No process (default functor of _funcProcess). */
    override private function _nop(len : Int) : Void
    {
        // rotate output buffer
        _outPipe = _chip.getPipe(4, (_bufferIndex + len) & (_chip.bufferLength - 1));
        _outPipe2 = _chip.getPipe(3, (_bufferIndex + len) & (_chip.bufferLength - 1));
    }
    
    
    
    
    //====================================================================================================
    // Internal uses
    //====================================================================================================
    // process 1 operator
    //--------------------------------------------------
    private function _proc(len : Int, ope : SiOPMOperator, mix : Bool, finalOutput : Bool) : Void
    {
        var t : Int;
        var l : Int;
        var i : Int;
        var n : Float;
        var log : Array<Int> = _table.logTable;
        var phase_filter : Int = SiOPMTable.PHASE_FILTER;
        var op : SLLint = _outPipe;
        var op2 : SLLint = _outPipe2;
        var bp : SLLint = _outPipe;
        var bp2 : SLLint = _outPipe2;
        if (!mix)             bp = bp2 = _chip.zeroBuffer;
        
        if (ope._pcm_channels == 1) {
            // MONORAL
            //----------------------------------------
            if (ope._pcm_endPoint > 0) {
                // buffering
                i = 0;
                while (i < len) {
                    // lfo_update();
                    //----------------------------------------
                    _lfo_timer -= _lfo_timer_step;
                    if (_lfo_timer < 0) {
                        _lfo_phase = (_lfo_phase + 1) & 255;
                        t = _lfo_waveTable[_lfo_phase];
                        _am_out = (t * _am_depth) >> 7 << 3;
                        _pm_out = (((t << 1) - 255) * _pm_depth) >> 8;
                        ope.detune2 = _pm_out;
                        _lfo_timer += _lfo_timer_initial;
                    }

                    // eg_update();
                    // ----------------------------------------
                    ope._eg_timer -= ope._eg_timer_step;
                    if (ope._eg_timer < 0) {
                        if (ope._eg_state == SiOPMOperator.EG_ATTACK) {
                            t = ope._eg_incTable[ope._eg_counter];
                            if (t > 0) {
                                ope._eg_level -= 1 + (ope._eg_level >> t);
                                if (ope._eg_level <= 0)                                     ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                            }
                        }
                        else {
                            ope._eg_level += ope._eg_incTable[ope._eg_counter];
                            if (ope._eg_level >= ope._eg_stateShiftLevel)                                 ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                        }
                        ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level) << 3;
                        ope._eg_counter = (ope._eg_counter + 1) & 7;
                        ope._eg_timer += _eg_timer_initial;
                    }

                    // pg_update();
                    // ----------------------------------------
                    ope._phase += ope._phase_step;
                    t = ope._phase >>> PCM_waveFixedBits;
                    if (t >= ope._pcm_endPoint) {
                        if (ope._pcm_loopPoint == -1) {
                            ope._eg_shiftState(SiOPMOperator.EG_OFF);
                            ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level) << 3;
                            while (i < len){
                                op.i = 0;
                                op = op.next;
                                i++;
                            }
                            break;
                        }
                        else {
                            t -= ope._pcm_endPoint - ope._pcm_loopPoint;
                            ope._phase -= (ope._pcm_endPoint - ope._pcm_loopPoint) << PCM_waveFixedBits;
                        }
                    }
                    l = ope._waveTable[t];
                    l += ope._eg_out + (_am_out >> ope._ams);
                    
                    // output and increment pointers
                    //----------------------------------------
                    op.i = log[l] + bp.i;
                    op = op.next;
                    bp = bp.next;
                    i++;
                }
            }
            else {
                // no operation
                for (i in 0...len) {
                    op.i = bp.i;
                    op = op.next;
                    bp = bp.next;
                }
            }
            
            if (finalOutput) {
                // streaming
                if (!_mute) _mwrite(_outPipe, len);   // update pointers
                
                _outPipe = op;
            }
        }
        else {
            // STEREO
            //----------------------------------------
            if (ope._pcm_endPoint > 0) {
                // buffering
                i = 0;
                while (i < len) {
                    // lfo_update();
                    //----------------------------------------
                    _lfo_timer -= _lfo_timer_step;
                    if (_lfo_timer < 0) {
                        _lfo_phase = (_lfo_phase + 1) & 255;
                        t = _lfo_waveTable[_lfo_phase];
                        _am_out = (t * _am_depth) >> 7 << 3;
                        _pm_out = (((t << 1) - 255) * _pm_depth) >> 8;
                        ope.detune2 = _pm_out;
                        _lfo_timer += _lfo_timer_initial;
                    }

                    // eg_update();
                    // ----------------------------------------
                    ope._eg_timer -= ope._eg_timer_step;
                    if (ope._eg_timer < 0) {
                        if (ope._eg_state == SiOPMOperator.EG_ATTACK) {
                            t = ope._eg_incTable[ope._eg_counter];
                            if (t > 0) {
                                ope._eg_level -= 1 + (ope._eg_level >> t);
                                if (ope._eg_level <= 0)                                     ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                            }
                        }
                        else {
                            ope._eg_level += ope._eg_incTable[ope._eg_counter];
                            if (ope._eg_level >= ope._eg_stateShiftLevel)                                 ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                        }
                        ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level) << 3;
                        ope._eg_counter = (ope._eg_counter + 1) & 7;
                        ope._eg_timer += _eg_timer_initial;
                    }

                    // pg_update();
                    // ----------------------------------------
                    ope._phase += ope._phase_step;
                    t = ope._phase >>> PCM_waveFixedBits;
                    if (t >= ope._pcm_endPoint) {
                        if (ope._pcm_loopPoint == -1) {
                            ope._eg_shiftState(SiOPMOperator.EG_OFF);
                            ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level) << 3;
                            while (i < len){
                                op.i = 0;
                                op2.i = 0;
                                op = op.next;
                                op2 = op2.next;
                                i++;
                            }
                            break;
                        }
                        else {
                            t -= ope._pcm_endPoint - ope._pcm_loopPoint;
                            ope._phase -= (ope._pcm_endPoint - ope._pcm_loopPoint) << PCM_waveFixedBits;
                        }
                    }


                    // output and increment pointers
                    // ----------------------------------------
                    // left
                    t <<= 1;
                    l = ope._waveTable[t];
                    l += ope._eg_out + (_am_out >> ope._ams);
                    op.i = bp.i;
                    op.i += log[l];
                    op = op.next;
                    bp = bp.next;
                    // right
                    t++;
                    l = ope._waveTable[t];
                    l += ope._eg_out + (_am_out >> ope._ams);
                    op2.i = bp2.i;
                    op2.i += log[l];
                    op2 = op2.next;
                    bp2 = bp2.next;
                    i++;
                }
            }
            else {
                // no operation
                for (i in 0...len) {
                    op.i = bp.i;
                    op = op.next;
                    bp = bp.next;
                    op2.i = bp2.i;
                    op2 = op2.next;
                    bp2 = bp2.next;
                }
            }
            
            if (finalOutput) {
                // streaming
                if (!_mute) _swrite(_outPipe, _outPipe2, len);  // update pointers
                
                _outPipe = op;
                _outPipe2 = op2;
            }
        }
    }
    
    
    // monoral stream writing with filtering
    private function _mwrite(input : SLLint, len : Int) : Void
    {
        var i : Int;
        var stream : SiOPMStream;
        var vol : Float = _sampleVolume * _chip.pcmVolume;
        var pan : Int = _pan + _samplePan;
        if (pan < 0)             pan = 0
        else if (pan > 128)             pan = 128;
        
        if (_filterOn)             _applySVFilter(input, len);
        if (_hasEffectSend) {
            for (i in 0...SiOPMModule.STREAM_SEND_SIZE){
                if (_volumes[i] > 0) {
                    stream = (_streams[i] != null) ? _streams[i] : _chip.streamSlot[i];
                    if (stream != null) stream.write(input, _bufferIndex, len, _volumes[i] * vol, pan);
                }
            }
        }
        else {
            stream = (_streams[0] != null) ? _streams[0] : _chip.outputStream;
            stream.write(input, _bufferIndex, len, _volumes[0] * vol, pan);
        }
    }
    
    
    // stereo stream writing with filtering
    private function _swrite(inputL : SLLint, inputR : SLLint, len : Int) : Void
    {
        var i : Int;
        var stream : SiOPMStream;
        var vol : Float = _sampleVolume * _chip.pcmVolume;
        var pan : Int = _pan + _samplePan;
        if (pan < 0)             pan = 0
        else if (pan > 128)             pan = 128;
        
        if (_filterOn) {
            _applySVFilter(inputL, len, _filterVriables);
            _applySVFilter(inputR, len, _filterVriables2);
        }
        if (_hasEffectSend) {
            for (i in 0...SiOPMModule.STREAM_SEND_SIZE){
                if (_volumes[i] > 0) {
                    stream = (_streams[i] != null) ? _streams[i] : _chip.streamSlot[i];
                    if (stream != null) stream.writeStereo(inputL, inputR, _bufferIndex, len, _volumes[i] * vol, pan);
                }
            }
        }
        else {
            stream = (_streams[0] != null) ? _streams[0] : _chip.outputStream;
            stream.writeStereo(inputL, inputR, _bufferIndex, len, _volumes[0] * vol, pan);
        }
    }
}


