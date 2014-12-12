//----------------------------------------------------------------------------------------------------
// SiOPM HP filter
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;


/** HPF. */
class SiFilterHighPass extends SiFilterBase
{
    // constructor
    //------------------------------------------------------------
    /** constructor.
     *  @param freq cutoff frequency[Hz].
     *  @param band band width [oct].
     */
    public function new(freq : Float = 5500, band : Float = 1)
    {
        super();
        setParameters(freq, band);
    }
    
    
    
    
    // operations
    //------------------------------------------------------------
    /** set parameters
     *  @param freq cutoff frequency[Hz].
     *  @param band band width [oct].
     */
    public function setParameters(freq : Float = 5500, band : Float = 1) : Void
    {
        var omg : Float = freq * 0.00014247585730565955;
        var cos : Float = Math.cos(omg);
        var sin : Float = Math.sin(omg);
        var alp : Float = sin * sinh(0.34657359027997264 * band * omg / sin);
        var ia0 : Float = 1 / (1 + alp);
        _a1 = -2 * cos * ia0;
        _a2 = (1 - alp) * ia0;
        _b1 = -(1 + cos) * ia0;
        _b2 = _b0 = -_b1 * 0.5;
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
                ((!Math.isNaN(args[1]))) ? args[1] : 1);
    }
}


