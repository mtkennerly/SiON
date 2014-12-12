//----------------------------------------------------------------------------------------------------
// class for YM2151 simulartor
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.simulator;


import org.si.sion.sequencer.SiMMLTrack;
import org.si.sion.module.SiOPMTable;
import org.si.sion.sequencer.SiMMLVoice;
import org.si.sion.sequencer.SiMMLTable;
import org.si.sion.sequencer.base.MMLSequence;



/** YAMAHA YM2151 simulartor */
class SiMMLSimulatorFMOPM extends SiMMLSimulatorBaseFM
{
    public function new()
    {
        super(SiMMLSimulatorBase.MT_FM_OPM, 1);
    }
}


