//----------------------------------------------------------------------------------------------------
// Voice data
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer;

import org.si.sion.sequencer.SiMMLTrack;

import org.si.sion.module.channels.*;
import org.si.sion.module.SiOPMChannelParam;
import org.si.sion.module.SiOPMWaveBase;
import org.si.sion.module.SiOPMWavePCMTable;
import org.si.sion.module.SiOPMWavePCMData;
import org.si.sion.module.SiOPMWaveTable;
import org.si.sion.module.SiOPMWaveSamplerTable;




/** Voice data. This includes SiOPMChannelParam.
 *  @see org.si.sion.module.SiOPMChannelParam
 *  @see org.si.sion.module.SiOPMOperatorParam
 */
class SiMMLVoice
{
    public var isFMVoice(get, never) : Bool;
    public var isPCMVoice(get, never) : Bool;
    public var isSamplerVoice(get, never) : Bool;
    public var isWaveTableVoice(get, never) : Bool;
    public var _isSuitableForFMVoice(get, never) : Bool;

    // variables
    //--------------------------------------------------
    /** chip type */
    public var chipType : String;
    
    /** update track paramaters, false to update only channel params. @default false(SiMMLVoice), true(SiONVoice) */
    public var updateTrackParamaters : Bool;
    /** update volume, velocity, expression and panning when the voice is set. @default false(ignore volume settings) */
    public var updateVolumes : Bool;
    
    /** module type, 1st argument of '%'. @default 0 */
    public var moduleType : Int;
    /** channel number, 2nd argument of '%'. @default 0 */
    public var channelNum : Int;
    /** tone number, 1st argument of '&#64;'. -1;do nothing. @default -1 */
    public var toneNum : Int;
    /** preferable note. -1;no preferable note. @default -1 */
    public var preferableNote : Int;
    
    /** parameters for FM sound channel. */
    public var channelParam : SiOPMChannelParam;
    /** wave data. @default null */
    public var waveData : SiOPMWaveBase;
    /** PMS guitar tension @default 8 */
    public var pmsTension : Int;
    
    
    
