//----------------------------------------------------------------------------------------------------
// Polyphonic synthesizer class
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound;

import org.si.sound.VoiceReference;

import org.si.sion.*;
import org.si.sion.sequencer.base.*;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sound.patterns.*;

import org.si.sound.synthesizers.*;


/** Polyphonic synthesizer class provides synthesizer with multi tracks.
 */
class PolyphonicSynthesizer extends MultiTrackSoundObject
{
    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    
    
    
    
    // properties
    //----------------------------------------
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor 
     *  @param synth synthesizer to play
     */
    public function new(synth : VoiceReference = null)
    {
        super("PolyphonicSynthesizer", synth);
    }
    
    
    
    
    // operations
    //----------------------------------------
    /** @private [protected] Reset */
    override public function reset() : Void
    {
        super.reset();
    }
    
    
    /** start streaming without any sounds */
    override public function play() : Void
    {
        _stopAllTracks();
        _tracks = new Array<SiMMLTrack>();
    }
    
    
    /** stop all tracks */
    override public function stop() : Void
    {
        _stopAllTracks();
    }
    
    
    /** note on 
     *  @param note note number (0-128)
     *  @param velocity velocity (0-128-255)
     *  @param length length (1 = 16th beat length)
     */
    public function noteOn(note : Int, velocity : Int = 128, length : Int = 0) : Void
    {
        if (_tracks) {
            _length = length;
            _note = note;
            _track = _noteOn(_note, false);
            if (_track)                 _synthesizer._registerTrack(_track);
            _track.velocity = velocity;
            _tracks.push(_track);
        }
    }
    
    
    /** note off 
     *  @param note note number to sound off (0-127)
     */
    public function noteOff(note : Int, stopWithReset : Bool = true) : Void
    {
        var noteOffTracks : Array<SiMMLTrack> = _noteOff(note, stopWithReset);
        for (t in noteOffTracks){
            _synthesizer._unregisterTracks(t);
            t.setDisposable();
        }
    }
}


