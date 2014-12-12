// Frequency Modulation Synthesizer
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.synthesizers;

import org.si.sound.synthesizers.FMSynthOperator;

import org.si.sion.*;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sound.SoundObject;


/** Frequency Modulation Synthesizer
 */
class FMSynth extends BasicSynth
{
    public var alg(get, set) : Int;
    public var fb(get, set) : Int;
    public var fbc(get, set) : Int;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    /** FM Operators vector [m1,c1,m2,c2] */
    public var operators : Array<FMSynthOperator>;
    
    
    
    
    // properties
    //----------------------------------------
    /** ALG; connection algorism [0-15]. */
    private function get_alg() : Int{return _voice.channelParam.alg;
    }
    private function set_alg(i : Int) : Int{
        if (_voice.channelParam.alg == i || i < 0 || i > 15)             return;
        _voice.channelParam.alg = i;
        _voiceUpdateNumber++;
        return i;
    }
    
    /** FB; feedback [0-7]. */
    private function get_fb() : Int{return _voice.channelParam.fb;
    }
    private function set_fb(i : Int) : Int{
        if (_voice.channelParam.fb == i || i < 0 || i > 7)             return;
        _voice.channelParam.fb = i;
        _voiceUpdateNumber++;
        return i;
    }
    
    /** FBC; feedback connection [0-3]. */
    private function get_fbc() : Int{return _voice.channelParam.fbc;
    }
    private function set_fbc(i : Int) : Int{
        if (_voice.channelParam.fbc == i || i < 0 || i > 3)             return;
        _voice.channelParam.fbc = i;
        _voiceUpdateNumber++;
        return i;
    }
    
    
    /** @private */
    override private function set_voice(v : SiONVoice) : SiONVoice{
        _voice.copyFrom(v);  // copy from passed voice  
        _voiceUpdateNumber++;
        return v;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor 
     *  @param channelNumber pseudo channel number.
     */
    public function new(channelNumber : Int = 0)
    {
        super(5, channelNumber);
        operators = new Array<FMSynthOperator>();
        for (i in 0...4){operators[i] = new FMSynthOperator(this, i);
        }
    }
}



