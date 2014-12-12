//----------------------------------------------------------------------------------------------------
// class for PCM module channel
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.simulator;

import org.si.sion.sequencer.simulator.SiMMLSimulatorVoiceSet;

import org.si.sion.module.SiOPMTable;
import org.si.sion.module.channels.SiOPMChannelManager;


/** Simple sampler simulator */
class SiMMLSimulatorSampler extends SiMMLSimulatorBase
{
    public function new()
    {
        super(SiMMLSimulatorBase.MT_SAMPLE, 1, false);
        this._defaultVoiceSet = new SiMMLSimulatorVoiceSet(SiOPMChannelManager.CT_CHANNEL_SAMPLER, 1, 0);
    }
}


