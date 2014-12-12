//----------------------------------------------------------------------------------------------------
// Stream buffer class
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.module;

import openfl.utils.ByteArray;
import org.si.utils.SLLint;


/** Stream buffer class */
class SiOPMStream
{
    // variables
    //--------------------------------------------------
    /** number of channels */
    public var channels : Int = 2;
    /** stream buffer */
    public var buffer : Array<Float> = new Array<Float>();
    
    // coefficient of volume/panning
    private var _panTable : Array<Float>;
    private var _i2n : Float;
    
    
    
    
    // constructor
    //--------------------------------------------------
    /** constructor */
    public function new()
    {
        var st : SiOPMTable = SiOPMTable.instance;
        _panTable = st.panTable;
        _i2n = st.i2n;
    }
    
    
    
    
    // operation
    //--------------------------------------------------
    /** clear buffer */
    public function clear() : Void
    {
        var i : Int;
        var imax : Int = buffer.length;
        for (i in 0...imax){
            buffer[i] = 0;
        }
    }
    
    
    /** limit buffered signals between -1 and 1 */
    public function limit() : Void
    {
        var n : Float;
        var i : Int;
        var imax : Int = buffer.length;
        for (i in 0...imax){
            n = buffer[i];
            if (n < -1)                 buffer[i] = -1
            else if (n > 1)                 buffer[i] = 1;
        }
    }
    
    
    /** Quantize buffer by bit rate. */
    public function quantize(bitRate : Int) : Void
    {
        var i : Int;
        var imax : Int = buffer.length;
        var r : Float = 1 << bitRate;
        var ir : Float = 2 / r;
        for (i in 0...imax){
            buffer[i] = (Math.round(buffer[i] * r) >> 1) * ir;
        }
    }
    
    
    /** write buffer by org.si.utils.SLLint */
    public function write(pointer : SLLint, start : Int, len : Int, vol : Float, pan : Int) : Void
    {
        var i : Int;
        var n : Float;
        var imax : Int = (start + len) << 1;
        vol *= _i2n;
        if (channels == 2) {
            // stereo
            var volL : Float = _panTable[128 - pan] * vol;
            var volR : Float = _panTable[pan] * vol;
            i = start << 1;
            while (i < imax){
                n = pointer.i;
                buffer[i] += n * volL;i++;
                buffer[i] += n * volR;i++;
                pointer = pointer.next;
            }
        }
        else 
        if (channels == 1) {
            // monoral
            i = start << 1;
            while (i < imax){
                n = pointer.i * vol;
                buffer[i] += n;i++;
                buffer[i] += n;i++;
                pointer = pointer.next;
            }
        }
    }
    
    
    /** write stereo buffer by 2 pipes */
    public function writeStereo(pointerL : SLLint, pointerR : SLLint, start : Int, len : Int, vol : Float, pan : Int) : Void
    {
        var i : Int;
        var n : Float;
        var imax : Int = (start + len) << 1;
        vol *= _i2n;
        
        if (channels == 2) {
            // stereo
            var volL : Float = _panTable[128 - pan] * vol;
            var volR : Float = _panTable[pan] * vol;
            i = start << 1;
            while (i < imax){
                buffer[i] += pointerL.i * volL; i++;
                buffer[i] += pointerR.i * volR; i++;
                pointerL = pointerL.next;
                pointerR = pointerR.next;
            }
        }
        else 
        if (channels == 1) {
            // monoral
            vol *= 0.5;
            i = start << 1;
            while (i < imax){
                n = pointerL.i + pointerR.i * vol;
                buffer[i] += n;i++;
                buffer[i] += n;i++;
                pointerL = pointerL.next;
                pointerR = pointerR.next;
            }
        }
    }
    
    
    /** write buffer by Vector.&lt;Number&gt; */
    public function writeVectorNumber(pointer : Array<Float>, startPointer : Int, startBuffer : Int, len : Int, vol : Float, pan : Int, sampleChannelCount : Int) : Void
    {
        var i : Int = 0;
        var j : Int;
        var n : Float;
        var jmax : Int;
        var volL : Float;
        var volR : Float;
        
        if (channels == 2) {
            if (sampleChannelCount == 2) {
                // stereo data to stereo buffer
                volL = _panTable[128 - pan] * vol;
                volR = _panTable[pan] * vol;
                jmax = (startPointer + len) << 1;
                j = startPointer << 1;
                i = startBuffer << 1;
                while (j < jmax){
                    buffer[i] += pointer[j] * volL;j++;i++;
                    buffer[i] += pointer[j] * volR;j++;i++;
                }
            }
            else {
                // monoral data to stereo buffer
                volL = _panTable[128 - pan] * vol * 0.707;
                volR = _panTable[pan] * vol * 0.707;
                jmax = startPointer + len;
                j=startPointer;
                while (j < jmax){
                    n = pointer[j];
                    buffer[i] += n * volL;i++;
                    buffer[i] += n * volR;i++;
                    j++;
                }
            }
        }
        else if (channels == 1) {
            if (sampleChannelCount == 2) {
                // stereo data to monoral buffer
                jmax = (startPointer + len) << 1;
                vol *= 0.5;
                j = startPointer << 1;
                i = startBuffer << 1;
                while (j < jmax){
                    n = pointer[j];j++;
                    n += pointer[j];j++;
                    n *= vol;
                    buffer[i] += n;i++;
                    buffer[i] += n;i++;
                }
            }
            else {
                // monoral data to monoral buffer
                jmax = startPointer + len;
                i=startBuffer<<1;
                for (j in startPointer...jmax){
                    n = pointer[j] * vol;
                    buffer[i] += n;i++;
                    buffer[i] += n;i++;
                }
            }
        }
    }
    
    
    /** write buffer by ByteArray (stereo only). */
    public function writeByteArray(bytes : ByteArray, start : Int, len : Int, vol : Float) : Void
    {
        var i : Int;
        var n : Float;
        var imax : Int = (start + len) << 1;
        var initPosition : Int = bytes.position;
        
        if (channels == 2) {
            for (i in 0...imax){
                buffer[i] += bytes.readFloat() * vol;
            }
        }
        else 
        if (channels == 1) {
            // stereo data to monoral buffer
            vol *= 0.6;
            i = start << 1;
            while (i < imax){
                n = (bytes.readFloat() + bytes.readFloat()) * vol;
                buffer[i] += n;i++;
                buffer[i] += n;i++;
            }
        }
        
        bytes.position = initPosition;
    }
}


