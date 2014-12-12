//----------------------------------------------------------------------------------------------------
// MDX event class
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.mdx;


import openfl.utils.ByteArray;


/** MDX event */
class MDXEvent
{
    // constant
    //--------------------------------------------------------------------------------
    public static inline var REST : Int = 0x00;
    public static inline var NOTE : Int = 0x80;
    public static inline var TIMERB : Int = 0xff;
    public static inline var REGISTER : Int = 0xfe;
    public static inline var VOICE : Int = 0xfd;
    public static inline var PAN : Int = 0xfc;
    public static inline var VOLUME : Int = 0xfb;
    public static inline var VOLUME_DEC : Int = 0xfa;
    public static inline var VOLUME_INC : Int = 0xf9;
    public static inline var GATE : Int = 0xf8;
    public static inline var SLUR : Int = 0xf7;
    public static inline var REPEAT_BEGIN : Int = 0xf6;
    public static inline var REPEAT_END : Int = 0xf5;
    public static inline var REPEAT_BREAK : Int = 0xf4;
    public static inline var DETUNE : Int = 0xf3;
    public static inline var PORTAMENT : Int = 0xf2;
    public static inline var DATA_END : Int = 0xf1;
    public static inline var KEY_ON_DELAY : Int = 0xf0;
    public static inline var SYNC_SEND : Int = 0xef;
    public static inline var SYNC_WAIT : Int = 0xee;
    public static inline var FREQUENCY : Int = 0xed;
    public static inline var PITCH_LFO : Int = 0xec;
    public static inline var VOLUME_LFO : Int = 0xeb;
    public static inline var OPM_LFO : Int = 0xea;
    public static inline var LFO_DELAY : Int = 0xe9;
    public static inline var SET_PCM8 : Int = 0xe8;
    public static inline var FADEOUT : Int = 0xe7;
    
    
    private static var _noteText : Array<String> = ["c ", "c+", "d ", "d+", "e ", "f ", "f+", "g ", "g+", "a ", "a+", "b "];
    
    
    
    
    // variables
    //--------------------------------------------------------------------------------
    public var type : Int = 0;
    public var data : Int = 0;
    public var data2 : Int = 0;
    public var deltaClock : Int = 0;
    
    
    
    
    // properties
    //--------------------------------------------------------------------------------
    /** toString */
    public function toString() : String
    {
        var i : Int;
        switch (type)
        {
            case REST:return "r ;" + Std.string(deltaClock);
            case NOTE:
                i = (data + 15) % 12;
                return "o" + Std.string(((data + 15) / 12) >> 0) + _noteText[i] + ";" + Std.string(deltaClock);
            case GATE:return "q" + Std.string(data);
            case DETUNE:return "k" + Std.string(data >> 8);
            case REPEAT_BEGIN:return "[" + Std.string(data);
            case REPEAT_BREAK:return "|";
            case REPEAT_END:return "]";
            case PORTAMENT:return "po";
            case SLUR:return "&";
            case VOICE:return "@" + Std.string(data);
            case PAN:return "p" + Std.string(data);
            case VOLUME:return ((data < 16)) ? "v" + Std.string(data) : "@v" + Std.string(data & 127);
            case LFO_DELAY:return "LFO_delay" + Std.string(data);
            case PITCH_LFO:return "LFO" + Std.string((data & 255)) + " mp" + (data >> 8) + "," + (data2);
            case VOLUME_LFO:return "LFO" + Std.string((data & 255)) + " ma" + (data >> 8) + "," + (data2);
            case FREQUENCY:return "FREQ" + Std.string(data);
            case TIMERB:return "TIMER_B " + Std.string(data);
            case SET_PCM8:return "PCM8";
            default:return "#" + Std.string(type) + "; " + Std.string(data);
        }
        return "";
    }
    
    
    
    
    // constructor
    //--------------------------------------------------------------------------------
    public function new(type : Int, data : Int, data2 : Int, deltaClock : Int)
    {
        this.type = type;
        this.data = data;
        this.data2 = data2;
        this.deltaClock = deltaClock;
    }
}


