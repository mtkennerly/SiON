//----------------------------------------------------------------------------------------------------
// SiOPM Peaking filter
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;


/** Peaking EQ. */
class SiFilterPeak extends SiFilterBase
{
    // constructor
    //------------------------------------------------------------
    /** constructor.
     *  @param freq cutoff frequency[Hz].
     *  @param band band width [oct].
     *  @param gain gain [dB].
     */
    public function new(freq : Float = 3000, band : Float = 1, gain : Float = 6)
    {
        super();
        setParameters(freq, band);
    }
    
    
    
    
    // operations
    //------------------------------------------------------------
    /** set parameters
     *  @param freq cutoff frequency[Hz].
     *  @param band band width [oct].
     *  @param gain gain [dB].
     */
    public function setParameters(freq : Float = 3000, band : Float = 1, gain : Float = 6) : Void{
        var A : Float = Math.pow(10, gain * 0.025);
        var omg : Float = freq * 0.00014247585730565955;
        var cos : Float = Math.cos(omg);
        var sin : Float = Math.sin(omg);
        var alp : Float = sin * sinh(0.34657359027997264 * band * omg / sin);
        var alpA : Float = alp * A;
        var alpiA : Float = alp / A;
        var ia0 : Float = 1 / (1 + alpiA);
        _b1 = _a1 = -2 * cos * ia0;
        _a2 = (1 - alpiA) * ia0;
        _b0 = (1 + alpA) * ia0;
        _b2 = (1 - alpA) * ia0;
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
        setParameters(((!Math.isNaN(args[0]))) ? args[0] : 3000,
                ((!Math.isNaN(args[1]))) ? args[1] : 1,
                ((!Math.isNaN(args[2]))) ? args[2] : 6);
    }
}


