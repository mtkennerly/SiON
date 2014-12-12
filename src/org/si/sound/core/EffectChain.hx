//----------------------------------------------------------------------------------------------------
// Effector chain class
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.core;

import org.si.sound.core.SiEffectBase;
import org.si.sound.core.SiEffectStream;
import org.si.sound.core.SiONDriver;
import org.si.sound.core.SiOPMStream;

import org.si.sion.*;
import org.si.sion.effector.*;
import org.si.sion.module.SiOPMStream;



/** Effector chain class. This class manages local effector chain of SoundObject. */
class EffectChain
{
    public var isActive(get, never) : Bool;
    public var effectList(get, set) : Array<Dynamic>;
    public var streamingBuffer(get, never) : SiOPMStream;

    // variables
    //--------------------------------------------------
    /** Stream buffer of local effect */
    private var _effectStream : SiEffectStream;
    /** Effect list */
    private var _effectList : Array<Dynamic>;
    
    
    
    // properties
    //--------------------------------------------------
    /** Is processing effect ? */
    private function get_isActive() : Bool{return (_effectStream != null);
    }
    
    
    /** effector list */
    private function get_effectList() : Array<Dynamic>{return _effectList;
    }
    private function set_effectList(list : Array<Dynamic>) : Array<Dynamic>{
        _effectList = list;
        if (_effectStream != null) {
            _effectStream.chain = _effectList;
        }
        return list;
    }
    
    
    /** streaming buffer */
    private function get_streamingBuffer() : SiOPMStream{
        return ((_effectStream != null)) ? _effectStream.stream : null;
    }
    
    
    
    
    // constructor
    //--------------------------------------------------
    /** @private constructor, you should not create new EffectChain instance. */
    public function new()
    {
        _effectStream = null;
        _effectList = list || [];
    }
    
    
    
    
    // operations
    //--------------------------------------------------
    /** @private [internal] activate local effect. deeper effectors executes first. */
    private function _activateLocalEffect(depth : Int) : Void
    {
        if (_effectStream != null)             return;
        var driver : SiONDriver = SiONDriver.mutex;
        if (driver != null) {
            _effectStream = driver.effector.newLocalEffect(depth, _effectList);
        }
    }
    
    
    /** @private [internal] inactivate local effect */
    private function _inactivateLocalEffect() : Void
    {
        if (_effectStream == null)             return;
        var driver : SiONDriver = SiONDriver.mutex;
        if (driver != null) {
            driver.effector.deleteLocalEffect(_effectStream);
            _effectStream = null;
        }
    }
    
    
    /** set all stream send levels by Vector.&lt;int&gt;(8) (0-128) */
    public function setAllStreamSendLevels(volumes : Array<Int>) : Void
    {
        if (_effectStream == null)             return;
        _effectStream.setAllStreamSendLevels(volumes);
    }
    
    
    /** set stream send level by Number(0-1) */
    public function setStreamSend(slot : Int, volume : Float) : Void
    {
        if (_effectStream == null)             return;
        _effectStream.setStreamSend(slot, volume);
    }
    
    
    /** connect to another chain */
    public function connectTo(ec : EffectChain) : Void
    {
        if (_effectStream == null)             return;
        _effectStream.connectTo(ec.streamingBuffer);
    }
    
    
    
    // factory
    //--------------------------------------------------
    private static var _freeList : Array<EffectChain> = new Array<EffectChain>();
    
    /** allocate new EffectChain */
    public static function alloc(effectList : Array<Dynamic>) : EffectChain
    {
        if (effectList == null || effectList.length == 0)             return null;
        var ec : EffectChain = _freeList.pop() || new EffectChain();
        ec.effectList = effectList;
        return ec;
    }
    
    
    /** delete this EffectChain */
    public function free() : Void
    {
        effectList = [];
        _freeList.push(this);
    }
}


