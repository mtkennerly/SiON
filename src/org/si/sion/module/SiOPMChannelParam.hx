//----------------------------------------------------------------------------------------------------
// SiOPM channel parameters
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module;

import openfl.errors.Error;

import org.si.sion.sequencer.base.MMLSequence;


/** SiOPM Channel Parameters. This is a member of SiONVoice.
 *  @see org.si.sion.SiONVoice
 *  @see org.si.sion.module.SiOPMOperatorParam
 */
class SiOPMChannelParam
{
    public var lfoFrame(get, set) : Int;

    // variables 11 parameters
    //--------------------------------------------------
    /** operator params x4 */
    public var operatorParam : Array<SiOPMOperatorParam>;
    
    /** operator count [0,5]. 0 ignores all operators params. 5 sets analog like mode. */
    public var opeCount : Int;
    /** algorism [0,15] */
    public var alg : Int;
    /** feedback [0,7] */
    public var fb : Int;
    /** feedback connection [0,3] */
    public var fbc : Int;
    /** envelop frequency ratio */
    public var fratio : Int;
    /** LFO wave shape */
    public var lfoWaveShape : Int;
    /** LFO frequency */
    public var lfoFreqStep : Int;
    
    /** amplitude modulation depth */
    public var amd : Int;
    /** pitch modulation depth */
    public var pmd : Int;
    /** [extention] master volume [0,1] */
    public var volumes : Array<Float>;
    /** [extention] panning */
    public var pan : Int;
    
    /** filter type */
    public var filterType : Int;
    /** filter cutoff */
    public var cutoff : Int;
    /** filter resonance */
    public var resonance : Int;
    /** filter attack rate */
    public var far : Int;
    /** filter decay rate 1 */
    public var fdr1 : Int;
    /** filter decay rate 2 */
    public var fdr2 : Int;
    /** filter release rate */
    public var frr : Int;
    /** filter decay offset 1 */
    public var fdc1 : Int;
    /** filter decay offset 2 */
    public var fdc2 : Int;
    /** filter sustain offset */
    public var fsc : Int;
    /** filter release offset */
    public var frc : Int;
    
