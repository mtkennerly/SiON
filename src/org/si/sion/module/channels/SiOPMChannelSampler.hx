//----------------------------------------------------------------------------------------------------
// SiOPM Sampler pad channel.
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module.channels;

import openfl.utils.ByteArray;
import org.si.utils.SLLNumber;
import org.si.utils.SLLint;
import org.si.sion.module.*;


/** Sampler pad channel. */
class SiOPMChannelSampler extends SiOPMChannelBase
{
    // variables
    //--------------------------------------------------
    /** bank number */private var _bankNumber : Int;
    /** wave number */private var _waveNumber : Int;
    
    /** expression */private var _expression : Float;
    
    /** sample table */private var _samplerTable : SiOPMWaveSamplerTable;
    /** sample table */private var _sampleData : SiOPMWaveSamplerData;
    /** sample index */private var _sampleIndex : Int;
    /** phase reset */private var _sampleStartPhase : Int;
    
    /** ByteArray to extract */private var _extractedByteArray : ByteArray;
    /** sample data */private var _extractedSample : Array<Float>;
    
    // pan of current note
    private var _samplePan : Int;
    
    
    
    
    // toString
    //--------------------------------------------------
    /** Output parameters. */
    public function toString() : String
    {
        var str : String = "SiOPMChannelSampler : ";

        function dlr2(p : String, i : Dynamic, q : String, j : Dynamic) : Void{
            str += "  " + p + "=" + Std.string(i) + " / " + q + "=" + Std.string(j) + "\n";
        };

        dlr2("vol", _volumes[0] * _expression, "pan", _pan - 64);
        return str;
    }
    
    
    
    
    // constructor
    //--------------------------------------------------
    /** constructor */
    public function new(chip : SiOPMModule)
    {
        _extractedByteArray = new ByteArray();
        _extractedSample = new Array<Float>();
        super(chip);
    }
    
    
    
    
    // parameter setting
    //--------------------------------------------------
    /** Set by SiOPMChannelParam. 
     *  @param param SiOPMChannelParam.
     *  @param withVolume Set volume when its true.
     */
    override public function setSiOPMChannelParam(param : SiOPMChannelParam, withVolume : Bool, withModulation : Bool = true) : Void
    {
        var i : Int;
        if (param.opeCount == 0)             return;
        
        if (withVolume) {
            var imax : Int = SiOPMModule.STREAM_SEND_SIZE;
            for (i in 0...imax) {
                _volumes[i] = param.volumes[i];
            }
            _hasEffectSend=false;
            for (i in 1...imax) {
                if (_volumes[i] > 0) _hasEffectSend = true;
            }
            _pan = param.pan;
        }
    }
    
    
    /** Get SiOPMChannelParam.
     *  @param param SiOPMChannelParam.
     */
    override public function getSiOPMChannelParam(param : SiOPMChannelParam) : Void
    {
        var i : Int;
        var imax : Int = SiOPMModule.STREAM_SEND_SIZE;
        for (i in 0...imax){
            param.volumes[i] = _volumes[i];
        }
        param.pan = _pan;
    }
    
    // interfaces
    //--------------------------------------------------
    /** Set algorism (&#64;al) 
     *  @param cnt Operator count.
     *  @param alg Algolism number of the operator's connection.
     */
    override public function setAlgorism(cnt : Int, alg : Int) : Void
    {
        
    }
    
    
    /** pgType and ptType (&#64; call from SiMMLChannelSetting.selectTone()/initializeTone()) */
    override public function setType(pgType : Int, ptType : Int) : Void
    {
        _bankNumber = pgType & 3;
    }
    
    
    
    
    // interfaces
    //--------------------------------------------------
    /** pitch = (note &lt;&lt; 6) | (kf &amp; 63) [0,8191] */
    override private function get_pitch() : Int {
        return _waveNumber << 6;
    }
    override private function set_pitch(p : Int) : Int {
        _waveNumber = p >> 6;
        return p;
    }
    
    /** Set wave data. */
    override public function setWaveData(waveData : SiOPMWaveBase) : Void {
        _samplerTable = try cast(waveData, SiOPMWaveSamplerTable) catch(e:Dynamic) null;
        _sampleData = try cast(waveData, SiOPMWaveSamplerData) catch(e:Dynamic) null;
    }
    
    
    
    
    // volume controls
    //--------------------------------------------------
    /** update all tl offsets of final carriors */
    override public function offsetVolume(expression : Int, velocity : Int) : Void{
        _expression = expression * velocity * 0.00006103515625;
    }
    
