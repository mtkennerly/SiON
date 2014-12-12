// Basic Synthesizer
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.synthesizers;

import org.si.sound.synthesizers.SiONVoice;
import org.si.sound.synthesizers.VoiceReference;

import org.si.sion.*;
import org.si.sion.module.SiOPMTable;
import org.si.sion.module.SiOPMChannelParam;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sound.SoundObject;


/** Basic Synthesizer */
class BasicSynth extends VoiceReference
{
    public var cutoff(get, set) : Float;
    public var resonance(get, set) : Float;
    public var filterType(get, set) : Int;
    public var lfoWaveShape(get, set) : Int;
    public var lfoCycleFrames(get, set) : Int;
    public var amplitudeModulation(get, set) : Int;
    public var pitchModulation(get, set) : Int;
    public var attackTime(get, set) : Float;
    public var releaseTime(get, set) : Float;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    /** tracks to control */
    private var _tracks : Array<SiMMLTrack>;
    
    
    
    
    // properties
    //----------------------------------------
    /** @private */
    override private function set_voice(v : SiONVoice) : SiONVoice{
        _voice.copyFrom(v);  // copy from passed voice  
        _voiceUpdateNumber++;
        return v;
    }
    
    
    /** low-pass filter cutoff(0-1). */
    private function get_cutoff() : Float{return _voice.channelParam.cutoff * 0.0078125;
    }
    private function set_cutoff(c : Float) : Float{
        var i : Int;
        var imax : Int = _tracks.length;
        var p : SiOPMChannelParam = _voice.channelParam;
        p.cutoff = ((c <= 0)) ? 0 : ((c >= 1)) ? 128 : Math.floor(c * 128);
        for (imax){
            _tracks[i].channel.setSVFilter(p.cutoff, p.resonance, p.far, p.fdr1, p.fdr2, p.frr, p.fdc1, p.fdc2, p.fsc, p.frc);
        }
        return c;
    }
    
    
    /** low-pass filter resonance(0-1). */
    private function get_resonance() : Float{return _voice.channelParam.resonance * 0.1111111111111111;
    }
    private function set_resonance(r : Float) : Float{
        var i : Int;
        var imax : Int = _tracks.length;
        var p : SiOPMChannelParam = _voice.channelParam;
        p.resonance = ((r <= 0)) ? 0 : ((r >= 1)) ? 9 : Math.floor(r * 9);
        for (imax){
            _tracks[i].channel.setSVFilter(p.cutoff, p.resonance, p.far, p.fdr1, p.fdr2, p.frr, p.fdc1, p.fdc2, p.fsc, p.frc);
        }
        return r;
    }
    
    
    /** filter type (0:lowpass, 1:bandpass, 2:highpass) */
    private function get_filterType() : Int{return _voice.channelParam.filterType;
    }
    private function set_filterType(t : Int) : Int{
        var i : Int;
        var imax : Int = _tracks.length;
        _voice.channelParam.filterType = t;
        for (imax){
            _tracks[i].channel.filterType = t;
        }
        return t;
    }
    
    
    
    /** modulation (low-frequency oscillator) wave shape, 0=saw, 1=square, 2=triangle, 3=random. */
    private function get_lfoWaveShape() : Int{return _voice.channelParam.lfoWaveShape;
    }
    private function set_lfoWaveShape(type : Int) : Int{
        _voice.channelParam.lfoWaveShape = type;
        _voiceUpdateNumber++;
        return type;
    }
    
    /** modulation (low-frequency oscillator) cycle frames. */
    private function get_lfoCycleFrames() : Int{return _voice.channelParam.lfoFrame;
    }
    private function set_lfoCycleFrames(frame : Int) : Int{
        _voice.channelParam.lfoFrame = frame;
        var i : Int;
        var imax : Int = _tracks.length;
        var ms : Float = frame * 1000 / 60;
        for (imax){
            _tracks[i].channel.setLFOCycleTime(ms);
        }
        return frame;
    }
    
