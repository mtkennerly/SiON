//----------------------------------------------------------------------------------------------------
// SiON effect basic class
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;


/** Effector basic class. */
class SiEffectBase
{
    // variables
    //------------------------------------------------------------
    /** @private [internal] used by manager */
    @:allow(org.si.sion.effector)
    private var _isFree : Bool = true;
    
    
    
    // constructor
    //------------------------------------------------------------
    /** Constructor. do nothing. */
    public function new()
    {
    }
    
    
    
    
    // callback functions
    //------------------------------------------------------------
    /** Initializer. The system calls this when the instance is created. */
    public function initialize() : Void
    {
        
    }
    
    
    /** Parameter setting by mml arguments. The sequencer calls this when "#EFFECT" appears.
     *  @param args The arguments refer from mml. The value of Number.NaN is put when its abbriviated.
     */
    public function mmlCallback(args : Array<Float>) : Void
    {
        
    }
    
    
    /** Prepare processing. The system calls this before processing.
     *  @return requesting channels count.
     */
    public function prepareProcess() : Int
    {
        return 1;
    }
    
    
    /** Process effect to stream buffer. The system calls this to process.
     *  @param channels Stream channel count. 1=monoral(same data in buffer[i*2] and buffer[i*2+1]). 2=stereo.
     *  @param buffer Stream buffer to apply effect. The order is same as wave format [L0,R0,L1,R1,L2,R2 ... ].
     *  @param startIndex startIndex to apply effect. You CANNOT use this index to the stream buffer directly. Should be doubled because its a stereo stream.
     *  @param length length to apply effect. You CANNOT use this length to the stream buffer directly. Should be doubled because its a stereo stream.
     *  @return output channels count.
     */
    public function process(channels : Int, buffer : Array<Float>, startIndex : Int, length : Int) : Int
    {
        return channels;
    }
}


