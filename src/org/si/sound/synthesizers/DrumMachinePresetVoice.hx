//----------------------------------------------------------------------------------------------------
// Preset voices for DrumMachine
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.synthesizers;

import org.si.sound.synthesizers.SiONVoice;
import org.si.sound.synthesizers.VoiceReference;

import org.si.sion.SiONVoice;


/** Preset voices for DrumMachine, this class can also be synthesizer. */
class DrumMachinePresetVoice extends VoiceReference
{
    public var type(never, set) : String;
    public var index(never, set) : Int;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // constants
    //----------------------------------------
    /** voice type bass drum */
    public static inline var BASS : String = "bass";
    /** voice type snare drum */
    public static inline var SNARE : String = "snare";
    /** voice type hihat symbal */
    public static inline var HIHAT : String = "hihat";
    /** voice type other percussions */
    public static inline var PERCUSSION : String = "percus";
    
    
    
    // variables
    //----------------------------------------
    /** categoly list. */
    public var categolies : Array<Dynamic> = [];
    
    // voice reference
    private var _voiceList : Array<Dynamic>;
    
    
    
    
    // variables
    //----------------------------------------
    /** bass drum pattern number. */
    private function set_type(typeString : String) : String{
        _voiceList = this[typeString];
        return typeString;
    }
    
    
    /** bass drum pattern number. */
    private function set_index(index : Int) : Int{
        index <<= 1;
        if (index < 0 || index >= _voiceList.length)             return;
        _voice = _voiceList[index];
        return index;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor */
    public function new()
    {
        super();
        // bass drums
        _category("bass");
        _percuss1op("bass1", "1 operator bass drum (sine)", 0, 0, 0, 63, 28, -128);
        _percuss1op("bass1w", "1 operator bass drum (sine) weak", 0, 4, 0, 63, 28, -128);
        _percuss1op("bass2", "1 operator bass drum (triangle)", 0, 0, 3, 63, 36, -32, 80, 0);
        _percuss1op("bass2w", "1 operator bass drum (triangle) weak", 0, 4, 3, 63, 36, -32, 80, 0);
        _percuss1op("bass3", "1 operator bass drum (pulse)", 0, 20, 5, 63, 32, -128);
        _percuss1op("bass3w", "1 operator bass drum (pulse) weak", 0, 24, 5, 63, 32, -128);
        _percuss1op("bass4", "1 operator bass drum (pulse)", 0, 20, 5, 63, 32, -128, 52, 1);
        _percuss1op("bass4w", "1 operator bass drum (pulse) weak", 0, 24, 5, 63, 32, -128, 52, 1);
        _percuss1op("bass5", "1 operator bass drum (saw)", 0, 16, 1, 63, 36, -32, 96);
        _percuss1op("bass5w", "1 operator bass drum (saw) weak", 0, 20, 1, 63, 36, -32, 96);
        _percuss1op("bass6", "1 operator bass drum (noise)", 12, 28, 17, 63, 36, 0);
        _percuss1op("bass6w", "1 operator bass drum (noise) weak", 12, 32, 17, 63, 36, 0);
        
        // snare drums
        _category("snare");
        _percuss1op("snare1", "1 operator snare drum", 68, 4, 17, 63, 32, 0, 64, 1);
        _percuss1op("snare1w", "1 operator snare drum weak", 68, 8, 17, 63, 34, 0, 64, 1);
        _percuss1op("snare2", "1 operator snare drum", 68, 8, 17, 63, 32, 0, 80, 1);
        _percuss1op("snare2w", "1 operator snare drum weak", 68, 12, 17, 63, 36, 0, 80, 1);
        _percuss1op("snare3", "1 operator snare drum", 48, 10, 19, 63, 32, 0);
        _percuss1op("snare3w", "1 operator snare drum weak", 48, 14, 19, 63, 36, 0);
        _percuss1op("snare4", "1 operator snare drum", 68, 12, 17, 63, 32, 0);
        _percuss1op("snare4w", "1 operator snare drum weak", 68, 16, 17, 63, 36, 0);
        _percuss1op("snare5", "1 operator snare drum", 68, 0, 20, 63, 28, 0, 96, 1);
        _percuss1op("snare5w", "1 operator snare drum weak", 68, 4, 20, 63, 32, 0, 96, 1);
        _percuss1op("snare5", "1 operator snare drum", 68, 4, 16, 63, 28, 0, 54, 4);
        _percuss1op("snare5w", "1 operator snare drum weak", 68, 8, 16, 63, 32, 0, 54, 4);
        
        // closed hihats
        _category("hihat");
        _percuss1op("closedhh1", "1 operator closed hi-hat", 68, 6, 19, 63, 44, 0);
        _percuss1op("openedhh1", "1 operator opened hi-hat", 68, 10, 19, 63, 28, 0);
        _percuss1op("closedhh1", "1 operator closed hi-hat", 68, 0, 19, 63, 44, 0, 80);
        _percuss1op("openedhh1", "1 operator opened hi-hat", 68, 4, 19, 63, 28, 0, 80);
        _percuss1op("closedhh2", "1 operator closed hi-hat", 88, 0, 24, 63, 44, 0);
        _percuss1op("openedhh2", "1 operator opened hi-hat", 88, 6, 24, 63, 28, 0);
        _percuss1op("closedhh3", "1 operator closed hi-hat", 96, 4, 25, 63, 44, 0);
        _percuss1op("openedhh3", "1 operator opened hi-hat", 96, 12, 25, 63, 28, 0);
        
        // symbals
        _category("symbal");
        _percuss1op("symbal1", "1 operator crash symbal", 68, 8, 16, 48, 24, 0);
        
        // others
        _category("percus");
        
        _voiceList = this["bass"];
    }
    
    
    
    
    // internals
    //----------------------------------------
    // create new 1operator percussive voice
    private function _percuss1op(key : String, name : String, note : Int, tl : Int, ws : Int, ar : Int, rr : Int, sw : Int, cut : Int = 128, res : Int = 0) : Void{
        var voice : SiONVoice = new SiONVoice(5, ws, ar, rr);
        voice.defaultGateTime = 0;
        voice.channelParam.operatorParam[0].fixedPitch = note << 6;
        voice.channelParam.operatorParam[0].tl = tl;
        voice.releaseSweep = sw;
        voice.setFilterEnvelop(0, cut, res);
        voice.name = name;
        _categoryList.push(voice);
        this[key] = voice;
    }
    
    
    // register categoly
    private var _categoryList : Array<Dynamic>;
    private function _category(key : String) : Void{
        _categoryList = [];
        _categoryList["name"] = key;
        categolies.push(_categoryList);
        this[key] = _categoryList;
    }
}


