// synthsizer with SiONPresetVoice
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.synthesizers;

import openfl.errors.Error;
import org.si.sound.synthesizers.SiONPresetVoice;
import org.si.sound.synthesizers.VoiceReference;

import org.si.sion.SiONVoice;
import org.si.sion.utils.SiONPresetVoice;


/** synthsizer with SiONPresetVoice */
class PresetVoiceLoader extends VoiceReference
{
    public var voiceNumber(get, set) : Int;
    public var voiceNumberMax(get, never) : Int;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    /** current categoly's list */
    private var _voiceList : Array<Dynamic> = null;
    /** current voice number */
    private var _voiceNumber : Int = 0;
    
    
    
    // properties
    //----------------------------------------
    /** load voice from current categoly's voice list */
    private function get_voiceNumber() : Int{
        return _voiceNumber;
    }
    private function set_voiceNumber(i : Int) : Int{
        if (i < 0)             i = 0
        else if (i >= _voiceList.length)             i = _voiceList.length - 1;
        _voiceNumber = i;
        var v : SiONVoice = _voiceList[_voiceNumber];
        if (_voice != v)             _voiceUpdateNumber++;
        _voice = v;
        return i;
    }
    
    
    /** maximum value of voiceNumber */
    private function get_voiceNumberMax() : Int{
        return _voiceList.length;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor, set categoly key to use. */
    public function new(categoly : String)
    {
        super();
        var presetVoiceList : SiONPresetVoice = SiONPresetVoice.mutex || new SiONPresetVoice();
        if (!(Lambda.has(presetVoiceList, categoly)))             throw new Error("PresetVoiceReference; no '" + categoly + "' categolies in SiONPresetVoice.");
        _voiceList = Reflect.field(presetVoiceList, categoly);
    }
}


