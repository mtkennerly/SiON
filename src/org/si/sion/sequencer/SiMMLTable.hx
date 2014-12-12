//----------------------------------------------------------------------------------------------------
// tables for SiMML driver
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer;

import org.si.utils.SLLint;
import org.si.sion.module.SiOPMTable;
import org.si.sion.module.SiOPMChannelParam;
import org.si.sion.module.SiOPMOperatorParam;
import org.si.sion.module.channels.SiOPMChannelManager;


import org.si.sion.sequencer.simulator.*;


/** table for sequencer */
class SiMMLTable
{
    public static var instance(get, never) : SiMMLTable;

    // constants
    //--------------------------------------------------
    // module types (0-11)
    public static var MT_PSG : Int = SiMMLSimulatorBase.MT_PSG;  // PSG(DCSG)  
    public static var MT_APU : Int = SiMMLSimulatorBase.MT_APU;  // FC pAPU  
    public static var MT_NOISE : Int = SiMMLSimulatorBase.MT_NOISE;  // noise wave  
    public static var MT_MA3 : Int = SiMMLSimulatorBase.MT_MA3;  // MA3 wave form  
    public static var MT_CUSTOM : Int = SiMMLSimulatorBase.MT_CUSTOM;  // SCC / custom wave table  
    public static var MT_ALL : Int = SiMMLSimulatorBase.MT_ALL;  // all pgTypes  
    public static var MT_FM : Int = SiMMLSimulatorBase.MT_FM;  // FM sound module  
    public static var MT_PCM : Int = SiMMLSimulatorBase.MT_PCM;  // PCM  
    public static var MT_PULSE : Int = SiMMLSimulatorBase.MT_PULSE;  // pulse wave  
    public static var MT_RAMP : Int = SiMMLSimulatorBase.MT_RAMP;  // ramp wave  
    public static var MT_SAMPLE : Int = SiMMLSimulatorBase.MT_SAMPLE;  // sampler  
    public static var MT_KS : Int = SiMMLSimulatorBase.MT_KS;  // karplus strong  
    public static var MT_GB : Int = SiMMLSimulatorBase.MT_GB;  // gameboy  
    public static var MT_VRC6 : Int = SiMMLSimulatorBase.MT_VRC6;  // vrc6  
    public static var MT_SID : Int = SiMMLSimulatorBase.MT_SID;  // sid  
    public static var MT_FM_OPM : Int = SiMMLSimulatorBase.MT_FM_OPM;  // YM2151  
    public static var MT_FM_OPN : Int = SiMMLSimulatorBase.MT_FM_OPN;  // YM2203  
    public static var MT_FM_OPNA : Int = SiMMLSimulatorBase.MT_FM_OPNA;  // YM2608  
    public static var MT_FM_OPLL : Int = SiMMLSimulatorBase.MT_FM_OPLL;  // YM2413  
    public static var MT_FM_OPL3 : Int = SiMMLSimulatorBase.MT_FM_OPL3;  // YM3812  
    public static var MT_FM_MA3 : Int = SiMMLSimulatorBase.MT_FM_MA3;  // YMU762  
    public static var MT_MAX : Int = SiMMLSimulatorBase.MT_MAX;
    
    
    // module restriction type
    public static inline var ENV_TABLE_MAX : Int = 512;
    public static inline var VOICE_MAX : Int = 256;
    
    
    
    
    // variables
    //--------------------------------------------------
    /** module setting table */
    public var channelModuleSetting : Array<Dynamic> = null;
    /** module setting table */
    public var effectModuleSetting : Array<Dynamic> = null;
    /** module simulators */
    public var simulators : Array<Dynamic> = null;
    
    
    /** table from tsscp @s commnd to OPM ar */
    public var tss_s2ar : Array<String> = null;
    /** table from tsscp @s commnd to OPM dr */
    public var tss_s2dr : Array<String> = null;
    /** table from tsscp @s commnd to OPM sr */
    public var tss_s2sr : Array<String> = null;
    /** table from tsscp s commnd to OPM rr */
    public var tss_s2rr : Array<String> = null;
    
