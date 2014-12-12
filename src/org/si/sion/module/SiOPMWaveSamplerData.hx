//----------------------------------------------------------------------------------------------------
// class for SiOPM samplers wave
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module;

import openfl.errors.Error;

import openfl.media.Sound;
import org.si.sion.sequencer.SiMMLTable;
import org.si.sion.utils.SiONUtil;
import org.si.sion.utils.PeakDetector;
import org.si.utils.SLLNumber;

/** SiOPM samplers wave data */
class SiOPMWaveSamplerData extends SiOPMWaveBase
{
    public var soundData(get, never) : Sound;
    public var waveData(get, never) : Array<Float>;
    public var channelCount(get, never) : Int;
    public var pan(get, never) : Int;
    public var length(get, never) : Int;
    public var isExtracted(get, never) : Bool;
    public var ignoreNoteOff(get, set) : Bool;
    public var startPoint(get, never) : Int;
    public var endPoint(get, never) : Int;
    public var loopPoint(get, never) : Int;
    public var peakList(get, never) : Array<Float>;

    // constant
    //----------------------------------------
    /** maximum length limit to extract Sound [ms] */
    public static var extractThreshold : Int = 4000;
    
    
    
    // variables
    //----------------------------------------
    // Sound data
    private var _soundData : Sound;
    // Wave data
    private var _waveData : Array<Float>;
    // channel count of this data
    private var _channelCount : Int;
    // pan
    private var _pan : Int;
    // extraction flag
    private var _isExtracted : Bool;
    // wave starting position in sample count.
    private var _startPoint : Int;
    // wave end position in sample count.
    private var _endPoint : Int;
    // wave looping position in sample count. -1 means no repeat.
    private var _loopPoint : Int;
    // flag to slice after loading
    private var _sliceAfterLoading : Bool;
    // flag to ignore note off
    private var _ignoreNoteOff : Bool;
    // peak list for time stretch
    private var _peakList : Array<Float>;
    
    
    
    // properties
    //----------------------------------------
    /** Sound data */
    private function get_soundData() : Sound{
        return _soundData;
    }
    
    /** Wave data */
    private function get_waveData() : Array<Float>{
        return _waveData;
    }
    
    /** channel count of this data. */
    private function get_channelCount() : Int{
        return _channelCount;
    }
    
    /** pan [-64 - 64] */
    private function get_pan() : Int{
        return _pan;
    }
    
    /** Sammple length */
    private function get_length() : Int{
        if (_isExtracted) return (_waveData.length >> (_channelCount - 1));
        if (_soundData != null) return (Math.floor(_soundData.length * 44.1));
        return 0;
    }
    
    
    /** Is extracted ? */
    private function get_isExtracted() : Bool{
        return _isExtracted;
    }
    
    
    /** flag to ignore note off. set true to ignore note off (one shot voice). this flag is only available for non-loop samples. */
    private function get_ignoreNoteOff() : Bool{
        return _ignoreNoteOff;
    }
    private function set_ignoreNoteOff(b : Bool) : Bool{
        _ignoreNoteOff = (_loopPoint == -1) && b;
        return b;
    }
    
    
    /** wave starting position in sample count. you can set this property by slice(). @see #slice() */
    private function get_startPoint() : Int {
        return _startPoint;
    }
    
    /** wave end position in sample count. you can set this property by slice(). @see #slice() */
    private function get_endPoint() : Int {
        return _endPoint;
    }
    
    /** wave looping position in sample count. -1 means no repeat. you can set this property by slice(). @see #slice() */
    private function get_loopPoint() : Int {
        return _loopPoint;
    }
    
    /** peak list only available for extracted data */
    private function get_peakList() : Array<Float> {
        return _peakList;
    }
    

