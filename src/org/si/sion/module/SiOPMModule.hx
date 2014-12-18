//----------------------------------------------------------------------------------------------------
// SiOPM sound module
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module;

import org.si.utils.SLLNumber;
import org.si.utils.SLLint;
import org.si.sion.module.channels.*;



/** SiOPM sound module */
class SiOPMModule
{
    public var output(get, never) : Array<Float>;
    public var channelCount(get, never) : Int;
    public var bitRate(get, never) : Int;
    public var bufferLength(get, never) : Int;

    // constants
    //--------------------------------------------------
    /** size of stream send */
    public static inline var STREAM_SEND_SIZE : Int = 8;
    /** pipe size */
    public static inline var PIPE_SIZE : Int = 5;
    
    
    
    
    // variables
    //--------------------------------------------------
    /** Intial values for operator parameters */
    public var initOperatorParam : SiOPMOperatorParam;
    /** zero buffer */
    public var zeroBuffer : SLLint;
    /** output stream */
    public var outputStream : SiOPMStream;
    /** slot of global mixer */
    public var streamSlot : Array<SiOPMStream>;
    /** pcm module volume @default 4 */
    public var pcmVolume : Float;
    /** sampler module volume @default 2 */
    public var samplerVolume : Float;
    
    private var _bufferLength : Int;  // buffer length  
    private var _bitRate : Int;  // bit rate  
    
    // pipes
    private var _pipeBuffer : Array<SLLint>;
    private var _pipeBufferPager : Array<Array<SLLint>>;
    
    
    // properties
    //--------------------------------------------------
    /** Buffer count */
    private function get_output() : Array<Float>{
        return outputStream.buffer;
    }
    /** Buffer channel count */
    private function get_channelCount() : Int{
        return outputStream.channels;
    }
    /** Bit rate */
    private function get_bitRate() : Int{
        return _bitRate;
    }
    /** Buffer length */
    private function get_bufferLength() : Int{
        return _bufferLength;
    }
    
    
    
    
    // constructor
    //--------------------------------------------------
    /** Default constructor
     *  @param busSize Number of mixing buses.
     */
    public function new()
    {
        trace('     ---------- SiOPMModule constructor ----------');
        // initial values
        initOperatorParam = new SiOPMOperatorParam();
        
        // stream buffer
        outputStream = new SiOPMStream();
        streamSlot = new Array<SiOPMStream>();
        
        // zero buffer gives always 0
        zeroBuffer = SLLint.allocRing(1);
        
        // others
        _bufferLength = 0;
        _pipeBuffer = new Array<SLLint>();
        _pipeBufferPager = new Array<Array<SLLint>>();
        
        // call at once
        SiOPMChannelManager.initialize(this);
    }
    
    
    
    
    // operation
    //--------------------------------------------------
    /** Initialize module and all tone generators.
     *  @param channelCount ChannelCount
     *  @param bitRate bit rate 
     *  @param bufferLength Maximum buffer size processing at once.
     */
    public function initialize(channelCount : Int, bitRate : Int, bufferLength : Int) : Void
    {
        trace('     ---------- SiOPMModule ----------');
        _bitRate = bitRate;
        
        var i : Int;
        var stream : SiOPMStream;
        
        // reset stream slot
        for (i in 0...STREAM_SEND_SIZE) {
            streamSlot[i] = null;
        }
        streamSlot[0] = outputStream;
        
        // reallocate buffer
        if (_bufferLength != bufferLength) {
            _bufferLength = bufferLength;
            // AS3 original: outputStream.buffer.length = bufferLength << 1;
            outputStream.buffer = new Array<Float>();
            for (i in 0...PIPE_SIZE) {
                SLLint.freeRing(_pipeBuffer[i]);
                _pipeBuffer[i] = SLLint.allocRing(bufferLength);
                _pipeBufferPager[i] = SLLint.createRingPager(_pipeBuffer[i], true);
            }
        }
        
        pcmVolume = 4;
        samplerVolume = 2;
        
        // initialize all channels
        SiOPMChannelManager.initializeAllChannels();
    }
    
    
    /** Reset. */
    public function reset() : Void
    {
        // reset all channels
        SiOPMChannelManager.resetAllChannels();
    }
    
    
    /** @private [sion internal] Clear output buffer. */
    public function _beginProcess() : Void
    {
        outputStream.clear();
    }
    
    
    /** @private [sion internal] Limit output level in the ranged between -1 ~ 1.*/
    public function _endProcess() : Void
    {
        outputStream.limit();
        if (_bitRate != 0) outputStream.quantize(_bitRate);
    }
    
    
    /** get pipe buffer */
    public function getPipe(pipeNum : Int, index : Int = 0) : SLLint
    {
        return _pipeBufferPager[pipeNum][index];
    }
}


