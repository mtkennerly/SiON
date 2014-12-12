//----------------------------------------------------------------------------------------------------
// SiOPM High booster
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;


/** High booster. */
class SiFilterHighBoost extends SiFilterBase
{
    // constructor
    //------------------------------------------------------------
    /** constructor.
     *  @param freq shelfing frequency[Hz].
     *  @param slope slope, 1 for steepest slope.
     *  @param gain gain [dB].
     */
    public function new(freq : Float = 5500, slope : Float = 1, gain : Float = 6)
    {
        super();
        setParameters(freq, slope, gain);
    }
    
    
    
    
    // operations
    //------------------------------------------------------------
    /** set parameters
     *  @param freq shelfing frequency[Hz].
     *  @param slope slope, 1 for steepest slope.
     *  @param gain gain [dB].
     */
    public function setParameters(freq : Float = 5500, slope : Float = 1, gain : Float = 6) : Void{
        if (slope < 1)             slope = 1;
        var A : Float = Math.pow(10, gain * 0.025);
        var omg : Float = freq * 0.00014247585730565955;
        var cos : Float = Math.cos(omg);
        var sin : Float = Math.sin(omg);
        var alp : Float = sin * 0.5 * Math.sqrt((A + 1 / A) * (1 / slope - 1) + 2);
        var alpsA2 : Float = alp * Math.sqrt(A) * 2;
        var ia0 : Float = 1 / ((A + 1) - (A - 1) * cos + alpsA2);
        _a1 = 2 * ((A - 1) - (A + 1) * cos) * ia0;
        _a2 = ((A + 1) - (A - 1) * cos - alpsA2) * ia0;
        _b0 = ((A + 1) + (A - 1) * cos + alpsA2) * A * ia0;
        _b1 = -2 * ((A - 1) + (A + 1) * cos) * A * ia0;
        _b2 = ((A + 1) + (A - 1) * cos - alpsA2) * A * ia0;
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
        setParameters(((!Math.isNaN(args[0]))) ? args[0] : 5500,
                ((!Math.isNaN(args[1]))) ? args[1] : 1,
                ((!Math.isNaN(args[2]))) ? args[2] : 6);
    }
}


