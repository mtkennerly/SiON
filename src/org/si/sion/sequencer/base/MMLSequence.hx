  //----------------------------------------------------------------------------------------------------  
// MML Sequence class
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.base;


import openfl.utils.ByteArray;


/** Sequence of 1 sound channel. MMLData > MMLSequenceGroup > MMLSequence > MMLEvent (">" meanse "has a"). */
class MMLSequence
{
    public var nextSequence(get, never) : MMLSequence;
    public var mmlString(get, never) : String;
    public var mmlLength(get, never) : Int;
    public var hasRepeatAll(get, never) : Bool;

    // namespace
    //--------------------------------------------------
    
    
    
    
    
    // variables
    //--------------------------------------------------
    /** First MMLEvent. The ID is always MMLEvent.SEQUENCE_HEAD. */
    public var headEvent : MMLEvent;
    /** Last MMLEvent. The ID is always MMLEvent.SEQUENCE_TAIL and lastEvent.next is always null. */
    public var tailEvent : MMLEvent;
    /** Is active ? The sequence is skipped to play when this value is false. */
    public var isActive : Bool;
    
    // mml string
    private var _mmlString : String;
    // mml length in resolution unit
    private var _mmlLength : Int;
    // flag for apearance of repeat all command (segno)
    private var _hasRepeatAll : Bool;
    
    // Previous sequence in the chain.
    private var _prevSequence : MMLSequence;
    // Next sequence in the chain.
    private var _nextSequence : MMLSequence;
    // Is terminal sequence.
    private var _isTerminal : Bool;
    
    /** @private [sion seqiencer internal] callback functions for Event.INTERNAL_CALL */
    public var _callbackInternalCall : Array<Int->MMLEvent>;
    /** @private [sion seqiencer internal] owner data */
    public var _owner : MMLData;
    
    
    
    // properties
    //--------------------------------------------------
    /** next sequence. */
    private function get_nextSequence() : MMLSequence
    {
        return ((!_nextSequence._isTerminal)) ? _nextSequence : null;
    }
    
    /** MML String, if its cached when its compiling. */
    private function get_mmlString() : String{return _mmlString;
    }
    
    /** MML length, in resolution unit (1920 = whole-tone in default). */
    private function get_mmlLength() : Int{
        if (_mmlLength == -1)             _updateMMLLength();
        return _mmlLength;
    }
    
    /** flag for apearance of repeat all command (segno) */
    private function get_hasRepeatAll() : Bool{
        if (_mmlLength == -1)             _updateMMLLength();
        return _hasRepeatAll;
    }
    
    
    // constructor
    //--------------------------------------------------
    /** Constructor. */
    public function new(term : Bool = false)
    {
        _owner = null;
        headEvent = null;
        tailEvent = null;
        isActive = true;
        _mmlString = "";
        _mmlLength = -1;
        _hasRepeatAll = false;
        _prevSequence = ((term)) ? this : null;
        _nextSequence = ((term)) ? this : null;
        _isTerminal = term;
        _callbackInternalCall = [];
    }
    
    
    /** toString returns the event ids. */
    public function toString() : String
    {
        if (_isTerminal)             return "terminator";
        var e : MMLEvent = headEvent.next;
        var str : String = "";
        for (i in 0...32){
            str += Std.string(e.id) + " ";
            e = e.next;
            if (e == null)                 break;
        }
        return str;
    }
    
    
    /** Returns events as an Vector.&lt;MMLEvent&gt;. 
     *  @param lengthLimit maximum length of returning Vector. When this argument set to 0, the Vector includes all events.
     *  @param offset starting index of returning Vector.
     *  @param eventID event id to get. When this argument set to -1, the Vector includes all kind of events.
     */
    public function toVector(lengthLimit : Int = 0, offset : Int = 0, eventID : Int = -1) : Array<MMLEvent>
    {
        if (headEvent == null)             return null;
        var e : MMLEvent;
        var i : Int = 0;
        var result : Array<MMLEvent> = new Array<MMLEvent>();
        e = headEvent.next;
        while (e != null && e.id != MMLEvent.SEQUENCE_TAIL){
            if (eventID == -1 || eventID == e.id) {
                if (i >= offset)                     result.push(e);
                if (lengthLimit > 0 && i >= lengthLimit)                     break;
                i++;
            }
            e = e.next;
        }
        return result;
    }
    
    
    /** Create sequence from Vector.&lt;MMLEvent&gt;. 
     *  @param events event list of the sequence.
     */
    public function fromVector(events : Array<MMLEvent>) : MMLSequence
    {
        initialize();
        for (e in events)push(e);
        return this;
    }
    
    
    
    
    