    /** default gate time (same as "q" command * 0.125), set Number.NaN to ignore. @default Number.NaN */
    public var defaultGateTime : Float;
    /** [Not implemented in current version] default absolute gate time (same as 1st argument of "&#64;q" command), set -1 to ignore. @default -1 */
    public var defaultGateTicks : Int;
    /** [Not implemented in current version] default key on delay (same as 2nd argument "&#64;q" command), set -1 to ignore. @default -1 */
    public var defaultKeyOnDelayTicks : Int;
    /** track pitch shift (same as "k" command). @default 0 */
    public var pitchShift : Int;
    /** track key transpose (same as "kt" command). @default 0 */
    public var noteShift : Int;
    /** portament. @default 0 */
    public var portament : Int;
    /** release sweep. 2nd argument of '&#64;rr' and 's'. @default 0 */
    public var releaseSweep : Int;
    
    
    /** velocity @default 256 */
    public var velocity : Int;
    /** expression @default 128 */
    public var expression : Int;
    /** velocity table mode (same as 1st argument of "%v" command). @default 0 */
    public var velocityMode : Int;
    /** velocity table mode (same as 2nd argument of "%v" command). @default 0 */
    public var vcommandShift : Int;
    /** expression table mode (same as "%x" command). @default 0 */
    public var expressionMode : Int;
    
    
    /** amplitude modulation depth. 1st argument of 'ma'. @default 0 */
    public var amDepth : Int;
    /** amplitude modulation depth after changing. 2nd argument of 'ma'. @default 0 */
    public var amDepthEnd : Int;
    /** amplitude modulation changing delay. 3rd argument of 'ma'. @default 0 */
    public var amDelay : Int;
    /** amplitude modulation changing term. 4th argument of 'ma'. @default 0 */
    public var amTerm : Int;
    /** pitch modulation depth. 1st argument of 'mp'. @default 0 */
    public var pmDepth : Int;
    /** pitch modulation depth after changing. 2nd argument of 'mp'. @default 0 */
    public var pmDepthEnd : Int;
    /** pitch modulation changing delay. 3rd argument of 'mp'. @default 0 */
    public var pmDelay : Int;
    /** pitch modulation changing term. 4th argument of 'mp'. @default 0 */
    public var pmTerm : Int;
    
    
    /** note on tone envelop table. 1st argument of '&#64;&#64;' @default null */
    public var noteOnToneEnvelop : SiMMLEnvelopTable;
    /** note on amplitude envelop table. 1st argument of 'na' @default null */
    public var noteOnAmplitudeEnvelop : SiMMLEnvelopTable;
    /** note on filter envelop table. 1st argument of 'nf' @default null */
    public var noteOnFilterEnvelop : SiMMLEnvelopTable;
    /** note on pitch envelop table. 1st argument of 'np' @default null */
    public var noteOnPitchEnvelop : SiMMLEnvelopTable;
    /** note on note envelop table. 1st argument of 'nt' @default null */
    public var noteOnNoteEnvelop : SiMMLEnvelopTable;
    /** note off tone envelop table. 1st argument of '_&#64;&#64;' @default null */
    public var noteOffToneEnvelop : SiMMLEnvelopTable;
    /** note off amplitude envelop table. 1st argument of '_na' @default null */
    public var noteOffAmplitudeEnvelop : SiMMLEnvelopTable;
    /** note off filter envelop table. 1st argument of '_nf' @default null */
    public var noteOffFilterEnvelop : SiMMLEnvelopTable;
    /** note off pitch envelop table. 1st argument of '_np' @default null */
    public var noteOffPitchEnvelop : SiMMLEnvelopTable;
    /** note off note envelop table. 1st argument of '_nt' @default null */
    public var noteOffNoteEnvelop : SiMMLEnvelopTable;
    
    
    /** note on tone envelop tablestep. 2nd argument of '&#64;&#64;' @default 1 */
    public var noteOnToneEnvelopStep : Int;
    /** note on amplitude envelop tablestep. 2nd argument of 'na' @default 1 */
    public var noteOnAmplitudeEnvelopStep : Int;
    /** note on filter envelop tablestep. 2nd argument of 'nf' @default 1 */
    public var noteOnFilterEnvelopStep : Int;
    /** note on pitch envelop tablestep. 2nd argument of 'np' @default 1 */
    public var noteOnPitchEnvelopStep : Int;
    /** note on note envelop tablestep. 2nd argument of 'nt' @default 1 */
    public var noteOnNoteEnvelopStep : Int;
    /** note off tone envelop tablestep. 2nd argument of '_&#64;&#64;' @default 1 */
    public var noteOffToneEnvelopStep : Int;
    /** note off amplitude envelop tablestep. 2nd argument of '_na' @default 1 */
    public var noteOffAmplitudeEnvelopStep : Int;
    /** note off filter envelop tablestep. 2nd argument of '_nf' @default 1 */
    public var noteOffFilterEnvelopStep : Int;
    /** note off pitch envelop tablestep. 2nd argument of '_np' @default 1 */
    public var noteOffPitchEnvelopStep : Int;
    /** note off note envelop tablestep. 2nd argument of '_nt' @default 1 */
    public var noteOffNoteEnvelopStep : Int;
    
    
    
    
    // properties
    //--------------------------------------------------
    /** FM voice flag */
    private function get_isFMVoice() : Bool{return (moduleType == 6);
    }
    
    /** PCM voice flag */
    private function get_isPCMVoice() : Bool{return (Std.is(waveData, SiOPMWavePCMTable) || Std.is(waveData, SiOPMWavePCMData));
    }
    
    /** Sampler voice flag */
    private function get_isSamplerVoice() : Bool{return (Std.is(waveData, SiOPMWaveSamplerTable));
    }
    
    /** wave table voice flag */
    private function get_isWaveTableVoice() : Bool{return (Std.is(waveData, SiOPMWaveTable));
    }
    
