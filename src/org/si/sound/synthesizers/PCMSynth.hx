// Pulse Code Modulation Synthesizer
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.synthesizers;

import org.si.sion.module.SiOPMWavePCMData;
import org.si.sound.synthesizers.SiOPMWavePCMData;
import org.si.sound.synthesizers.SiOPMWavePCMTable;

import openfl.media.Sound;
import org.si.sion.*;
import org.si.sion.module.*;
import org.si.sion.sequencer.SiMMLTrack;


/** Pulse Code Modulation Synthesizer 
 */
class PCMSynth extends IFlashSoundOperator
{
    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    /** PCM table */
    private var _pcmTable : SiOPMWavePCMTable;
    /** default PCM data */
    private var _defaultPCMData : SiOPMWavePCMData;
    
    
    
    
    // properties
    //----------------------------------------
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor
     *  @param data wave data, Sound or Vector.&lt;Number&gt; can be set, the Sound is extracted inside.
     *  @param samplingNote sampling data's note, this argument allows decimal number.
     *  @param channelCount channel count of playing PCM.
     */
    public function new(data : Dynamic = null, samplingNote : Float = 68, channelCount : Int = 2)
    {
        super();
        _defaultPCMData = new SiOPMWavePCMData(data, Math.floor(samplingNote * 64), channelCount, 0);
        _pcmTable = new SiOPMWavePCMTable();
        _pcmTable.clear(_defaultPCMData);
        _voice.waveData = _pcmTable;
    }
    
    
    
    
    // operation
    //----------------------------------------
    /** Set PCM sample with key range (this feature is not available in currennt version).
     *  @param data wave data, Sound or Vector.&lt;Number&gt; can be set, the Sound is extracted inside.
     *  @param samplingNote sampling data's note, this argument allows decimal number.
     *  @param keyRangeFrom Assigning key range starts from
     *  @param keyRangeTo Assigning key range ends at. -1 to set only at the key of argument "keyRangeFrom".
     *  @param channelCount channel count of this data, 1 for monoral, 2 for stereo
     *  @return assigned SiOPMWavePCMData.
     */
    public function setSample(data : Dynamic, samplingNote : Float = 68, keyRangeFrom : Int = 0, keyRangeTo : Int = 127, channelCount : Int = 2) : SiOPMWavePCMData
    {
        var pcmData : SiOPMWavePCMData;
        if (keyRangeFrom == 0 && keyRangeTo == 127) {
            _defaultPCMData.initialize(data, Math.floor(samplingNote * 64), channelCount, 0);
            pcmData = _defaultPCMData;
        }
        else {
            pcmData = new SiOPMWavePCMData(data, Math.floor(samplingNote * 64), channelCount, 0);
        }
        _voiceUpdateNumber++;
        return _pcmTable.setSample(pcmData, keyRangeFrom, keyRangeTo);
    }
}