    // constructor
    //----------------------------------------
    /** constructor : must call an initialize function after construction (Haxe's lack of overloading and lack of RTTI for Array types prevents a simple solution)
     *  @param data wave data, Sound, Vector.&lt;Number&gt; or Vector.&lt;int&gt; is available. The Sound is extracted when the length is shorter than SiOPMWaveSamplerData.extractThreshold[msec].
     *  @param ignoreNoteOff flag to ignore note off
     *  @param pan pan of this sample [-64 - 64].
     *  @param srcChannelCount channel count of source data, this argument is only available when data type is Vector.&lt;Number&gt;.
     *  @param channelCount channel count of this data, 0 sets same with srcChannelCount
     *  @param peakList peak list for time stretching
     */
    public function new()
    {
        super(SiMMLTable.MT_SAMPLE);
    }
    
    
    
    
    // operations
    //----------------------------------------
    /** initializeFromSound
     *  @param data Sound to get the wave data from. The Sound is extracted when the length is shorter than SiOPMWaveSamplerData.extractThreshold[msec].
     *  @param ignoreNoteOff flag to ignore note off
     *  @param pan pan of this sample.
     *  @param srcChannelCount channel count of source data, this argument is only available when data type is Vector.&lt;Number&gt;.
     *  @param channelCount channel count of this data, 0 sets same with srcChannelCount. This argument is ignored when the data is not extracted.
     *  @see #extractThreshold
     *  @return this instance.
     */
    public function initializeFromSound(data : Sound, ignoreNoteOff : Bool = false, pan : Int = 0, srcChannelCount : Int = 2, channelCount : Int = 0, peakList : Array<Float> = null) : SiOPMWaveSamplerData
    {
        _sliceAfterLoading = false;
        srcChannelCount = ((srcChannelCount == 1)) ? 1 : 2;
        if (channelCount == 0)             channelCount = srcChannelCount;
        this._channelCount = ((channelCount == 1)) ? 1 : 2;
        _listenSoundLoadingEvents(data);
        this._startPoint = 0;
        this._endPoint = length;
        this._loopPoint = -1;
        this._peakList = peakList;
        this.ignoreNoteOff = ignoreNoteOff;
        this._pan = pan;
        return this;
    }

    /** initializeFromFloatData
     *  @param data Array&lt;Float&gt; containing wave data
     *  @param ignoreNoteOff flag to ignore note off
     *  @param pan pan of this sample.
     *  @param srcChannelCount channel count of source data, this argument is only available when data type is Vector.&lt;Number&gt;.
     *  @param channelCount channel count of this data, 0 sets same with srcChannelCount. This argument is ignored when the data is not extracted.
     *  @see #extractThreshold
     *  @return this instance.
     */
    // TODO: Code for initializeFromIntData was idential, even calling the same _transChannel() method that only takes
    //       an Array<Float>. But try adding initFromInt if it becomes necessary later.
    public function initializeFromFloatData(data : Array<Float>, ignoreNoteOff : Bool = false, pan : Int = 0, srcChannelCount : Int = 2, channelCount : Int = 0, peakList : Array<Float> = null) : SiOPMWaveSamplerData
    {
        _sliceAfterLoading = false;
        srcChannelCount = ((srcChannelCount == 1)) ? 1 : 2;
        if (channelCount == 0)             channelCount = srcChannelCount;
        this._channelCount = ((channelCount == 1)) ? 1 : 2;
        this._soundData = null;
        this._waveData = _transChannel(data, srcChannelCount, _channelCount);
        _isExtracted = true;
        this._startPoint = 0;
        this._endPoint = length;
        this._loopPoint = -1;
        this._peakList = peakList;
        this.ignoreNoteOff = ignoreNoteOff;
        this._pan = pan;
        return this;
    }

