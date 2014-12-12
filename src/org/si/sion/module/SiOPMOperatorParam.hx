//----------------------------------------------------------------------------------------------------
// SiOPM operator parameters
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module;


/** OPM Parameters. This is a member of SiOPMChannelParam. 
 *  @see org.si.sion.SiONVoice
 *  @see org.si.sion.module.SiOPMChannelParam
 */
class SiOPMOperatorParam
{
    public var mul(get, set) : Int;

    // variables
    //--------------------------------------------------
    /** [extension] Pulse generator type [0,511] */
    public var pgType : Int;
    /** [extension] Pitch table type [0,7] */
    public var ptType : Int;
    
    /** Attack rate [0,63] */
    public var ar : Int;
    /** Decay rate [0,63] */
    public var dr : Int;
    /** Sustain rate [0,63] */
    public var sr : Int;
    /** Release rate [0,63] */
    public var rr : Int;
    /** Sustain level [0,15] */
    public var sl : Int;
    /** [extension] Total level [0,127] */
    public var tl : Int;
    
    /** Key scaling rate [0,3] */
    public var ksr : Int;
    /** [extension] Key scaling level [0,3] */
    public var ksl : Int;
    
    /** [extension] Fine multiple [0,...] */
    public var fmul : Int;
    /** dt1 [0,7]  */
    public var dt1 : Int;
    /** detune */
    public var detune : Int;
    
    /** Amp modulation shift [0-3] */
    public var ams : Int;
    /** [extension] Initiail phase [0,255]. The value of 255 sets no phase reset. */
    public var phase : Int;
    /** [extension] Fixed pitch. 0 means pitch is not fixed. */
    public var fixedPitch : Int;
    
    /** mute */
    public var mute : Bool;
    /** SSG type envelop control */
    public var ssgec : Int;
    /** [extension] Frequency modulation level [0,7]. 5 is standard modulation. */
    public var modLevel : Int;
    /** envelop reset on attack */
    public var erst : Bool;
    
    
    /** multiple [0,15] */
    private function set_mul(m : Int) : Int {
        fmul = ((m != 0)) ? (m << 7) : 64;
        return m;
    }
    private function get_mul() : Int{
        return (fmul >> 7) & 15;
    }
    
    /** set pgType and ptType */
    public function setPGType(type : Int) : Void
    {
        pgType = type & 511;
        ptType = SiOPMTable.instance.getWaveTable(pgType).defaultPTType;
    }
    
    
    /** constructor */
    public function new()
    {
        initialize();
    }
    
    
    /** intialize all parameters. */
    public function initialize() : Void
    {
        pgType = SiOPMTable.PG_SINE;
        ptType = SiOPMTable.PT_OPM;
        ar = 63;
        dr = 0;
        sr = 0;
        rr = 63;
        sl = 0;
        tl = 0;
        ksr = 1;
        ksl = 0;
        fmul = 128;
        dt1 = 0;
        detune = 0;
        ams = 0;
        phase = 0;
        fixedPitch = 0;
        mute = false;
        ssgec = 0;
        modLevel = 5;
        erst = false;
    }
    
    
    /** copy all parameters. */
    public function copyFrom(org : SiOPMOperatorParam) : Void
    {
        pgType = org.pgType;
        ptType = org.ptType;
        ar = org.ar;
        dr = org.dr;
        sr = org.sr;
        rr = org.rr;
        sl = org.sl;
        tl = org.tl;
        ksr = org.ksr;
        ksl = org.ksl;
        fmul = org.fmul;
        dt1 = org.dt1;
        detune = org.detune;
        ams = org.ams;
        phase = org.phase;
        fixedPitch = org.fixedPitch;
        mute = org.mute;
        ssgec = org.ssgec;
        modLevel = org.modLevel;
        erst = org.erst;
    }
    
    
    /** all parameters in 1line. */
    public function toString() : String
    {
        var str : String = "SiOPMOperatorParam : ";
        str += Std.string(pgType) + "(";
        str += Std.string(ptType) + ") : ";
        str += Std.string(ar) + "/";
        str += Std.string(dr) + "/";
        str += Std.string(sr) + "/";
        str += Std.string(rr) + "/";
        str += Std.string(sl) + "/";
        str += Std.string(tl) + " : ";
        str += Std.string(ksr) + "/";
        str += Std.string(ksl) + " : ";
        str += Std.string(fmul) + "/";
        str += Std.string(dt1) + "/";
        str += Std.string(detune) + " : ";
        str += Std.string(ams) + "/";
        str += Std.string(phase) + "/";
        str += Std.string(fixedPitch) + " : ";
        str += Std.string(ssgec) + "/";
        str += Std.string(mute) + "/";
        str += Std.string(erst);
        return str;
    }
}


