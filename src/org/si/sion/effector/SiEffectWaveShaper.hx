//----------------------------------------------------------------------------------------------------
// SiOPM effect wave shaper
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;


/** Stereo wave shaper. */
class SiEffectWaveShaper extends SiEffectBase
{
    // variables
    //------------------------------------------------------------
    private var _coefficient : Int;
    private var _outputLevel : Float;
    
    
    
    
    // constructor
    //------------------------------------------------------------
    /** constructor
     *  @param distortion distortion(0-1).
     *  @param outputLevel output level(0-1).
     */
    public function new(distortion : Float = 0.5, outputLevel : Float = 1.0)
    {
        super();
        setParameters(distortion, outputLevel);
    }
    
    
    
    
    // operations
    //------------------------------------------------------------
    /** set parameters
     *  @param distortion distortion(0-1).
     *  @param outputLevel output level(0-1).
     */
    public function setParameters(distortion : Float = 0.5, outputLevel : Float = 1.0) : Void
    {
        if (distortion >= 1) distortion = 0.9999847412109375;  //65535/65536
        _coefficient = Math.floor(2 * distortion / (1 - distortion));
        _outputLevel = outputLevel;
    }
    
    
    
    
    // overrided funcitons
    //------------------------------------------------------------
    /** @private */
    override public function initialize() : Void
    {
        setParameters();
    }
    
    
    /** @private */
    override public function mmlCallback(args : Array<Float>) : Void
    {
        setParameters(((!Math.isNaN(args[0]))) ? args[0] * 0.01 : 0.5,
                ((!Math.isNaN(args[1]))) ? args[1] * 0.01 : 1.0);
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
        var n : Float;
        var c1 : Float = (1 + _coefficient) * _outputLevel;
        var imax : Int = startIndex + length;
        if (channels == 2) {
            for (i in 0...imax){
                n = buffer[i];
                buffer[i] = c1 * n / (1 + _coefficient * (((n < 0)) ? -n : n));
            }
        }
        else {
            i = startIndex;
            while (i < imax){
                n = buffer[i];
                n = c1 * n / (1 + _coefficient * (((n < 0)) ? -n : n));
                buffer[i] = n;i++;
                buffer[i] = n;i++;
            }
        }
        return channels;
    }
}