    /** Slicer setting. You can cut samples and set repeating.
     *  @param startPoint slicing point to start data.The negative value skips head silence.
     *  @param endPoint slicing point to end data. The negative value plays whole data.
     *  @param loopPoint slicing point to repeat data. The negative value sets no repeat.
     *  @return this instance.
     */
    public function slice(startPoint : Int = -1, endPoint : Int = -1, loopPoint : Int = -1) : SiOPMWaveSamplerData
    {
        _startPoint = startPoint;
        _endPoint = endPoint;
        _loopPoint = loopPoint;
        if (!_isSoundLoading)             _slice()
        else _sliceAfterLoading = true;
        return this;
    }
    
    
    /** extract Sound data. The sound data shooter than extractThreshold is already extracted. [CAUTION] Long sound takes long time to extract and consumes large memory area. @see extractThreshold */
    public function extract() : Void
    {
        if (_isExtracted)             return;
        this._waveData = SiONUtil.extract(this._soundData, null, _channelCount, length, 0);
        _isExtracted = true;
    }
    
    
    /** Get initial sample index. 
     *  @param phase Starting phase, ratio from start point to end point(0-1).
     */
    public function getInitialSampleIndex(phase : Float = 0) : Int
    {
        return Math.floor(_startPoint * (1 - phase) + _endPoint * phase);
    }
    
    
    /** construct peak list,  
     */
    public function constructPeakList() : PeakDetector
    {
        if (!_isExtracted)             throw new Error("constructPeakList is only available for extracted data");
        var pd : PeakDetector = new PeakDetector();
        pd.setSamples(_waveData, _channelCount);
        _peakList = pd.peakList;
        return pd;
    }
    
    
    // seek head silence
    private function _seekHeadSilence() : Int
    {
        if (_waveData != null) {
            var i : Int = 0;
            var imax : Int = _waveData.length;
            var ms : Float;
            var msWindow : SLLNumber = SLLNumber.allocRing(22);  // 0.5ms  
            if (_channelCount == 1) {
                ms = 0;
                for (i in 0...imax) {
                    ms -= msWindow.n;
                    msWindow = msWindow.next;
                    msWindow.n = _waveData[i] * _waveData[i];
                    ms += msWindow.n;
                    if (ms > 0.0011)                         break;
                }
            }
            else {
                ms = 0;
                i = 0;
                while (i < imax){
                    ms -= msWindow.n;
                    msWindow = msWindow.next;
                    msWindow.n = _waveData[i] * _waveData[i];i++;
                    msWindow.n += _waveData[i] * _waveData[i];i++;
                    ms += msWindow.n;
                    if (ms > 0.0022)                         break;
                }
                i >>= 1;
            }
            SLLNumber.freeRing(msWindow);
            return i - 22;
        }
        return ((_soundData != null)) ? SiONUtil.getHeadSilence(_soundData) : 0;
    }
    
    
    // seek mp3 end gap
    private function _seekEndGap() : Int
    {
        if (_waveData != null) {
            var i : Int;
            var ms : Float;
            if (_channelCount == 1) {
                i = _waveData.length - 1;
                while (i >= 0){
                    if (_waveData[i] * _waveData[i] > 0.0001)                         break;
                    i--;
                }
            }
            else {
                i = _waveData.length - 1;
                while (i >= 0){
                    ms = _waveData[i] * _waveData[i];i--;
                    ms += _waveData[i] * _waveData[i];i--;
                    if (ms > 0.0002)                         break;
                }
                i >>= 1;
            }
            return ((i > length - 1152)) ? i : (length - 1152);
        }
        return ((_soundData != null)) ? (length - SiONUtil.getEndGap(_soundData)) : 0;
    }
    
    
    // change channel count as needed
    private function _transChannel(src : Array<Float>, srcChannelCount : Int, channelCount : Int) : Array<Float>
    {
        var i : Int;
        var j : Int;
        var imax : Int;
        var dst : Array<Float>;
        if (srcChannelCount == channelCount)             return src;
        if (srcChannelCount == 1) {  // 1->2  
            imax = src.length;
            dst = new Array<Float>();
            i = 0;
            j = 0;
            while (i < imax){
                dst[j + 1] = dst[j] = src[i];
                i++;
                j += 2;
            }
        }
        else {  // 2->1  
            imax = src.length >> 1;
            dst = new Array<Float>();
            i = 0;
j = 0;
            while (i < imax){dst[i] = (src[j] + src[j + 1]) * 0.5;
                i++;
                j += 2;
            }
        }
        return dst;
    }
    
    
    /** @private */
    override private function _onSoundLoadingComplete(sound : Sound) : Void
    {
        this._soundData = sound;
        if (this._soundData.length <= extractThreshold) {
            this._waveData = SiONUtil.extract(this._soundData, null, _channelCount, extractThreshold * 45, 0);
            _isExtracted = true;
        }
        else {
            this._waveData = null;
            _isExtracted = false;
        }
        if (_sliceAfterLoading)             _slice();
        _sliceAfterLoading = false;
    }
    
    
    private function _slice() : Void
    {
        if (_startPoint < 0)             _startPoint = _seekHeadSilence();
        if (_loopPoint < 0)             _loopPoint = -1;
        if (_endPoint < 0)             _endPoint = _seekEndGap();
        if (_endPoint < _loopPoint)             _loopPoint = -1;
        if (_endPoint < _startPoint)             _endPoint = length - 1;
    }
}


