//----------------------------------------------------------------------------------------------------
// class for VRC6 Simulator
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion.sequencer.simulator;


import org.si.sion.module.SiOPMTable;


/** KONAMI VRC6 Simulator */
class SiMMLSimulatorVRC6 extends SiMMLSimulatorBase
{
    public function new()
    {
        super(SiMMLSimulatorBase.MT_VRC6, 4);
        
        var i : Int;
        var toneVoiceSet : SiMMLSimulatorVoiceSet;
        
        // default voice set
        this._defaultVoiceSet = new SiMMLSimulatorVoiceSet(9);
        for (i in 0...8){
            this._defaultVoiceSet.voices[i] = new SiMMLSimulatorVoice(SiOPMTable.PG_PULSE + i, SiOPMTable.PT_PSG);
        }
        this._defaultVoiceSet.voices[8] = new SiMMLSimulatorVoice(SiOPMTable.PG_SAW_VC6, SiOPMTable.PT_PSG);
        this._defaultVoiceSet.initVoiceIndex = 7;
        
        // voice set for channel 1,2
        toneVoiceSet = new SiMMLSimulatorVoiceSet(8);
        toneVoiceSet.initVoiceIndex = 4;
        for (i in 0...8){
            toneVoiceSet.voices[i] = new SiMMLSimulatorVoice(SiOPMTable.PG_PULSE + i, SiOPMTable.PT_PSG);
        }
        this._channelVoiceSet[0] = toneVoiceSet;
        this._channelVoiceSet[1] = toneVoiceSet;
        
        // voice set for channel 3
        toneVoiceSet = new SiMMLSimulatorVoiceSet(1);
        toneVoiceSet.initVoiceIndex = 0;
        toneVoiceSet.voices[0] = new SiMMLSimulatorVoice(SiOPMTable.PG_SAW_VC6, SiOPMTable.PT_PSG);
        this._channelVoiceSet[2] = toneVoiceSet;
    }
}


