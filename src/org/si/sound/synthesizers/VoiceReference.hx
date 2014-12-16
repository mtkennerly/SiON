// Voice reference
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.synthesizers;


import org.si.sion.*;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sound.SoundObject;


/** Voice reference, basic class of all synthesizers. */
class VoiceReference
{
    public var voice(get, set) : SiONVoice;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    /** @private [synthesizer internal] Instance of voice setting */
    public var _voice : SiONVoice = null;
    
    /** @private [synthesizer internal] require voice update number */
    public var _voiceUpdateNumber : Int;
    
    
    
    
    // properties
    //----------------------------------------
    /** voice setting */
    private function get_voice() : SiONVoice {
        return _voice;
    }
    private function set_voice(v : SiONVoice) : SiONVoice {
        if (_voice != v)             _voiceUpdateNumber++;
        _voice = v;
        return v;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor */
    public function new()
    {
        _voiceUpdateNumber = 0;
    }
    
    
    
    
    // operation
    //----------------------------------------
    /** @private [synthesizer internal] register single track */
    public function _registerTrack(track : SiMMLTrack) : Void
    {
        
    }
    
    
    /** @private [synthesizer internal] register prural tracks */
    public function _registerTracks(tracks : Array<SiMMLTrack>) : Void
    {
        
    }
    
    
    /** @private [synthesizer internal] unregister tracks */
    public function _unregisterTracks(firstTrack : SiMMLTrack, count : Int = 1) : Void
    {
        
    }
}



