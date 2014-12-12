// Sampler Synthesizer
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.synthesizers;

import org.si.sound.synthesizers.SiOPMWaveSamplerData;
import org.si.sound.synthesizers.SiOPMWaveSamplerTable;

import openfl.media.Sound;
import org.si.sion.*;
import org.si.sion.module.*;
import org.si.sion.sequencer.SiMMLTrack;


/** Sampler Synthesizer
 */
class SamplerSynth extends IFlashSoundOperator
{
    public var ignoreNoteOff(get, set) : Bool;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    /** sample table */
    private var _samplerTable : SiOPMWaveSamplerTable;
    /** default PCM data */
    private var _defaultSamplerData : SiOPMWaveSamplerData;
    
    
    
    
    // properties
    //----------------------------------------
    /** true to ignore note off */
    private function get_ignoreNoteOff() : Bool{return _defaultSamplerData.ignoreNoteOff;
    }
    private function set_ignoreNoteOff(b : Bool) : Bool{
        _defaultSamplerData.ignoreNoteOff = b;
        _voiceUpdateNumber++;
        return b;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor 
     *  @param data wave data, Sound or Vector.&lt;Number&gt;, the Sound is extracted when the length is shorter than 4[sec].
     *  @param ignoreNoteOff flag to ignore note off
     *  @param channelCount channel count of this data, 1 for monoral, 2 for stereo
     */
    public function new(data : Dynamic = null, ignoreNoteOff : Bool = false, channelCount : Int = 2)
    {
        super();
        _defaultSamplerData = new SiOPMWaveSamplerData(data, ignoreNoteOff, channelCount);
        _samplerTable = new SiOPMWaveSamplerTable();
        _samplerTable.clear(_defaultSamplerData);
        _voice.waveData = _samplerTable;
    }
    
    
    
    
    // operation
    //----------------------------------------
    /** Set sample with key range.
     *  @param data wave data, Sound or Vector.&lt;Number&gt; can be set, the Sound is extracted when the length is shorter than 4[sec].
     *  @param ignoreNoteOff flag to ignore note off
     *  @param keyRangeFrom Assigning key range starts from
     *  @param keyRangeTo Assigning key range ends at. -1 to set only at the key of argument "keyRangeFrom".
     *  @param channelCount channel count of this data, 1 for monoral, 2 for stereo
     *  @return assigned SiOPMWavePCMData.
     */
    public function setSample(data : Dynamic, ignoreNoteOff : Bool = false, keyRangeFrom : Int = 0, keyRangeTo : Int = 127, channelCount : Int = 2) : SiOPMWaveSamplerData
    {
        var sample : SiOPMWaveSamplerData;
        if (keyRangeFrom == 0 && keyRangeTo == 127) {
            _defaultSamplerData.initialize(data, ignoreNoteOff, channelCount, 0);
            sample = _defaultSamplerData;
        }
        else {
            sample = new SiOPMWaveSamplerData(data, ignoreNoteOff, channelCount, 0);
        }
        _voiceUpdateNumber++;
        return _samplerTable.setSample(sample, keyRangeFrom, keyRangeTo);
    }
}



