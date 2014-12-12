  //----------------------------------------------------------------------------------------------------  
// Fader class
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion.utils;


/** Fader class. */
class Fader
{
    public var isActive(get, never) : Bool;
    public var isIncrement(get, never) : Bool;
    public var value(get, never) : Float;

    // variables
    //--------------------------------------------------
    // end value
    private var _end : Float = 0;
    // increment step
    private var _step : Float = 0;
    // counter
    private var _counter : Int = 0;
    // value
    private var _value : Float = 0;
    // callback function
    private var _callback : Float->Void = null;
    
    
    
    
    // properties
    //--------------------------------------------------
    /** is active. */
    private function get_isActive() : Bool{
        return (_counter > 0);
    }
    /** is incrementation, */
    private function get_isIncrement() : Bool{
        return (_step > 0);
    }
    /** controling value. */
    private function get_value() : Float{
        return _value;
    }
    
    
    
    
    // constructor
    //--------------------------------------------------
    /** constructor.
     *  @param valueFrom The starting value.
     *  @param valueTo The value chaging to.
     *  @param frames Changing frames.
     */
    public function new(callback : Float->Void = null, valueFrom : Float = 0, valueTo : Float = 1, frames : Int = 60)
    {
        setFade(callback, valueFrom, valueTo, frames);
    }
    
    
    
    
    // operations
    //--------------------------------------------------
    /** set fading values 
     *  @param valueFrom The starting value.
     *  @param valueTo The value chaging to.
     *  @param frames Changing frames.
     *  @return this instance.
     */
    public function setFade(callback : Float->Void, valueFrom : Float = 0, valueTo : Float = 1, frames : Int = 60) : Fader
    {
        _value = valueFrom;
        if (frames == 0 || callback == null) {
            _counter = 0;
            return this;
        }
        _callback = callback;
        _end = valueTo;
        _step = (valueTo - valueFrom) / frames;
        _counter = frames;
        _callback(_value);
        return this;
    }
    
    
    /** Execute 
     *  @return Activation changing. returns true when the execution is finished.
     */
    public function execute() : Bool
    {
        if (_counter > 0) {
            _value += _step;
            if (--_counter == 0) {
                _value = _end;
                _callback(_end);
                return true;
            }
            else {
                _callback(_value);
            }
        }
        return false;
    }
    
    
    /** Stop fading */
    public function stop() : Void
    {
        _counter = 0;
    }
}