    /** table of OPLL preset voices (from virturenes) */
    public var presetRegisterYM2413 : Array<Int> = [
                0x00000000, 0x00000000, 0x61611e17, 0xf07f0717, 0x13410f0d, 0xced24313, 0x03019904, 0xffc30373, 
                0x21611b07, 0xaf634028, 0x22211e06, 0xf0760828, 0x31221605, 0x90710018, 0x21611d07, 0x82811017, 
                0x23212d16, 0xc0700707, 0x61211b06, 0x64651818, 0x61610c18, 0x85a07907, 0x23218711, 0xf0a400f7, 
                0x97e12807, 0xfff302f8, 0x61100c05, 0xf2c440c8, 0x01015603, 0xb4b22358, 0x61418903, 0xf1f4f013];
    
    /** table of VRC7 preset voices (from virturenes) */
    public var presetRegisterVRC7 : Array<Int> = [
                0x00000000, 0x00000000, 0x3301090e, 0x94904001, 0x13410f0d, 0xced34313, 0x01121b06, 0xffd20032, 
                0x61611b07, 0xaf632028, 0x22211e06, 0xf0760828, 0x66211500, 0x939420f8, 0x21611c07, 0x82811017, 
                0x2321201f, 0xc0710747, 0x25312605, 0x644118f8, 0x17212807, 0xff8302f8, 0x97812507, 0xcfc80214, 
                0x2121540f, 0x807f0707, 0x01015603, 0xd3b24358, 0x31210c03, 0x82c04007, 0x21010c03, 0xd4d34084];
    
    /** table of VRC7/OPLL preset drums (from virturenes) */
    public var presetRegisterVRC7Drums : Array<Int> = [
                0x04212800, 0xdff8fff8, 0x23220000, 0xd8f8f8f8, 0x25180000, 0xf8daf855];
    
    /** Preset voice set of OPLL */
    public var presetVoiceYM2413 : Array<SiMMLVoice> = null;
    /** Preset voice set of VRC7 */
    public var presetVoiceVRC7 : Array<SiMMLVoice> = null;
    /** Preset voice set of VRC7/OPLL drum */
    public var presetVoiceVRC7Drums : Array<SiMMLVoice> = null;
    
    /** algorism table for OPM/OPN. */
    public var alg_opm : Array<Dynamic> = [[0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1, -1, -1], 
        [0, 1, 1, 1, 1, 0, 1, 1, -1, -1, -1, -1, -1, -1, -1, -1], 
        [0, 1, 2, 3, 3, 4, 3, 5, -1, -1, -1, -1, -1, -1, -1, -1], 
        [0, 1, 2, 3, 4, 5, 6, 7, -1, -1, -1, -1, -1, -1, -1, -1]];
    /** algorism table for OPL3 */
    public var alg_opl : Array<Dynamic> = [[0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1], 
        [0, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1], 
        [0, 3, 2, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1], 
        [0, 4, 8, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]];
    /** algorism table for MA3 */
    public var alg_ma3 : Array<Dynamic> = [[0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1, -1, -1], 
        [0, 1, 1, 1, 0, 1, 1, 1, -1, -1, -1, -1, -1, -1, -1, -1], 
        [-1, -1, 5, 2, 0, 3, 2, 2, -1, -1, -1, -1, -1, -1, -1, -1], 
        [-1, -1, 7, 2, 0, 4, 8, 9, -1, -1, -1, -1, -1, -1, -1, -1]];
    /** algorism table for OPX. LSB4 is the flag of feedback connection. */
    public var alg_opx : Array<Dynamic> = [[0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1], 
        [0, 16, 1, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1], 
        [0, 16, 1, 2, 3, 19, 5, 6, -1, -1, -1, -1, -1, -1, -1, -1], 
        [0, 16, 1, 2, 3, 19, 4, 20, 8, 11, 6, 22, 5, 9, 12, 7]];
    /** initial connection */
    public var alg_init : Array<Dynamic> = [0, 1, 5, 7];
    
