//----------------------------------------------------------------------------------------------------
// SiOPM Karplus-Strong algorism with FM synth.
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module.channels;

import org.si.utils.SLLNumber;
import org.si.utils.SLLint;
import org.si.sion.module.*;
import org.si.sion.sequencer.SiMMLTable;
import org.si.sion.sequencer.SiMMLVoice;


/** Karplus-Strong algorism with FM synth. */
class SiOPMChannelKS extends SiOPMChannelFM
{
    // variables
    //--------------------------------------------------
    private var KS_BUFFER_SIZE : Int = 5400;  // 5394 = sampling count of MIDI note number=0  
    private static inline var INT_MIN_VALUE = -2147483648;

    private static inline var KS_SEED_DEFAULT : Int = 0;
    private static inline var KS_SEED_FM : Int = 1;
    private static inline var KS_SEED_PCM : Int = 2;
    
    
    
    // variables
    //--------------------------------------------------
    private var _ks_delayBuffer : Array<Int>;  // delay buffer  
    private var _ks_delayBufferIndex : Float;  // delay buffer index  
    private var _ks_pitchIndex : Int;  // pitch index  
    private var _ks_decay_lpf : Float;  // lpf decay  
    private var _ks_decay : Float;  // decay  
    private var _ks_mute_decay_lpf : Float;  // lpf decay @mute  
    private var _ks_mute_decay : Float;  // decay @mute  
    
    private var _output : Float;  // output  
    private var _decay_lpf : Float;  // lpf decay  
    private var _decay : Float;  // decay  
    private var _expression : Float;  // expression  
    
    private var _ks_seedType : Int;  // seed type  
    private var _ks_seedIndex : Int;  // seed index  
    
    
    
    // toString
    //--------------------------------------------------
    /** Output parameters. */
    override public function toString() : String
    {
        var str : String = "SiOPMChannelKS : operatorCount=";

        // These were $() and $2() in AS3
        function dlr(p : String, i : Dynamic) : Void {
            str += "  " + p + "=" + Std.string(i) + "\n";
        };
        function dlr2(p : String, i : Dynamic, q : String, j : Dynamic) : Void {
            str += "  " + p + "=" + Std.string(i) + " / " + q + "=" + Std.string(j) + "\n";
        };

        str += Std.string(_operatorCount) + "\n";
        dlr("fb ", _inputLevel - 6);
        dlr2("vol", _volumes[0], "pan", _pan - 64);
        if (operator[0] != null) str += Std.string(operator[0]) + "\n";
        if (operator[1] != null) str += Std.string(operator[1]) + "\n";
        if (operator[2] != null) str += Std.string(operator[2]) + "\n";
        if (operator[3] != null) str += Std.string(operator[3]) + "\n";
        return str;
    }
    
    // constructor
    //--------------------------------------------------
    /** constructor */
    public function new(chip : SiOPMModule)
    {
        super(chip);
        _ks_delayBuffer = new Array<Int>();
    }
    

    // LFO settings
    //--------------------------------------------------
    /** @private */
    override private function _lfoSwitch(sw : Bool) : Void
    {
        _lfo_on = 0;
    }
    

    // parameter setting
    //--------------------------------------------------
    /** Set Karplus Strong parameters
     *  @param ar attack rate of plunk energy
     *  @param dr decay rate of plunk energy
     *  @param tl total level of plunk energy
     *  @param fixedPitch plunk noise pitch
     *  @param ws wave shape of plunk
     *  @param tension sustain rate of the tone
     */
    public function setKarplusStrongParam(ar : Int = 48, dr : Int = 48, tl : Int = 0, fixedPitch : Int = 0, ws : Int = -1, tension : Int = 8) : Void
    {
        if (ws == -1)             ws = SiOPMTable.PG_NOISE_PINK;
        _ks_seedType = KS_SEED_DEFAULT;
        setAlgorism(1, 0);
        setFeedBack(0, 0);
        setSiOPMParameters(ar, dr, 0, 63, 15, tl, 0, 0, 1, 0, 0, 0, 0, fixedPitch);
        activeOperator.pgType = ws;
        activeOperator.ptType = _table.getWaveTable(activeOperator.pgType).defaultPTType;
        setAllReleaseRate(tension);
    }
    

