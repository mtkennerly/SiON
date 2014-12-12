//----------------------------------------------------------------------------------------------------
// Track of MDX data
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.mdx;


import openfl.utils.ByteArray;


/** Track of MDX data */
class MDXTrack
{
    public var hasNoData(get, never) : Bool;

    // variables
    //--------------------------------------------------------------------------------
    /** sequence */
    public var sequence : Array<MDXEvent> = new Array<MDXEvent>();
    /** Return pointer of segno */
    public var segnoPointer : MDXEvent;
    /** timer B value to set */
    public var timerB : Int;
    
    /** owner MDXData */
    public var owner : MDXData;
    /** channel number */
    public var channelNumber : Int;
    
    
    
    // properties
    //--------------------------------------------------------------------------------
    /** has no data. */
    private function get_hasNoData() : Bool{
        return (sequence.length <= 1);
    }
    
    /** to string. */
    public function toString() : String
    {
        var text : String = "";
        var i : Int;
        var imax : Int = sequence.length;
        for (imax){text += sequence[i] + "\n";
        }
        return text;
    }
    
    
    
    
    // constructor
    //--------------------------------------------------------------------------------
    public function new(owner : MDXData, channelNumber : Int)
    {
        this.owner = owner;
        this.channelNumber = channelNumber;
        sequence = new Array<MDXEvent>();
        segnoPointer = null;
    }
    
    
    
    
    // operations
    //--------------------------------------------------------------------------------
    /** Clear. */
    public function clear() : MDXTrack
    {
        sequence.length = 0;
        segnoPointer = null;
        timerB = -1;
        return this;
    }
    
    
    /** Load track from byteArray. */
    public function loadBytes(bytes : ByteArray) : MDXTrack
    {
        clear();
        
        var clock : Int;
        var code : Int;
        var v : Int;
        var pos : Int;
        var mem : Array<Dynamic> = [];
        var exitLoop : Bool = false;
        
        while (!exitLoop && bytes.bytesAvailable > 0){
            pos = bytes.position;
            code = bytes.readUnsignedByte();
            if (code < 0x80) {  // rest  
                newEvent(MDXEvent.REST, 0, 0, code + 1);
                clock += code + 1;
            }
            else 
            if (code < 0xe0) {  // note  
                v = bytes.readUnsignedByte() + 1;
                newEvent(MDXEvent.NOTE, code - 0x80, 0, v);
                clock += v;
            }
            else {
                switch (code)
                {
                    case MDXEvent.REGISTER, MDXEvent.FADEOUT:
                        newEvent(code, bytes.readUnsignedByte(), bytes.readUnsignedByte());
                    case MDXEvent.VOICE, MDXEvent.PAN, MDXEvent.VOLUME, MDXEvent.GATE, MDXEvent.KEY_ON_DELAY, MDXEvent.FREQUENCY, MDXEvent.LFO_DELAY, MDXEvent.SYNC_SEND:
                        newEvent(code, bytes.readUnsignedByte());
                    case MDXEvent.VOLUME_DEC, MDXEvent.VOLUME_INC, MDXEvent.SLUR, MDXEvent.SET_PCM8, MDXEvent.SYNC_WAIT:
                        newEvent(code);
                    //----- REPEAT
                    case MDXEvent.DETUNE, MDXEvent.PORTAMENT, MDXEvent.REPEAT_BEGIN:

                        switch (code)
                        {case MDXEvent.PORTAMENT:
                                newEvent(code, bytes.readShort());  //...short?  
                                break;
                        }
                        newEvent(code, bytes.readUnsignedByte(), bytes.readUnsignedByte());
                    //----- others
                    case MDXEvent.REPEAT_END, MDXEvent.REPEAT_BREAK, MDXEvent.TIMERB:

                        switch (code)
                        {case MDXEvent.REPEAT_END:
                                newEvent(code, pos + bytes.readShort());  // position of REPEAT_BEGIN  
                                break;
                        }

                        switch (code)
                        {case MDXEvent.REPEAT_BREAK:
                                newEvent(code, pos + bytes.readShort() + 2);  // position of REPEAT_END  
                                break;
                        }
                        v = bytes.readUnsignedByte();
                        if (clock == 0)                             timerB = v;
                        newEvent(code, v);
                    case MDXEvent.PITCH_LFO, MDXEvent.VOLUME_LFO:
                        v = bytes.readUnsignedByte();
                        if (v == 0x80 || v == 0x81)                             newEvent(code, v)
                        else newEvent(code, v | (bytes.readUnsignedShort() << 8), bytes.readShort());
                    case MDXEvent.OPM_LFO:
                        v = bytes.readUnsignedByte();
                        if (v == 0x80 || v == 0x81)                             newEvent(code, v << 16)
                        else {
                            v = (v << 16) | (bytes.readUnsignedByte() << 8) | bytes.readUnsignedByte();
                            newEvent(code, v, bytes.readShort());
                        }
                    case MDXEvent.DATA_END:  // ...?  
                        v = bytes.readShort();
                        newEvent(code, v);
                        if (v > 0 && pos - v + 3 >= 0)                             segnoPointer = mem[pos - v + 3]
                        else if (v < 0 && pos + v + 3 >= 0)                             segnoPointer = mem[pos + v + 3];
                        exitLoop = true;
                    default:
                        newEvent(MDXEvent.DATA_END);
                        exitLoop = true;
                        break;
                }
            }
        }
        
        
        function newEvent(type : Int, data : Int = 0, data2 : Int = 0, deltaClock : Int = 0) : MDXEvent{
            var inst : MDXEvent = new MDXEvent(type, data, data2, deltaClock);
            sequence.push(inst);
            mem[pos] = inst;
            return inst;
        }  //trace(String(this));    //trace("------------------- ch", channelNumber, "-------------------");  ;
        
        
        
        
        
        return this;
    }
}



