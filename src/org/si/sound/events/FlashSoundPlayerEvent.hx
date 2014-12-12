//----------------------------------------------------------------------------------------------------
// Event for FlashSoundPlayer
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.events;

import org.si.sound.events.Event;
import org.si.sound.events.Sound;

import openfl.events.*;
import openfl.media.Sound;
import org.si.sion.*;
import org.si.sion.effector.*;
import org.si.sion.module.SiOPMStream;



/** FlashSoundPlayerEvent is dispatched by FlashSoundPlayer. @see org.si.sound.FlashSoundPlayer */
class FlashSoundPlayerEvent extends Event
{
    public var sound(get, never) : Sound;
    public var keyRangeFrom(get, never) : Int;
    public var keyRangeTo(get, never) : Int;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // constants
    //----------------------------------------
    /** Complete all loading sounds */
    public static inline var COMPLETE : String = "fspComplete";
    
    
    
    
    // properties
    //----------------------------------------
    /** Target sound */
    private function get_sound() : Sound{return _sound;
    }
    /** keyRangeFrom */
    private function get_keyRangeFrom() : Int{return _keyRangeFrom;
    }
    /** keyRangeTo */
    private function get_keyRangeTo() : Int{return _keyRangeTo;
    }
    
    
    /**@private*/private var _sound : Sound;
    /**@private*/private var _onComplete : Function;
    /**@private*/private var _onError : Function;
    /**@private*/private var _keyRangeFrom : Int;
    /**@private*/private var _keyRangeTo : Int;
    /**@private*/private var _startPoint : Int;
    /**@private*/private var _endPoint : Int;
    /**@private*/private var _loopPoint : Int;
    
    
    
    
    // functions
    //----------------------------------------
    /** @private */
    public function new(sound : Sound, onComplete : Function, onError : Function, keyRangeFrom : Int, keyRangeTo : Int, startPoint : Int, endPoint : Int, loopPoint : Int)
    {
        super(COMPLETE, false, false);
        this._sound = sound;
        this._onComplete = onComplete;
        this._onError = onError;
        this._keyRangeFrom = keyRangeFrom;
        this._keyRangeTo = keyRangeTo;
        this._startPoint = startPoint;
        this._endPoint = endPoint;
        this._loopPoint = loopPoint;
        _sound.addEventListener(Event.COMPLETE, _handleComplete);
        _sound.addEventListener(IOErrorEvent.IO_ERROR, _handleError);
    }
    
    
    private function _handleComplete(e : Event) : Void{
        _sound.removeEventListener(Event.COMPLETE, _handleComplete);
        _sound.removeEventListener(IOErrorEvent.IO_ERROR, _handleError);
        _onComplete(this);
    }
    
    
    private function _handleError(e : Event) : Void{
        _sound.removeEventListener(Event.COMPLETE, _handleComplete);
        _sound.removeEventListener(IOErrorEvent.IO_ERROR, _handleError);
        _onError(this);
    }
}