    /** Initializing sequence */
    public var initSequence : MMLSequence;
    
    
    /** LFO cycle time */
    private function set_lfoFrame(fps : Int) : Int
    {
        lfoFreqStep = Math.floor(SiOPMTable.LFO_TIMER_INITIAL / (fps * 2.882352941176471));
        return fps;
    }
    private function get_lfoFrame() : Int
    {
        return Math.floor(SiOPMTable.LFO_TIMER_INITIAL * 0.346938775510204 / lfoFreqStep);
    }
    
    
    /** constructor */
    public function new()
    {
        initSequence = new MMLSequence();
        volumes = new Array<Float>();
        
        operatorParam = new Array<SiOPMOperatorParam>();
        for (i in 0...4){
            operatorParam[i] = new SiOPMOperatorParam();
        }
        
        initialize();
    }
    
    
    /** initializer */
    public function initialize() : SiOPMChannelParam
    {
        var i : Int;
        
        opeCount = 1;
        
        alg = 0;
        fb = 0;
        fbc = 0;
        lfoWaveShape = SiOPMTable.LFO_WAVE_TRIANGLE;
        lfoFreqStep = 12126;  // 12126 = 30frame/100fratio  
        amd = 0;
        pmd = 0;
        fratio = 100;
        for (i in 1...SiOPMModule.STREAM_SEND_SIZE){
            volumes[i] = 0;
        }
        volumes[0] = 0.5;
        pan = 64;
        
        filterType = 0;
        cutoff = 128;
        resonance = 0;
        far = 0;
        fdr1 = 0;
        fdr2 = 0;
        frr = 0;
        fdc1 = 128;
        fdc2 = 64;
        fsc = 32;
        frc = 128;
        
        for (i in 0...4){
            operatorParam[i].initialize();
        }
        
        initSequence.free();
        
        return this;
    }
    
    
    /** copier */
    public function copyFrom(org : SiOPMChannelParam) : SiOPMChannelParam
    {
        var i : Int;
        
        opeCount = org.opeCount;
        
        alg = org.alg;
        fb = org.fb;
        fbc = org.fbc;
        lfoWaveShape = org.lfoWaveShape;
        lfoFreqStep = org.lfoFreqStep;
        amd = org.amd;
        pmd = org.pmd;
        fratio = org.fratio;
        for (i in 0...SiOPMModule.STREAM_SEND_SIZE) {
            volumes[i] = org.volumes[i];
        }
        pan = org.pan;
        
        filterType = org.filterType;
        cutoff = org.cutoff;
        resonance = org.resonance;
        far = org.far;
        fdr1 = org.fdr1;
        fdr2 = org.fdr2;
        frr = org.frr;
        fdc1 = org.fdc1;
        fdc2 = org.fdc2;
        fsc = org.fsc;
        frc = org.frc;
        
        for (i in 0...4) {
            operatorParam[i].copyFrom(org.operatorParam[i]);
        }
        
        initSequence.free();
        
        return this;
    }
    
    
    /** information */
    public function toString() : String
    {
        var str : String = "SiOPMChannelParam : opeCount=";

        // Originally named $ in AS3
        function dlr(p : String, i : Int) : Void {
            str += "  " + p + "=" + Std.string(i) + "\n";
        };

        // Originally named $2 in AS3
        function dlr2(p : String, i : Int, q : String, j : Int) : Void {
            str += "  " + p + "=" + Std.string(i) + " / " + q + "=" + Std.string(j) + "\n";
        };

        str += Std.string(opeCount) + "\n";
        dlr("freq.ratio", fratio);
        dlr("alg", alg);
        dlr2("fb ", fb, "fbc", fbc);
        dlr2("lws", lfoWaveShape, "lfq", Math.floor(SiOPMTable.LFO_TIMER_INITIAL * 0.005782313 / lfoFreqStep));
        dlr2("amd", amd, "pmd", pmd);
        dlr2("vol", Math.floor(volumes[0]), "pan", pan - 64);
        dlr("filter type", filterType);
        dlr2("co", cutoff, "res", resonance);
        str += "fenv=" + Std.string(far) + "/" + Std.string(fdr1) + "/" + Std.string(fdr2) + "/" + Std.string(frr) + "\n";
        str += "feco=" + Std.string(fdc1) + "/" + Std.string(fdc2) + "/" + Std.string(fsc) + "/" + Std.string(frc) + "\n";
        for (i in 0...opeCount){
            str += Std.string(operatorParam[i]) + "\n";
        }
        return str;
    }
    
    
    /** Set voice by OPM's register value
     *  @param channel pseudo OPM channel number
     *  @param addr register address
     *  @param data register data
     */
    public function setByOPMRegister(channel : Int, addr : Int, data : Int) : SiOPMChannelParam
    {
        var v : Int;
        var pms : Int;
        var ams : Int;
        var opp : SiOPMOperatorParam;
        
        if (addr < 0x20) {  // Module parameter  
            switch (addr)
            {
                case 15:  // NOIZE:7 FREQ:4-0 for channel#7  
                if (channel == 7 && ((data & 128) != 0)) {
                    operatorParam[3].pgType = SiOPMTable.PG_NOISE_PULSE;
                    operatorParam[3].ptType = SiOPMTable.PT_OPM_NOISE;
                    operatorParam[3].fixedPitch = ((data & 31) << 6) + 2048;
                }
                case 24:  // LFO FREQ:7-0 for all 8 channels  
                lfoFreqStep = SiOPMTable.instance.lfo_timerSteps[data];
                case 25:  // A(0)/P(1):7 DEPTH:6-0 for all 8 channels  
                if ((data & 128) != 0) {
                    pmd = data & 127;
                }
                else {
                    amd = data & 127;
                }
                case 27:  // LFO WS:10 for all 8 channels  
                lfoWaveShape = data & 3;
            }
        }
        else {
            if (channel == (addr & 7)) {
                if (addr < 0x40) {
                    // Channel parameter
                    var _sw0_ = ((addr - 0x20) >> 3);                    

                    switch (_sw0_)
                    {
                        case 0:  // L:7 R:6 FB:5-3 ALG:2-0  
                            v = data >> 6;
                            volumes[0] = ((v != 0)) ? 0.5 : 0;
                            pan = ((v == 1)) ? 128 : ((v == 2)) ? 0 : 64;
                            fb = (data >> 3) & 7;
                            alg = (data) & 7;
                        // Haxe doesn't allow empty cases, but note that these were here in the original AS3
                        //case 1:  // KC:6-0
                        //    break;
                        //case 2:  // KF:6-0
                        //    break;
                        case 3:  // PMS:6-4 AMS:10
                            pms = (data >> 4) & 7;
                            ams = (data) & 3;
                            //pmd = (pms<6) ? (_pmd >> (6-pms)) : (_pmd << (pms-5));
                            //amd = (ams>0) ? (_amd << (ams-1)) : 0;
                    }
                }
                else {
                    // Operator parameter
                    opp = operatorParam[[3, 1, 2, 0][(addr >> 3) & 3]];  // [0,2,1,3]?  
                    var _sw1_ = ((addr - 0x40) >> 5);                    

                    switch (_sw1_)
                    {
                        case 0:  // DT1:6-4 MUL:3-0  
                            opp.dt1 = (data >> 4) & 7;
                            opp.mul = (data) & 15;
                        case 1:  // TL:6-0  
                            opp.tl = data & 127;
                        case 2:  // KS:76 AR:4-0  
                            opp.ksr = (data >> 6) & 3;
                            opp.ar = (data & 31) << 1;
                        case 3:  // AMS:7 DR:4-0  
                            opp.ams = ((data >> 7) & 1) << 1;
                            opp.dr = (data & 31) << 1;
                        case 4:  // DT2:76 SR:4-0  
                            opp.detune = [0, 384, 500, 608][(data >> 6) & 3];
                            opp.sr = (data & 31) << 1;
                        case 5:  // SL:7-4 RR:3-0  
                            opp.sl = (data >> 4) & 15;
                            opp.rr = (data & 15) << 2;
                    }
                }
            }
        }
        return this;
    }
    
    
    /** Set voice by OPNA's register value */
    public function setByOPNARegister(addr : Int, data : Int) : SiOPMChannelParam{
        throw new Error("SiOPMChannelParam.setByOPNARegister(): Sorry, this function is not available.");
        return this;
    }
}