    /** phase (&#64;ph) */
    override private function set_phase(i : Int) : Int{
        _sampleStartPhase = i;
        return i;
    }
    
    
    
    
    // operation
    //--------------------------------------------------
    /** Initialize. */
    override public function initialize(prev : SiOPMChannelBase, bufferIndex : Int) : Void
    {
        super.initialize(prev, bufferIndex);
        reset();
    }
    
    
    /** Reset. */
    override public function reset() : Void
    {
        _isNoteOn = false;
        _isIdling = true;
        _bankNumber = 0;
        _waveNumber = -1;
        _samplePan = 0;
        
        _samplerTable = _table.samplerTables[0];
        _sampleData = null;
        
        _sampleIndex = 0;
        _sampleStartPhase = 0;
        _expression = 1;
    }
    
    
    /** Note on. */
    override public function noteOn() : Void
    {
        if (_waveNumber >= 0) {
            if (_samplerTable != null)                 _sampleData = _samplerTable.getSample(_waveNumber & 127);
            if (_sampleData != null && _sampleStartPhase != 255) {
                _sampleIndex = _sampleData.getInitialSampleIndex(_sampleStartPhase * 0.00390625);  // 1/256  
                _samplePan = _pan + _sampleData.pan;
                if (_samplePan < 0)                     _samplePan = 0
                else if (_samplePan > 128)                     _samplePan = 128;
            }
            _isIdling = (_sampleData == null);
            _isNoteOn = !_isIdling;
        }
    }
    
    
    /** Note off. */
    override public function noteOff() : Void
    {
        if (_sampleData != null) {
            if (!_sampleData.ignoreNoteOff) {
                _isNoteOn = false;
                _isIdling = true;
                if (_samplerTable != null)                     _sampleData = null;
            }
        }
    }
    
    
    /** Buffering */
    override public function buffer(len : Int) : Void
    {
        var i : Int;
        var imax : Int;
        var vol : Float;
        var residue : Int;
        var processed : Int;
        var stream : SiOPMStream;
        if (_isIdling || _sampleData == null || _mute) {
            //_nop(len);
        }
        else {
            if (_sampleData.isExtracted) {
                // stream extracted data
                residue = len;
                i = 0;
                while (residue > 0){
                    // copy to buffer
                    processed = ((_sampleIndex + residue < _sampleData.endPoint)) ? residue : (_sampleData.endPoint - _sampleIndex);
                    if (_hasEffectSend) {
                        for (i in 0...SiOPMModule.STREAM_SEND_SIZE){
                            if (_volumes[i] > 0) {
                                stream = (_streams[i] != null) ? _streams[i] : _chip.streamSlot[i];
                                if (stream != null) {
                                    vol = _volumes[i] * _expression * _chip.samplerVolume;
                                    stream.writeVectorNumber(_sampleData.waveData, _sampleIndex, _bufferIndex, processed, vol, _samplePan, _sampleData.channelCount);
                                }
                            }
                        }
                    }
                    else {
                        stream = _streams[0];
                        if (stream == null) stream = _chip.outputStream;
                        vol = _volumes[0] * _expression * _chip.samplerVolume;
                        stream.writeVectorNumber(_sampleData.waveData, _sampleIndex, _bufferIndex, processed, vol, _samplePan, _sampleData.channelCount);
                    }
                    _sampleIndex += processed;
                    
                    // processed samples are not enough == achieves to the end
                    residue -= processed;
                    if (residue > 0) {
                        if (_sampleData.loopPoint >= 0) {
                            // loop
                            if (_sampleData.loopPoint > _sampleData.startPoint) _sampleIndex = _sampleData.loopPoint
                            else _sampleIndex = _sampleData.startPoint;
                        }
                        else {
                            // end (note off)
                            _isIdling = true;
                            if (_samplerTable != null) _sampleData = null;  //_nop(len - processed);
                            
                            break;
                        }
                    }
                }
            }
#if SOUND_EXTRACT_ENABLED
            else {
                // stream Sound data with extracting
                residue = len;
                i = 0;
                imax = 0;
                while (residue > 0){
                    // extract a part
                    while (_extractedByteArray.length > 0) _extractedByteArray.pop();
                    processed = _sampleData.soundData.extract(_extractedByteArray, residue, _sampleIndex << 1);
                    _sampleIndex += processed >> 1;
                    if (_sampleIndex > _sampleData.endPoint) processed -= _sampleIndex - _sampleData.endPoint;  // copy to vector
                    
                    imax += processed << 1;
                    _extractedByteArray.position = 0;
                    while (i<imax){
                        _extractedSample[i] = _extractedByteArray.readFloat();
                        i++;
                    }

                    // processed samples are not enough == achieves to the end
                    residue -= processed;
                    if (residue > 0) {
                        if (_sampleData.loopPoint >= 0) {
                            // loop
                            if (_sampleData.loopPoint > _sampleData.startPoint) _sampleIndex = _sampleData.loopPoint
                            else _sampleIndex = _sampleData.startPoint;
                        }
                        else {
                            // end (note off)
                            _isIdling = true;
                            if (_samplerTable != null) _sampleData = null;  //_nop(len - processed);
                            
                            break;
                        }
                    }
                }
                processed = len - residue;
                
                // copy to buffer
                if (_hasEffectSend) {
                    for (i in 0...SiOPMModule.STREAM_SEND_SIZE){
                        if (_volumes[i] > 0) {
                            stream = (_streams[i] != null) ? _streams[i] : _chip.streamSlot[i];
                            if (stream != null) {
                                vol = _volumes[i] * _expression * _chip.samplerVolume;
                                stream.writeVectorNumber(_extractedSample, 0, _bufferIndex, processed, vol, _samplePan, 2);
                            }
                        }
                    }
                }
                else {
                    stream = (_streams[0] != null) ? _streams[0] : _chip.outputStream;
                    vol = _volumes[0] * _expression * _chip.samplerVolume;
                    stream.writeVectorNumber(_extractedSample, 0, _bufferIndex, processed, vol, _samplePan, 2);
                }
            }
#else
            else {
                trace('***** WARNING: Sound.extract() is not implemented!!');
            }
#end
        }

        // update buffer index
        _bufferIndex += len;
    }
    
    
    /** Buffering without processnig */
    public override function nop(len : Int) : Void
    {
        //_nop(len);
        _bufferIndex += len;
    }
}


