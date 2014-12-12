//----------------------------------------------------------------------------------------------------
// Loader basic class
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------




package org.si.utils;

import openfl.errors.Error;
import org.si.utils.ErrorEvent;
import org.si.utils.Event;
import org.si.utils.EventDispatcher;
import org.si.utils.ProgressEvent;
import org.si.utils.URLLoader;
import org.si.utils.URLRequest;

import openfl.events.*;
import openfl.net.*;
import openfl.utils.ByteArray;


/** Loader basic class. */
class AbstructLoader extends EventDispatcher
{
    // variables
    //------------------------------------------------------------
    /** loader */
    private var _loader : URLLoader;
    /** total bytes */
    private var _bytesTotal : Float;
    /** loaded bytes */
    private var _bytesLoaded : Float;
    /** flag complete loading */
    private var _isLoadCompleted : Bool;
    /** child loaders */
    private var _childLoaders : Array<Dynamic>;
    /** event priority */
    private var _eventPriority : Int;
    
    
    
    
    // constructor
    //------------------------------------------------------------
    /** Constructor */
    public function new(priority : Int = 0)
    {
        super();
        _loader = new URLLoader();
        _bytesTotal = 0;
        _bytesLoaded = 0;
        _isLoadCompleted = false;
        _childLoaders = [];
        _eventPriority = priority;
    }
    
    
    
    
    // operation
    //------------------------------------------------------------
    /** load */
    public function load(url : URLRequest) : Void
    {
        _loader.close();
        _bytesTotal = 0;
        _bytesLoaded = 0;
        _isLoadCompleted = false;
        _addAllListeners();
        _loader.load(url);
    }
    
    
    /** add child loader */
    public function addChild(child : AbstructLoader) : Void
    {
        _childLoaders.push(child);
        child.addEventListener(Event.COMPLETE, _onChildComplete);
    }
    
    
    
    
    // virtual function
    //------------------------------------------------------------
    /** overriding function when completes loading */
    private function onComplete() : Void{
    }
    
    
    
    
    // default handler
    //------------------------------------------------------------
    private function _onProgress(e : ProgressEvent) : Void
    {
        _bytesTotal = e.bytesTotal;
        _bytesLoaded = e.bytesLoaded;
        _isLoadCompleted = false;
        dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _bytesLoaded, _bytesTotal));
    }
    
    
    private function _onComplete(e : Event) : Void
    {
        _removeAllListeners();
        _bytesLoaded = _bytesTotal;
        _isLoadCompleted = true;
        onComplete();
        if (_childLoaders.length == 0) {
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }
    
    
    private function _onError(e : ErrorEvent) : Void
    {
        _removeAllListeners();
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, Std.string(e)));
    }
    
    
    private function _onChildComplete(e : Event) : Void
    {
        var index : Int = Lambda.indexOf(_childLoaders, e.target);
        if (index == -1)             throw new Error("AbstructLoader; unkown error, children mismatched.");
        _childLoaders.splice(index, 1);
        if (_childLoaders.length == 0 && _isLoadCompleted) {
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }
    
    
    private function _addAllListeners() : Void
    {
        _loader.addEventListener(Event.COMPLETE, _onComplete, false, _eventPriority);
        _loader.addEventListener(ProgressEvent.PROGRESS, _onProgress, false, _eventPriority);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, _onError, false, _eventPriority);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onError, false, _eventPriority);
    }
    
    
    private function _removeAllListeners() : Void
    {
        _loader.removeEventListener(Event.COMPLETE, _onComplete);
        _loader.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, _onError);
        _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _onError);
    }
}


