//----------------------------------------------------------------------------------------------------
// Sound Loader
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------




package org.si.sion.utils.soundloader;

import openfl.errors.Error;
import openfl.events.*;
import openfl.net.URLRequest;
import openfl.media.Sound;
import openfl.utils.ByteArray;


// Dispatching events
/** @eventType flash.events.Event.COMPLETE */
@:meta(Event(name="complete",type="flash.events.Event"))

/** @eventType flash.events.ErrorEvent.ERROR */
@:meta(Event(name="error",type="flash.events.ErrorEvent"))

/** @eventType  flash.events.ProgressEvent.PROGRESS */
@:meta(Event(name="progress",type="flash.events.ProgressEvent"))




/** Sound Loader.</br> 
 *  SoundLoader.setURL() to set loading url, SoundLoader.loadAll() to load all files and SoundLoader.hash to access all loaded files.</br>
 *  @see #setURL()
 *  @see #loadAll()
 *  @see #hash
 */
class SoundLoader extends EventDispatcher
{
    public var hash(get, never) : Dynamic;
    public var bytesTotal(get, never) : Float;
    public var bytesLoaded(get, never) : Float;
    public var loadingFileCount(get, never) : Int;
    public var loadedFileCount(get, never) : Int;
    public var loadImgFileAsSoundFont(get, set) : Bool;
    public var loadMP3FileAsBinary(get, set) : Bool;
    public var rememberHistory(get, set) : Bool;

    // variables
    //------------------------------------------------------------
    /** loaded sounds */
    private var _loaded : Map<String,Dynamic>;
    /** loading url list */
    private var _preserveList : Array<SoundLoaderFileData>;
    /** total file size */
    private var _bytesTotal : Float;
    /** loaded file size */
    private var _bytesLoaded : Int;
    /** error file count */
    private var _errorFileCount : Int;
    /** loading file count */
    private var _loadingFileCount : Int;
    /** loaded file count */
    private var _loadedFileCount : Int;
    /** loaded file data */
    private var _loadedFileData : Map<String, SoundLoaderFileData>;
    /** @private event priority */
    @:allow(org.si.sion.utils.soundloader)
    private var _eventPriority : Int;
    
    /** true to load 'swf' and 'png' type file as 'ssf' and 'ssfpng' @default false */
    private var _loadImgFileAsSoundFont : Bool;
    /** true to load 'mp3' type file as 'mp3bin' @default false */
    private var _loadMP3FileAsBinary : Bool;
    /** true to remember history @default false */
    private var _rememberHistory : Bool;
    
    
    
    
    // properties
    //------------------------------------------------------------
    /** Object to access all Sound instances. */
    private function get_hash() : Dynamic {
        return _loaded;
    }
    
    /** total file size when complete all loadings. */
    private function get_bytesTotal() : Float {
        return _bytesTotal;
    }
    
    /** file size currently loaded */
    private function get_bytesLoaded() : Float {
        return _bytesLoaded;
    }
    
    /** loading file count, this number is decreased when the file is loaded. */
    private function get_loadingFileCount() : Int {
        return _loadingFileCount + _preserveList.length;
    }
    
    /** loaded file count */
    private function get_loadedFileCount() : Int {
        return _loadedFileCount;
    }
    
    /** true to load 'swf' and 'png' type file as 'ssf' and 'ssfpng' @default false */
    private function get_loadImgFileAsSoundFont() : Bool {
        return _loadImgFileAsSoundFont;
    }
    private function set_loadImgFileAsSoundFont(b : Bool) : Bool {
        _loadImgFileAsSoundFont = b;
        return b;
    }
    
    /** true to load 'mp3' type file as 'mp3bin' @default false */
    private function get_loadMP3FileAsBinary() : Bool{return _loadMP3FileAsBinary;
    }
    private function set_loadMP3FileAsBinary(b : Bool) : Bool{_loadMP3FileAsBinary = b;
        return b;
    }
    