    // interfaces
    //--------------------------------------------------
    /** Set parameters (&#64; commands 2nd-15th args.). (&#64;alg,ar,dr,tl,fix,ws)
     */
    override public function setParameters(param : Array<Int>) : Void
    {
        _ks_seedType = ((param[0] == INT_MIN_VALUE)) ? 0 : param[0];
        _ks_seedIndex = ((param[1] == INT_MIN_VALUE)) ? 0 : param[1];
        
        switch (_ks_seedType)
        {
            case KS_SEED_FM:
                if (_ks_seedIndex >= 0 && _ks_seedIndex < SiMMLTable.VOICE_MAX) {
                    var voice : SiMMLVoice = SiMMLTable.instance.getSiMMLVoice(_ks_seedIndex);
                    if (voice != null)                         setSiOPMChannelParam(voice.channelParam, false);
                }
            case KS_SEED_PCM:
                if (_ks_seedIndex >= 0 && _ks_seedIndex < SiOPMTable.PCM_DATA_MAX) {
                    var pcm : SiOPMWavePCMTable = _table.getPCMData(_ks_seedIndex);
                    if (pcm != null)                         setWaveData(pcm);
                }
            default:
                _ks_seedType = KS_SEED_DEFAULT;
                //setAlgorism(1, 0);
                //setFeedBack(0, 0);
                setSiOPMParameters(param[1], param[2], 0, 63, 15, param[3], 0, 0, 1, 0, 0, 0, 0, param[4]);
                activeOperator.pgType = ((param[5] == INT_MIN_VALUE)) ? SiOPMTable.PG_NOISE_PINK : param[5];
                activeOperator.ptType = _table.getWaveTable(activeOperator.pgType).defaultPTType;
        }
    }
    
    
    /** pgType and ptType (&#64; commands 1st arg except for %6,7) */
    override public function setType(pgType : Int, ptType : Int) : Void
    {
        _ks_seedType = pgType;
        _ks_seedIndex = 0;
    }
    
    
    /** Attack rate */
    override public function setAllAttackRate(ar : Int) : Void
    {
        var ope : SiOPMOperator = operator[0];
        ope.ar = ar;
        ope.dr = ((ar > 48)) ? 48 : ar;
        ope.tl = ((ar > 48)) ? 0 : (48 - ar);
    }
    
    
    /** Release rate (s) */
    override public function setAllReleaseRate(rr : Int) : Void
    {
        _ks_decay_lpf = 1 - rr * 0.015625;
    }
    
    
    
    
    // interfaces
    //--------------------------------------------------
    /** pitch = (note &lt;&lt; 6) | (kf &amp; 63) [0,8191] */
    override private function get_pitch() : Int{return _ks_pitchIndex;
    }
    override private function set_pitch(p : Int) : Int{
        _ks_pitchIndex = p;
        return p;
    }
    
    /** release rate (&#64;rr) */
    override private function set_rr(i : Int) : Int{
        _ks_decay_lpf = 1 - i * 0.015625;
        return i;
    }
    
    /** fixed pitch (&#64;fx) */
    override private function set_fixedPitch(i : Int) : Int{
        for (i in 0..._operatorCount){operator[i].fixedPitchIndex = i;
        }
        return i;
    }
    
    
    
    
    // volume controls
    //--------------------------------------------------
    /** update all tl offsets of final carriors */
    override public function offsetVolume(expression : Int, velocity : Int) : Void
    {
        _expression = expression * 0.0078125;
        super.offsetVolume(128, velocity);
    }
    
    
    
    
    // operation
    //--------------------------------------------------
    /** Initialize. */
    override public function initialize(prev : SiOPMChannelBase, bufferIndex : Int) : Void
    {
        _ks_delayBufferIndex = 0;
        _ks_pitchIndex = 0;
        _ks_decay_lpf = 0.875;
        _ks_decay = 0.98;
        _ks_mute_decay_lpf = 0.5;
        _ks_mute_decay = 0.75;
        
        _output = 0;
        _decay_lpf = _ks_mute_decay_lpf;
        _decay = _ks_mute_decay;
        _expression = 1;
        
        super.initialize(prev, bufferIndex);
        
        _ks_seedType = 0;
        _ks_seedIndex = 0;
        setSiOPMParameters(48, 48, 0, 63, 15, 0, 0, 0, 1, 0, 0, 0, -1, 0);
        activeOperator.pgType = SiOPMTable.PG_NOISE_PINK;
        activeOperator.ptType = SiOPMTable.PT_PCM;
    }
    
    
    /** Reset. */
    override public function reset() : Void
    {
        for (i in 0...KS_BUFFER_SIZE){_ks_delayBuffer[i] = 0;
        }
        super.reset();
    }
    
    
    /** Note on. */
    override public function noteOn() : Void
    {
        _output = 0;
        for (i in 0...KS_BUFFER_SIZE) {
            _ks_delayBuffer[i] = Math.round(_ks_delayBuffer[i] * 0.3);
        }
        _decay_lpf = _ks_decay_lpf;
        _decay = _ks_decay;
        
        super.noteOn();
    }
    
    
    /** Note off. */
    override public function noteOff() : Void
    {
        _decay_lpf = _ks_mute_decay_lpf;
        _decay = _ks_mute_decay;
    }
    
    
    /** Prepare buffering */
    override public function resetChannelBufferStatus() : Void
    {
        _bufferIndex = 0;
        _isIdling = false;
    }
    
    
    
