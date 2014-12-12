//----------------------------------------------------------------------------------------------------
// class for SiOPM wave table
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module;


import org.si.sion.sequencer.SiMMLTable;

/** SiOPM wave table */
class SiOPMWaveTable extends SiOPMWaveBase
{
    public var wavelet : Array<Int>;
    public var fixedBits : Int;
    public var defaultPTType : Int;
    
    
    /** create new SiOPMWaveTable instance. */
    public function new()
    {
        super(SiMMLTable.MT_CUSTOM);
        this.wavelet = null;
        this.fixedBits = 0;
        this.defaultPTType = 0;
    }
    
    
    /** initialize 
     *  @param wavelet wave table in log scale.
     *  @param defaultPTType default pitch table type.
     */
    public function initialize(wavelet : Array<Int>, defaultPTType : Int = 0) : SiOPMWaveTable
    {
        var len : Int;
        var bits : Int = 0;
        len = wavelet.length >> 1;
        while (len != 0){bits++;
            len >>= 1;
        }
        
        this.wavelet = wavelet;
        this.fixedBits = SiOPMTable.PHASE_BITS - bits;
        this.defaultPTType = defaultPTType;
        
        return this;
    }
    
    
    /** copy 
     *  @return this instance
     */
    public function copyFrom(src : SiOPMWaveTable) : SiOPMWaveTable
    {
        var i : Int;
        var imax : Int = src.wavelet.length;
        this.wavelet = new Array<Int>();
        for (i in 0...imax) {
            this.wavelet[i] = src.wavelet[i];
        }
        this.fixedBits = src.fixedBits;
        this.defaultPTType = src.defaultPTType;
        
        return this;
    }
    
    
    /** free. */
    public function free() : Void
    {
        _freeList.push(this);
    }
    
    
    private static var _freeList : Array<SiOPMWaveTable> = new Array<SiOPMWaveTable>();
    
    
    /** allocate. */
    public static function alloc(wavelet : Array<Int>, defaultPTType : Int = 0) : SiOPMWaveTable
    {
        var newInstance : SiOPMWaveTable = _freeList.pop();
        if (newInstance == null) newInstance = new SiOPMWaveTable();
        return newInstance.initialize(wavelet, defaultPTType);
    }
}


