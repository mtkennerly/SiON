//----------------------------------------------------------------------------------------------------
// SMF Track chunk
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

import openfl.errors.Error;

import openfl.utils.ByteArray;


/** SMF Track chunk */
class SMFTrack
{
    public var trackIndex(get, never) : Int;

    // variables
    //------------------------------------------------------------------------
    /** sequence */
    public var sequence : Array<SMFEvent> = new Array<SMFEvent>();
    /** total time in MIDI clock */
    public var totalTime : Int;
    
    // parent SMFData
    private var _smfData : SMFData;
    // for exiting loop
    private var _exitLoop : Bool;
    // track index (start from 1)
    private var _trackIndex : Int;
    
    
    
    // properties
    //------------------------------------------------------------------------
    /** track index (start from 1) */
    private function get_trackIndex() : Int{return _trackIndex;
    }
    
    /** toString */
    public function toString() : String
    {
        var text : String = totalTime + "\n";
        
        for (i in 0...sequence.length){
            text += Std.string(sequence[i]) + "\n";
        }
        
        return text;
    }
    
    
    
    
    // constructor
    //------------------------------------------------------------------------
    /** constructor */
    public function new(smfData : SMFData, index : Int, bytes : ByteArray)
    {
        _trackIndex = index + 1;
        _smfData = smfData;
        
        var eventType : Int = -1;
        var code : Int;
        var value : Int = 0;
        var deltaTime : Int;
        var time : Int = 0;
        
        _exitLoop = false;
        bytes.position = 0;
        
        while (bytes.bytesAvailable > 0 && !_exitLoop){
            deltaTime = _readVariableLength(bytes);
            time += deltaTime;
            
            code = bytes.readUnsignedByte();
            if (!_readMetaEvent(code, bytes, deltaTime, time)) 
                if (!_readSystemExclusive(code, bytes, deltaTime, time)) 
            {
                if ((code & 0x80) != 0) {
                    eventType = code;
                }
                else {
                    if (eventType == -1)                         throw _errorIncorrectData();
                    bytes.position--;
                }
                
                var _sw4_ = (eventType & 0xf0);                

                switch (_sw4_)
                {
                    case SMFEvent.PROGRAM_CHANGE, SMFEvent.CHANNEL_PRESSURE:
                        value = bytes.readUnsignedByte();
                    case SMFEvent.NOTE_OFF, SMFEvent.NOTE_ON, SMFEvent.KEY_PRESSURE, SMFEvent.CONTROL_CHANGE:
                        value = (bytes.readUnsignedByte() << 16) | bytes.readUnsignedByte();
                    case SMFEvent.PITCH_BEND:
                        value = (bytes.readUnsignedByte() | (bytes.readUnsignedByte() << 7)) - 8192;
                }
                
                sequence.push(new SMFEvent(eventType, value, deltaTime, time));
            };
        }
        
        totalTime = time;
    }
    
    
    // read meta event
    private function _readMetaEvent(eventType : Int, bytes : ByteArray, deltaTime : Int, time : Int) : Bool
    {
        if (eventType != SMFEvent.META)             return false;
        
        var event : SMFEvent;
        var value : Int;
        var text : String;
        var metaEventType : Int = bytes.readUnsignedByte() | 0xff00;
        var len : Int = _readVariableLength(bytes);
        
        if ((metaEventType & 0x00f0) == 0) {
            // meta text data
            event = new SMFEvent(metaEventType, len, deltaTime, time);
            text = bytes.readMultiByte(len, "Shift-JIS");
            event.text = text;
            switch (metaEventType)
            {
                case SMFEvent.META_TEXT:_smfData.text = text;
                case SMFEvent.META_TITLE:if (_smfData.title == null) _smfData.title = text;
                case SMFEvent.META_AUTHOR:if (_smfData.author == null) _smfData.author = text;
            }
            sequence.push(event);
        }
        else {
            switch (metaEventType)
            {
                case SMFEvent.META_TEMPO:
                    value = (bytes.readUnsignedByte() << 16) | bytes.readUnsignedShort();
                    // [usec/beat] => [beats/minute]
                    event = new SMFEvent(SMFEvent.META_TEMPO, Math.round(60000000 / value), deltaTime, time);
                    if (_smfData.bpm == 0)                         _smfData.bpm = event.value;
                    sequence.push(event);
                case SMFEvent.META_TIME_SIGNATURE:
                    value = (bytes.readUnsignedByte() << 16) | (1 << bytes.readUnsignedByte());
                    event = new SMFEvent(SMFEvent.META_TIME_SIGNATURE, value, deltaTime, time);
                    if (_smfData.signature_d == 0) {
                        _smfData.signature_n = value >> 16;
                        _smfData.signature_d = value & 0xffff;
                    }
                    bytes.position += 2;
                    sequence.push(event);
                case SMFEvent.META_PORT:
                    value = bytes.readUnsignedByte();
                case SMFEvent.META_TRACK_END:
                    _exitLoop = true;
                default:
                    bytes.position += len;
            }
        }
        return true;
    }
    
    
    // read system exclusive data
    private function _readSystemExclusive(eventType : Int, bytes : ByteArray, deltaTime : Int, time : Int) : Bool
    {
        if (eventType != SMFEvent.SYSTEM_EXCLUSIVE && eventType != SMFEvent.SYSTEM_EXCLUSIVE_SHORT)             return false;
        
        var i : Int;
        var b : Int;
        var event : SMFEvent = new SMFEvent(eventType, 0, deltaTime, time);
        var len : Int = _readVariableLength(bytes);
        
        // read sysex bytes
        event.byteArray = new ByteArray();
        event.byteArray.writeByte(0xf0);  // start  
        for (i in 0...len){
            b = bytes.readUnsignedByte();
            event.byteArray.writeByte(b);
        }
        
        sequence.push(event);
        
        return true;
    }
    
    
    // read variable length
    private function _readVariableLength(bytes : ByteArray, time : Int = 0) : Int
    {
        var t : Int = bytes.readUnsignedByte();
        time += t & 0x7F;
        return ((t & 0x80) != 0) ? _readVariableLength(bytes, time << 7) : time;
    }
    
    
    
    
    // error
    //------------------------------------------------------------------------
    private function _errorIncorrectData() : Error{
        return new Error("The SMF File is not good.");
    }
}


