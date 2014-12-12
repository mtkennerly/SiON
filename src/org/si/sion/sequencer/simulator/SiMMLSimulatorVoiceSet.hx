//----------------------------------------------------------------------------------------------------
// class for SiMML sequencer setting
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.simulator;


import org.si.sion.module.SiOPMTable;

/** @private set of vioce setting for SiMMLSimulators */
class SiMMLSimulatorVoiceSet
{
    // variables
    //--------------------------------------------------
    public var voices : Array<SiMMLSimulatorVoice>;
    public var initVoiceIndex : Int;
    
    
    
    
    // constructor
    //--------------------------------------------------
    /** offset > -1 sets all voice instances */
    public function new(length : Int, offset : Int = -1, channelType : Int = -1)
    {
        this.initVoiceIndex = 0;
        this.voices = new Array<SiMMLSimulatorVoice>();
        if (offset != -1) {
            var i : Int;
            var ptType : Int;
            if (channelType == -1) channelType = SiMMLChannelSetting.SELECT_TONE_FM;
            for (i in 0...length ){
                ptType = SiOPMTable.instance.getWaveTable(i + offset).defaultPTType;
                this.voices[i] = new SiMMLSimulatorVoice(i + offset, ptType, channelType);
            }
        }
    }
}