    /** true to check ID confirictoin @default false */
    private function get_rememberHistory() : Bool{return _rememberHistory;
    }
    private function set_rememberHistory(b : Bool) : Bool{_rememberHistory = b;
        return b;
    }
    
    
    
    
    // constructor
    //------------------------------------------------------------
    /** Constructor.
     *  @param eventPriority priority of all events disopatched by this sound loader.
     *  @param loadImgFileAsSoundFont true to load 'swf' and 'png' type file as 'ssf' and 'ssfpng'
     *  @param loadMP3FileAsBinary true to load 'mp3' type file as 'mp3bin'
     *  @param rememberHistory true to check ID confirictoin, 
     */
    public function new(eventPriority : Int = 0, loadImgFileAsSoundFont : Bool = false, loadMP3FileAsBinary : Bool = false, rememberHistory : Bool = false)
    {
        super();
        _eventPriority = eventPriority;
        _loaded = new Map<String, Dynamic>();
        _loadedFileData = new Map<String, SoundLoaderFileData>();
        _preserveList = new Array<SoundLoaderFileData>();
        _bytesTotal = 0;
        _bytesLoaded = 0;
        _loadingFileCount = 0;
        _loadedFileCount = 0;
        _errorFileCount = 0;
        _loadImgFileAsSoundFont = loadImgFileAsSoundFont;
        _loadMP3FileAsBinary = loadMP3FileAsBinary;
        _rememberHistory = rememberHistory;

    }
    
    
    /** output loaded file information */
    override public function toString() : String
    {
        var output : String = "[SoundLoader: " + loadedFileCount + " files are loaded.\n";
        for (id in Reflect.fields(_loaded)){
            output += "  '" + id + "' : " + Std.string(Reflect.field(_loaded, id)) + "\n";
        }
        output += "]";
        return output;
    }
    
    
    
    
    // operation
    //------------------------------------------------------------
    /** set loading file's urls.
     *  @param url requesting url
     *  @param id access key of SoundLoder.hash. null to set same as file name (without path, with extension).
     *  @param type file type, "mp3", "wav", "ssf", "ssfpng", "mid", "swf" or "mp3bin" is available, null to detect automatically by file extension. ("swf", "png", "gif", "jpg", "img", "bin", "txt" and "var" are available for non-sound files).
     *  @param checkPolicyFile LoaderContext.checkPolicyFile
     *  @return SoundLoaderFileData instance. SoundLoaderFileData is information class of loading file.
     */
    public function setURL(urlRequest : URLRequest, id : String = null, type : String = null, checkPolicyFile : Bool = false) : SoundLoaderFileData
    {
        var urlString : String = urlRequest.url;
        var lastDotIndex : Int = urlString.lastIndexOf(".");
        var lastSlashIndex : Int = urlString.lastIndexOf("/");
        var fileData : SoundLoaderFileData;
        if (lastSlashIndex == -1)             lastSlashIndex = 0;
        if (lastDotIndex < lastSlashIndex)             lastDotIndex = urlString.length;
        if (id == null)             id = urlString.substr(lastSlashIndex);
        if (_rememberHistory && _loadedFileData.exists(id) && _loadedFileData.get(id).urlString == urlString) {
            fileData = _loadedFileData.get(id);
        }
        else {
            if (type == null)                 type = urlString.substr(lastDotIndex + 1);
            if (_loadImgFileAsSoundFont) {
                if (type == "swf")                     type = "ssf"
                else if (type == "png")                     type = "ssfpng";
            }
            if (_loadMP3FileAsBinary && type == "mp3")                 type = "mp3bin";
            if (!(Lambda.has(SoundLoaderFileData._ext2typeTable, type))) {
                throw new Error("unknown file type. : " + urlString);
            }
            fileData = new SoundLoaderFileData(this, id, urlRequest, null, type, checkPolicyFile);
        }
        _preserveList.push(fileData);
        return fileData;
    }
    
    
    /** ByteArray convert to Sound
     *  @param byteArray ByteArray to convert
     *  @param id access key of SoundLoder.hash
     *  @return SoundLoaderFileData instance. SoundLoaderFileData is information class of loading file.
     */
    public function setByteArraySound(byteArray : ByteArray, id : String) : SoundLoaderFileData
    {
        var fileData : SoundLoaderFileData = new SoundLoaderFileData(this, id, null, byteArray, "b2snd", false);
        _preserveList.push(fileData);
        return fileData;
    }
    
    
    /** ByteArray convert to Loader (image and swf)
     *  @param byteArray ByteArray to convert
     *  @param id access key of SoundLoder.hash
     *  @return SoundLoaderFileData instance. SoundLoaderFileData is information class of loading file.
     */
    public function setByteArrayImage(byteArray : ByteArray, id : String) : SoundLoaderFileData
    {
        var fileData : SoundLoaderFileData = new SoundLoaderFileData(this, id, null, byteArray, "b2img", false);
        _preserveList.push(fileData);
        return fileData;
    }
    
    
    /** load all files specifed by SoundLoder.setURL() 
     *  @return loading file count, 0 when no loading
     */
    public function loadAll() : Int
    {
        var count : Int = 0;
        for (i in 0..._preserveList.length){
            if (_preserveList[i].load())                 count++
            else _preserveList[i].dispatchEvent(new Event(Event.COMPLETE, false, false));
        }
        
        if (_loadingFileCount + count > 0) {
            while (_preserveList.length > 0) {
                _preserveList.pop();
            }
            _loadingFileCount += count;
        }
        else {
            dispatchEvent(new Event(Event.COMPLETE, false, false));
        }
        return count;
    }
    
    
    
    
    // default handler
    //------------------------------------------------------------
    /** @private */
    @:allow(org.si.sion.utils.soundloader)
    private function _onProgress(fileData : SoundLoaderFileData, bytesLoadedDiff : Int, bytesTotalDiff : Int) : Void
    {
        _bytesTotal += bytesTotalDiff;
        _bytesLoaded += bytesLoadedDiff;
        dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _bytesLoaded, _bytesTotal));
    }
    
    /** @private */
    @:allow(org.si.sion.utils.soundloader)
    private function _onComplete(fileData : SoundLoaderFileData) : Void
    {
        if (fileData.dataID != null) {
            if (!(Lambda.has(_loaded, fileData.dataID))) {
                _loadedFileCount++;
            }
            _loadedFileData[fileData.dataID] = fileData;
            _loaded[fileData.dataID] = fileData.data;
        }
        fileData.dispatchEvent(new Event(Event.COMPLETE, false, false));
        if (--_loadingFileCount == 0) {
            _bytesLoaded = Math.floor(_bytesTotal);
            dispatchEvent(new Event(Event.COMPLETE, false, false));
        }
    }
    
    /** @private */
    @:allow(org.si.sion.utils.soundloader)
    private function _onError(fileData : SoundLoaderFileData, message : String) : Void
    {
        var errorMessage : String = "SoundLoader Error on " + fileData.dataID + " : " + message;
        _errorFileCount++;
        fileData.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, errorMessage));
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, errorMessage));
        if (--_loadingFileCount == 0) {
            _bytesLoaded = Math.floor(_bytesTotal);
            dispatchEvent(new Event(Event.COMPLETE, false, false));
        }
    }
}


