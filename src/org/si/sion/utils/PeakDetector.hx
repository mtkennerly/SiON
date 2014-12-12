  //----------------------------------------------------------------------------------------------------  
// Peak detector
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion.utils;

import org.si.sion.effector.*;
import org.si.utils.*;

/** PeakDetector provides wave power peak profiler with bandpass filter. This analyzer takes finer time resolution, looser frequency resolution and faster calculation than FFT. */
class PeakDetector
{
    public var windowLength(get, set) : Int;
    public var frequency(get, set) : Float;
    public var bandWidth(get, set) : Float;
    public var signalToNoiseRatio(get, set) : Float;
    public var samples(get, never) : Array<Float>;
    public var samplesChannelCount(get, never) : Int;
    public var powerProfile(get, never) : Array<Float>;
    public var differencialOfLogPowerProfile(get, never) : Array<Float>;
    public var average(get, never) : Float;
    public var maximum(get, never) : Float;
    public var peakList(get, never) : Array<Float>;
    public var peaksPerMinuteEstimationScoreTable(get, never) : Array<Float>;
    public var peaksPerMinute(get, never) : Float;
    public var peaksPerMinuteProbability(get, never) : Float;

    // variables
    //----------------------------------------
    /** maximum value of peaksPerMinute, the minimum value is a half of maximum value. @default 192 */
    public static var maxPeaksPerMinute : Float = 192;
    
    
    private var _bpf : SiFilterBandPass = new SiFilterBandPass();
    private var _window : SLLNumber = null;
    
    private var _frequency : Float;
    private var _bandWidth : Float;
    private var _windowLength : Float;
    private var _profileDirty : Bool;
    private var _peakListDirty : Bool;
    private var _peakFreqDirty : Bool;
    private var _signalToNoiseRatio : Float;
    private var _samplesChannelCount : Int;
    private var _samples : Array<Float> = null;
    
