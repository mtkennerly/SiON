//----------------------------------------------------------------------------------------------------
// class for SiOPM FM sound module
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.simulator;


import org.si.sion.sequencer.SiMMLTrack;
import org.si.sion.module.SiOPMTable;
import org.si.sion.sequencer.SiMMLVoice;
import org.si.sion.sequencer.SiMMLTable;
import org.si.sion.sequencer.base.MMLSequence;
import org.si.sion.sequencer.base.SionSequencerInternal;


/** SiOPM FM sound module simulator */
class SiMMLSimulatorFMSiOPM extends SiMMLSimulatorBaseFM
{
    public function new()
    {
        super(SiMMLSimulatorBase.MT_FM, 1);
    }
}