    /** amplitude modulation. */
    private function get_amplitudeModulation() : Int{return _voice.amDepth;
    }
    private function set_amplitudeModulation(m : Int) : Int{
        _voice.channelParam.amd = _voice.amDepth = m;
        var i : Int;
        var imax : Int = _tracks.length;
        for (imax){
            _tracks[i].channel.setAmplitudeModulation(m);
        }
        return m;
    }
    
    
    /** pitch modulation. */
    private function get_pitchModulation() : Int{return _voice.pmDepth;
    }
    private function set_pitchModulation(m : Int) : Int{
        _voice.channelParam.pmd = _voice.pmDepth = m;
        var i : Int;
        var imax : Int = _tracks.length;
        for (imax){
            _tracks[i].channel.setPitchModulation(m);
        }
        return m;
    }
    
    
    /** attack rate (0-1), lower value makes attack slow. */
    private function get_attackTime() : Float{
        var iar : Int = _voice.channelParam.operatorParam[_voice.channelParam.opeCount - 1].ar;
        return ((iar > 48)) ? 0 : (1 - iar * 0.020833333333333332);
    }
    private function set_attackTime(n : Float) : Float{
        var flg : Int = SiOPMTable.instance.final_oscilator_flags[_voice.channelParam.opeCount][_voice.channelParam.alg];
        var iar : Int = ((n == 0)) ? 63 : ((1 - n) * 48);
        if (flg & 1)             _voice.channelParam.operatorParam[0].ar = iar;
        if (flg & 2)             _voice.channelParam.operatorParam[1].ar = iar;
        if (flg & 4)             _voice.channelParam.operatorParam[2].ar = iar;
        if (flg & 8)             _voice.channelParam.operatorParam[3].ar = iar;
        var i : Int;
        var imax : Int = _tracks.length;
        for (imax){
            _tracks[i].channel.setAllAttackRate(iar);
        }
        return n;
    }
    
    
    /** release rate (0-1), lower value makes release slow. */
    private function get_releaseTime() : Float{
        var irr : Int = _voice.channelParam.operatorParam[_voice.channelParam.opeCount - 1].rr;
        return ((irr > 48)) ? 0 : (1 - irr * 0.020833333333333332);
    }
    private function set_releaseTime(n : Float) : Float{
        var flg : Int = SiOPMTable.instance.final_oscilator_flags[_voice.channelParam.opeCount][_voice.channelParam.alg];
        var irr : Int = ((n == 0)) ? 63 : ((1 - n) * 48);
        if (flg & 1)             _voice.channelParam.operatorParam[0].rr = irr;
        if (flg & 2)             _voice.channelParam.operatorParam[1].rr = irr;
        if (flg & 4)             _voice.channelParam.operatorParam[2].rr = irr;
        if (flg & 8)             _voice.channelParam.operatorParam[3].rr = irr;
        var i : Int;
        var imax : Int = _tracks.length;
        for (imax){
            _tracks[i].channel.setAllReleaseRate(irr);
        }
        return n;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor.
     *  @param moduleType Module type. 1st argument of '%'.
     *  @param channelNum Channel number. 2nd argument of '%'.
     *  @param ar Attack rate (0-63).
     *  @param rr Release rate (0-63).
     *  @param dt pitchShift (64=1halftone).
     */
    public function new(moduleType : Int = 5, channelNum : Int = 0, ar : Int = 63, rr : Int = 63, dt : Int = 0)
    {
        super();
        _voice = new SiONVoice(moduleType, channelNum, ar, rr, dt);
        _tracks = new Array<SiMMLTrack>();
    }
    
    
    
    
    // operations
    //----------------------------------------
    /** set filter envelop (same as '&#64;f' command in MML).
     *  @param cutoff LP filter cutoff (0-1)
     *  @param resonance LP filter resonance (0-1)
     *  @param far LP filter attack rate (0-63)
     *  @param fdr1 LP filter decay rate 1 (0-63)
     *  @param fdr2 LP filter decay rate 2 (0-63)
     *  @param frr LP filter release rate (0-63)
     *  @param fdc1 LP filter decay cutoff 1 (0-1)
     *  @param fdc2 LP filter decay cutoff 2 (0-1)
     *  @param fsc LP filter sustain cutoff (0-1)
     *  @param frc LP filter release cutoff (0-1)
     */
    public function setFilterEnvelop(filterType : Int = 0, cutoff : Float = 1, resonance : Float = 0, far : Int = 0, fdr1 : Int = 0, fdr2 : Int = 0, frr : Int = 0, fdc1 : Float = 1, fdc2 : Float = 0.5, fsc : Float = 0.25, frc : Float = 1) : Void
    {
        _voice.setFilterEnvelop(filterType, cutoff * 128, resonance * 9, far, fdr1, fdr2, frr, fdc1 * 128, fdc2 * 128, fsc * 128, frc * 128);
        _voiceUpdateNumber++;
    }
    
    
    /** [Please use setFilterEnvelop instead of this function]. This function is for compatibility of old versions.
     *  @param cutoff LP filter cutoff (0-1)
     *  @param resonance LP filter resonance (0-1)
     *  @param far LP filter attack rate (0-63)
     *  @param fdr1 LP filter decay rate 1 (0-63)
     *  @param fdr2 LP filter decay rate 2 (0-63)
     *  @param frr LP filter release rate (0-63)
     *  @param fdc1 LP filter decay cutoff 1 (0-1)
     *  @param fdc2 LP filter decay cutoff 2 (0-1)
     *  @param fsc LP filter sustain cutoff (0-1)
     *  @param frc LP filter release cutoff (0-1)
     */
    public function setLPFEnvelop(cutoff : Float = 1, resonance : Float = 0, far : Int = 0, fdr1 : Int = 0, fdr2 : Int = 0, frr : Int = 0, fdc1 : Float = 1, fdc2 : Float = 0.5, fsc : Float = 0.25, frc : Float = 1) : Void
    {
        setFilterEnvelop(0, cutoff, resonance, far, fdr1, fdr2, frr, fdc1, fdc2, fsc, frc);
    }
    
    
    /** Set amplitude modulation parameters (same as "ma" command in MML).
     *  @param depth start modulation depth (same as 1st argument)
     *  @param end_depth end modulation depth (same as 2nd argument)
     *  @param delay changing delay (same as 3rd argument)
     *  @param term changing term (same as 4th argument)
     *  @return this instance
     */
    public function setAmplitudeModulation(depth : Int = 0, end_depth : Int = 0, delay : Int = 0, term : Int = 0) : Void
    {
        _voice.setAmplitudeModulation(depth, end_depth, delay, term);
        _voiceUpdateNumber++;
    }
    
    
    /** Set amplitude modulation parameters (same as "mp" command in MML).
     *  @param depth start modulation depth (same as 1st argument)
     *  @param end_depth end modulation depth (same as 2nd argument)
     *  @param delay changing delay (same as 3rd argument)
     *  @param term changing term (same as 4th argument)
     *  @return this instance
     */
    public function setPitchModulation(depth : Int = 0, end_depth : Int = 0, delay : Int = 0, term : Int = 0) : Void
    {
        _voice.setPitchModulation(depth, end_depth, delay, term);
        _voiceUpdateNumber++;
    }
    
    
    
    
    // internals
    //----------------------------------------
    /** @private [synthesizer internal] register single track */
    override public function _registerTrack(track : SiMMLTrack) : Void
    {
        _tracks.push(track);
    }
    
    
    /** @private [synthesizer internal] register prural tracks */
    override public function _registerTracks(tracks : Array<SiMMLTrack>) : Void
    {
        var i0 : Int = _tracks.length;
        var imax : Int = tracks.length;
        var i : Int;
        _tracks.length = i0 + imax;
        for (imax){_tracks[i0 + i] = tracks[i];
        }
    }
    
    
    /** @private [synthesizer internal] unregister tracks */
    override public function _unregisterTracks(firstTrack : SiMMLTrack, count : Int = 1) : Void
    {
        var index : Int = Lambda.indexOf(_tracks, firstTrack);
        if (index >= 0)             _tracks.splice(index, count);
    }
}



