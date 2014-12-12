//----------------------------------------------------------------------------------------------------
// class for SiMML sequencer setting
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.simulator;


/** @private vioce setting for SiMMLSimulators */
class SiMMLSimulatorVoice
{
    // variables
    //--------------------------------------------------
    public var pgType : Int;
    public var ptType : Int;
    public var channelType : Int;
    
    
    
    // constructor
    //--------------------------------------------------
    public function new(pgType : Int, ptType : Int, channelType : Int = -1)
    {
        this.pgType = pgType;
        this.ptType = ptType;
        this.channelType = ((channelType == -1)) ? SiMMLChannelSetting.SELECT_TONE_FM : channelType;
    }
}
