//----------------------------------------------------------------------------------------------------
// SiOPM effect Stereo expander
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;


/** Stereo expander. matrix transformation of stereo sound. */
class SiEffectStereoExpander extends SiEffectBase
{
    // variables
    //------------------------------------------------------------
    private var _l2l : Float;private var _r2l : Float;private var _l2r : Float;private var _r2r : Float;
    private var _monoralize : Bool;
    
    
    
    
    // constructor
    //------------------------------------------------------------
    /** constructor
     *  @param phaseInvert invert r channel's phase.
     *  @param width stereo width (ussualy -1 ~ 2). 1=same as input, 0=monoral, 2=monoral with phase invertion, -1=swap channels.
     *  @param rotation rotate center. 1 for 90deg.
     */
    public function new(width : Float = 1, rotation : Float = 0, phaseInvert : Bool = false)
    {
        super();
        setParameters(width, rotation, phaseInvert);
    }
    
    
    
    
    // operations
    //------------------------------------------------------------
    /** set parameters
     *  @param width stereo width (ussualy -1 ~ 2). 1=same as input, 0=monoral, 2=monoral with phase invertion, -1=swap channels.
     *  @param rotation rotate center. 1 for 90deg.
     *  @param phaseInvert invert r channel's phase.
     */
    public function setParameters(width : Float = 1.4, rotation : Float = 0, phaseInvert : Bool = false) : Void
    {
        _monoralize = (width == 0 && rotation == 0 && !phaseInvert);
        var halfWidth : Float = width * 0.7853981633974483;
        var centerAngle : Float = (rotation + 0.5) * 1.5707963267948965;
        var langle : Float = centerAngle - halfWidth;
        var rangle : Float = centerAngle + halfWidth;
        var invert : Float = ((phaseInvert)) ? -1 : 1;
        var x : Float;
        var y : Float;
        var l : Float;
        _l2l = Math.cos(langle);
        _r2l = Math.sin(langle);
        _l2r = Math.cos(rangle) * invert;
        _r2r = Math.sin(rangle) * invert;
        x = _l2l + _l2r;
        y = _r2l + _r2r;
        l = Math.sqrt(x * x + y * y);
        if (l > 0.01) {
            l = 1 / l;
            _l2l *= l;
            _r2l *= l;
            _l2r *= l;
            _r2r *= l;
        }
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
        setParameters(((!Math.isNaN(args[1]))) ? (args[1] * 0.01) : 1.4,
                ((!Math.isNaN(args[2]))) ? (args[2] * 0.01) : 0,
                ((!Math.isNaN(args[0]))) ? (args[0] != 0) : false);
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
        var l : Float;
        var r : Float;
        var imax : Int = startIndex + length;
        if (_monoralize) {
            i = startIndex;
            while (i < imax){
                l = buffer[i];i++;
                l += buffer[i];--i;
                l *= 0.7071067811865476;
                buffer[i] = l;i++;
                buffer[i] = l;i++;
            }
            return 1;
        }
        i = startIndex;
        while (i < imax){
            l = buffer[i];i++;
            r = buffer[i];--i;
            buffer[i] = l * _l2l + r * _r2l;i++;
            buffer[i] = l * _l2r + r * _r2r;i++;
        }
        return 2;
    }
}


