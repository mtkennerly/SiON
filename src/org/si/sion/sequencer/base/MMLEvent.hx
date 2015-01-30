//----------------------------------------------------------------------------------------------------
// MML event class
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.base;


/** MML event. */
class MMLEvent
{
    // constants
    //--------------------------------------------------
    private static inline var INT_MIN_VALUE = -2147483648;

    // event id for default mml commands
    public static inline var NOP : Int = 0;
    public static inline var PROCESS : Int = 1;
    public static inline var REST : Int = 2;
    public static inline var NOTE : Int = 3;
    //static public const LENGTH       :int = 4;
    //static public const TEI          :int = 5;
    //static public const OCTAVE       :int = 6;
    //static public const OCTAVE_SHIFT :int = 7;
    public static inline var KEY_ON_DELAY : Int = 8;
    public static inline var QUANT_RATIO : Int = 9;
    public static inline var QUANT_COUNT : Int = 10;
    public static inline var VOLUME : Int = 11;
    public static inline var VOLUME_SHIFT : Int = 12;
    public static inline var FINE_VOLUME : Int = 13;
    public static inline var SLUR : Int = 14;
    public static inline var SLUR_WEAK : Int = 15;
    public static inline var PITCHBEND : Int = 16;
    public static inline var REPEAT_BEGIN : Int = 17;
    public static inline var REPEAT_BREAK : Int = 18;
    public static inline var REPEAT_END : Int = 19;
    public static inline var MOD_TYPE : Int = 20;
    public static inline var MOD_PARAM : Int = 21;
    public static inline var INPUT_PIPE : Int = 22;
    public static inline var OUTPUT_PIPE : Int = 23;
    public static inline var REPEAT_ALL : Int = 24;
    public static inline var PARAMETER : Int = 25;
    public static inline var SEQUENCE_HEAD : Int = 26;
    public static inline var SEQUENCE_TAIL : Int = 27;
    public static inline var SYSTEM_EVENT : Int = 28;
    public static inline var TABLE_EVENT : Int = 29;
    public static inline var GLOBAL_WAIT : Int = 30;
    public static inline var TEMPO : Int = 31;
    public static inline var TIMER : Int = 32;
    public static inline var REGISTER : Int = 33;
    public static inline var DEBUG_INFO : Int = 34;
    public static inline var INTERNAL_CALL : Int = 35;
    public static inline var INTERNAL_WAIT : Int = 36;
    public static inline var DRIVER_NOTE : Int = 37;
    
    
    /** Event id for the first user defined command. */
    public static inline var USER_DEFINE : Int = 64;
    
    /** Maximum value of event id. */
    public static inline var COMMAND_MAX : Int = 128;
    
    // variables
    //--------------------------------------------------
    /** NOP event */
    public static var nopEvent : MMLEvent = (new MMLEvent()).initialize(MMLEvent.NOP, 0, 0);
    
    /** Event ID. */
    public var id : Int = 0;
    /** Event data. */
    public var data : Int = 0;
    /** Processing length. */
    public var length : Int = 0;
    /** Next event pointer in an event chain. */
    public var next : MMLEvent;
    /** Pointer refered by repeating. */
    public var jump : MMLEvent;

    
    // functions
    //--------------------------------------------------
    /** Constructor */
    public function new(id : Int = 0, data : Int = 0, length : Int = 0)
    {
        if (id > 1) {
            initialize(id, data, length);
        }
    }
    
    
    /** Format as "#id; data" */
    public function toString() : String
    {
        return "#" + Std.string(id) + "; " + Std.string(data);
    }
    
    
    /** Initializes 
     *  @param id Event ID.
     *  @param data Event data. Recommend that the value &lt;= 0xffffff.
     */
    public function initialize(id : Int, data : Int, length : Int) : MMLEvent
    {
        this.id = id & 0x7f;
        this.data = data;
        this.length = length;
        this.next = null;
        this.jump = null;
        return this;
    }
    
    
    /** Get parameters as an array. 
     *  @param param Reference to get parameters.
     *  @param length Max parameters count to get.
     *  @return The last parameter event.
     */
    public function getParameters(param : Array<Int>, length : Int) : MMLEvent
    {
        var i : Int;
        var e : MMLEvent = this;
        
        i = 0;
        while (i < length){
            param[i] = e.data;i++;
            if (e.next == null || e.next.id != PARAMETER)                 break;
            e = e.next;
        }
        while (i < length){
            param[i] = INT_MIN_VALUE;i++;
        }
        return e;
    }
    
    
    /** free this event to reuse. */
    public function free() : Void
    {
        if (next == null) {
            MMLParser._freeEvent(this);
        }
    }
    
    
    /** Pack to int. */
    public function pack() : Int
    {
        return 0;
    }
    
    
    /** Unpack from int. */
    public function unpack(d : Int) : Void
    {
        
    }
}



