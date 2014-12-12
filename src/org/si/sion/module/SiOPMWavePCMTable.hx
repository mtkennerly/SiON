//----------------------------------------------------------------------------------------------------
// class for SiOPM PCM data
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module;

import openfl.errors.Error;

import org.si.sion.sequencer.SiMMLTable;
import org.si.sion.module.SiOPMTable;


/** PCM data class */
class SiOPMWavePCMTable extends SiOPMWaveBase
{
    // variables
    //----------------------------------------
    /** @private PCM wave data assign table for each note. */
    public var _table : Array<SiOPMWavePCMData>;
    /** @private volume table */
    public var _volumeTable : Array<Float>;
    /** @private pan table */
    public var _panTable : Array<Int>;
    
    
    
    
    // constructor
    //----------------------------------------
    /** Constructor */
    public function new()
    {
        super(SiMMLTable.MT_PCM);
        _volumeTable = new Array<Float>();
        _table = new Array<SiOPMWavePCMData>();
        _panTable = new Array<Int>();
        clear();
    }
    
    
    
    
    // oprations
    //----------------------------------------
    /** Clear all of the table.
     *  @param pcmData SiOPMWavePCMData to fill layer0's pcm.
     *  @return this instance
     */
    public function clear(pcmData : SiOPMWavePCMData = null) : SiOPMWavePCMTable
    {
        var i : Int;
        for (i in 0...SiOPMTable.NOTE_TABLE_SIZE){
            _table[i] = pcmData;
            _volumeTable[i] = 1;
            _panTable[i] = 0;
        }
        return this;
    }
    
    
    /** Set sample data.
     *  @param pcmData assignee SiOPMWavePCMData
     *  @param keyRangeFrom Assigning key range starts from
     *  @param keyRangeTo Assigning key range ends at. -1 to set only at the key of argument "keyRangeFrom".
     *  @return assigned PCM data (same as pcmData passed as the 1st argument.)
     */
    public function setSample(pcmData : SiOPMWavePCMData, keyRangeFrom : Int = 0, keyRangeTo : Int = 127) : SiOPMWavePCMData
    {
        if (keyRangeFrom < 0)             keyRangeFrom = 0;
        if (keyRangeTo > 127)             keyRangeTo = 127;
        if (keyRangeTo == -1)             keyRangeTo = keyRangeFrom;
        if (keyRangeFrom > 127 || keyRangeTo < 0 || keyRangeTo < keyRangeFrom) throw new Error("SiOPMWavePCMTable error; Invalid key range");
        for (i in keyRangeFrom...keyRangeTo + 1) {
            _table[i] = pcmData;
        }
        return pcmData;
    }
    
    
    /** update key scale volume
     *  @param centerNoteNumber note number of volume changing center
     *  @param keyRange key range of volume changing notes
     *  @param volumeRange range of volume changing (128 for full volouming)
     *  @return this instance
     */
    public function setKeyScaleVolume(centerNoteNumber : Int = 64, keyRange : Float = 0, volumeRange : Float = 0) : SiOPMWavePCMTable
    {
        volumeRange *= 0.0078125;
        var imin : Int = centerNoteNumber - Math.floor(keyRange * 0.5);
        var imax : Int = centerNoteNumber + Math.floor(keyRange * 0.5);
        var v : Float;
        var dv : Float = ((keyRange == 0)) ? volumeRange : (volumeRange / keyRange);
        var i : Int;
        if (volumeRange > 0) {
            v = 1 - volumeRange;
            i = 0;
            while (i < imin){
                _volumeTable[i] = v;
                i++;
            }

            while (i < imax) {
                _volumeTable[i] = v;
                i++;
                v += dv;
            }

            while (i < SiOPMTable.NOTE_TABLE_SIZE) {
                _volumeTable[i] = 1;
                i++;
            }
        }
        else {
            v = 1;
            i = 0;
            while (i < imin) {
                _volumeTable[i] = 1;
                i++;
            }
            while (i < imax) {
                _volumeTable[i] = v;
                i++;
                v += dv;
            }
            v = 1 + volumeRange;
            while (i < SiOPMTable.NOTE_TABLE_SIZE) {
                _volumeTable[i] = v;
                i++;
            }
        }
        return this;
    }
    
    
    /** update key scale panning
     *  @param centerNoteNumber note number of panning center
     *  @param keyRange key range of panning notes
     *  @param panWidth panning width for all of key range (128 for full panning)
     *  @return this instance
     */
    public function setKeyScalePan(centerNoteNumber : Int = 64, keyRange : Float = 0, panWidth : Float = 0) : SiOPMWavePCMTable
    {
        var imin : Int = centerNoteNumber - Math.floor(keyRange * 0.5);
        var imax : Int = centerNoteNumber + Math.floor(keyRange * 0.5);
        var p : Float = -panWidth * 0.5;
        var dp : Float = ((keyRange == 0)) ? panWidth : (panWidth / keyRange);
        var i : Int;
        i = 0;
        while (i < imin) {
            _panTable[i] = Math.floor(p);
            i++;
        }
        while (i < imax){
            _panTable[i] = Math.floor(p);
            i++;
            p += dp;
        }
        p=Math.floor(panWidth * 0.5);
        while (i < SiOPMTable.NOTE_TABLE_SIZE) {
            _panTable[i] = Math.floor(p);
            i++;
        }
        return this;
    }
    
    
    /** @private [internal use] free all */
    public function _free() : Void
    {
        for (i in 0...SiOPMTable.NOTE_TABLE_SIZE){
            //if (_table[i]) _table[i].free();
            _table[i] = null;
        }
    }
}


