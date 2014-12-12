//----------------------------------------------------------------------------------------------------
// Monophonic synthesizer class
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound;

import org.si.sound.PatternSequencer;
import org.si.sound.VoiceReference;

import org.si.sion.*;
import org.si.sion.sequencer.base.*;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sound.patterns.*;

import org.si.sound.synthesizers.*;


/** Monophonic synthesizer class provides single voice synthesizer sounding on the beat.
 */
class MonophonicSynthesizer extends PatternSequencer
{
    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    /** @private [protected] note object to sound on the beat */
    private var _noteObject : Note;
    
    
    
    
    // properties
    //----------------------------------------
    /** current note in the sequence, you cannot change this property. */
    override private function get_note() : Int{return ((_track)) ? _track.note : _sequencer.note;
    }
    override private function set_note(n : Int) : Int{_errorCannotChange("note");
        return n;
    }
    
    /** Synchronizing quantizing, uint in 16th beat. (0:No synchronization, 1:sync.with 16th, 4:sync.with 4th). @default 0. */
    override private function get_quantize() : Float{return _quantize;
    }
    override private function set_quantize(q : Float) : Float{
        _quantize = q;
        _sequencer.gridStep = q * 120;
        return q;
    }
    
    /** Sound delay, uint in 16th beat. @default 0. */
    override private function get_delay() : Float{return _delay;
    }
    override private function set_delay(d : Float) : Float{
        _errorCannotChange("delay");
        return d;
    }
    
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor 
     *  @param synth synthesizer to play
     */
    public function new(synth : VoiceReference = null)
    {
        super(60, 128, 0, synth);
        name = "MonophonicSynthesizer";
        _noteObject = new Note();
        _sequencer.pattern = [_noteObject];
        _sequencer.onExitFrame = _onExitFrame;
    }
    
    
    
    
    // operations
    //----------------------------------------
    /** start streaming without any sounds */
    override public function play() : Void
    {
        super.play();
    }
    
    
    /** stop streaming */
    override public function stop() : Void
    {
        super.stop();
    }
    
    
    /** note on
     *  @param note note number (0-127)
     *  @param velocity velocity (0-128-255)
     *  @param length length (1 = 16th beat length)
     */
    public function noteOn(note : Int, velocity : Int = 128, length : Int = 0) : Void
    {
        _noteObject.setNote(note, velocity, length);
    }
    
    
    /** note off
     *  @param note note number to sound off (0-127)
     */
    public function noteOff() : Void
    {
        if (_track)             _track.keyOff(0, false);
    }
    
    
    
    
    // internal
    //----------------------------------------
    /** @private [protected] */
    private function _onExitFrame(seq : Sequencer) : Void
    {
        _noteObject.setRest();
    }
}


