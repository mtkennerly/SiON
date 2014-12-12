//----------------------------------------------------------------------------------------------------
// NSF data class
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.nsf;


import openfl.utils.ByteArray;


/** NSF data class */
class NSFData
{
    // variables
    //--------------------------------------------------------------------------------
    public var version : Int;
    public var songCount : Int;
    public var startSongID : Int;
    public var loadAddress : Int;
    public var initAddress : Int;
    public var playAddress : Int;
    public var title : String;
    public var artist : String;
    public var copyright : String;
    public var speedNRSC : Int;
    public var speedPAL : Int;
    public var NTSC_PALbits : Int;
    public var bankSwitch : Array<Int> = new Array<Int>();
    public var extraChipFlag : Int;
    public var reserved : Int;
    
    
    
    
    // properties
    //--------------------------------------------------------------------------------
    /** Is avaiblable ? */
    public function isAvailable() : Bool{return false;
    }
    
    
    /** to string. */
    public function toString() : String
    {
        var text : String = "";
        return text;
    }
    
    
    
    
    // constructor
    //--------------------------------------------------------------------------------
    public function new()
    {
        
    }
    
    
    
    
    
    // operations
    //--------------------------------------------------------------------------------
    /** Clear. */
    public function clear() : NSFData
    {
        
        return this;
    }
    
    
    /** Load NSF data from byteArray. */
    public function loadBytes(bytes : ByteArray) : NSFData
    {
        bytes.position = 0;
        clear();
        
        if (bytes.readMultiByte(4, "us-ascii") != "NESM")             return this;
        bytes.position = 5;
        version = bytes.readUnsignedByte();
        songCount = bytes.readUnsignedByte();
        startSongID = bytes.readUnsignedByte();
        loadAddress = bytes.readUnsignedShort();
        initAddress = bytes.readUnsignedShort();
        playAddress = bytes.readUnsignedShort();
        
        title = bytes.readMultiByte(32, "us-ascii");  //shift_jis  
        artist = bytes.readMultiByte(32, "us-ascii");  //shift_jis  
        copyright = bytes.readMultiByte(32, "us-ascii");  //shift_jis  
        
        speedNRSC = bytes.readUnsignedShort();
        for (i in 0...8){bankSwitch[i] = bytes.readUnsignedByte();
        }
        speedPAL = bytes.readUnsignedShort();
        NTSC_PALbits = bytes.readUnsignedByte();
        extraChipFlag = bytes.readUnsignedByte();
        reserved = bytes.readUnsignedInt();
        bytes.position = 128;
        
        
        
        return this;
    }
}



