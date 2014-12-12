//----------------------------------------------------------------------------------------------------
// SiMML data
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer;

import openfl.errors.Error;

import org.si.sion.module.SiOPMChannelParam;
import org.si.sion.module.SiOPMTable;
import org.si.sion.module.SiOPMWaveTable;
import org.si.sion.module.SiOPMWavePCMTable;
import org.si.sion.module.SiOPMWaveSamplerTable;
import org.si.sion.module.SiopmModuleInternal;
import org.si.sion.sequencer.base.MMLData;
import org.si.utils.SLLint;
import org.si.sion.namespaces.SionInternal;



/** SiMML data class. */
class SiMMLData extends MMLData
{
    public var voices(get, never) : Array<SiMMLVoice>;

    // variables
    //----------------------------------------
    /** envelope tables */
    public var envelopes : Array<SiMMLEnvelopTable>;
    
    /** wave tables */
    public var waveTables : Array<SiOPMWaveTable>;
    
    /** FM voice data */
    public var fmVoices : Array<SiMMLVoice>;
    
    /** pcm data (log-transformed) */
    public var pcmVoices : Array<SiMMLVoice>;
    
    /** wave data */
    public var samplerTables : Array<SiOPMWaveSamplerTable>;
    
    
    
    
    // properties
    //----------------------------------------
    /** [NOT RECOMMENDED] This property is for the compatibility of previous versions, please use fmVoices instead of this. @see #fmVoices */
    private function get_voices() : Array<SiMMLVoice>{return fmVoices;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor. */
    public function new()
    {
        super();
        envelopes = new Array<SiMMLEnvelopTable>();
        waveTables = new Array<SiOPMWaveTable>();
        fmVoices = new Array<SiMMLVoice>();
        pcmVoices = new Array<SiMMLVoice>();
        samplerTables = new Array<SiOPMWaveSamplerTable>();
        for (i in 0...SiOPMTable.SAMPLER_TABLE_MAX){
            samplerTables[i] = new SiOPMWaveSamplerTable();
        }
    }
    
    
    
    
    // operations
    //----------------------------------------
    /** Clear all parameters and free all sequence groups. */
    override public function clear() : Void
    {
        super.clear();
        
        var i : Int;
        var pcm : SiOPMWavePCMTable;
        for (i in 0...SiMMLTable.ENV_TABLE_MAX){envelopes[i] = null;
        }
        for (i in 0...SiMMLTable.VOICE_MAX){fmVoices[i] = null;
        }
        for (i in 0...SiOPMTable.WAVE_TABLE_MAX){
            if (waveTables[i] != null) {
                waveTables[i].free();
                waveTables[i] = null;
            }
        }
        for (i in 0...SiOPMTable.PCM_DATA_MAX){
            if (pcmVoices[i] != null) {
                pcm = try cast(pcmVoices[i].waveData, SiOPMWavePCMTable) catch(e:Dynamic) null;
                if (pcm != null) pcm._free();
                pcmVoices[i] = null;
            }
        }
        for (i in 0...SiOPMTable.SAMPLER_TABLE_MAX){
            samplerTables[i]._free();
        }
    }
    
    
    /** Set envelope table data refered by &#64;&#64;,na,np,nt,nf,_&#64;&#64;,_na,_np,_nt and _nf.
     *  @param index envelope table number.
     *  @param envelope envelope table.
     */
    public function setEnvelopTable(index : Int, envelope : SiMMLEnvelopTable) : Void
    {
        if (index >= 0 && index < SiMMLTable.ENV_TABLE_MAX)             envelopes[index] = envelope;
    }
    
    
    /** Set wave table data refered by %6.
     *  @param index wave table number.
     *  @param voice voice to register.
     */
    public function setVoice(index : Int, voice : SiMMLVoice) : Void
    {
        if (index >= 0 && index < SiMMLTable.VOICE_MAX) {
            if (!voice._isSuitableForFMVoice) throw errorNotGoodFMVoice();
            fmVoices[index] = voice;
        }
    }
    
    
    /** Set wave table data refered by %4.
     *  @param index wave table number.
     *  @param data Vector.&lt;Number&gt; wave shape data ranged from -1 to 1.
     *  @return created data instance
     */
    public function setWaveTable(index : Int, data : Array<Float>) : SiOPMWaveTable
    {
        index &= SiOPMTable.WAVE_TABLE_MAX - 1;
        var i : Int;
        var imax : Int = data.length;
        var table : Array<Int> = new Array<Int>();
        for (i in 0...imax) {
            table[i] = SiOPMTable.calcLogTableIndex(data[i]);
        }
        waveTables[index] = SiOPMWaveTable.alloc(table);
        return waveTables[index];
    }
    
    
    
    
    // internal function
    //--------------------------------------------------
    /** @private [internal] Get channel parameter */
    @:allow(org.si.sion.sequencer)
    private function _getSiOPMChannelParam(index : Int) : SiOPMChannelParam
    {
        var v : SiMMLVoice = new SiMMLVoice();
        v.channelParam = new SiOPMChannelParam();
        fmVoices[index] = v;
        return v.channelParam;
    }
    
    
    /** @private [internal] Get CPM SiMMLVoice */
    public function _getPCMVoice(index : Int) : SiMMLVoice
    {
        index &= (SiOPMTable.PCM_DATA_MAX - 1);
        if (pcmVoices[index] == null) {
            pcmVoices[index] = new SiMMLVoice();
            return pcmVoices[index]._newBlankPCMVoice(index);
        }
        return pcmVoices[index];
    }
    
    
    /** @private [internal] register all tables. called from SiMMLTrack._prepareBuffer(). */
    @:allow(org.si.sion.sequencer)
    private function _registerAllTables() : Void
    {
        /**/  // currently bank2,3 are not available
        SiOPMTable._instance.samplerTables[0].stencil = samplerTables[0];
        SiOPMTable._instance.samplerTables[1].stencil = samplerTables[1];
        SiOPMTable._instance._stencilCustomWaveTables = waveTables;
        SiOPMTable._instance._stencilPCMVoices = pcmVoices;
        SiMMLTable._instance._stencilEnvelops = envelopes;
        SiMMLTable._instance._stencilVoices = fmVoices;
    }
    
    
    
    
    // error
    //----------------------------------------
    private function errorNotGoodFMVoice() : Error{
        return new Error("SiONDriver error; Cannot register the voice.");
    }
}


