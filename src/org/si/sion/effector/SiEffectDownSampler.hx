//----------------------------------------------------------------------------------------------------
// Down sampler
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;


/** Down sampler. */
class SiEffectDownSampler extends SiEffectBase
{
    // variables
    //------------------------------------------------------------
    private var _freqShift : Int = 0;
    private var _bitConv0 : Float = 1;
    private var _bitConv1 : Float = 1;
    private var _channelCount : Int = 2;
    
    
    
    
    // constructor
    //------------------------------------------------------------
    /** Constructor. 
     *  @param freqShift frequency shift 0=44.1kHz, 1=22.05kHz, 2=11.025kHz.
     *  @param bitRate bit rate of the sample
     *  @param channelCount channel count 1=monoral, 2=stereo
     */
    public function new(freqShift : Int = 0, bitRate : Int = 16, channelCount : Int = 2)
    {
        super();
        setParameters(freqShift, bitRate, channelCount);
    }
    
    
    /** set parameter
     *  @param freqShift frequency shift 0=44.1kHz, 1=22.05kHz, 2=11.025kHz.
     *  @param bitRate bit rate of the sample
     *  @param channelCount channel count 1=monoral, 2=stereo
     */
    public function setParameters(freqShift : Int = 0, bitRate : Int = 16, channelCount : Int = 2) : Void
    {
        _freqShift = freqShift;
        _bitConv0 = 1 << bitRate;
        _bitConv1 = 1 / _bitConv0;
        _channelCount = channelCount;
    }
    
    
    
    
    // callback functions
    //------------------------------------------------------------
    /** @private */
    override public function initialize() : Void
    {
        setParameters();
    }
    
    
    /** @private */
    override public function mmlCallback(args : Array<Float>) : Void
    {
        setParameters(((!Math.isNaN(args[0]))) ? Math.floor(args[0]) : 0,
                ((!Math.isNaN(args[1]))) ? Math.floor(args[1]) : 16,
                ((!Math.isNaN(args[2]))) ? Math.floor(args[2]) : 2);
    }
    
    
    /** @private */
    override public function prepareProcess() : Int
    {
        return 2;
    }
    
    
    /** @private */
    override public function process(channels : Int, buffer : Array<Float>, startIndex : Int, length : Int) : Int
    {
        startIndex <<= 1;
        length <<= 1;
        var i : Int;
        var j : Int;
        var jmax : Int;
        var bc0 : Float;
        var l : Float;
        var r : Float;
        var imax : Int = startIndex + length;
        if (_channelCount == 1) {
            switch (_freqShift)
            {
                case 0:
                    bc0 = 0.5 * _bitConv0;
                    i = startIndex;
                    while (i < imax){
                        l = buffer[i];i++;
                        l += buffer[i];i--;
                        l = (Math.floor(l * bc0)) * _bitConv1;
                        buffer[i] = l;i++;
                        buffer[i] = l;i++;
                    }
                case 1:
                    bc0 = 0.25 * _bitConv0;
                    i = startIndex;
                    while (i < imax){
                        l = buffer[i];i++;
                        l += buffer[i];i++;
                        l += buffer[i];i++;
                        l += buffer[i];i -= 3;
                        l = (Math.floor(l * bc0)) * _bitConv1;
                        buffer[i] = l;i++;
                        buffer[i] = l;i++;
                        buffer[i] = l;i++;
                        buffer[i] = l;i++;
                    }
                case 2:
                    bc0 = 0.125 * _bitConv0;
                    i = startIndex;
                    while (i < imax){
                        l = buffer[i];i++;
                        l += buffer[i];i++;
                        l += buffer[i];i++;
                        l += buffer[i];i++;
                        l += buffer[i];i++;
                        l += buffer[i];i++;
                        l += buffer[i];i++;
                        l += buffer[i];i -= 7;
                        l = (Math.floor(l * bc0)) * _bitConv1;
                        buffer[i] = l;i++;
                        buffer[i] = l;i++;
                        buffer[i] = l;i++;
                        buffer[i] = l;i++;
                        buffer[i] = l;i++;
                        buffer[i] = l;i++;
                        buffer[i] = l;i++;
                        buffer[i] = l;i++;
                    }
                default:
                    jmax = 2 << _freqShift;
                    bc0 = (1 / jmax) * _bitConv0;
                    i = startIndex;
                    while (i < imax){
                        j = 0;
                        l = 0;
                        while (j < jmax){
                            l += buffer[i];
                            j++;
                            i++;
                        }
                        i -= jmax;
                        l = (Math.floor(l * bc0)) * _bitConv1;
                        j = 0;
                        while (j < jmax){
                            buffer[i] = l;
                            j++;
                            i++;
                        }
                    }
            }
        }
        else {
            switch (_freqShift)
            {
                case 0:
                    for (i in 0...imax){
                        buffer[i] = (Math.floor(buffer[i] * _bitConv0)) * _bitConv1;
                    }
                case 1:
                    bc0 = 0.5 * _bitConv0;
                    i = startIndex;
                    while (i < imax){
                        l = buffer[i];i++;
                        r = buffer[i];i++;
                        l += buffer[i];i++;
                        r += buffer[i];i -= 3;
                        l = (Math.floor(l * bc0)) * _bitConv1;
                        r = (Math.floor(r * bc0)) * _bitConv1;
                        buffer[i] = l;i++;
                        buffer[i] = r;i++;
                        buffer[i] = l;i++;
                        buffer[i] = r;i++;
                    }
                case 2:
                    bc0 = 0.25 * _bitConv0;
                    i = startIndex;
                    while (i < imax){
                        l = buffer[i];i++;
                        r = buffer[i];i++;
                        l += buffer[i];i++;
                        r += buffer[i];i++;
                        l += buffer[i];i++;
                        r += buffer[i];i++;
                        l += buffer[i];i++;
                        r += buffer[i];i -= 7;
                        l = (Math.floor(l * bc0)) * _bitConv1;
                        r = (Math.floor(r * bc0)) * _bitConv1;
                        buffer[i] = l;i++;
                        buffer[i] = r;i++;
                        buffer[i] = l;i++;
                        buffer[i] = r;i++;
                        buffer[i] = l;i++;
                        buffer[i] = r;i++;
                        buffer[i] = l;i++;
                        buffer[i] = r;i++;
                    }
                default:
                    jmax = 1 << _freqShift;
                    bc0 = (1 / jmax) * _bitConv0;
                    i = startIndex;
                    while (i < imax){
                        j = 0;
                        l = 0;
                        r = 0;
                        while (j < jmax){
                            l += buffer[i];
                            r += buffer[i];
                            j++;
                            i++;
                        }
                        i -= jmax;
                        l = (Math.floor(l * bc0)) * _bitConv1;
                        r = (Math.floor(r * bc0)) * _bitConv1;
                        for (j in 0...jmax){
                            buffer[i] = l;i++;
                            buffer[i] = r;i++;
                        }
                    }
            }
        }
        return _channelCount;
    }
}


