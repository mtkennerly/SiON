//----------------------------------------------------------------------------------------------------
// SiON Effect serial connector
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;


import org.si.sion.module.SiOPMModule;
import org.si.sion.module.SiOPMStream;


/** SiON Effector stream. */
class SiEffectStream
{
    public var stream(get, never) : SiOPMStream;
    public var pan(get, set) : Int;
    public var _outputDirectly(get, never) : Bool;

    // variables
    //--------------------------------------------------------------------------------
    /** effector chain */
    public var chain : Array<SiEffectBase> = new Array<SiEffectBase>();
    
    /** @private [internal] streaming buffer */
    @:allow(org.si.sion.effector)
    private var _stream : SiOPMStream;
    /** @private [internal] depth. deeper stream execute first. */
    @:allow(org.si.sion.effector)
    private var _depth : Int;
    
    // module
    private var _module : SiOPMModule;
    // panning
    private var _pan : Int;
    // has effect send
    private var _hasEffectSend : Bool;
    // streaming level
    private var _volumes : Array<Float> = new Array<Float>();
    // output streams
    private var _outputStreams : Array<SiOPMStream> = new Array<SiOPMStream>();

    public static inline var INT_MIN_VALUE = -2147483648;
    
    
    // properties
    //----------------------------------------
    /** stream buffer */
    private function get_stream() : SiOPMStream{
        return _stream;
    }
    
    
    /** panning of output (-64:L - 0:C - 64:R). */
    private function get_pan() : Int{
        return _pan - 64;
    }
    private function set_pan(p : Int) : Int{
        _pan = p + 64;
        if (_pan < 0)             _pan = 0
        else if (_pan > 128)             _pan = 128;
        return p;
    }
    
    
    /** @private [internal use] flag to write output stream directly */
    @:allow(org.si.sion.effector)
    private function get__outputDirectly() : Bool{
        return (!_hasEffectSend && _volumes[0] == 1 && _pan == 64);
    }
    
    
    
    
    // constructor
    //--------------------------------------------------------------------------------
    /** Constructor, you should not create new EffectStream, you may call SiEffectModule.newLocalEffect() for these purpose. */
    // the 2nd argument is for MasterEffect to operate master output.
    public function new(module : SiOPMModule, stream : SiOPMStream = null)
    {
        _depth = 0;
        _module = module;
        _stream = stream;
        if (_stream == null) _stream = new SiOPMStream();
    }
    
    
    
    
    // setting
    //--------------------------------------------------------------------------------
    /** set all stream send levels by Vector.&lt;int&gt;.
     *  @param param Vector.&lt;int&gt;(8) of all volumes[0-128].
     */
    public function setAllStreamSendLevels(param : Array<Int>) : Void
    {
        var i : Int;
        var imax : Int = SiOPMModule.STREAM_SEND_SIZE;
        var v : Int;
        for (i in 0...imax){
            v = param[i];
            _volumes[i] = ((v != INT_MIN_VALUE)) ? (v * 0.0078125) : 0;
        }
        for (i in 0...imax){
            if (_volumes[i] > 0)                 _hasEffectSend = true;
        }
    }
    
    
    /** set stream send.
     *  @param streamNum stream number[0-7]. The streamNum of 0 means master volume.
     *  @param volume send level[0-1].
     */
    public function setStreamSend(streamNum : Int, volume : Float) : Void
    {
        _volumes[streamNum] = volume;
        if (streamNum == 0)             return;
        if (volume > 0)             _hasEffectSend = true
        else {
            var i : Int;
            var imax : Int = SiOPMModule.STREAM_SEND_SIZE;
            for (i in 0...imax){
                if (_volumes[i] > 0)                     _hasEffectSend = true;
            }
        }
    }
    
    
    /** get stream send.
     *  @param streamNum stream number[0-7]. The streamNum of 0 means master volume.
     *  @return send level[0-1].
     */
    public function getStreamSend(streamNum : Int) : Float
    {
        return _volumes[streamNum];
    }
    
    
    
    
    // operations
    //--------------------------------------------------------------------------------
    /** initialize, called when allocated */
    public function initialize(depth : Int) : Void
    {
        free();
        reset();
        for (i in 0...SiOPMModule.STREAM_SEND_SIZE){
            _volumes[i] = 0;
            _outputStreams[i] = null;
        }
        _volumes[0] = 1;
        _pan = 64;
        _hasEffectSend = false;
        _depth = depth;
    }
    
    
    /** reset all parameters except for effector chain, called when effector module is initialized */
    public function reset() : Void
    {
        //_stream.buffer.length = _module.bufferLength << 1;
        _stream.clear();
    }
    
    
    /** free all of effector chain, called when effector module is initialized */
    public function free() : Void
    {
        for (e in chain)e._isFree = true;
        while (chain.length > 0) chain.pop();
    }
    
    
    /** connect to another stream
     *  @param output stream connect to.
     */
    public function connectTo(output : SiOPMStream = null) : Void
    {
        _outputStreams[0] = output;
    }
    
    
    /** prepare for process */
    public function prepareProcess() : Int
    {
        if (chain.length == 0)             return 0;
        _stream.channels = chain[0].prepareProcess();
        for (i in 1...chain.length){chain[i].prepareProcess();
        }
        return _stream.channels;
    }
    
    
    /** processing */
    public function process(startIndex : Int, length : Int, writeInStream : Bool = true) : Int
    {
        var i : Int;
        var imax : Int;
        var effect : SiEffectBase;
        var stream : SiOPMStream;
        var buffer : Array<Float> = _stream.buffer;
        var channels : Int = _stream.channels;
        imax = chain.length;
        for (i in 0...imax){
            channels = chain[i].process(channels, buffer, startIndex, length);
        }

        // write in stream buffer
        if (writeInStream) {
            if (_hasEffectSend) {
                for (i in 0...SiOPMModule.STREAM_SEND_SIZE) {
                    if (_volumes[i] > 0) {
                        stream = _outputStreams[i];
                        if (stream == null) stream = _module.streamSlot[i];
                        if (stream != null) stream.writeVectorNumber(buffer, startIndex, startIndex, length, _volumes[i], _pan, 2);
                    }
                }
            }
            else {
                stream = _outputStreams[0];
                if (stream == null) stream = _module.outputStream;
                stream.writeVectorNumber(buffer, startIndex, startIndex, length, _volumes[0], _pan, 2);
            }
        }
        
        return channels;
    }
    
    
    
    
    // effector connection
    //--------------------------------------------------------------------------------
    /** Parse MML for effector 
     *  @param mml MML string.
     *  @param postfix Postfix string.
     */
    public function parseMML(slot : Int, mml : String, postfix : String) : Void
    {
        var res : Dynamic;
        var i : Int;
        var cmd : String = "";
        var argc : Int = 0;
        var args : Array<Float> = new Array<Float>();
        var rexMML : EReg = new EReg('([a-zA-Z_]+|,)\\s*([.\\-\\d]+)?', "g");
        var rexPost : EReg = new EReg('(p|@p|@v|,)\\s*([.\\-\\d]+)?', "g");
        var res:Array<String> = new Array<String>();

        // connect new effector
        function _connectEffect() : Void{
            if (argc == 0)                 return;
            var e : SiEffectBase = SiEffectModule.getInstance(cmd);
            if (e != null) {
                e.mmlCallback(args);
                chain.push(e);
            }
        }

        // set volumes  ;
        function _setVolume() : Void{
            var v : Float;
            var i : Int;
            if (argc == 0)                 return;
            switch (cmd)
            {
                case "p":
                    pan = ((Math.floor(args[0])) << 4) - 64;
                case "@p":
                    pan = Math.floor(args[0]);
                case "@v":
                    v = Math.floor(args[0]) * 0.0078125;
                    setStreamSend(0, ((v < 0)) ? 0 : ((v > 1)) ? 1 : v);
                    if (argc + slot >= SiOPMModule.STREAM_SEND_SIZE)                         argc = SiOPMModule.STREAM_SEND_SIZE - slot - 1;
                    for (i in 0...argc){
                        v = Math.floor(args[i]) * 0.0078125;
                        setStreamSend(i + slot, ((v < 0)) ? 0 : ((v > 1)) ? 1 : v);
                    }
            }
        }

        // clear arguments  ;
        function _clearArgs() : Void{
            for (i in 0...16){
                args[i] = Math.NaN;
            }
            argc = 0;
        };

        // clear
        initialize(0);
        _clearArgs();
        
        // parse mml
        var matchString = mml;
        while (rexMML.match(matchString)) {
            // Convert to the array format expected by all the functions
            res.splice(0,res.length); // Reset the matching array
            for (i in 0...3) {
                res.push(rexMML.matched(i));
            }

            if (res[1] == ",") {
                args[argc++] = Std.parseFloat(res[2]);
            }
            else {
                _connectEffect();
                _clearArgs();
                cmd = res[1];
                args[0] = Std.parseFloat(res[2]);
                argc = 1;
            }

            // Update the string so we can look for the next match
            matchString = rexMML.matchedRight();
        }
        _connectEffect();
        _clearArgs();
        
        // parse postfix
        var matchString = postfix;
        while (rexPost.match(matchString)){
            if (rexPost.matched(1) == ",") {
                args[argc++] = Std.parseFloat(rexPost.matched(2));
            }
            else {
                _setVolume();
                _clearArgs();
                cmd = rexPost.matched(1);
                args[0] = Std.parseFloat(rexPost.matched(2));
                argc = 1;
            }

            // Update the string so we can look for the next match
            matchString = rexPost.matchedRight();
        }
        _setVolume();
    }
}