    // operations
    //--------------------------------------------------
    /** initialize. */
    public function initialize() : MMLSequence
    {
        if (!isEmpty()) {
            headEvent.jump.next = tailEvent;
            MMLParser._freeAllEvents(this);
            _callbackInternalCall = [];
        }
        headEvent = MMLParser._allocEvent(MMLEvent.SEQUENCE_HEAD, 0);
        tailEvent = MMLParser._allocEvent(MMLEvent.SEQUENCE_TAIL, 0);
        headEvent.next = tailEvent;
        headEvent.jump = headEvent;
        isActive = true;
        return this;
    }
    
    
    /** Free. */
    public function free() : Void
    {
        if (headEvent != null) {
            // disconnect
            headEvent.jump.next = tailEvent;
            MMLParser._freeAllEvents(this);
            _prevSequence = null;
            _nextSequence = null;
        }
        else 
        if (_isTerminal) {
            _prevSequence = this;
            _nextSequence = this;
        }
        _mmlString = "";
    }
    
    
    /** is empty ? */
    public function isEmpty() : Bool
    {
        return (headEvent == null);
    }
    
    
    /** Pack to ByteArray. */
    public function pack(seq : ByteArray) : Void
    {
        // not available
        
    }
    
    
    /** Unpack from ByteArray. */
    public function unpack(seq : ByteArray) : Void
    {
        // not available
        
    }
    
    
    /** Append new MMLEvent at tail 
     *  @param id MML event id.
     *  @param data MML event data.
     *  @param length MML event length.
     *  @see org.si.sion.sequencer.base.MMLEvent
     */
    public function appendNewEvent(id : Int, data : Int, length : Int = 0) : MMLEvent
    {
        return push(MMLParser._allocEvent(id, data, length));
    }
    
    
    /** Append new Callback function 
     *  @param func The function to call. (function(int) : MMLEvent)
     *  @param data The value to pass to the callback as an argument
     */
    public function appendNewCallback(func : Int->MMLEvent, data : Int) : MMLEvent
    {
        _callbackInternalCall.push(func);
        return push(MMLParser._allocEvent(MMLEvent.INTERNAL_CALL, _callbackInternalCall.length - 1, data));
    }
    
    
    /** Prepend new MMLEvent at head
     *  @param id MML event id.
     *  @param data MML event data.
     *  @param length MML event length.
     *  @see org.si.sion.sequencer.base.MMLEvent
     */
    public function prependNewEvent(id : Int, data : Int, length : Int = 0) : MMLEvent
    {
        return unshift(MMLParser._allocEvent(id, data, length));
    }
    
    
    /** Add MMLEvent at tail.
     *  @param MML event to be pushed.
     *  @return added event, same as an argument.
     */
    public function push(e : MMLEvent) : MMLEvent
    {
        // connect event at tail
        headEvent.jump.next = e;
        e.next = tailEvent;
        headEvent.jump = e;
        return e;
    }
    
    
    /** Remove MMLEvent from tail.
     *  @return removed MML event. You should call MMLEvent.free() after using this event.
     */
    public function pop() : MMLEvent
    {
        if (headEvent.jump == headEvent)             return null;
        var e : MMLEvent = headEvent.next;
        while (e != null){
            if (e.next == headEvent.jump) {
                var ret : MMLEvent = e.next;
                e.next = tailEvent;
                headEvent.jump = e;
                ret.next = null;
                return ret;
            }
            e = e.next;
        }
        return null;
    }
    
    
    /** Add MMLEvent at head.
     *  @param MML event to be pushed.
     *  @return added event, same as an argument.
     */
    public function unshift(e : MMLEvent) : MMLEvent
    {
        // connect event at head
        e.next = headEvent.next;
        headEvent.next = e;
        if (headEvent.jump == headEvent)             headEvent.jump = e;
        return e;
    }
    
    
    /** Remove MMLEvent from head.
     *  @return removed MML event. You should call MMLEvent.free() after using this event.
     */
    public function shift() : MMLEvent
    {
        if (headEvent.jump == headEvent)             return null;
        var ret : MMLEvent = headEvent.next;
        headEvent.next = ret.next;
        ret.next = null;
        return ret;
    }
    
    
    /** connect 2 sequences temporarily, this function doesnt change tail pointer, so you have to call connectBefore(null) after using this connection. 
     *  @param secondHead head event of second sequence, null to set tail event as default.
     *  @return this instance
     */
    public function connectBefore(secondHead : MMLEvent) : MMLSequence
    {
        // simply connect first tail to second head.
        headEvent.jump.next = secondHead;
        if (headEvent.jump.next == null) headEvent.jump.next = tailEvent;
        return this;
    }
    
    
    /** is system command */
    public function isSystemCommand() : Bool
    {
        return (headEvent.next.id == MMLEvent.SYSTEM_EVENT);
    }
    
    
    /** get system command */
    public function getSystemCommand() : String
    {
        return MMLParser._getSystemEventString(headEvent.next);
    }
    
    
    /** @private [sion sequencer internal] cutout MMLSequence */
    public function _cutout(head : MMLEvent) : MMLEvent
    {
        var last : MMLEvent = head.jump;  // last event of this sequence  
        var next : MMLEvent = last.next;  // head of next sequence  
        
        // cut out
        headEvent = head;
        tailEvent = MMLParser._allocEvent(MMLEvent.SEQUENCE_TAIL, 0);
        last.next = tailEvent;  // append tailEvent at last  
        
        return next;
    }
    
    
    /** @private [internal] update mml string */
    @:allow(org.si.sion.sequencer.base)
    private function _updateMMLString() : Void
    {
        if (headEvent.next.id == MMLEvent.DEBUG_INFO) {
            _mmlString = MMLParser._getSequenceMML(headEvent.next);
            headEvent.length = 0;
        }
    }
    
    
    /** @private [internal] insert before */
    @:allow(org.si.sion.sequencer.base)
    private function _insertBefore(next : MMLSequence) : Void
    {
        _prevSequence = next._prevSequence;
        _nextSequence = next;
        _prevSequence._nextSequence = this;
        _nextSequence._prevSequence = this;
    }
    
    
    /** @private [internal] insert after */
    @:allow(org.si.sion.sequencer.base)
    private function _insertAfter(prev : MMLSequence) : Void
    {
        _prevSequence = prev;
        _nextSequence = prev._nextSequence;
        _prevSequence._nextSequence = this;
        _nextSequence._prevSequence = this;
    }
    
    
    /** @private [sion sequencer internal] remove from chain. @return previous sequence. */
    public function _removeFromChain() : MMLSequence
    {
        var ret : MMLSequence = _prevSequence;
        _prevSequence._nextSequence = _nextSequence;
        _nextSequence._prevSequence = _prevSequence;
        _prevSequence = null;
        _nextSequence = null;
        return ((ret == this)) ? null : ret;
    }
    
    
    // calculate mml length
    private function _updateMMLLength() : Void
    {
        var exec : MMLExecutor = MMLSequencer._tempExecutor;
        var e : MMLEvent = headEvent.next;
        var length : Int = 0;
        
        _hasRepeatAll = false;
        exec.initialize(this);
        while (e != null){
            if (e.length > 0) {
                // note or rest
                length += e.length;
                e = e.next;
            }
            else {
                // others
                var _sw0_ = (e.id);                

                switch (_sw0_)
                {
                    case MMLEvent.REPEAT_BEGIN:e = exec._onRepeatBegin(e);
                    case MMLEvent.REPEAT_BREAK:e = exec._onRepeatBreak(e);
                    case MMLEvent.REPEAT_END:e = exec._onRepeatEnd(e);
                    case MMLEvent.REPEAT_ALL:e = null;_hasRepeatAll = true;
                    case MMLEvent.SEQUENCE_TAIL:e = null;
                    default:e = e.next;
                }
            }
        }
        
        _mmlLength = length;
    }
}



