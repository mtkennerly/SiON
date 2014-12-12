//----------------------------------------------------------------------------------------------------
// SMF event
//  modified by keim.
//  This soruce code is distributed under BSD-style license (see org.si.license.txt).
//
// Original code
//  url; http://wonderfl.net/code/0aad6e9c1c5f5a983c6fce1516ea501f7ea7dfaa
//  Copyright (c) 2010 nemu90kWw All rights reserved.
//  The original code is distributed under MIT license.
//  (see http://www.opensource.org/licenses/mit-license.php).
//----------------------------------------------------------------------------------------------------


package org.si.sion.midi;


import openfl.utils.ByteArray;


/** SMF event */
class SMFEvent
{
    public var channel(get, never) : Int;
    public var note(get, never) : Int;
    public var velocity(get, never) : Int;
    public var text(get, set) : String;

    // constant
    //--------------------------------------------------------------------------------
    public static inline var NOTE_OFF : Int = 0x80;
    public static inline var NOTE_ON : Int = 0x90;
    public static inline var KEY_PRESSURE : Int = 0xa0;
    public static inline var CONTROL_CHANGE : Int = 0xb0;
    public static inline var PROGRAM_CHANGE : Int = 0xc0;
    public static inline var CHANNEL_PRESSURE : Int = 0xd0;
    public static inline var PITCH_BEND : Int = 0xe0;
    public static inline var SYSTEM_EXCLUSIVE : Int = 0xf0;
    public static inline var SYSTEM_EXCLUSIVE_SHORT : Int = 0xf7;
    public static inline var META : Int = 0xff;
    
    public static inline var META_SEQNUM : Int = 0xff00;
    public static inline var META_TEXT : Int = 0xff01;
    public static inline var META_AUTHOR : Int = 0xff02;
    public static inline var META_TITLE : Int = 0xff03;
    public static inline var META_INSTRUMENT : Int = 0xff04;
    public static inline var META_LYLICS : Int = 0xff05;
    public static inline var META_MARKER : Int = 0xff06;
    public static inline var META_CUE : Int = 0xff07;
    public static inline var META_PROGRAM_NAME : Int = 0xff08;
    public static inline var META_DEVICE_NAME : Int = 0xff09;
    public static inline var META_CHANNEL : Int = 0xff20;
    public static inline var META_PORT : Int = 0xff21;
    public static inline var META_TRACK_END : Int = 0xff2f;
    public static inline var META_TEMPO : Int = 0xff51;
    public static inline var META_SMPTE_OFFSET : Int = 0xff54;
    public static inline var META_TIME_SIGNATURE : Int = 0xff58;
    public static inline var META_KEY_SIGNATURE : Int = 0xff59;
    public static inline var META_SEQUENCER_SPEC : Int = 0xff7f;
    
    public static inline var CC_BANK_SELECT_MSB : Int = 0;
    public static inline var CC_BANK_SELECT_LSB : Int = 32;
    public static inline var CC_MODULATION : Int = 1;
    public static inline var CC_PORTAMENTO_TIME : Int = 5;
    public static inline var CC_DATA_ENTRY_MSB : Int = 6;
    public static inline var CC_DATA_ENTRY_LSB : Int = 38;
    public static inline var CC_VOLUME : Int = 7;
    public static inline var CC_BALANCE : Int = 8;
    public static inline var CC_PANPOD : Int = 10;
    public static inline var CC_EXPRESSION : Int = 11;
    public static inline var CC_SUSTAIN_PEDAL : Int = 64;
    public static inline var CC_PORTAMENTO : Int = 65;
    public static inline var CC_SOSTENUTO_PEDAL : Int = 66;
    public static inline var CC_SOFT_PEDAL : Int = 67;
    public static inline var CC_RESONANCE : Int = 71;
    public static inline var CC_RELEASE_TIME : Int = 72;
    public static inline var CC_ATTACK_TIME : Int = 73;
    public static inline var CC_CUTOFF_FREQ : Int = 74;
    public static inline var CC_DECAY_TIME : Int = 75;
    public static inline var CC_PROTAMENTO_CONTROL : Int = 84;
    public static inline var CC_REVERB_SEND : Int = 91;
    public static inline var CC_CHORUS_SEND : Int = 93;
    public static inline var CC_DELAY_SEND : Int = 94;
    public static inline var CC_NRPN_LSB : Int = 98;
    public static inline var CC_NRPN_MSB : Int = 99;
    public static inline var CC_RPN_LSB : Int = 100;
    public static inline var CC_RPN_MSB : Int = 101;
    
    public static inline var RPN_PITCHBEND_SENCE : Int = 0;
    public static inline var RPN_FINE_TUNE : Int = 1;
    public static inline var RPN_COARSE_TUNE : Int = 2;
    
    private static var _noteText : Array<String> = ["c ", "c+", "d ", "d+", "e ", "f ", "f+", "g ", "g+", "a ", "a+", "b "];
    
    
    
    // variables
    //--------------------------------------------------------------------------------
    public var type : Int = 0;
    public var value : Int = 0;
    public var byteArray : ByteArray = null;
    
    public var deltaTime : Int = 0;
    public var time : Int = 0;
    
    
    
    
    // properties
    //--------------------------------------------------------------------------------
    /** channel */
    private function get_channel() : Int{return ((type >= SYSTEM_EXCLUSIVE)) ? 0 : (type & 0x0f);
    }
    
    /** note */
    private function get_note() : Int{return value >> 16;
    }
    
    /** velocity */
    private function get_velocity() : Int{return value & 0x7f;
    }
    
    /** text data */
    private function get_text() : String{return ((byteArray != null)) ? byteArray.readUTF() : "";
    }
    private function set_text(str : String) : String{
        if (byteArray == null)             byteArray = new ByteArray();
        byteArray.writeUTF(str);
        return str;
    }
    
    
    /** toString */
    public function toString() : String
    {
        if ((type & 0xff00) != 0) {
            var _sw0_ = (type & 0xf0);            

            switch (_sw0_)
            {
                case META_TEMPO:
                    return "bpm(" + Std.string(value) + ")";
            }
        }
        else {
            var ret : String = "ch" + Std.string((type & 15)) + ":";
            var n : Int;
            var v : Int;
            var _sw1_ = (type & 0xf0);

            switch (_sw1_)
            {
                case NOTE_ON:
                    return ret + "ON(" + Std.string(note) + ") " + Std.string(velocity);
                case NOTE_OFF:
                    return ret + "OF(" + Std.string(note) + ") " + Std.string(velocity);
                case CONTROL_CHANGE:
                    return ret + "CC(" + Std.string((value >> 16)) + ") " + Std.string((value & 0xffff));
                case PROGRAM_CHANGE:
                    return ret + "PC(" + Std.string(value) + ") ";
                case SYSTEM_EXCLUSIVE:
                    var text : String = "SX:";
                    if (byteArray != null) {
                        byteArray.position = 0;
                        while (byteArray.bytesAvailable > 0){
                            text += Std.string(byteArray.readUnsignedByte()) + " ";
                        }
                    }
                    return ret + text;
            }
        }
        
        return "#" + Std.string(type) + "(" + Std.string(value) + ")";
    }
    
    
    
    
    // constructor
    //--------------------------------------------------------------------------------
    public function new(type : Int, value : Int, deltaTime : Int, time : Int)
    {
        this.type = type;
        this.value = value;
        this.deltaTime = deltaTime;
        this.time = time;
    }
}