    // Master envelop tables list
    private var _masterEnvelops : Array<SiMMLEnvelopTable> = null;
    // Master voices list
    private var _masterVoices : Array<SiMMLVoice> = null;
    /** @private [internal] Stencil envelop tables list */
    @:allow(org.si.sion.sequencer)
    private var _stencilEnvelops : Array<SiMMLEnvelopTable> = null;
    /** @private [internal] Stencil voices list */
    @:allow(org.si.sion.sequencer)
    private var _stencilVoices : Array<SiMMLVoice> = null;
    
    
    
    
    // static public instance
    //--------------------------------------------------
    /** internal instance, you can access this after creating SiONDriver. */
    public static var _instance : SiMMLTable = null;
    
    
    /** singleton instance */
    private static function get_instance() : SiMMLTable
    {
        if (_instance == null) {
            _instance = new SiMMLTable();
        }

        return _instance;
    }
    
    
    
    
    // constructor
    //--------------------------------------------------
    /** constructor */
    public function new()
    {
        var i : Int;
        var j : Int;
        
        // Channel module setting
        var ms : SiMMLChannelSetting;
        channelModuleSetting = new Array<Dynamic>();
        channelModuleSetting[MT_PSG] = new SiMMLChannelSetting(MT_PSG, SiOPMTable.PG_SQUARE, 3, 1, 4);  // PSG  
        channelModuleSetting[MT_APU] = new SiMMLChannelSetting(MT_APU, SiOPMTable.PG_PULSE, 11, 2, 4);  // FC pAPU  
        channelModuleSetting[MT_NOISE] = new SiMMLChannelSetting(MT_NOISE, SiOPMTable.PG_NOISE_WHITE, 16, 1, 16);  // noise  
        channelModuleSetting[MT_MA3] = new SiMMLChannelSetting(MT_MA3, SiOPMTable.PG_MA3_WAVE, 32, 1, 32);  // MA3  
        channelModuleSetting[MT_CUSTOM] = new SiMMLChannelSetting(MT_CUSTOM, SiOPMTable.PG_CUSTOM, 256, 1, 256);  // SCC / custom wave table  
        channelModuleSetting[MT_ALL] = new SiMMLChannelSetting(MT_ALL, SiOPMTable.PG_SINE, 512, 1, 512);  // all pgTypes  
        channelModuleSetting[MT_FM] = new SiMMLChannelSetting(MT_FM, SiOPMTable.PG_SINE, 1, 1, 1);  // FM sound module  
        channelModuleSetting[MT_PCM] = new SiMMLChannelSetting(MT_PCM, SiOPMTable.PG_PCM, 128, 1, 128);  // PCM  
        channelModuleSetting[MT_PULSE] = new SiMMLChannelSetting(MT_PULSE, SiOPMTable.PG_PULSE, 32, 1, 32);  // pulse  
        channelModuleSetting[MT_RAMP] = new SiMMLChannelSetting(MT_RAMP, SiOPMTable.PG_RAMP, 128, 1, 128);  // ramp  
        channelModuleSetting[MT_SAMPLE] = new SiMMLChannelSetting(MT_SAMPLE, 0, 4, 1, 4);  // sampler. this is based on SiOPMChannelSampler  
        channelModuleSetting[MT_KS] = new SiMMLChannelSetting(MT_KS, 0, 3, 1, 3);  // karplus strong (0-2 to choose seed generator algrism)  
        channelModuleSetting[MT_GB] = new SiMMLChannelSetting(MT_GB, SiOPMTable.PG_PULSE, 11, 2, 4);  // Gameboy  
        channelModuleSetting[MT_VRC6] = new SiMMLChannelSetting(MT_VRC6, SiOPMTable.PG_PULSE, 8, 1, 9);  // VRC6  
        channelModuleSetting[MT_SID] = new SiMMLChannelSetting(MT_SID, SiOPMTable.PG_PULSE, 8, 1, 9);  // SID  
        
        // PSG setting
        ms = channelModuleSetting[MT_PSG];
        ms._pgTypeList[0] = SiOPMTable.PG_SQUARE;
        ms._pgTypeList[1] = SiOPMTable.PG_NOISE_PULSE;
        ms._pgTypeList[2] = SiOPMTable.PG_PC_NZ_16BIT;
        ms._ptTypeList[0] = SiOPMTable.PT_PSG;
        ms._ptTypeList[1] = SiOPMTable.PT_PSG_NOISE;
        ms._ptTypeList[2] = SiOPMTable.PT_PSG;
        ms._voiceIndexTable[0] = 0;
        ms._voiceIndexTable[1] = 0;
        ms._voiceIndexTable[2] = 0;
        ms._voiceIndexTable[3] = 1;
        // APU setting
        ms = channelModuleSetting[MT_APU];
        ms._pgTypeList[8] = SiOPMTable.PG_TRIANGLE_FC;
        ms._pgTypeList[9] = SiOPMTable.PG_NOISE_PULSE;
        ms._pgTypeList[10] = SiOPMTable.PG_NOISE_SHORT;
        for (i in 0...9){
            ms._ptTypeList[i] = SiOPMTable.PT_PSG;
        }
        for (i in 0...11){
            ms._ptTypeList[i] = SiOPMTable.PT_APU_NOISE;
        }
        ms._initVoiceIndex = 1;
        ms._voiceIndexTable[0] = 4;
        ms._voiceIndexTable[1] = 4;
        ms._voiceIndexTable[2] = 8;
        ms._voiceIndexTable[3] = 9;
        // GB setting
        ms = channelModuleSetting[MT_GB];
        ms._pgTypeList[8] = SiOPMTable.PG_CUSTOM;
        ms._pgTypeList[9] = SiOPMTable.PG_NOISE_PULSE;
        ms._pgTypeList[10] = SiOPMTable.PG_NOISE_GB_SHORT;
        for (i in 0...9){
            ms._ptTypeList[i] = SiOPMTable.PT_PSG;
        }
        for (i in 0...11){
            ms._ptTypeList[i] = SiOPMTable.PT_GB_NOISE;
        }
        ms._initVoiceIndex = 1;
        ms._voiceIndexTable[0] = 4;
        ms._voiceIndexTable[1] = 4;
        ms._voiceIndexTable[2] = 8;
        ms._voiceIndexTable[3] = 9;
        // VRC6 setting
        ms = channelModuleSetting[MT_VRC6];
        ms._pgTypeList[9] = SiOPMTable.PG_SAW_VC6;
        ms._ptTypeList[9] = SiOPMTable.PT_PSG;
        ms._initVoiceIndex = 1;
        ms._voiceIndexTable[0] = 7;
        ms._voiceIndexTable[1] = 7;
        ms._voiceIndexTable[2] = 8;
        // FM setting
        channelModuleSetting[MT_FM]._selectToneType = SiMMLChannelSetting.SELECT_TONE_FM;
        channelModuleSetting[MT_FM]._isSuitableForFMVoice = false;
        // PCM setting
        channelModuleSetting[MT_PCM]._channelType = SiOPMChannelManager.CT_CHANNEL_PCM;
        channelModuleSetting[MT_PCM]._isSuitableForFMVoice = false;
        // Sampler
        //channelModuleSetting[MT_SAMPLE]._selectToneType = SiMMLChannelSetting.SELECT_TONE_NOP;
        channelModuleSetting[MT_SAMPLE]._channelType = SiOPMChannelManager.CT_CHANNEL_SAMPLER;
        channelModuleSetting[MT_SAMPLE]._isSuitableForFMVoice = false;
        // Karplus strong
        channelModuleSetting[MT_KS]._channelType = SiOPMChannelManager.CT_CHANNEL_KS;
        channelModuleSetting[MT_KS]._isSuitableForFMVoice = false;
        
        
        // simulators setting
        simulators = new Array<Dynamic>();
        simulators[MT_PSG] = new SiMMLSimulatorPSG();  // PSG(DCSG)  
        simulators[MT_APU] = new SiMMLSimulatorAPU();  // FC pAPU  
        simulators[MT_NOISE] = new SiMMLSimulatorNoise();  // noise wave  
        simulators[MT_MA3] = new SiMMLSimulatorMA3WaveTable();  // MA3 wave form  
        simulators[MT_CUSTOM] = new SiMMLSimulatorWT();  // SCC / custom wave table  
        simulators[MT_ALL] = new SiMMLSimulatorSiOPM();  // all pgTypes  
        simulators[MT_FM] = new SiMMLSimulatorFMSiOPM();  // FM sound module  
        simulators[MT_PCM] = new SiMMLSimulatorPCM();  // PCM  
        simulators[MT_PULSE] = new SiMMLSimulatorPulse();  // pulse wave  
        simulators[MT_RAMP] = new SiMMLSimulatorRamp();  // ramp wave  
        simulators[MT_SAMPLE] = new SiMMLSimulatorSampler();  // sampler  
        simulators[MT_KS] = new SiMMLSimulatorKS();  // karplus strong  
        simulators[MT_GB] = new SiMMLSimulatorGB();  // gameboy  
        simulators[MT_VRC6] = new SiMMLSimulatorVRC6();  // vrc6  
        simulators[MT_SID] = new SiMMLSimulatorSID();  // sid  
        simulators[MT_FM_OPM] = new SiMMLSimulatorFMOPM();  // YM2151  
        simulators[MT_FM_OPN] = new SiMMLSimulatorFMOPN();  // YM2203  
        simulators[MT_FM_OPNA] = new SiMMLSimulatorFMOPNA();  // YM2608  
        simulators[MT_FM_OPLL] = new SiMMLSimulatorFMOPLL();  // YM2413  
        simulators[MT_FM_OPL3] = new SiMMLSimulatorFMOPL3();  // YM3812  
        simulators[MT_FM_MA3] = new SiMMLSimulatorFMMA3();  // YMU762  
        
        // setup OPLL default voices
        presetVoiceYM2413 = _setupYM2413DefaultVoices(presetRegisterYM2413);
        presetVoiceVRC7 = _setupYM2413DefaultVoices(presetRegisterVRC7);
        presetVoiceVRC7Drums = _setupYM2413DefaultVoices(presetRegisterVRC7Drums);
        
        // tables
        _masterEnvelops = new Array<SiMMLEnvelopTable>();
        for (i in 0...ENV_TABLE_MAX){
            _masterEnvelops[i] = null;
        }
        _masterVoices = new Array<SiMMLVoice>();
        for (i in 0...VOICE_MAX){
            _masterVoices[i] = null;
        }

        function _logTable(start : Int, step : Int, v0 : Int, v255 : Int) : Array<String>{
            var vector : Array<String> = new Array<String>();
            var imax : Int;
            var j : Int;
            var t : Int;
            var dt : Int;

            t = start << 16;
            dt = step << 16;
            i = 1;
            for (j in 1...9) {
                imax = 1 << j;
                while (i < imax) {
                    vector[i] = Std.string(t >> 16);
                    t += dt;
                    i++;
                }
                dt >>= 1;
            }
            vector[0] = Std.string(v0);
            vector[255] = Std.string(v255);

            return vector;
        };

        // These tables are just depended on my ear ... ('A`)
        tss_s2ar = _logTable(41, -4, 63, 9);
        tss_s2dr = _logTable(52, -4, 0, 20);
        tss_s2sr = _logTable(9, 5, 0, 63);
        tss_s2rr = _logTable(12, 4, 63, 63);
        //trace(tss_s2ar); trace(tss_s2dr); trace(tss_s2sr); trace(tss_s2rr);
    }
    
