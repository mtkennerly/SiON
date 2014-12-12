// Nintendo Entertainment System (Family Computer) Synthesizer
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.synthesizers;

import org.si.sound.synthesizers.SLLint;
import org.si.sound.synthesizers.SiMMLEnvelopTable;

import org.si.utils.SLLint;
import org.si.sion.*;
import org.si.sion.sequencer.SiMMLEnvelopTable;
import org.si.sound.SoundObject;


/** Nintendo Entertainment System (Family Computer) Synthesizer 
 */
class NESSynth extends BasicSynth
{
    public var channelNumber(get, never) : Int;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    
    
    
    
    // properties
    //----------------------------------------
    /** APU channel number */
    private function get_channelNumber() : Int{return _voice.channelNum;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor */
    public function new(channelNumber : Int = 0)
    {
        super(1, channelNumber);
    }
    
    
    
    
    // operation
    //----------------------------------------
    /** set envelop table 
     *  @param table envelop table, null sets envelop off.
     *  @param loopPoint index of looping point, -1 sets loop at tail.
     *  @param step envelop changing step, 1 sets 60fps, 2 sets 30fps...
     */
    public function setEnevlop(table : Array<Dynamic>, loopPoint : Int = -1, step : Int = 1) : Void
    {
        _voice.noteOnAmplitudeEnvelop = _constructEnvelopTable(_voice.noteOnAmplitudeEnvelop, table, loopPoint);
        _voice.noteOnAmplitudeEnvelopStep = step;
        _voiceUpdateNumber++;
    }
    
    
    /** set pitch envelop table 
     *  @param table envelop table, null sets envelop off.
     *  @param loopPoint index of looping point, -1 sets loop at tail.
     *  @param step envelop changing step, 1 sets 60fps, 2 sets 30fps...
     */
    public function setPitchEnevlop(table : Array<Dynamic>, loopPoint : Int = -1, step : Int = 1) : Void
    {
        _voice.noteOnPitchEnvelop = _constructEnvelopTable(_voice.noteOnPitchEnvelop, table, loopPoint);
        _voice.noteOnPitchEnvelopStep = step;
        _voiceUpdateNumber++;
    }
    
    
    /** set note envelop table 
     *  @param table envelop table, null sets envelop off.
     *  @param loopPoint index of looping point, -1 sets loop at tail.
     *  @param step envelop changing step, 1 sets 60fps, 2 sets 30fps...
     */
    public function setNoteEnevlop(table : Array<Dynamic>, loopPoint : Int = -1, step : Int = 1) : Void
    {
        _voice.noteOnNoteEnvelop = _constructEnvelopTable(_voice.noteOnNoteEnvelop, table, loopPoint);
        _voice.noteOnNoteEnvelopStep = step;
        _voiceUpdateNumber++;
    }
    
    
    /** set tone envelop table 
     *  @param table envelop table, null sets envelop off.
     *  @param loopPoint index of looping point, -1 sets loop at tail.
     *  @param step envelop changing step, 1 sets 60fps, 2 sets 30fps...
     */
    public function setToneEnevlop(table : Array<Dynamic>, loopPoint : Int = -1, step : Int = 1) : Void
    {
        _voice.noteOnToneEnvelop = _constructEnvelopTable(_voice.noteOnToneEnvelop, table, loopPoint);
        _voice.noteOnToneEnvelopStep = step;
        _voiceUpdateNumber++;
    }
    
    
    /** set envelop table after note off 
     *  @param table envelop table, null sets envelop off.
     *  @param loopPoint index of looping point, -1 sets loop at tail.
     *  @param step envelop changing step, 1 sets 60fps, 2 sets 30fps...
     */
    public function setEnevlopNoteOff(table : Array<Dynamic>, loopPoint : Int = -1, step : Int = 1) : Void
    {
        _voice.noteOffAmplitudeEnvelop = _constructEnvelopTable(_voice.noteOffAmplitudeEnvelop, table, loopPoint);
        _voice.noteOffAmplitudeEnvelopStep = step;
        _voiceUpdateNumber++;
    }
    
    
    /** set pitch envelop table after note off 
     *  @param table envelop table, null sets envelop off.
     *  @param loopPoint index of looping point, -1 sets loop at tail.
     *  @param step envelop changing step, 1 sets 60fps, 2 sets 30fps...
     */
    public function setPitchEnevlopNoteOff(table : Array<Dynamic>, loopPoint : Int = -1, step : Int = 1) : Void
    {
        _voice.noteOffPitchEnvelop = _constructEnvelopTable(_voice.noteOffPitchEnvelop, table, loopPoint);
        _voice.noteOffPitchEnvelopStep = step;
        _voiceUpdateNumber++;
    }
    
    
    /** set note envelop table after note off 
     *  @param table envelop table, null sets envelop off.
     *  @param loopPoint index of looping point, -1 sets loop at tail.
     *  @param step envelop changing step, 1 sets 60fps, 2 sets 30fps...
     */
    public function setNoteEnevlopNoteOff(table : Array<Dynamic>, loopPoint : Int = -1, step : Int = 1) : Void
    {
        _voice.noteOffNoteEnvelop = _constructEnvelopTable(_voice.noteOffNoteEnvelop, table, loopPoint);
        _voice.noteOffNoteEnvelopStep = step;
        _voiceUpdateNumber++;
    }
    
    
    /** set tone envelop table after note off 
     *  @param table envelop table, null sets envelop off.
     *  @param loopPoint index of looping point, -1 sets loop at tail.
     *  @param step envelop changing step, 1 sets 60fps, 2 sets 30fps...
     */
    public function setToneEnevlopNoteOff(table : Array<Dynamic>, loopPoint : Int = -1, step : Int = 1) : Void
    {
        _voice.noteOffToneEnvelop = _constructEnvelopTable(_voice.noteOffToneEnvelop, table, loopPoint);
        _voice.noteOffToneEnvelopStep = step;
        _voiceUpdateNumber++;
    }
    
    
    
    
    // private functions
    //--------------------------------------------------
    private function _constructEnvelopTable(env : SiMMLEnvelopTable, table : Array<Dynamic>, loopPoint : Int) : SiMMLEnvelopTable{
        if (env != null)             env.free();
        if (table == null)             return null;
        
        var tail : SLLint;
        var head : SLLint;
        var loop : SLLint;
        var i : Int;
        var imax : Int = table.length;
        head = tail = SLLint.allocList(imax);
        loop = null;
        for (imax - 1){
            if (loopPoint == i)                 loop = tail;
            tail.i = table[i];
            tail = tail.next;
        }
        tail.i = table[i];
        tail.next = loop;
        
        if (env == null)             env = new SiMMLEnvelopTable();
        env.head = head;
        env.tail = tail;
        return env;
    }
}



