//----------------------------------------------------------------------------------------------------
// class for SiOPM samplers wave table
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module;

import openfl.errors.Error;

import org.si.sion.sequencer.SiMMLTable;


/** SiOPM samplers wave table */
class SiOPMWaveSamplerTable extends SiOPMWaveBase
{
    // variables
    //----------------------------------------
    /** Stencil table, search sample in stencil table before seaching this instances table. */
    public var stencil : SiOPMWaveSamplerTable;
    
    // SiOPMWaveSamplerData table to refer from sampler channel.
    private var _table : Array<SiOPMWaveSamplerData>;
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor 
     *  @param waveList SiOPMWaveSamplerData list to set as table
     */
    public function new()
    {
        super(SiMMLTable.MT_SAMPLE);
        _table = new Array<SiOPMWaveSamplerData>();
        stencil = null;
        clear();
    }
    
    
    
    
    // oprations
    //----------------------------------------
    /** Clear all of the table. 
     *  @param sampleData SiOPMWaveSamplerData to fill with.
     *  @return this instance
     */
    public function clear(sampleData : SiOPMWaveSamplerData = null) : SiOPMWaveSamplerTable
    {
        for (i in 0...SiOPMTable.SAMPLER_DATA_MAX){_table[i] = sampleData;
        }
        return this;
    }
    
    
    /** Set sample data.
     *  @param sample assignee SiOPMWaveSamplerData
     *  @param keyRangeFrom Assigning key range starts from
     *  @param keyRangeTo Assigning key range ends at. -1 to set only at the key of argument "keyRangeFrom".
     *  @return assigned SiOPMWaveSamplerData (same as sample passed as the 1st argument).
     */
    public function setSample(sample : SiOPMWaveSamplerData, keyRangeFrom : Int = 0, keyRangeTo : Int = -1) : SiOPMWaveSamplerData
    {
        if (keyRangeFrom < 0)             keyRangeFrom = 0;
        if (keyRangeTo > 127)             keyRangeTo = 127;
        if (keyRangeTo == -1)             keyRangeTo = keyRangeFrom;
        if (keyRangeFrom > 127 || keyRangeTo < 0 || keyRangeTo < keyRangeFrom) throw new Error("SiOPMWaveSamplerTable error; Invalid key range");
        for (i in keyRangeFrom...keyRangeTo + 1) {
            _table[i] = sample;
        }
        return sample;
    }
    
    
    /** Get sample data.
     *  @param sampleNumber Sample number (0-127).
     *  @return assigned SiOPMWaveSamplerData
     */
    public function getSample(sampleNumber : Int) : SiOPMWaveSamplerData
    {
        if (stencil != null) {
            return stencil._table[sampleNumber];
        }
        return _table[sampleNumber];
    }
    
    
    /** @private [internal use] free all */
    public function _free() : Void
    {
        for (i in 0...SiOPMTable.SAMPLER_DATA_MAX) {
            _table[i] = null;
        }
    }
}