    private var _stream : Array<Float> = new Array<Float>();
    private var _profile : Array<Float> = new Array<Float>();
    private var _diffLogProfile : Array<Float> = new Array<Float>();
    private var _peakList : Array<Float> = new Array<Float>();
    private var _ppmScore : Array<Float>;
    private var _peaksPerMinute : Float;
    private var _peaksPerMinuteProbability : Float;
    private var _maximum : Float;
    private var _average : Float;
    
    
    
    
    // properties
    //----------------------------------------
    /** window length of simple moving avarage [ms] @default 20 */
    private function get_windowLength() : Int{
        return Math.floor(_windowLength);
    }
    private function set_windowLength(l : Int) : Int{
        if (_windowLength != l) {
            _peakFreqDirty = _peakListDirty = _profileDirty = true;
            _windowLength = l;
            _resetWindow();
        }
        return l;
    }
    
    
    /** frequency of band pass filter [Hz], set 0 to skip filtering @default 0 */
    private function get_frequency() : Float{return _frequency;
    }
    private function set_frequency(f : Float) : Float{
        if (_frequency != f) {
            _peakFreqDirty = _peakListDirty = _profileDirty = true;
            _frequency = f;
            _updateFilter();
        }
        return f;
    }
    
    
    /** half band width of band pass filter [oct.] @default 0.5 */
    private function get_bandWidth() : Float{return ((_frequency > 0)) ? _bandWidth : 0;
    }
    private function set_bandWidth(b : Float) : Float{
        if (_bandWidth != b) {
            _peakFreqDirty = _peakListDirty = _profileDirty = true;
            _bandWidth = b;
            _updateFilter();
        }
        return b;
    }
    
    
    /** S/N ratio for peak detection [dB] @default 20 */
    private function get_signalToNoiseRatio() : Float{return _signalToNoiseRatio;
    }
    private function set_signalToNoiseRatio(n : Float) : Float{_signalToNoiseRatio = n;
        return n;
    }
    
    
    /** samples to analyze, 44.1kHz only */
    private function get_samples() : Array<Float>{return _samples;
    }
    
    
    /** channel count of analyzing samples (1 or 2) */
    private function get_samplesChannelCount() : Int{return _samplesChannelCount;
    }
    
    
    /** analyzed wave energy profile 2100[fps] (the length is 1/21(2100/44100) of analyzing samples). */
    private function get_powerProfile() : Array<Float>{
        _updateProfile();
        return _profile;
    }
    
    
    /** exponential of differencial of log scaled powerProfile, same length with powerProfile */
    private function get_differencialOfLogPowerProfile() : Array<Float>{
        _updatePeakList();
        return _diffLogProfile;
    }
    
    
    /** avarage wave energy */
    private function get_average() : Float{
        _updateProfile();
        return _average;
    }
    
    
    /** maximum wave energy */
    private function get_maximum() : Float{
        _updateProfile();
        return _maximum;
    }
    
    
    /** analyzed peak list in [ms]. */
    private function get_peakList() : Array<Float>{
        _updatePeakList();
        return _peakList;
    }
    
    
    /** @internal peak per minutes estimation score table. */
    private function get_peaksPerMinuteEstimationScoreTable() : Array<Float>{
        _updatePeakFreq();
        return _ppmScore;
    }
    
    
    /** estimated peak per minutes. this value is similar but different form bpm(tempo), because the peaks are not only on 4th beats, but also 8th or 16th beats. */
    private function get_peaksPerMinute() : Float{
        _updatePeakFreq();
        return _peaksPerMinute;
    }
    
    
    /** probability of estimated peaksPerMinute value. 1 means estimated perfectly and 0 means not good estimation. */
    private function get_peaksPerMinuteProbability() : Float{
        _updatePeakFreq();
        return _peaksPerMinuteProbability;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor 
     *  @param frequency frequency of band pass filter [Hz], set 0 to skip filtering
     *  @param bandWidth half band width of band pass filter [oct.]
     *  @param windowLength window length of simple moving avarage [ms]
     *  @param signalToNoiseRatio S/N ratio for peak detection [dB]
     */
    public function new(frequency : Float = 0, bandWidth : Float = 0.5, windowLength : Float = 20, signalToNoiseRatio : Float = 20)
    {
        _frequency = frequency;
        _bandWidth = bandWidth;
        _windowLength = windowLength;
        _signalToNoiseRatio = signalToNoiseRatio;
        _updateFilter();
        _resetWindow();
        _profileDirty = true;
        _peakListDirty = true;
        _peakFreqDirty = true;
        _average = 0;
    }
    
    
    
    
    // methods
    //----------------------------------------
    /** set analyzing source samples
     *  @param samples analyzing source 
     *  @param channelCount channel count of analyzing source
     *  @param isStreaming true to continuous data with previous analyze
     *  @return this instance
     */
    public function setSamples(samples : Array<Float>, channelCount : Int = 2, isStreaming : Bool = false) : PeakDetector
    {
        _peakFreqDirty = _peakListDirty = _profileDirty = true;
        _samples = samples;
        _samplesChannelCount = channelCount;
        if (!isStreaming)             _resetWindow();
        return this;
    }
    
    
    /** calcuate peak inetncity 
     *  @param peakPosition peak positoin [ms]
     *  @param integrateLength integration length [ms]
     */
    public function calcPeakIntencity(peakPosition : Float, integrateLength : Float = 10) : Float
    {
        var i : Int;
        var n : Float;
        var imin : Int = Math.floor(peakPosition * 2.1 + 0.5);
        var imax : Int = Math.floor((peakPosition + integrateLength) * 2.1 + 0.5);
        _updateProfile();
        if (imin > _profile.length)             imin = _profile.length;
        if (imax > _profile.length)             imax = _profile.length;
        n = 0;
        for (i in imin...imax) {
            n += _profile[i];
        }
        return n;
    }
    
    
    /** merage peak list
     *  @param arrayOfPeakList Array of peakList(Vector.&lt;Number&gt; type) to marge
     *  @param singlePeakLength time distance to merge near peaks as 1 peak
     *  @return merged peak list
     */
    public static function mergePeakList(arrayOfPeakList : Array<Dynamic>, singlePeakLength : Float = 40) : Array<Float>
    {
        var listIndex : Int;
        var peakListCount : Int;
        var i : Int;
        var currentPosition : Float;
        var nextPeakPosition : Float;
        var nextPeakHolder : Int;
        var merged : Array<Float>;
        var list : Array<Float>;
        var idx : Array<Int>;
        peakListCount = arrayOfPeakList.length;
        idx = new Array<Int>();
        merged = new Array<Float>();
        
        for (i in 0...peakListCount) {
            idx[i] = 0;
        }
        currentPosition = -singlePeakLength;
        while (true){
            nextPeakPosition = 99999999;
            nextPeakHolder = -1;
            for (listIndex in 0...peakListCount) {
                list = arrayOfPeakList[listIndex];
                if (idx[listIndex] < list.length && list[idx[listIndex]] < nextPeakPosition) {
                    nextPeakPosition = list[idx[listIndex]];
                    nextPeakHolder = listIndex;
                }
            }
            if (nextPeakHolder != -1) {
                idx[nextPeakHolder]++;
                if (nextPeakPosition - currentPosition >= singlePeakLength) {
                    merged.push(nextPeakPosition);
                    currentPosition = nextPeakPosition;
                }
            }
            else break;
        }
        
        return merged;
    }
    
    
    
    
    // internals
    //----------------------------------------
    // reset window buffer
    private function _resetWindow() : Void{
        if (_window != null)             SLLNumber.freeRing(_window);
        _window = SLLNumber.allocRing(Math.floor(_windowLength * 2.1 + 0.5), 0);
    }
    
    
    // update filter parameters
    private function _updateFilter() : Void{
        if (_frequency > 0) {
            _bpf.initialize();
            _bpf.setParameters(_frequency, _bandWidth);
        }
    }
    
    
    // update power prof.
    private function _updateProfile() : Void{
        if (_profileDirty && _samples != null) {
            var imax : Int;
            var i : Int;
            var ix2 : Int;
            var ix42 : Int;
            var pow : Float;
            var n : Float;
            
            // copy samples to working area (_stream)
            imax = _samples.length;
            if (_samplesChannelCount == 1) {  // monoral input  
                ix2=0;
                for (i in 0...imax) {
                    _stream[ix2] = _samples[i];ix2++;
                    _stream[ix2] = _samples[i];ix2++;
                }
            }
            else {  // stereo input  
                i = 0;
                while (i < imax) {
                    n = _samples[i];i++;
                    n += _samples[i];i--;
                    n *= 0.5;
                    _stream[i] = n;i++;
                    _stream[i] = n;i++;
                }
            }

            // filtering
            if (_frequency > 0) {
                _bpf.prepareProcess();
                _bpf.process(1, _stream, 0, _stream.length >> 1);
            }

            // calculate power profile
            imax = Math.floor((_stream.length - 41) / 42);
            pow = 0;
            _average = 0;
            _maximum = 0;
            ix42 = 0;
            for (i in 0...imax){
                // 44100/21 = 2100fps
                _window.n = _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                _window.n += _stream[ix42] * _stream[ix42];ix42 += 2;
                pow += _window.n;
                _window = _window.next;
                pow -= _window.n;
                _profile[i] = pow;
                _average += pow;
                if (_maximum < pow)                     _maximum = pow;
            }
            _average /= imax;
            
            _profileDirty = false;
        }
    }
    
    
    // update DLP and peakList
    private function _updatePeakList() : Void
    {
        _updateProfile();
        if (_peakListDirty && _profile.length > 0) {
            var imax : Int = _profile.length;
            var thres : Float = _maximum * 0.001;
            var snr : Float = Math.pow(10, _signalToNoiseRatio * 0.1);
            var wnd : Int = Math.floor(_windowLength * 2.1 + 0.5);
            var decay : Float = Math.pow(2, -1 / wnd);
            var i : Int;
            var i1 : Int;
            var n : Float;
            var envelope : Float;
            var prevPoint : Int;
            
            _diffLogProfile[0] = 0;
            for (i in 1...imax) {
                i1 = i - 1;
                _diffLogProfile[i] = ((_profile[i1] > thres)) ? (_profile[i] / _profile[i1] - 1) : 0;
            }
            
            while (_peakList.length > 0) _peakList.pop();
            envelope = 0;
            prevPoint = 0;
            for (i in wnd...imax) {
                if (_diffLogProfile[i] > envelope) {
                    n = _diffLogProfile[i - wnd];
                    if (n <= 0)                         n = 0.001;
                    n = _diffLogProfile[i] / n;
                    if (n > snr) {
                        if (i - prevPoint < wnd) {
                            _peakList[_peakList.length - 1] = i / 2.1;
                        }
                        else {
                            _peakList.push(i / 2.1);
                        }
                        prevPoint = i;
                        envelope = _diffLogProfile[i];
                    }
                }
                envelope *= decay;
            }
            _peakListDirty = false;
        }
    }
    
    
    // update peak frequency
    private function _updatePeakFreq() : Void
    {
        _updatePeakList();
        if (_peakFreqDirty && _profile.length > 0) {
            var i : Int;
            var j : Int;
            var highScoreFrames : Int;
            var total : Int;
            var frm : Int;
            var score : Int;
            _ppmScore = calcPeaksPerMinuteEstimationScoreTable(_peakList, _ppmScore);
            _estimatePeaksPerMinuteFromScoreTable();
            _peakFreqDirty = false;
        }
    }
    
    
    // estimate peaks per minute from score table
    private function _estimatePeaksPerMinuteFromScoreTable() : Void
    {
        var highScoreFrames : Int;
        var i : Int;
        var imax : Int;
        var j : Int;
        var frm : Int;
        var thres : Float;
        var pmin : Float;
        var pmax : Float;

        // find highest score
        highScoreFrames=100;
        for (i in 101...2000){
            if (_ppmScore[i] > _ppmScore[highScoreFrames])                 highScoreFrames = i;
        }  // move finding peak to less than 200ppm (630frames)  
        
        while (highScoreFrames < 630)highScoreFrames *= 2;
        // move to peak top
        while (_ppmScore[highScoreFrames] < _ppmScore[highScoreFrames + 1])highScoreFrames++;
        while (_ppmScore[highScoreFrames] < _ppmScore[highScoreFrames - 1])highScoreFrames--;
        // calculate cross point of [peak height] * 0.7
        thres = _ppmScore[highScoreFrames] * 0.7;
        pmin = 0;
        imax = highScoreFrames - 100;
        i = highScoreFrames;
        while (i > imax){
            if (_ppmScore[i] < thres) {
                pmin = i + (thres - _ppmScore[i]) / (_ppmScore[i + 1] - _ppmScore[i]);
                break;
            }
            i--;
        }
        pmax = 0;
        imax = highScoreFrames + 100;
        for (i in highScoreFrames...imax) {
            if (_ppmScore[i] < thres) {
                pmax = i + (_ppmScore[i - 1] - thres) / (_ppmScore[i - 1] - _ppmScore[i]);
                break;
            }
        }  // calcualte peak top again and translate to peaks per minute value  
        
        if (pmin != 0 && pmax != 0)             _peaksPerMinute = ((highScoreFrames > 0)) ? (2100 * 60 / ((pmax + pmin) * 0.5)) : 0
        else _peaksPerMinute = ((highScoreFrames > 0)) ? (2100 * 60 / highScoreFrames) : 0;
        // move range into maxPeaksPerMinute
        var minPeaksPerMinute : Float = maxPeaksPerMinute * 0.5;
        while (_peaksPerMinute >= maxPeaksPerMinute)_peaksPerMinute *= 0.5;
        while (_peaksPerMinute < minPeaksPerMinute)_peaksPerMinute *= 2;
        // integrate peaks to calculate probability
        _peaksPerMinuteProbability = 0;
        for (i in 0...10){
            frm = Math.round(highScoreFrames * _probCheck[i]);
            if (frm > 2100)                 break;
            for (j in -22...23) {
                _peaksPerMinuteProbability += _ppmScore[frm + j];
            }
        }
    }
    private static var _probCheck : Array<Float> = [0.25, 0.5, 1, 2, 3, 4, 5, 6, 7, 8];
    
    
    /** @internal caclulate peak frequency estimation scores 
     *  @param peakList peal list [ms]
     *  @param scoreTable score table instance to set, null to create new table.
     *  @return score table
     */
    public static function calcPeaksPerMinuteEstimationScoreTable(peakList : Array<Float>, scoreTable : Array<Float> = null) : Array<Float>
    {
        var i : Int;
        var j : Int;
        var k : Int;
        var s : Int;
        var peakCount : Int;
        var peakDist : Int;
        var dist : Float;
        var dist2 : Float;
        var scale : Float;
        var scoreTotal : Int;
        if (scoreTable == null)             scoreTable = new Array<Float>();


        // clear score table
        for (i in 0...2124){
            scoreTable[i] = 0;
        }
        
        // calculate scores
        peakCount = peakList.length;
        for (i in 0...peakCount) {
            j = i + 1;
            while (j < peakCount) {
                dist = peakList[j] - peakList[i];
                if (dist < 48) {
                    j++;continue;
                };
                if (dist > 1000)  break;
                scale = 1;
                for (k in j+1...peakCount) {
                    dist2 = (peakList[k] - peakList[j]) / dist + 0.1;
                    dist2 -= Math.floor(dist2);
                    if (dist2 < 0.2) {
                        dist2 -= 0.1;
                        if (dist2 < 0)                             dist2 = -dist2;
                        scale += _normalDist[Math.floor(dist2 * 20)] * 0.01;
                    }
                }
                peakDist = Math.floor(dist * 2.1 + 0.5);
                scoreTable[peakDist] += _normalDist[0] * scale;
                for (k in 1...20){
                    s = peakDist + k;scoreTable[s] += _normalDist[k] * scale;
                    s = peakDist - k;scoreTable[s] += _normalDist[k] * scale;
                }
                j++;
            }
        }  // normalize  


        scoreTotal=0;
        for (i in 0...2124) scoreTotal = scoreTotal + Math.round(scoreTable[i]);

        scale=1/scoreTotal;
        for (i in 0...2124) scoreTable[i] *= scale;

        return scoreTable;
    }
    private static var _normalDist : Array<Int> = [100, 99, 95, 89, 81, 73, 63, 53, 44, 35, 28, 21, 16, 11, 8, 6, 4, 2, 2, 1];
}