    private function _setupYM2413DefaultVoices(registerMap : Array<Int>) : Array<SiMMLVoice>
    {
        var voices : Array<SiMMLVoice> = new Array<SiMMLVoice>();
        var i : Int;
        var i2 : Int;
        i = i2 = 0;
        while (i < voices.length){voices[i] = _dumpYM2413Register(new SiMMLVoice(), registerMap[i2], registerMap[i2 + 1]);
            i++;
            i2 += 2;
        }
        return voices;
    }
    
    private function _dumpYM2413Register(voice : SiMMLVoice, u0 : Int, u1 : Int) : SiMMLVoice
    {
        var i : Int;
        var param : SiOPMChannelParam = voice.channelParam;
        var opp0 : SiOPMOperatorParam = param.operatorParam[0];
        var opp1 : SiOPMOperatorParam = param.operatorParam[1];
        voice.setModuleType(6);
        voice.chipType = "OPL";
        param.fratio = 133;
        param.opeCount = 2;
        param.alg = 0;
        
        opp0.ams = ((u0 >> 31) & 1) << 1;  //(dump[0]>>7)&1 ;  
        opp1.ams = ((u0 >> 23) & 1) << 1;  //(dump[1]>>7)&1 ;  
        //opp0.PM = (u0>>30)&1;  //(dump[0]>>6)&1 ;
        //opp1.PM = (u0>>22)&1;  //(dump[1]>>6)&1 ;
        opp0.ksr = ((u0 >> 28) & 1) << 1;  //(dump[0]>>4)&1 ;  
        opp1.ksr = ((u0 >> 20) & 1) << 1;  //(dump[1]>>4)&1 ;  
        i = (u0 >> 24) & 15;  //(dump[0])&15 ;  
        opp0.mul = ((i == 11 || i == 13)) ? (i - 1) : ((i == 14)) ? (i + 1) : i;
        i = (u0 >> 16) & 15;  //(dump[1])&15 ;  
        opp1.mul = ((i == 11 || i == 13)) ? (i - 1) : ((i == 14)) ? (i + 1) : i;
        opp0.ksl = (u0 >> 14) & 3;  //(dump[2]>>6)&3 ;  
        opp1.ksl = (u0 >> 6) & 3;  //(dump[3]>>6)&3 ;  
        param.fb = (u0 >> 0) & 7;  //(dump[3])&7 ;  
        opp0.setPGType(SiOPMTable.PG_MA3_WAVE + ((u0 >> 3) & 1));  //(dump[3]>>3)&1 ;  
        opp1.setPGType(SiOPMTable.PG_MA3_WAVE + ((u0 >> 4) & 1));  //(dump[3]>>4)&1 ;  
        opp0.ar = ((u1 >> 28) & 15) << 2;  //(dump[4]>>4)&15 ;  
        opp1.ar = ((u1 >> 20) & 15) << 2;  //(dump[5]>>4)&15 ;  
        opp0.dr = ((u1 >> 24) & 15) << 2;  //(dump[4])&15 ;  
        opp1.dr = ((u1 >> 16) & 15) << 2;  //(dump[5])&15 ;  
        opp0.sl = (u1 >> 12) & 15;  //(dump[6]>>4)&15 ;  
        opp1.sl = (u1 >> 4) & 15;  //(dump[7]>>4)&15 ;  
        opp0.rr = ((u1 >> 8) & 15) << 2;  //(dump[6])&15 ;  
        opp1.rr = ((u1 >> 0) & 15) << 2;  //(dump[7])&15 ;  
        opp0.sr = ((((u0 >> 29) & 1) != 0)) ? 0 : opp0.rr;  //EG=(dump[0]>>5)&1 ;  
        opp1.sr = ((((u0 >> 21) & 1) != 0)) ? 0 : opp1.rr;  //EG=(dump[1]>>5)&1 ;  
        opp0.tl = (u0 >> 8) & 63;  //(dump[2])&63 ;  
        opp1.tl = 0;
        
        return voice;
    }
    
    
    
    
    // operations
    //--------------------------------------------------
    /** @private [internal use] reset all user tables */
    public function resetAllUserTables() : Void
    {
        var i : Int;
        for (i in 0...ENV_TABLE_MAX){
            if (_masterEnvelops[i] != null) {
                _masterEnvelops[i].free();
                _masterEnvelops[i] = null;
            }
        }
        for (i in 0...VOICE_MAX){
            _masterVoices[i] = null;
        }
    }
    
    
    /** Register envelop table.
     *  @param index table number refered by &#64;&#64;,na,np,nt,nf,_&#64;&#64;,_na,_np,_nt and _nf.
     *  @param table envelop table.
     */
    public static function registerMasterEnvelopTable(index : Int, table : SiMMLEnvelopTable) : Void
    {
        if (index >= 0 && index < ENV_TABLE_MAX)             instance._masterEnvelops[index] = table;
    }
    
    
    /** Register voice data.
     *  @param index voice parameter number refered by %6.
     *  @param voice voice.
     */
    public static function registerMasterVoice(index : Int, voice : SiMMLVoice) : Void
    {
        if (index >= 0 && index < VOICE_MAX)             instance._masterVoices[index] = voice;
    }
    
    
    /** Get Envelop table.
     *  @param index table number.
     */
    public function getEnvelopTable(index : Int) : SiMMLEnvelopTable
    {
        if (index < 0 || index >= ENV_TABLE_MAX) {
            return null;
        }
        if (_stencilEnvelops != null && (_stencilEnvelops[index] != null)) {
            return _stencilEnvelops[index];
        }
        return _masterEnvelops[index];
    }
    
    
    /** Get voice data.
     *  @param index voice parameter number.
     */
    public function getSiMMLVoice(index : Int) : SiMMLVoice
    {
        if (index < 0 || index >= VOICE_MAX) return null;
        if (_stencilVoices != null && _stencilVoices[index] != null) return _stencilVoices[index];
        return _masterVoices[index];
    }
    
    
    /** get 0th operators pgType number from moduleType, channelNum and toneNum. 
     *  @param moduleType Channel module type
     *  @param channelNum Channel number. For %2-11, this value is same as 1st argument of '_&#64;'.
     *  @param toneNum Tone number. Ussualy, this argument is used only in %0;PSG and %1;APU.
     *  @return pgType value, or -1 when moduleType == 6(FM) or 7(PCM).
     */
    public static function getPGType(moduleType : Int, channelNum : Int, toneNum : Int = -1) : Int
    {
        var ms : SiMMLChannelSetting = instance.channelModuleSetting[moduleType];
        
        if (ms._selectToneType == SiMMLChannelSetting.SELECT_TONE_NORMAL) {
            if (toneNum == -1 && channelNum >= 0 && channelNum < ms._voiceIndexTable.length)                 toneNum = ms._voiceIndexTable[channelNum];
            if (toneNum < 0 || toneNum >= ms._pgTypeList.length)                 toneNum = ms._initVoiceIndex;
            return ms._pgTypeList[toneNum];
        }
        
        return -1;
    }
    
    
    /** get 0th operators pgType number from moduleType, channelNum and toneNum. 
     *  @param moduleType Channel module type
     *  @param channelNum Channel number. For %2-11, this value is same as 1st argument of '_&#64;'.
     *  @param toneNum Tone number. Ussualy, this argument is used only in %0;PSG and %1;APU.
     *  @return pgType value, or -1 when moduleType == 6(FM) or 7(PCM).
     */
    public static function isSuitableForFMVoice(moduleType : Int) : Bool
    {
        return instance.channelModuleSetting[moduleType]._isSuitableForFMVoice;
    }
}


