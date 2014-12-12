//----------------------------------------------------------------------------------------------------
// Pattern generator on scale
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.patterns;

import org.si.sound.patterns.Scale;

import org.si.sion.utils.Scale;


/** Pattern generator on scale */
class Scaler extends Array<Dynamic>
{
    public var pattern(get, set) : Array<Dynamic>;
    public var scale(get, set) : Scale;
    public var scaleIndex(get, set) : Int;

    // variables
    //--------------------------------------------------
    /** scale instance */
    private var _scale : Scale;
    /** pattern of scale indexes */
    private var _scaleIndexPattern : Array<Dynamic>;
    /** scale index shift */
    private var _scaleIndexShift : Int;
    
    
    
    
    // properties
    //----------------------------------------
    /** pattern of scale indexes */
    private function get_pattern() : Array<Dynamic>{return _scaleIndexPattern;
    }
    private function set_pattern(p : Array<Dynamic>) : Array<Dynamic>{
        if (p == null) {
            this.length = 0;
            return;
        }
        _scaleIndexPattern = p;
        var i : Int;
        var imax : Int = _scaleIndexPattern.length;
        if (this.length < imax) {
            for (imax){
                this[i] = new Note();
            }
        }
        this.length = imax;
        for (imax){
            this[i].note = _scale.getNote(_scaleIndexPattern[i] + _scaleIndexShift);
        }
        return p;
    }
    
    
    /** scale instance */
    private function get_scale() : Scale{return _scale;
    }
    private function set_scale(s : Scale) : Scale{
        if (_scale == s)             return;
        _scale = s || new Scale();
        var i : Int;
        var imax : Int = _scaleIndexPattern.length;
        for (imax){
            this[i].note = _scale.getNote(_scaleIndexPattern[i] + _scaleIndexShift);
        }
        return s;
    }
    
    /** scale index shift */
    private function get_scaleIndex() : Int{return _scaleIndexShift;
    }
    private function set_scaleIndex(s : Int) : Int{
        if (_scaleIndexShift == s)             return;
        _scaleIndexShift = s;
        var i : Int;
        var imax : Int = this.length;
        for (imax){
            this[i].note = _scale.getNote(_scaleIndexPattern[i] + _scaleIndexShift);
        }
        return s;
    }
    
    
    
    
    // constructor
    //--------------------------------------------------
    /** constructor
     *  @param scale Scale instance.
     */
    public function new(scale : Scale = null, pattern : Array<Dynamic> = null)
    {
        super();
        _scaleIndexShift = 0;
        _scale = scale || new Scale();
        this.pattern = pattern;
    }
}


