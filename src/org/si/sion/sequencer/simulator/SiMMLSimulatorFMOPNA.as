//----------------------------------------------------------------------------------------------------
// class for YM2608 simulartor
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.simulator {
    import org.si.sion.sequencer.SiMMLTrack;
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.sequencer.SiMMLVoice;
    import org.si.sion.sequencer.SiMMLTable;
    import org.si.sion.sequencer.base.MMLSequence;
    import org.si.sion.sequencer.base._sion_sequencer_internal;
    
    
    /** YAMAHA YM2608 simulartor */
    public class SiMMLSimulatorFMOPNA extends SiMMLSimulatorBaseFM
    {
        function SiMMLSimulatorFMOPNA()
        {
            super(MT_FM_OPN, 1);
        }
    }
}