    /** @private [sion internal] suitability to register in %6 voices */
    private function get__isSuitableForFMVoice() : Bool{
        return updateTrackParamaters || (SiMMLTable.isSuitableForFMVoice(moduleType) && waveData == null);
    }
    
    
    /** set moduleType, channelNum, toneNum and 0th operator's pgType simultaneously.
     *  @param moduleType Channel module type
     *  @param channelNum Channel number. For %2-11, this value is same as 1st argument of '_&#64;'.
     *  @param toneNum Tone number. Ussualy, this argument is used only in %0;PSG and %1;APU.
     */
    public function setModuleType(moduleType : Int, channelNum : Int = 0, toneNum : Int = -1) : Void
    {
        this.moduleType = moduleType;
        this.channelNum = channelNum;
        this.toneNum = toneNum;
        var pgType : Int = SiMMLTable.getPGType(moduleType, channelNum, toneNum);
        if (pgType != -1)             channelParam.operatorParam[0].setPGType(pgType);
    }
    
    
    
    
    // constrctor
    //--------------------------------------------------
    /** constructor. */
    public function new()
    {
        channelParam = new SiOPMChannelParam();
        initialize();
    }
    
    
    
    
    // setting
    //--------------------------------------------------
    /** update track's voice paramters */
    public function updateTrackVoice(track : SiMMLTrack) : SiMMLTrack
    {
        // synthesizer modules
        switch (moduleType)
        {
            case 6:  // Registered FM voice (%6)  
            track.setChannelModuleType(6, channelNum);
            case 11:  // PMS Guitar (%11)  
                track.setChannelModuleType(11, 1);
                track.channel.setSiOPMChannelParam(channelParam, false);
                track.channel.setAllReleaseRate(pmsTension);
                if (isPCMVoice)                     track.channel.setWaveData(waveData);
            default:  // other sound modules  
                if (waveData != null) {
                    // voice with wave data
                    track.setChannelModuleType(waveData.moduleType, -1);
                    track.channel.setSiOPMChannelParam(channelParam, updateVolumes);
                    track.channel.setWaveData(waveData);
                }
                else {
                    track.setChannelModuleType(moduleType, channelNum, toneNum);
                    track.channel.setSiOPMChannelParam(channelParam, updateVolumes);
                }
        }

        //if (defaultGateTicks > 0) track.quantCount = defaultGateTicks -> samplecount;
        // if (defaultKeyOnDelayTicks  > 0) track.defaultKeyOnDelayTicks = defaultKeyOnDelayTicks -> samplecount;

        // track settings
        if (!Math.isNaN(defaultGateTime))             track.quantRatio = defaultGateTime;
        track.pitchShift = pitchShift;
        track.noteShift = noteShift;
        track._vcommandShift = vcommandShift;
        track.velocityMode = velocityMode;
        track.expressionMode = expressionMode;
        if (updateVolumes) {
            track.velocity = velocity;
            track.expression = expression;
        }
        
        track.setPortament(portament);
        track.setReleaseSweep(releaseSweep);
        track.setModulationEnvelop(false, amDepth, amDepthEnd, amDelay, amTerm);
        track.setModulationEnvelop(true, pmDepth, pmDepthEnd, pmDelay, pmTerm);
        {
            track.setToneEnvelop(1, noteOnToneEnvelop, noteOnToneEnvelopStep);
            track.setAmplitudeEnvelop(1, noteOnAmplitudeEnvelop, noteOnAmplitudeEnvelopStep);
            track.setFilterEnvelop(1, noteOnFilterEnvelop, noteOnFilterEnvelopStep);
            track.setPitchEnvelop(1, noteOnPitchEnvelop, noteOnPitchEnvelopStep);
            track.setNoteEnvelop(1, noteOnNoteEnvelop, noteOnNoteEnvelopStep);
            track.setToneEnvelop(0, noteOffToneEnvelop, noteOffToneEnvelopStep);
            track.setAmplitudeEnvelop(0, noteOffAmplitudeEnvelop, noteOffAmplitudeEnvelopStep);
            track.setFilterEnvelop(0, noteOffFilterEnvelop, noteOffFilterEnvelopStep);
            track.setPitchEnvelop(0, noteOffPitchEnvelop, noteOffPitchEnvelopStep);
            track.setNoteEnvelop(0, noteOffNoteEnvelop, noteOffNoteEnvelopStep);
        }
        return track;
    }
    
    
    /** [NOT RECOMENDED] this function is only for compatibility of previous versions */
    public function setTrackVoice(track : SiMMLTrack) : SiMMLTrack{
        return updateTrackVoice(track);
    }
    
    
    
    
    // operation
    //--------------------------------------------------
    /** initializer */
    public function initialize() : Void
    {
        chipType = "";
        
        updateTrackParamaters = false;
        updateVolumes = false;
        
        moduleType = 5;
        channelNum = -1;
        toneNum = -1;
        preferableNote = -1;
        
        channelParam.initialize();
        waveData = null;
        pmsTension = 8;
        
        defaultGateTime = Math.NaN;
        defaultGateTicks = -1;
        defaultKeyOnDelayTicks = -1;
        pitchShift = 0;
        noteShift = 0;
        portament = 0;
        releaseSweep = 0;
        
        velocity = 256;
        expression = 128;
        vcommandShift = 4;
        velocityMode = 0;
        expressionMode = 0;
        
        amDepth = 0;
        amDepthEnd = 0;
        amDelay = 0;
        amTerm = 0;
        pmDepth = 0;
        pmDepthEnd = 0;
        pmDelay = 0;
        pmTerm = 0;
        
        noteOnToneEnvelop = null;
        noteOnAmplitudeEnvelop = null;
        noteOnFilterEnvelop = null;
        noteOnPitchEnvelop = null;
        noteOnNoteEnvelop = null;
        noteOffToneEnvelop = null;
        noteOffAmplitudeEnvelop = null;
        noteOffFilterEnvelop = null;
        noteOffPitchEnvelop = null;
        noteOffNoteEnvelop = null;
        
        noteOnToneEnvelopStep = 1;
        noteOnAmplitudeEnvelopStep = 1;
        noteOnFilterEnvelopStep = 1;
        noteOnPitchEnvelopStep = 1;
        noteOnNoteEnvelopStep = 1;
        noteOffToneEnvelopStep = 1;
        noteOffAmplitudeEnvelopStep = 1;
        noteOffFilterEnvelopStep = 1;
        noteOffPitchEnvelopStep = 1;
        noteOffNoteEnvelopStep = 1;
    }
    
    
    /** copy all parameters */
    public function copyFrom(src : SiMMLVoice) : Void
    {
        chipType = src.chipType;
        
        updateTrackParamaters = src.updateTrackParamaters;
        updateVolumes = src.updateVolumes;
        
        moduleType = src.moduleType;
        channelNum = src.channelNum;
        toneNum = src.toneNum;
        preferableNote = src.preferableNote;
        channelParam.copyFrom(src.channelParam);
        
        waveData = src.waveData;
        pmsTension = src.pmsTension;
        
        defaultGateTime = src.defaultGateTime;
        defaultGateTicks = src.defaultGateTicks;
        defaultKeyOnDelayTicks = src.defaultKeyOnDelayTicks;
        pitchShift = src.pitchShift;
        noteShift = src.noteShift;
        portament = src.portament;
        releaseSweep = src.releaseSweep;
        
        velocity = src.velocity;
        expression = src.expression;
        vcommandShift = src.vcommandShift;
        velocityMode = src.velocityMode;
        expressionMode = src.expressionMode;
        
        amDepth = src.amDepth;
        amDepthEnd = src.amDepthEnd;
        amDelay = src.amDelay;
        amTerm = src.amTerm;
        pmDepth = src.pmDepth;
        pmDepthEnd = src.pmDepthEnd;
        pmDelay = src.pmDelay;
        pmTerm = src.pmTerm;
        
        if (src.noteOnToneEnvelop != null)       noteOnToneEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOnToneEnvelop);
        if (src.noteOnAmplitudeEnvelop != null)  noteOnAmplitudeEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOnAmplitudeEnvelop);
        if (src.noteOnFilterEnvelop != null)     noteOnFilterEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOnFilterEnvelop);
        if (src.noteOnPitchEnvelop != null)      noteOnPitchEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOnPitchEnvelop);
        if (src.noteOnNoteEnvelop != null)       noteOnNoteEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOnNoteEnvelop);
        if (src.noteOffToneEnvelop != null)      noteOffToneEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOffToneEnvelop);
        if (src.noteOffAmplitudeEnvelop != null) noteOffAmplitudeEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOffAmplitudeEnvelop);
        if (src.noteOffFilterEnvelop != null)    noteOffFilterEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOffFilterEnvelop);
        if (src.noteOffPitchEnvelop != null)     noteOffPitchEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOffPitchEnvelop);
        if (src.noteOffNoteEnvelop != null)      noteOffNoteEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOffNoteEnvelop);
        
        noteOnToneEnvelopStep = src.noteOnToneEnvelopStep;
        noteOnAmplitudeEnvelopStep = src.noteOnAmplitudeEnvelopStep;
        noteOnFilterEnvelopStep = src.noteOnFilterEnvelopStep;
        noteOnPitchEnvelopStep = src.noteOnPitchEnvelopStep;
        noteOnNoteEnvelopStep = src.noteOnNoteEnvelopStep;
        noteOffToneEnvelopStep = src.noteOffToneEnvelopStep;
        noteOffAmplitudeEnvelopStep = src.noteOffAmplitudeEnvelopStep;
        noteOffFilterEnvelopStep = src.noteOffFilterEnvelopStep;
        noteOffPitchEnvelopStep = src.noteOffPitchEnvelopStep;
        noteOffNoteEnvelopStep = src.noteOffNoteEnvelopStep;
    }
    
    
    /** @private [sion internal] set as blank pcm voice */
    public function _newBlankPCMVoice(channelNum : Int) : SiMMLVoice{
        var pcmTable : SiOPMWavePCMTable = new SiOPMWavePCMTable();
        this.moduleType = 7;
        this.channelNum = channelNum;
        this.waveData = pcmTable;
        return this;
    }
}



