//----------------------------------------------------------------------------------------------------
// class for SiMML sequencer setting
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.simulator;

import org.si.sion.sequencer.SiMMLTrack;
import org.si.sion.sequencer.base.MMLSequence;
import org.si.sion.module.SiOPMChannelParam;
import org.si.sion.module.channels.SiOPMChannelManager;
import org.si.sion.module.channels.SiOPMChannelBase;
import org.si.sion.sequencer.base.SionSequencerInternal;


/** Base class of all module simulators which control "SiMMLTrack" (not SiOPMChannel) to simulate various modules. */
class SiMMLSimulatorBase
{
    // constants
    //--------------------------------------------------
    /* module type */
    public static inline var MT_PSG : Int = 0;  // PSG(DCSG)
    public static inline var MT_APU : Int = 1;  // FC pAPU
    public static inline var MT_NOISE : Int = 2;  // noise wave
    public static inline var MT_MA3 : Int = 3;  // MA3 wave form
    public static inline var MT_CUSTOM : Int = 4;  // SCC / custom wave table
    public static inline var MT_ALL : Int = 5;  // all pgTypes
    public static inline var MT_FM : Int = 6;  // FM sound module
    public static inline var MT_PCM : Int = 7;  // PCM
    public static inline var MT_PULSE : Int = 8;  // pulse wave
    public static inline var MT_RAMP : Int = 9;  // ramp wave
    public static inline var MT_SAMPLE : Int = 10;  // sampler
    public static inline var MT_KS : Int = 11;  // karplus strong
    public static inline var MT_GB : Int = 12;  // gameboy
    public static inline var MT_VRC6 : Int = 13;  // vrc6
    public static inline var MT_SID : Int = 14;  // sid
    public static inline var MT_FM_OPM : Int = 15;  // YM2151
    public static inline var MT_FM_OPN : Int = 16;  // YM2203
    public static inline var MT_FM_OPNA : Int = 17;  // YM2608
    public static inline var MT_FM_OPLL : Int = 18;  // YM2413
    public static inline var MT_FM_OPL3 : Int = 19;  // YM3812
    public static inline var MT_FM_MA3 : Int = 20;  // YMU762
    public static inline var MT_MAX : Int = 21;
    
    
    
    
    // variables
    //--------------------------------------------------
    /** module type */
    public var type : Int;
    
    
    /** Default table converting from MML voice number to SiOPM pgType */
    private var _defaultVoiceSet : SiMMLSimulatorVoiceSet;
    /** Tables converting from MML voice number to SiOPM pgType for each channel, if the table is different for each channel */
    private var _channelVoiceSet : Array<SiMMLSimulatorVoiceSet>;
    /** This simulator can be used as the FM voice's source wave or not */
    private var _isSuitableForFMVoice : Bool;
    /** Default operator count */
    private var _defaultOpeCount : Int;

    private var _channelType:Int = -1;
    
    
    // constructor
    //--------------------------------------------------
    public function new(type : Int, channelCount : Int, defaultVoiceSet : SiMMLSimulatorVoiceSet = null, isSuitableForFMVoice : Bool = true)
    {
        this.type = type;
        this._isSuitableForFMVoice = isSuitableForFMVoice;
        this._defaultOpeCount = 1;
        this._channelVoiceSet = new Array<SiMMLSimulatorVoiceSet>();
        this._defaultVoiceSet = defaultVoiceSet;
    }
    
    
    
    
    // tone setting
    //--------------------------------------------------
    /** initialize tone by channel number. 
     *  call from SiMMLTrack::reset()/setChannelModuleType().
     *  call from "%" MML command
     */
    public function initializeTone(track : SiMMLTrack, chNum : Int, bufferIndex : Int) : Int
    {
        // initialize
        var restrictedChNum : Int = chNum;
        var voiceSet : SiMMLSimulatorVoiceSet = _defaultVoiceSet;
        if (0 <= chNum && chNum < _channelVoiceSet.length && (_channelVoiceSet[chNum] != null)) {
            voiceSet = _channelVoiceSet[chNum];
        }
        else {
            restrictedChNum = 0;
        }
        
        // update channel instance in SiMMLTrack
        _updateChannelInstance(track, bufferIndex, voiceSet);
        
        // track setup
        track._channelNumber = ((chNum < 0)) ? -1 : chNum;  // track has channel number include -1.
        track.channel.setChannelNumber(restrictedChNum);  // channel requires restrticted channel number  
        track.channel.setAlgorism(_defaultOpeCount, 0);  //  
        
        selectTone(track, voiceSet.initVoiceIndex);
        
        // return voice index
        return ((chNum == -1)) ? -1 : voiceSet.initVoiceIndex;
    }
    
    
    /** select tone by tone number. 
     *  call from initializeTone(), SiMMLTrack::setChannelModuleType()/_bufferEnvelop()/_keyOn()/_setChannelParameters().
     *  call from "%" and "&#64;" MML command
     */
    public function selectTone(track : SiMMLTrack, voiceIndex : Int) : MMLSequence
    {
        return _selectSingleWaveTone(track, voiceIndex);
    }
    
    
    /** @private */
    private function _selectSingleWaveTone(track : SiMMLTrack, voiceIndex : Int) : MMLSequence
    {
        if (voiceIndex == -1)             return null;
        
        var chNum : Int = track._channelNumber;
        var voiceSet : SiMMLSimulatorVoiceSet = _defaultVoiceSet;
        if (chNum >= 0 && chNum < _channelVoiceSet.length && (_channelVoiceSet[chNum] != null)) {
            voiceSet = _channelVoiceSet[chNum];
        }
        if (voiceIndex < 0 || voiceIndex >= voiceSet.voices.length) {
            voiceIndex = voiceSet.initVoiceIndex;
        }
        var voice : SiMMLSimulatorVoice = voiceSet.voices[voiceIndex];
        track.channel.setType(voice.pgType, voice.ptType);
        
        return null;
    }
    
    
    /** @private */
    private function _updateChannelInstance(track : SiMMLTrack, bufferIndex : Int, voiceSet : SiMMLSimulatorVoiceSet) : Void
    {
        var defaultVoice : SiMMLSimulatorVoice = voiceSet.voices[voiceSet.initVoiceIndex];
        var defaultChannelType : Int = defaultVoice.channelType;
        
        // update channel instance
        if (track.channel == null) {
            // create new channel
            track.channel = SiOPMChannelManager.newChannel(defaultChannelType, null, bufferIndex);
        }
        else 
        if (track.channel.channelType != _channelType) {
            // change channel type
            var prev : SiOPMChannelBase = track.channel;
            track.channel = SiOPMChannelManager.newChannel(defaultChannelType, prev, bufferIndex);
            SiOPMChannelManager.deleteChannel(prev);
        }
        else {
            // initialize channel
            track.channel.initialize(track.channel, bufferIndex);
            track._resetVolumeOffset();
        }
    }
}


