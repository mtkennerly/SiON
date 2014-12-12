//----------------------------------------------------------------------------------------------------
// MML Sequence group class
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.base;

import openfl.errors.Error;

import openfl.utils.ByteArray;


/** Group of MMLSequences. MMLData > MMLSequenceGroup > MMLSequence > MMLEvent (">" meanse "has a"). */
class MMLSequenceGroup
{
    public var sequenceCount(get, never) : Int;
    public var headSequence(get, never) : MMLSequence;
    public var tickCount(get, never) : Int;
    public var hasRepeatAll(get, never) : Bool;

    // variables
    //--------------------------------------------------
    // terminator
    private var _term : MMLSequence;
    
    // owner data
    private var _owner : MMLData;
    
    // properties
    //--------------------------------------------------
    /** Get sequence count. */
    private function get_sequenceCount() : Int
    {
        return _sequences.length;
    }

    /** head sequence pointer. */
    private function get_headSequence() : MMLSequence
    {
        return _term.nextSequence;
    }

    /** Get song length by tick count (1920 for wholetone). */
    private function get_tickCount() : Int
    {
        var ml : Int;
        var tc : Int = 0;
        var seq:MMLSequence;
        for (seq in _sequences){
            ml = seq.mmlLength;
            if (ml > tc) tc = ml;
        }
        return tc;
    }
    
    
    /** does this song have all repeat comand ? */
    private function get_hasRepeatAll() : Bool
    {
        var seq:MMLSequence;
        for (seq in _sequences){
            if (seq.hasRepeatAll) return true;
        }
        return false;
    }

    // constructor
    //--------------------------------------------------
    public function new(owner : MMLData)
    {
        _owner = owner;
        _sequences = new Array<MMLSequence>();
        _term = new MMLSequence(true);
    }
    
    
    
    
    // operation
    //--------------------------------------------------
    /** Create new sequence group. Why its not create() ???
     *  @param headEvent MMLEvnet returned from MMLParser.parse().
     */
    public function alloc(headEvent : MMLEvent) : Void
    {
        // divied into sequences
        var seq : MMLSequence;
        while (headEvent != null && headEvent.jump != null){
            if (headEvent.id != MMLEvent.SEQUENCE_HEAD) {
                throw new Error("MMLSequence: Unknown error on dividing sequences. " + headEvent);
            }
            seq = appendNewSequence();  // push new sequence  
            headEvent = seq._cutout(headEvent);  // cutout sequence  
            seq._updateMMLString();  // update mml string  
            seq.isActive = true;
        }
    }
    
    
    /** Free all sequences */
    public function free() : Void
    {
        var seq:MMLSequence;
        for (seq in _sequences){
            seq.free();
            _freeList.push(seq);
        }
        while (_sequences.length > 0) _sequences.pop();
        _term.free();
    }
    
    
    /** get sequence
     *  @param index The index of sequence.
     */
    public function getSequence(index : Int) : MMLSequence
    {
        if (index >= _sequences.length) return null;
        return _sequences[index];
    }
    
    
    
    // factory
    //--------------------------------------------------
    // allocated sequences
    private var _sequences : Array<MMLSequence>;
    // free list
    private static var _freeList : Array<Dynamic> = [];
    
    
    /** append new sequence */
    public function appendNewSequence() : MMLSequence
    {
        var seq : MMLSequence = _newSequence();
        seq._insertBefore(_term);
        seq.isActive = false;  // inactivate  
        return seq;
    }
    
    
    /** @private [internal] Allocate new sequence and push sequence chain. */
    @:allow(org.si.sion.sequencer.base)
    private function _newSequence() : MMLSequence
    {
        var seq : MMLSequence = _freeList.pop();
        if (seq == null) seq = new MMLSequence();
        seq._owner = _owner;
        _sequences.push(seq);
        return seq;
    }
}
