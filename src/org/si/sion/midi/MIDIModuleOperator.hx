//----------------------------------------------------------------------------------------------------
// MIDI sound module operator
//  Copyright (c) 2011 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion.midi;


import org.si.sion.sequencer.SiMMLTrack;


/** @private MIDI sound module operator */
class MIDIModuleOperator
{
    // variables
    //--------------------------------------------------------------------------------
    @:allow(org.si.sion.midi)
    private var next : MIDIModuleOperator;@:allow(org.si.sion.midi)
    private var prev : MIDIModuleOperator;
    @:allow(org.si.sion.midi)
    private var sionTrack : SiMMLTrack = null;
    @:allow(org.si.sion.midi)
    private var length : Int = 0;
    @:allow(org.si.sion.midi)
    private var programNumber : Int;
    @:allow(org.si.sion.midi)
    private var channel : Int;
    @:allow(org.si.sion.midi)
    private var note : Int;
    @:allow(org.si.sion.midi)
    private var isNoteOn : Bool;
    @:allow(org.si.sion.midi)
    private var drumExcID : Int;
    
    
    
    
    // constructor
    //--------------------------------------------------------------------------------
    @:allow(org.si.sion.midi)
    public function new(sionTrack : SiMMLTrack)
    {
        this.sionTrack = sionTrack;
        next = prev = this;
        programNumber = -1;
        channel = -1;
        note = -1;
        isNoteOn = false;
        drumExcID = -1;
    }
    
    
    
    
    // list operation
    //--------------------------------------------------------------------------------
    @:allow(org.si.sion.midi)
    private function clear() : Void
    {
        prev = next = this;
        length = 0;
    }
    
    
    @:allow(org.si.sion.midi)
    private function push(ope : MIDIModuleOperator) : Void
    {
        ope.prev = prev;
        ope.next = this;
        prev.next = ope;
        prev = ope;
        length++;
    }
    
    
    @:allow(org.si.sion.midi)
    private function pop() : MIDIModuleOperator
    {
        if (prev == this)             return null;
        var ret : MIDIModuleOperator = prev;
        prev = prev.prev;
        prev.next = this;
        ret.prev = ret.next = ret;
        length--;
        return ret;
    }
    
    
    @:allow(org.si.sion.midi)
    private function unshift(ope : MIDIModuleOperator) : Void
    {
        ope.prev = this;
        ope.next = next;
        next.prev = ope;
        next = ope;
        length++;
    }
    
    
    @:allow(org.si.sion.midi)
    private function shift() : MIDIModuleOperator
    {
        if (next == this)             return null;
        var ret : MIDIModuleOperator = next;
        next = next.next;
        next.prev = this;
        ret.prev = ret.next = ret;
        length--;
        return ret;
    }
    
    
    @:allow(org.si.sion.midi)
    private function remove(ope : MIDIModuleOperator) : Void
    {
        ope.prev.next = ope.next;
        ope.next.prev = ope.prev;
        ope.prev = ope.next = this;
        length--;
    }
}