    /** Buffering */
    override public function buffer(len : Int) : Void
    {
        var i : Int;
        var stream : SiOPMStream;
        
        if (_isIdling) {
            // idling process
            _nop(len);
        }
        else {
            // preserve _outPipe
            var monoOut : SLLint = _outPipe;
            
            // processing (update _outPipe inside)
            _funcProcess(len);
            
            // ring modulation
            if (_ringPipe != null) _applyRingModulation(monoOut, len);  // Karplus-Strong algorism
            
            
            
            _applyKarplusStrong(monoOut, len);
            
            // State variable filter
            if (_filterOn) _applySVFilter(monoOut, len);  // standard output

            if (_outputMode == SiOPMChannelBase.OUTPUT_STANDARD && !_mute) {
                if (_hasEffectSend) {
                    for (i in 0...SiOPMModule.STREAM_SEND_SIZE) {
                        if (_volumes[i] > 0) {
                            stream = _streams[i];
                            if (stream == null) stream = _chip.streamSlot[i];
                            if (stream != null) stream.write(monoOut, _bufferIndex, len, _volumes[i] * _expression, _pan);
                        }
                    }
                }
                else {
                    stream = _streams[0];
                    if (stream == null) {
                        stream = _chip.outputStream;
                    }
                    stream.write(monoOut, _bufferIndex, len, _volumes[0] * _expression, _pan);
                }
            }
        }

         // update buffer index
        _bufferIndex += len;
    }
    
    
    // Karplus-Strong algorism
    private function _applyKarplusStrong(pointer : SLLint, len : Int) : Void
    {
        var i : Int;
        var t : Int;
        var indexMax : Float;
        var tmax : Int = SiOPMTable.PITCH_TABLE_SIZE - 1;
        t = _ks_pitchIndex + operator[0]._pitchIndexShift + _pm_out;
        if (t < 0) t = 0
        else if (t > tmax) t = tmax;
        indexMax = _table.pitchWaveLength[t];
        
        for (i in 0...len){
            // lfo_update();
            _lfo_timer -= _lfo_timer_step;
            if (_lfo_timer < 0) {
                _lfo_phase = (_lfo_phase + 1) & 255;
                t = _lfo_waveTable[_lfo_phase];
                //_am_out = (t * _am_depth) >> 7 << 3;
                _pm_out = (((t << 1) - 255) * _pm_depth) >> 8;
                t = _ks_pitchIndex + operator[0]._pitchIndexShift + _pm_out;
                if (t < 0)                     t = 0
                else if (t > tmax)                     t = tmax;
                indexMax = _table.pitchWaveLength[t];
                _lfo_timer += _lfo_timer_initial;
            }  // ks_update();  
            
            
            
            if (++_ks_delayBufferIndex >= indexMax)                 _ks_delayBufferIndex %= indexMax;
            _output *= _decay;
            t = Math.floor(_ks_delayBufferIndex);
            _output += (_ks_delayBuffer[t] - _output) * _decay_lpf + pointer.i;
            _ks_delayBuffer[t] = Math.round(_output);
            pointer.i = Math.round(_output);
            pointer = pointer.next;
        }
    }
}


