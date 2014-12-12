//----------------------------------------------------------------------------------------------------
// Standard MIDI File class
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
import openfl.net.*;
import openfl.events.*;


// Dispatching events
/** @eventType flash.events.Event.COMPLETE */
@:meta(Event(name="complete",type="flash.events.Event"))

/** @eventType flash.events.ErrorEvent.ERROR */
@:meta(Event(name="error",type="flash.events.ErrorEvent"))

/** @eventType  flash.events.ProgressEvent.PROGRESS */
@:meta(Event(name="progress",type="flash.events.ProgressEvent"))



/** Standard MIDI File class */
class SMFData extends EventDispatcher
{
    public var isAvailable(get, never) : Bool;

    // variables
    //--------------------------------------------------------------------------------
    /** Standard MIDI file format (0,1 o 2) */
    public var format : Int;
    /** track count */
    public var numTracks : Int;
    /** resolution [ticks/whole tone] */
    public var resolution : Int;
    /** initial tempo */
    public var bpm : Int = 0;
    /** text information */
    public var text : String = "";
    /** title string */
    public var title : String = null;
    /** author infomation */
    public var author : String = null;
    /** numerator of signiture */
    public var signature_n : Int = 0;
    /** denominator of signiture */
    public var signature_d : Int = 0;
    /** song length [measures] */
    public var measures : Float = 0;
    /** SMF tracks */
    public var tracks : Array<SMFTrack> = new Array<SMFTrack>();
    
    private var _urlLoader : URLLoader;
    
    
    
    
    // properties
    //--------------------------------------------------------------------------------
    /** Is avaiblable ? */
    private function get_isAvailable() : Bool{return (numTracks > 0);
    }
    
    
    /** to string. */
    override public function toString() : String
    {
        var text : String = "";
        text += "format : SMF" + format + "\n";
        text += "numTracks : " + numTracks + "\n";
        text += "resolution : " + (resolution >> 2) + "\n";
        text += "title : " + title + "\n";
        text += "author : " + author + "\n";
        text += "signature : " + signature_n + "/" + signature_d + "\n";
        text += "BPM : " + bpm + "\n";
        return text;
    }
    
    
    
    
    // constructor
    //--------------------------------------------------------------------------------
    /** constructor */
    public function new()
    {
        super();
        clear();
    }
    
    
    
    
    // operations
    //--------------------------------------------------------------------------------
    /** Clear. */
    public function clear() : SMFData
    {
        format = 0;
        numTracks = 0;
        resolution = 0;
        bpm = 0;
        text = null;
        title = null;
        author = null;
        signature_n = 0;
        signature_d = 0;
        measures = 0;
        tracks.splice(0, tracks.length);
        
        return this;
    }
    
    
    /** Load SMF file. This function dispatches Event.COPMLETE when finish loading
     *  @param url URL of SMF file
     */
    public function load(url : URLRequest) : Void
    {
        var byteArray : ByteArray = new ByteArray();
        _urlLoader = new URLLoader();
        _urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
        _urlLoader.addEventListener(Event.COMPLETE, _onComplete);
        _urlLoader.addEventListener(ProgressEvent.PROGRESS, _onProgress);
        _urlLoader.addEventListener(IOErrorEvent.IO_ERROR, _onError);
        _urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onError);
        _urlLoader.load(url);
    }
    
    
    /** Load SMF data from byteArray. This function dispatches Event.COPMLETE but returns data immediately.
     *  @param bytes SMF file binary
     */
    public function loadBytes(bytes : ByteArray) : SMFData
    {
        bytes.position = 0;
        clear();
        
        var tr : Int;
        var len : Int;
        var temp : ByteArray = new ByteArray();
        while (bytes.bytesAvailable > 0){
            var type : String = bytes.readMultiByte(4, "us-ascii");
            switch (type)
            {
                case "MThd":
                    bytes.position += 4;
                    format = bytes.readUnsignedShort();
                    numTracks = bytes.readUnsignedShort();
                    resolution = bytes.readUnsignedShort() << 2;
                case "MTrk":
                    len = bytes.readUnsignedInt();
                    bytes.readBytes(temp, 0, len);
                    tracks.push(new SMFTrack(this, tracks.length, temp));
                default:
                    len = bytes.readUnsignedInt();
                    bytes.position += len;
                    break;
            }
        }
        
        if (text == null)             text = "";
        if (title == null)             title = "";
        if (author == null)             author = "";
        
        if (resolution > 0) {
            len = 0;
            for (tr in 0...tracks.length) {
                if (len < tracks[tr].totalTime) len = tracks[tr].totalTime;
            }
            measures = len / resolution;
        }
        
        dispatchEvent(new Event(Event.COMPLETE));
        
        return this;
    }
    
    
    
    
    // internal use
    //--------------------------------------------------
    private function _onProgress(e : ProgressEvent) : Void
    {
        dispatchEvent(e.clone());
    }
    
    
    private function _onComplete(e : Event) : Void
    {
        _removeAllListeners();
        loadBytes(_urlLoader.data);
    }
    
    
    private function _onError(e : ErrorEvent) : Void
    {
        _removeAllListeners();
        dispatchEvent(e.clone());
    }
    
    
    private function _removeAllListeners() : Void
    {
        _urlLoader.removeEventListener(Event.COMPLETE, _onComplete);
        _urlLoader.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
        _urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, _onError);
        _urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _onError);
    }
}



