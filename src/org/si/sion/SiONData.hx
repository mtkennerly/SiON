//----------------------------------------------------------------------------------------------------
// SiON data
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion;

import openfl.media.Sound;
import org.si.sion.sequencer.SiMMLVoice;
import org.si.sion.sequencer.SiMMLData;
import org.si.sion.sequencer.SiMMLEnvelopTable;

import org.si.sion.utils.SiONUtil;
import org.si.sion.module.ISiOPMWaveInterface;
import org.si.sion.module.SiOPMTable;
import org.si.sion.module.SiOPMWavePCMTable;
import org.si.sion.module.SiOPMWavePCMData;
import org.si.sion.module.SiOPMWaveSamplerTable;
import org.si.sion.module.SiOPMWaveSamplerData;



/** The SiONData class provides musical score (and voice settings) data of SiON.
 */
class SiONData extends SiMMLData implements ISiOPMWaveInterface
{
    // constructor
    //----------------------------------------
    public function new()
    {
        super();
    }
    
    // setter
    //----------------------------------------
    /** Set PCM wave data refered by %7.
     *  @param index PCM data number.
     *  @param data wave data, Sound, Vector.&lt;Number&gt; or Vector.&lt;int&gt; is available. The Sound instance is extracted internally, the maximum length to extract is SiOPMWavePCMData.maxSampleLengthFromSound[samples].
     *  @param samplingNote Sampling wave's original note number, this allows decimal number
     *  @param keyRangeFrom Assigning key range starts from (not implemented in current version)
     *  @param keyRangeTo Assigning key range ends at (not implemented in current version)
     *  @param srcChannelCount channel count of source data, 1 for monoral, 2 for stereo.
     *  @param channelCount channel count of this data, 1 for monoral, 2 for stereo, 0 sets same with srcChannelCount.
     *  @see #org.si.sion.module.SiOPMWavePCMData.maxSampleLengthFromSound
     *  @see #org.si.sion.SiONDriver.render()
     */
    public function setPCMWave(index : Int, data : Dynamic, samplingNote : Float = 69, keyRangeFrom : Int = 0, keyRangeTo : Int = 127, srcChannelCount : Int = 2, channelCount : Int = 0) : SiOPMWavePCMData
    {
        var pcmTable : SiOPMWavePCMTable = try cast(_getPCMVoice(index).waveData, SiOPMWavePCMTable) catch(e:Dynamic) null;

        if (pcmTable == null) {
            return null;
        }

        var samplerData = new SiOPMWavePCMData();
        samplerData.initializeFromSound(data, Math.floor(samplingNote * 64), srcChannelCount, channelCount);
        return pcmTable.setSample(samplerData, keyRangeFrom, keyRangeTo);
    }
    
    
    /** Set sampler wave data refered by %10.
     *  @param index note number. 0-127 for bank0, 128-255 for bank1.
     *  @param data wave data, Sound, Vector.&lt;Number&gt; or Vector.&lt;int&gt; is available. The Sound is extracted when the length is shorter than SiOPMWaveSamplerData.extractThreshold[msec].
     *  @param ignoreNoteOff True to set ignoring note off.
     *  @param pan pan of this sample [-64 - 64].
     *  @param srcChannelCount channel count of source data, 1 for monoral, 2 for stereo.
     *  @param channelCount channel count of this data, 1 for monoral, 2 for stereo, 0 sets same with srcChannelCount.
     *  @return created data instance
     *  @see #org.si.sion.module.SiOPMWaveSamplerData.extractThreshold
     *  @see #org.si.sion.SiONDriver.render()
     */
    public function setSamplerWave(index : Int, data : Dynamic, ignoreNoteOff : Bool = false, pan : Int = 0, srcChannelCount : Int = 2, channelCount : Int = 0) : SiOPMWaveSamplerData
    {
        var bank : Int = (index >> SiOPMTable.NOTE_BITS) & (SiOPMTable.SAMPLER_TABLE_MAX - 1);

        var samplerData = new SiOPMWaveSamplerData();
        samplerData.initializeFromSound(data, ignoreNoteOff, pan, srcChannelCount, channelCount);
        return samplerTables[bank].setSample(samplerData, index & (SiOPMTable.NOTE_TABLE_SIZE - 1));
    }
    
    
    /** Set pcm voice 
     *  @param index PCM data number.
     *  @param voice pcm voice to set, ussualy from SiONSoundFont
     *  @return cloned internal voice data
     */
    public function setPCMVoice(index : Int, voice : SiONVoice) : Void
    {
        pcmVoices[index & (pcmVoices.length - 1)] = voice;
    }
    
    
    /** Set sampler table 
     *  @param bank bank number
     *  @param table sampler table class, ussualy from SiONSoundFont
     *  @see SiONSoundFont
     */
    public function setSamplerTable(bank : Int, table : SiOPMWaveSamplerTable) : Void
    {
        samplerTables[bank & (samplerTables.length - 1)] = table;
    }
    
    
    /** [NOT RECOMMENDED] This function is for a compatibility with previous versions, please use setPCMWave instead of this function. @see #setPCMWave(). */
    public function setPCMData(index : Int, data : Array<Float>, samplingOctave : Int = 5, keyRangeFrom : Int = 0, keyRangeTo : Int = 127, isSourceDataStereo : Bool = false) : SiOPMWavePCMData
    {
        return setPCMWave(index, data, samplingOctave * 12 + 8, keyRangeFrom, keyRangeTo, ((isSourceDataStereo)) ? 2 : 1);
    }
    
    
    /** [NOT RECOMMENDED] This function is for a compatibility with previous versions, please use setPCMWave instead of this function. @see #setPCMWave(). */
    public function setPCMSound(index : Int, sound : Sound, samplingOctave : Int = 5, keyRangeFrom : Int = 0, keyRangeTo : Int = 127) : SiOPMWavePCMData
    {
        return setPCMWave(index, sound, samplingOctave * 12 + 8, keyRangeFrom, keyRangeTo, 1, 0);
    }
    
    
    /** [NOT RECOMMENDED] This function is for a compatibility with previous versions, please use setSamplerWave instead of this function. @see #setSamplerWave(). */
    public function setSamplerData(index : Int, data : Array<Float>, ignoreNoteOff : Bool = false, channelCount : Int = 1) : SiOPMWaveSamplerData
    {
        return setSamplerWave(index, data, ignoreNoteOff, 0, channelCount);
    }
    
    
    /** [NOT RECOMMENDED] This function is for a compatibility with previous versions, please use setSamplerWave instead of this function. @see #setSamplerWave(). */
    public function setSamplerSound(index : Int, sound : Sound, ignoreNoteOff : Bool = false, channelCount : Int = 2) : SiOPMWaveSamplerData
    {
        return setSamplerWave(index, sound, ignoreNoteOff, 0, channelCount);
    }
}


