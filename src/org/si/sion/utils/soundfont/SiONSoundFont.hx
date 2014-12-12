//----------------------------------------------------------------------------------------------------
// SiON sound font loader
//  Copyright (c) 2011 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.utils.soundfont;

import openfl.media.Sound;
import org.si.sion.namespaces.SionInternal;
import org.si.sion.*;
import org.si.sion.module.*;
import org.si.sion.sequencer.*;


/** SiON Sound font class. */
class SiONSoundFont
{
    // variables
    //--------------------------------------------------
    /** all loaded Sound instances, access them by id */
    public var sounds : Map<String, Dynamic>;
    
    /** all SiMMLEnvelopTable instances */
    public var envelopes : Array<SiMMLEnvelopTable> = new Array<SiMMLEnvelopTable>();
    
    /** all SiOPMWaveTable inetances */
    public var waveTables : Array<SiOPMWaveTable> = new Array<SiOPMWaveTable>();
    
    /** all fm voice instances */
    public var fmVoices : Array<SiONVoice> = new Array<SiONVoice>();
    
    /** all pcm voice instances */
    public var pcmVoices : Array<SiONVoice> = new Array<SiONVoice>();
    
    /** all sampler table instances */
    public var samplerTables : Array<SiOPMWaveSamplerTable> = new Array<SiOPMWaveSamplerTable>();
    
    /** default FPS */
    public var defaultFPS : Float = 60;
    /** default velocity mode */
    public var defaultVelocityMode : Int = 0;
    /** default expression mode */
    public var defaultExpressionMode : Int = 0;
    /** default v command shoft */
    public var defaultVCommandShift : Int = 4;
    
    
    
    
    // constructor
    //--------------------------------------------------
    /** constructor */
    public function new(sounds : Dynamic = null)
    {
        this.sounds = sounds;
        if (this.sounds == null) {
            this.sounds = new Map<String, Dynamic>();
        }
    }
    
    
    /** apply sound font to SiONData or SiONDriver.
     *  @param data SiONData to apply this font. null to set SiONDriver.
     *  @param pcmVoiceOffset index offset for pcmVoices
     *  @param samplerTableOffset index offset for samplerTable
     *  @param fmVoiceOffset index offset for fmVoices
     *  @param waveTableOffset index offset for waveTables
     *  @param envelopeOffset index offset for envelopes
     */
    public function apply(data : SiONData = null, pcmVoiceOffset : Int = 0, samplerTableOffset : Int = 0, fmVoiceOffset : Int = 0, waveTableOffset : Int = 0, envelopeOffset : Int = 0) : Void
    {
        var i : Int;
        if (data != null) {
            for (i in 0...pcmVoices.length) {
                if (pcmVoices[i] != null) data.pcmVoices[pcmVoiceOffset + i] = pcmVoices[i];
            }
            for (i in 0...samplerTables.length) {
                if (samplerTables[i] != null) data.samplerTables[samplerTableOffset + i] = samplerTables[i];
            }
            for (i in 0...fmVoices.length) {
                if (fmVoices[i] != null) data.fmVoices[fmVoiceOffset + i] = fmVoices[i];
            }
            for (i in 0...waveTables.length) {
                if (waveTables[i] != null) data.waveTables[waveTableOffset + i] = waveTables[i];
            }
            for (i in 0...envelopes.length) {
                if (envelopes[i] != null)  data.envelopes[envelopeOffset + i] = envelopes[i];
            }
            data.defaultFPS = Std.int(defaultFPS);
            data.defaultVelocityMode = defaultVelocityMode;
            data.defaultExpressionMode = defaultExpressionMode;
            data.defaultVCommandShift = defaultVCommandShift;
        }
        else {
            var driver : SiONDriver = SiONDriver.mutex;
            if (driver != null) {
                for (i in 0...pcmVoices.length) {
                    if (pcmVoices[i] != null) driver.setPCMVoice(pcmVoiceOffset + i, pcmVoices[i]);
                }
                for (i in 0...samplerTables.length) {
                    if (samplerTables[i] != null) driver.setSamplerTable(samplerTableOffset + i, samplerTables[i]);
                }
                for (i in 0...fmVoices.length) {
                    if (fmVoices[i] != null) driver.setVoice(fmVoiceOffset + i, fmVoices[i]);
                }
                for (i in 0...waveTables.length){
                    if (waveTables[i] != null) {
                        SiOPMTable._instance.registerExistingWaveTable(waveTableOffset + i, new SiOPMWaveTable().copyFrom(waveTables[i]));
                    }
                }
                for (i in 0...envelopes.length){
                    if (envelopes[i] != null) {
                        SiMMLTable.registerMasterEnvelopTable(envelopeOffset + i, new SiMMLEnvelopTable().copyFrom(envelopes[i]));
                    }
                }
            }
        }
    }
}


