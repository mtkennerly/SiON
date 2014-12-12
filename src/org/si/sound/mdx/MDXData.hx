//----------------------------------------------------------------------------------------------------
// MDX data class
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.mdx;

import openfl.errors.Error;
import org.si.sound.mdx.AbstructLoader;
import org.si.sound.mdx.ByteArray;
import org.si.sound.mdx.Event;
import org.si.sound.mdx.MDXExecutor;
import org.si.sound.mdx.MDXTrack;
import org.si.sound.mdx.MMLSequence;
import org.si.sound.mdx.PDXData;
import org.si.sound.mdx.PDXDataStorage;
import org.si.sound.mdx.SiONData;
import org.si.sound.mdx.SiONVoice;
import org.si.sound.mdx.SiOPMOperatorParam;
import org.si.sound.mdx.URLRequest;

import openfl.events.*;
import openfl.utils.ByteArray;
import openfl.net.URLRequest;
import org.si.sion.*;
import org.si.sion.module.SiOPMTable;
import org.si.sion.module.SiOPMChannelParam;
import org.si.sion.module.SiOPMOperatorParam;
import org.si.sion.sequencer.base.MMLEvent;
import org.si.sion.sequencer.base.MMLSequence;
import org.si.utils.AbstructLoader;


/** MDX data class */
class MDXData extends AbstructLoader
{
    public static var loadPDXDataAutomaticaly(get, set) : Bool;

    // variables
    //--------------------------------------------------------------------------------
    public var isPCM8 : Bool;
    public var bpm : Float = 0;
    public var title : String = null;
    public var pdxFileName : String = null;
    public var voices : Array<SiONVoice> = new Array<SiONVoice>();
    public var tracks : Array<MDXTrack> = new Array<MDXTrack>();
    public var executors : Array<MDXExecutor> = new Array<MDXExecutor>();
    
    private var _noiseVoice : SiONVoice;
    private var _noiseVoiceNumber : Int;
    private var _currentBPM : Float;
    private var _globalSequence : MMLSequence;
    private var _globalPrevClock : Int;
    
