//----------------------------------------------------------------------------------------------------
// SiOPM filters based on RBJ cockbook
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;


/** filters based on RBJ cockbook. */
class SiFilterBase extends SiEffectBase
{
    // constant
    //------------------------------------------------------------
    private static inline var THRESHOLD : Float = 0.0000152587890625;
    
    
    
    
    // variables
    //------------------------------------------------------------
    private var _a1 : Float;private var _a2 : Float;private var _b0 : Float;private var _b1 : Float;private var _b2 : Float;
    private var _in1L : Float;private var _in2L : Float;private var _out1L : Float;private var _out2L : Float;
    private var _in1R : Float;private var _in2R : Float;private var _out1R : Float;private var _out2R : Float;
    
    
    
    
    // Math calculation
    //------------------------------------------------------------
    /** hyperbolic sinh. */
    private function sinh(n : Float) : Float{
        return (Math.exp(n) - Math.exp(-n)) * 0.5;
    }
    
    
    
    
    // constructor
    //------------------------------------------------------------
    /** constructor */
    public function new()
    {
        super();
    }
    
    
    
    
    // overrided funcitons
    //------------------------------------------------------------
    /** @private */
    override public function prepareProcess() : Int
    {
        _in1L = _in2L = _out1L = _out2L = _in1R = _in2R = _out1R = _out2R = 0;
        return 2;
    }
    
    
    /** @private */
    override public function process(channels : Int, buffer : Array<Float>, startIndex : Int, length : Int) : Int
    {
        startIndex <<= 1;
        length <<= 1;
        if (_out1L < THRESHOLD)             _out2L = _out1L = 0;
        if (_out1R < THRESHOLD)             _out2R = _out1R = 0;
        
        var i : Int;
        var input : Float;
        var output : Float;
        var imax : Int = startIndex + length;
        if (channels == 2) {
            i = startIndex;
            while (i < imax){
                input = buffer[i];
                output = _b0 * input + _b1 * _in1L + _b2 * _in2L - _a1 * _out1L - _a2 * _out2L;
                if (output > 1)                     output = 1
                else if (output < -1)                     output = -1;
                _in2L = _in1L;_in1L = input;
                _out2L = _out1L;_out1L = output;
                buffer[i] = output;i++;
                
                input = buffer[i];
                output = _b0 * input + _b1 * _in1R + _b2 * _in2R - _a1 * _out1R - _a2 * _out2R;
                if (output > 1)                     output = 1
                else if (output < -1)                     output = -1;
                _in2R = _in1R;_in1R = input;
                _out2R = _out1R;_out1R = output;
                buffer[i] = output;i++;
            }
        }
        else {
            i = startIndex;
            while (i < imax){
                input = buffer[i];
                output = _b0 * input + _b1 * _in1L + _b2 * _in2L - _a1 * _out1L - _a2 * _out2L;
                if (output > 1)                     output = 1
                else if (output < -1)                     output = -1;
                _in2L = _in1L;_in1L = input;
                _out2L = _out1L;_out1L = output;
                buffer[i] = output;i++;
                buffer[i] = output;i++;
            }
        }
        return channels;
    }
}


