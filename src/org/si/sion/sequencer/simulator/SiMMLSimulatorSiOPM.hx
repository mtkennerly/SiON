//----------------------------------------------------------------------------------------------------
// class for Simulator of ramp waveform single operator sound generator
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.simulator;

import org.si.sion.sequencer.simulator.SiMMLSimulatorVoiceSet;

import org.si.sion.module.SiOPMTable;


/** Simulator of all SiOPM waveforms single operator sound generator */
class SiMMLSimulatorSiOPM extends SiMMLSimulatorBase
{
    public function new()
    {
        super(SiMMLSimulatorBase.MT_ALL, 1);
        this._defaultVoiceSet = new SiMMLSimulatorVoiceSet(512, SiOPMTable.PG_SINE);
    }
}