    private static var _loadPDXDataAutomaticaly : Bool = false;
    private static var _pdxDataStorage : PDXDataStorage;
    
    
    
    
    // properties
    //--------------------------------------------------------------------------------
    /** load PDXData automaticaly, if this flag is true, new PDXDataStorage instance is create internaly. */
    private static function get_loadPDXDataAutomaticaly() : Bool{
        return _loadPDXDataAutomaticaly;
    }
    private static function set_loadPDXDataAutomaticaly(b : Bool) : Bool{
        if (b && _pdxDataStorage == null)             _pdxDataStorage = new PDXDataStorage();
        _loadPDXDataAutomaticaly = b;
        return b;
    }
    
    
    /** Is avaiblable ? */
    public function isAvailable() : Bool{return false;
    }
    
    
    /** to string. */
    override public function toString() : String
    {
        var text : String = "";
        return text;
    }
    
    
    
    
    // constructor
    //--------------------------------------------------------------------------------
    /** constructor */
    public function new(url : URLRequest = null)
    {
        super();
        for (i in 0...16){executors[i] = new MDXExecutor();
        }
        _noiseVoice = new SiONVoice(2, 1);
        _noiseVoice.channelParam.operatorParam[0].ptType = SiOPMTable.PT_OPM_NOISE;
        if (url != null)             load(url);
    }
    
    
    
    
    // operations
    //--------------------------------------------------------------------------------
    /** Clear. */
    public function clear() : MDXData
    {
        var i : Int;
        isPCM8 = false;
        bpm = 0;
        title = null;
        pdxFileName = null;
        for (16){tracks[i] = null;
        }
        for (256){voices[i] = null;
        }
        _noiseVoiceNumber = -1;
        return this;
    }
    
    
    /** convert to SiONData 
     *  @param data SiONData to convert to, pass null to create new SiONData inside.
     *  @return converted SiONData
     */
    public function convertToSiONData(data : SiONData = null, pdxData : PDXData = null) : SiONData
    {
        if (SiONDriver.mutex == null)             throw new Error("MDXData.convertToSiONData() : This function can be called after creating SiONDriver.");
        
        var i : Int;
        var imax : Int;
        
        if (data == null)             data = new SiONData();
        data.clear();
        data.bpm = bpm;
        _globalSequence = data.globalSequence;
        
        // set voice data
        imax = voices.length;
        for (imax){data.fmVoices[i] = voices[i];
        }
        
        // set adpcm data
        if (pdxData != null) {
            imax = 96;
            for (imax){
                if (pdxData.extract(i))                     data.setPCMData(i, pdxData.pcmData[i]);
            }
        }  // construct mml sequences  
        
        
        
        imax = ((isPCM8)) ? 16 : 9;
        for (imax){
            if (tracks[i].hasNoData)                 executors[i].initialize(null, tracks[i], _noiseVoiceNumber, isPCM8)
            else executors[i].initialize(data.appendNewSequence().initialize(), tracks[i], _noiseVoiceNumber, isPCM8);
        }
        
        var totalClock : Int = 0;
        var nextClock : Int;
        var c : Int;
        _currentBPM = bpm;
        _globalPrevClock = 0;
        while (totalClock != Int.MAX_VALUE){
            // sync
            for (imax){
                executors[i].globalExec(totalClock, this);
            }  // exec  
            
            nextClock = Int.MAX_VALUE;
            for (imax){
                c = executors[i].exec(totalClock, _currentBPM);
                if (c < nextClock)                     nextClock = c;
            }
            totalClock = nextClock;
        }
        
        data.title = title;
        
        return data;
    }
    
    
    /** Load MDX data from byteArray. */
    public function loadBytes(bytes : ByteArray) : MDXData
    {
        _loadBytes(bytes);
        dispatchEvent(new Event(Event.COMPLETE));
        return this;
    }
    
    
    
    
    // handlers
    //--------------------------------------------------------------------------------
    /** @private */
    override private function onComplete() : Void
    {
        if (_loader.dataFormat == "binary") {
            _loadBytes(try cast(_loader.data, ByteArray) catch(e:Dynamic) null);
            if (pdxFileName != null && _loadPDXDataAutomaticaly) {
                addChild(_pdxDataStorage.load(new URLRequest(pdxFileName)));
            }
        }
    }
    
    
    
    
    // privates
    //--------------------------------------------------------------------------------
    // load from byte array
    private function _loadBytes(bytes : ByteArray) : Void
    {
        var titleLength : Int;
        var pdxLength : Int;
        var dataPointer : Int;
        var voiceOffset : Int;
        var voiceLength : Int;
        var voiceCount : Int;
        var i : Int;
        var mmlOffsets : Array<Dynamic> = new Array<Dynamic>(16);
        
        // initialize
        clear();
        bytes.endian = "bigEndian";
        bytes.position = 0;
        
        // title
        while (true){if (bytes.readByte() == 0x0d && bytes.readByte() == 0x0a && bytes.readByte() == 0x1a)                 break;
        }
        titleLength = bytes.position - 3;
        bytes.position = 0;
        title = bytes.readMultiByte(titleLength, "shift_jis");  //us-ascii  
        bytes.position = titleLength + 3;
        
        // pdx file
        while (true){if (bytes.readByte() == 0)                 break;
        }
        pdxLength = bytes.position - titleLength - 4;
        bytes.position = titleLength + 3;
        if (pdxLength != 0) {
            pdxFileName = bytes.readMultiByte(pdxLength, "shift_jis").toUpperCase();  //us-ascii  
            if (pdxFileName.substr(-4, 4) != ".PDX")                 pdxFileName += ".PDX";
        }
        bytes.position = titleLength + pdxLength + 4;
        
        // data offsets
        dataPointer = bytes.position;
        voiceOffset = bytes.readUnsignedShort();  // tone data  
        for (16){mmlOffsets[i] = dataPointer + bytes.readUnsignedShort();
        }
        // check pcm8
        bytes.position = mmlOffsets[0];
        isPCM8 = (bytes.readUnsignedByte() == 0xe8);
        
        // load voices
        bytes.position = dataPointer + voiceOffset;
        voiceLength = ((mmlOffsets[0] > voiceOffset)) ? (mmlOffsets[0] - voiceOffset) : (bytes.length - dataPointer - voiceOffset);  // ...?  
        _loadVoices(bytes, voiceLength);
        
        // load tracks
        _loadTracks(bytes, mmlOffsets);
    }
    
    
    // Load voice data from byteArray.
    private function _loadVoices(bytes : ByteArray, voiceLength : Int) : Void
    {
        var i : Int;
        var opi : Int;
        var v : Int;
        var voice : SiONVoice;
        var voiceNumber : Int;
        var fbalg : Int;
        var mask : Int;
        var opp : SiOPMOperatorParam;
        var reg : Array<Dynamic> = [];
        var opia : Array<Dynamic> = [3, 1, 2, 0];
        var dt2Table : Array<Dynamic> = [0, 384, 500, 608];
        
        voiceLength /= 27;
        for (voiceLength){
            voiceNumber = bytes.readUnsignedByte();
            fbalg = bytes.readUnsignedByte();
            mask = bytes.readUnsignedByte();
            for (6){reg[opi] = bytes.readUnsignedInt();
            }
            
            if (voices[voiceNumber] == null)                 voices[voiceNumber] = new SiONVoice();
            voice = voices[voiceNumber];
            voice.initialize();
            voice.chipType = SiONVoice.CHIPTYPE_OPM;
            voice.channelParam.opeCount = 4;
            
            voice.channelParam.fb = (fbalg >> 3) & 7;
            voice.channelParam.alg = (fbalg) & 7;
            
            for (4){
                opp = voice.channelParam.operatorParam[opia[opi]];
                opp.mute = (((mask >> opi) & 1) == 0);
                v = (reg[0] >> (opi << 3)) & 255;
                opp.dt1 = (v >> 4) & 7;
                opp.mul = v & 15;
                opp.tl = (reg[1] >> (opi << 3)) & 127;
                v = (reg[2] >> (opi << 3)) & 255;
                opp.ksr = (v >> 6) & 3;
                opp.ar = (v & 31) << 1;
                v = (reg[3] >> (opi << 3)) & 255;
                opp.ams = ((v >> 7) & 1) << 1;
                opp.dr = (v & 31) << 1;
                v = (reg[4] >> (opi << 3)) & 255;
                opp.detune = dt2Table[(v >> 6) & 3];
                opp.sr = (v & 31) << 1;
                v = (reg[5] >> (opi << 3)) & 255;
                opp.sl = (v >> 4) & 15;
                opp.rr = (v & 15) << 2;
            }  //trace(voice.getMML(voiceNumber));  
        }
        
        _noiseVoiceNumber = -1;
        i = 255;
        while (i >= 0){
            if (voices[i] == null) {
                _noiseVoiceNumber = i;
                voices[i] = _noiseVoice;
                break;
            }
            --i;
        }
    }
    
    
    // load mml tracks
    private function _loadTracks(bytes : ByteArray, mmlOffsets : Array<Dynamic>) : Void
    {
        var i : Int;
        var imax : Int = ((isPCM8)) ? 16 : 9;
        // load tracks
        bpm = 0;
        for (imax){
            bytes.position = mmlOffsets[i];
            tracks[i] = new MDXTrack(this, i);
            tracks[i].loadBytes(bytes);
            if (tracks[i].timerB != -1 && bpm == 0) {
                bpm = 4883 / (256 - tracks[i].timerB);
            }
        }
        if (bpm == 0)             bpm = 87.19642857142857  // 4883/(256-200)  ;
    }
    
    
    /** @private [internal] call from MDXExecutor.sync() */
    @:allow(org.si.sound.mdx)
    private function onSyncSend(channelNumber : Int, syncClock : Int) : Void
    {
        executors[channelNumber & 15].sync(syncClock);
    }
    
    
    /** @private [internal] call from MDXExecutor.sync() */
    @:allow(org.si.sound.mdx)
    private function onTimerB(timerB : Int, syncClock : Int) : Void
    {
        if (syncClock == 0)             return;
        if (syncClock > _globalPrevClock)             _globalSequence.appendNewEvent(MMLEvent.GLOBAL_WAIT, 0, (syncClock - _globalPrevClock) * 10);
        _globalPrevClock = syncClock;
        _currentBPM = 4883 / (256 - timerB);
        _globalSequence.appendNewEvent(MMLEvent.TEMPO, _currentBPM);
    }
}


