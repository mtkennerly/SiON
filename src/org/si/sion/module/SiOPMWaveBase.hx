//----------------------------------------------------------------------------------------------------
// basic class sfor SiOPM wave data
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module;

import openfl.media.Sound;
import openfl.events.*;

/** basic class for SiOPM wave data */
class SiOPMWaveBase
{
    private var _isSoundLoading(get, never) : Bool;

    /** module type */
    public var moduleType : Int;
    // loading target
    private var _loadingTarget : Sound;
    
    
    /** constructor */
    public function new(moduleType : Int)
    {
        this.moduleType = moduleType;
    }
    
    
    /** @private listen sound loading events */
    private function _listenSoundLoadingEvents(sound : Sound) : Void
    {
        if (sound.bytesTotal == 0 || cast(sound.bytesTotal, UInt) > cast(sound.bytesLoaded, UInt)) {
            _loadingTarget = sound;
            sound.addEventListener(Event.COMPLETE, _cmp);
            sound.addEventListener(IOErrorEvent.IO_ERROR, _err);
            sound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _err);
        }
        else {
            _onSoundLoadingComplete(sound);
        }
    }
    
    
    /** @private */
    private function get__isSoundLoading() : Bool{
        return (_loadingTarget != null);
    }
    
    
    /** @private complete event handler */
    private function _onSoundLoadingComplete(sound : Sound) : Void
    {
        
    }
    
    
    // event handlers
    private function _cmp(e : Event) : Void{
        _onSoundLoadingComplete(_loadingTarget);
        _removeAllListeners();
    }
    private function _err(e : Event) : Void{
        _removeAllListeners();
    }
    private function _removeAllListeners() : Void
    {
        _loadingTarget.removeEventListener(Event.COMPLETE, _cmp);
        _loadingTarget.removeEventListener(IOErrorEvent.IO_ERROR, _err);
        _loadingTarget.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _err);
        _loadingTarget = null;
    }
}


