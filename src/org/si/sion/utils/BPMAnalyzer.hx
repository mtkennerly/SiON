//----------------------------------------------------------------------------------------------------
// BPM analyzer
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion.utils;

import org.si.sion.utils.PeakDetector;
import org.si.sion.utils.Sound;

import openfl.media.*;


/** BPMAnalyzer analyzes beat per minute value of music */
class BPMAnalyzer
{
    public var bpm(get, never) : Int;
    public var bpmProbability(get, never) : Float;
    public var pickedupCount(get, never) : Int;
    public var pickedupBPMList(get, never) : Array<Int>;
    public var pickedupBPMProbabilityList(get, never) : Array<Float>;
    public var snapShotPosition(get, never) : Float;

    // variables
    //----------------------------------------
    /** filter banks, 5000Hz, 2400Hz, 100Hz @ default. */
    public var filterbanks : Array<PeakDetector>;
    
    private var _bpm : Int;
    private var _bpmProbability : Float;
    private var _pickedupCount : Int;
    private var _pickedupBPMList : Array<Int> = new Array<Int>();
    private var _pickedupBPMProbabilityList : Array<Float> = new Array<Float>();
    private var _snapShotIndex : Int;
    
    
    
    
    // properties
    //----------------------------------------
    /** estimated bpm */
    private function get_bpm() : Int{return _bpm;
    }
    
    /** estimated bpm's probability */
    private function get_bpmProbability() : Float{return _bpmProbability;
    }
    
    /** number of picked up point */
    private function get_pickedupCount() : Int{return _pickedupCount;
    }
    
    /** picked up bpm list */
    private function get_pickedupBPMList() : Array<Int>{return _pickedupBPMList;
    }
    
    /** picked up bpm's probability list */
    private function get_pickedupBPMProbabilityList() : Array<Float>{return _pickedupBPMProbabilityList;
    }
    
    /** starting position that has maximum probability */
    private function get_snapShotPosition() : Float{return _snapShotIndex * 0.000022675736961451247;
    }  // 1/44100  
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor 
    *  @param filterbankCount Number of filter bank for analysis (1-4).
     */
    public function new(filterbankCount : Int = 3)
    {
        if (filterbankCount < 1 || filterbankCount > 4)             filterbankCount = 4;
        filterbanks = new Array<PeakDetector>();
        filterbanks[0] = new PeakDetector(5000, 0.50, 25);
        if (filterbankCount > 1)             filterbanks[1] = new PeakDetector(2400, 0.50, 25);
        if (filterbankCount > 2)             filterbanks[2] = new PeakDetector(100, 0.50, 40);
        if (filterbankCount > 3)             filterbanks[3] = new PeakDetector();
    }
    
    
    
    
    // methods
    //----------------------------------------
    /** estimate BPM from Sound 
     *  @param sound sound to analyze
     *  @param rememberFilterbanksSnapShot remember filterbanks status that has the biggest probability
     *  @return estimated bpm value
     */
    public function estimateBPM(sound : Sound, rememberFilterbanksSnapShot : Bool = false) : Int{
        var pickupIndex : Int;
        var pickupStep : Int;
        var i : Int;
        var maxProb : Float;
        var thres : Float;
        var probs : Array<Float> = _pickedupBPMProbabilityList;
        var bpms : Array<Int> = _pickedupBPMList;
        var scores : Array<Float>;
        
        _pickedupCount = Math.floor(sound.length / 20000);
        if (_pickedupCount == 0)             _pickedupCount = 1
        else if (_pickedupCount > 10)             _pickedupCount = 10;
        scores = new Array<Float>();
        
        pickupStep = (sound.length - _pickedupCount * 4000) * 44.1 / (_pickedupCount + 1);
        if (pickupStep < 0)             pickupStep = 0;
        maxProb = 0;
        
        pickupIndex = pickupStep;
i = 0;
        while (i < _pickedupCount){
            _estimateBPMFromSamples(SiONUtil.extract(sound, null, 1, 176400, pickupIndex), 1);
            probs[i] = _bpmProbability;
            bpms[i] = Math.floor(_bpm);
            if (maxProb < _bpmProbability) {
                maxProb = _bpmProbability;
                _snapShotIndex = pickupIndex;
            }
            i++;
            pickupIndex += 176400 + pickupStep;
        }
        _bpmProbability = maxProb;
        
        thres = maxProb * 0.75;
        for (_pickedupCount){
            if (probs[i] > thres && 100 <= bpms[i] && bpms[i] < 200)                 scores[bpms[i] - 100] += probs[i];
        }
        maxProb = 0;
        for (100){
            if (maxProb < scores[i]) {
                maxProb = scores[i];
                _bpm = i + 100;
            }
        }
        
        if (rememberFilterbanksSnapShot)             _estimateBPMFromSamples(SiONUtil.extract(sound, null, 1, 176400, _snapShotIndex), 1);
        
        return _bpm;
    }
    
    
    /** estimate BPM from samples
     *  @param sample samples to analyze
     *  @param channels channel count of samples
     *  @return estimated bpm value
     */
    public function estimateBPMFromSamples(sample : Array<Float>, channels : Int) : Int{
        _pickedupCount = 0;
        _estimateBPMFromSamples(sample, channels);
        return _bpm;
    }
    
    
    
    
    // internal
    //----------------------------------------
    // estimate BPM from samples
    private function _estimateBPMFromSamples(sample : Array<Float>, channels : Int) : Void{
        var pd1 : PeakDetector;
        var pd2 : PeakDetector;
        var pmp : Float;
        var pmr : Float;
        var bpm : Float;
        var i : Int;
        var banksCount : Int = filterbanks.length;
        
        // set samples to filter banks
        for (banksCount){filterbanks[i].setSamples(sample, channels);
        }
        
        // pick up 1st and 2nd acculate filterbanks
        if (banksCount > 1) {
            // pick up 2 banks
            if (filterbanks[0].peaksPerMinuteProbability < filterbanks[1].peaksPerMinuteProbability) {
                pd1 = filterbanks[1];
                pd2 = filterbanks[0];
            }
            else {
                pd1 = filterbanks[0];
                pd2 = filterbanks[1];
            }
            for (banksCount){
                if (pd2.peaksPerMinuteProbability < filterbanks[i].peaksPerMinuteProbability) {
                    if (pd1.peaksPerMinuteProbability < filterbanks[i].peaksPerMinuteProbability) {
                        pd2 = pd1;
                        pd1 = filterbanks[i];
                    }
                    else {
                        pd2 = filterbanks[i];
                    }
                }
            }  // estimate bpm  
            
            pmp = pd1.peaksPerMinuteProbability / pd2.peaksPerMinuteProbability;
            pmr = pd1.peaksPerMinute / pd2.peaksPerMinute;
            if (pmp > 1.333 || pmr > 1.1 || pmr < 0.9)                 bpm = pd1.peaksPerMinute
            else bpm = (pd1.peaksPerMinute + pd2.peaksPerMinute) * 0.5;
            _bpm = Math.floor(bpm + 0.5);
            _bpmProbability = pd1.peaksPerMinuteProbability;
        }
        else {
            // only one bank
            _bpm = filterbanks[0].peaksPerMinute;
            _bpmProbability = filterbanks[0].peaksPerMinuteProbability;
        }
    }
}


