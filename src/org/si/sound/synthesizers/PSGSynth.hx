// Programmable Sound Generator Synthesizer
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.synthesizers;


import org.si.sion.*;
import org.si.sion.module.SiOPMTable;
import org.si.sion.module.SiOPMOperatorParam;
import org.si.sion.module.channels.SiOPMChannelFM;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sound.SoundObject;


/** Programmable Sound Generator Synthesizer 
 */
class PSGSynth extends BasicSynth
{
    public var channelNumber(get, never) : Int;
    public var channelMode(get, set) : Int;
    public var noiseFreq(get, set) : Int;
    public var channelGain(get, set) : Int;
    public var envelopControlMode(get, set) : Int;
    public var envelopFreq(get, set) : Int;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    /** PSG channel mode (0=mute, 1=PSG, 2=noise, 3=PSG+noise). */
    private var _channelMode : Int;
    /** PSG channel gain (*2db) (0=0db, 7=14db, 15=mute) */
    private var _channelTL : Int;
    /** SSG envelop controling rate */
    private var _evelopRate : Int;
    /** operator parameter for op0 */
    private var _opp0 : SiOPMOperatorParam;
    /** operator parameter for op1 */
    private var _opp1 : SiOPMOperatorParam;
    
    
    
    // properties
    //----------------------------------------
    /** PSG channel number */
    private function get_channelNumber() : Int{return _voice.channelNum;
    }
    
    /** PSG channel mode (0=mute, 1=PSG, 2=noise, 3=PSG+noise). */
    private function get_channelMode() : Int{return _channelMode;
    }
    private function set_channelMode(mode : Int) : Int{
        _opp0.mute = ((mode & 1) == 1);
        _opp1.mute = ((mode & 2) == 2);
        var i : Int;
        var imax : Int = _tracks.length;
        var ch : SiOPMChannelFM;
        for (imax){
            ch = try cast(_tracks[i].channel, SiOPMChannelFM) catch(e:Dynamic) null;
            if (ch != null) {
                ch.operator[0].mute = _opp0.mute;
                ch.operator[1].mute = _opp1.mute;
            }
        }
        return mode;
    }
    
    
    /** noise frequency */
    private function get_noiseFreq() : Int{return _opp1.fixedPitch >> 6;
    }
    private function set_noiseFreq(nf : Int) : Int{
        _opp1.fixedPitch = (nf << 6) + 1;
        if (!_opp1.mute) {
            var i : Int;
            var imax : Int = _tracks.length;
            var ch : SiOPMChannelFM;
            for (imax){
                ch = try cast(_tracks[i].channel, SiOPMChannelFM) catch(e:Dynamic) null;
                if (ch != null)                     ch.operator[1].fixedPitchIndex = _opp1.fixedPitch;
            }
        }
        return nf;
    }
    
    
    /** PSG channel gain (*2db) (0=0db, 7=14db, 15=mute) */
    private function get_channelGain() : Int{return ((_channelTL > 37)) ? 15 : Math.round(_channelTL * 0.375 + 0.5);
    }
    private function set_channelGain(g : Int) : Int{
        _channelTL = ((g >= 15)) ? 127 : Math.round(g * 2.6666666666666667 + 0.5);
        _opp1.tl = _opp0.tl = _channelTL;
        if (_opp0.ssgec == 0) {
            var i : Int;
            var imax : Int = _tracks.length;
            var ch : SiOPMChannelFM;
            for (imax){
                ch = try cast(_tracks[i].channel, SiOPMChannelFM) catch(e:Dynamic) null;
                if (ch != null) {
                    ch.operator[0].tl = _opp0.tl;
                    ch.operator[1].tl = _opp0.tl;
                }
            }
        }
        return g;
    }
    
    
    /** SSG Envelop control mode, only 8-17 are valiable, 0-7 set as no envelop. The ssgec number of 16th and 17th are the extention of SiOPM. */
    private function get_envelopControlMode() : Int{return _opp0.ssgec;
    }
    private function set_envelopControlMode(ecm : Int) : Int{
        if (ecm < 8) {  // no envelop  
            _opp1.ssgec = _opp0.ssgec = 0;
            _opp1.dr = _opp0.dr = 0;
            _opp1.tl = _opp0.tl = _channelTL;
        }
        else {  // envelop control  
            _opp1.ssgec = _opp0.ssgec = ecm;
            _opp1.dr = _opp0.dr = _evelopRate;
            _opp1.tl = _opp0.tl = 0;
        }
        _voiceUpdateNumber++;
        return ecm;
    }
    
    
    /** envelop frequency ... currently dishonesty. */
    private function get_envelopFreq() : Int{return _evelopRate << 2;
    }
    private function set_envelopFreq(ef : Int) : Int{
        _evelopRate = ef >> 2;
        if (_opp0.ssgec != 0) {
            _opp1.dr = _opp0.dr = _evelopRate;
            _voiceUpdateNumber++;
        }
        return ef;
    }
    
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor 
     *  @param channelNumber pseudo channel number.
     */
    public function new(channelNumber : Int = 0)
    {
        super(0, channelNumber);
        _opp0 = _voice.channelParam.operatorParam[0];
        _opp1 = _voice.channelParam.operatorParam[1];
        _voice.channelParam.opeCount = 2;
        _voice.channelParam.alg = 1;
        _opp0.pgType = SiOPMTable.PG_SQUARE;
        _opp0.ptType = SiOPMTable.PT_PSG;
        _opp1.pgType = SiOPMTable.PG_NOISE;
        _opp1.ptType = SiOPMTable.PT_PSG_NOISE;
        _opp1.fixedPitch = 1;
        _opp1.mute = true;
    }
}



