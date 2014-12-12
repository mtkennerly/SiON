//----------------------------------------------------------------------------------------------------
// SiON Utilities
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion.utils;

import openfl.media.*;
import openfl.utils.ByteArray;
//import mx.utils.Base64Decoder;
import org.si.utils.SLLNumber;
import org.si.sion.module.SiOPMTable;
import org.si.sion.module.SiOPMWaveTable;


/** Utilities for SiON */
class SiONUtil
{
    // PCM data transformation (for PCM Data %7)
    //--------------------------------------------------
    /** logarithmical transformation of Sound data. The transformed datas type is Vector.&lt;int&gt;. This data is used for PCM sound module (%7).
     *  @param src The Sound data transforming from. 
     *  @param dst The Vector.&lt;int&gt; instance to put result. You can pass null to create new Vector.&lt;int&gt; inside.
     *  @param dstChannelCount channel count of destination samples. 0 sets same with srcChannelCount
     *  @param sampleMax The maximum sample count to transform. The length of transformed data is limited by this value.
     *  @param startPosition Start position to extract. -1 to set extraction continuously.
     *  @param maximize maximize input sample
     *  @return logarithmical transformed data.
     */
    public static function logTrans(data : Sound, dst : Array<Int> = null, dstChannelCount : Int = 2,
                                    sampleMax : Int = 1048576, startPosition : Int = 0, maximize : Bool = true) : Array<Int>
    {
#if EXTRACT_ENABLED
        // openfl doesn't implement Sound.extract(), so we don't have any way to get this data.
        var wave : ByteArray = new ByteArray();
        var samples : Int = data.extract(wave, sampleMax, startPosition);
        return logTransByteArray(wave, dst, dstChannelCount, maximize);
#else
        trace('***** WARNING!!! Unimplemented logTrans() called--empty sound data returned!!');
        return new Array<Int>();
#end
    }
    
    
    /** logarithmical transformation of Vector.&lt;Number&gt; wave data. The transformed datas type is Vector.&lt;int&gt;. This data is used for PCM sound module (%7).
     *  @param src The Vector.&lt;Number&gt; wave data transforming from. This ussualy comes from SiONDriver.render().
     *  @param srcChannelCount channel count of source samples.
     *  @param dst The Vector.&lt;int&gt; instance to put result. You can pass null to create new Vector.&lt;int&gt; inside.
     *  @param dstChannelCount channel count of destination samples. 0 sets same with srcChannelCount
     *  @return logarithmical transformed data.
     */
    public static function logTransVector(src : Array<Float>, srcChannelCount : Int = 2, dst : Array<Int> = null, dstChannelCount : Int = 0, maximize : Bool = true) : Array<Int>
    {
        var i : Int;
        var j : Int = 0;
        var n : Float;
        var imax : Int;
        var logmax : Int = SiOPMTable.LOG_TABLE_BOTTOM;
        if (dst == null) {
            dst = new Array<Int>();
        }
        else {
            while (dst.length > 0) dst.pop();
        }
        if (srcChannelCount == dstChannelCount || dstChannelCount == 0) {
            imax = src.length;
            for (i in 0...imax) {
                dst[i] = SiOPMTable.calcLogTableIndex(src[i]);
                if (dst[i] < logmax) logmax = dst[i];
            }
        }
        else 
        if (srcChannelCount == 2) {  // dstChannelCount = 1  
            imax = src.length >> 1;
            for (i in 0...imax) {
                n = src[j];j++;
                n += src[j];j++;
                dst[i] = SiOPMTable.calcLogTableIndex(n * 0.5);
                if (dst[i] < logmax) logmax = dst[i];
            }
        }
        else {  // srcChannelCount=1 > dstChannelCount=2  
            imax = src.length;
            i = 0;
            j = 0;
            while (i < imax){
                dst[j + 1] = dst[j] = SiOPMTable.calcLogTableIndex(src[i]);
                if (dst[j] < logmax) logmax = dst[j];
                i++;
                j += 2;
            }
        }
        if (maximize && logmax > 1) _amplifyLogData(dst, logmax);
        return dst;
    }
    
    
    /** logarithmical transformation of ByteArray wave data. The transformed datas type is Vector.&lt;int&gt;. This data is used for PCM sound module (%7).
     *  @param src The ByteArray wave data transforming from. This is ussualy from Sound.extract().
     *  @param dst The Vector.&lt;int&gt; instance to put result. You can pass null to create new Vector.&lt;int&gt; inside.
     *  @param dstChannelCount channel count of destination samples. 0 sets same with srcChannelCount
     *  @return logarithmical transformed data.
     */
    public static function logTransByteArray(src : ByteArray, dst : Array<Int> = null, dstChannelCount : Int = 2, maximize : Bool = true) : Array<Int>
    {
        var i : Int;
        var imax : Int;
        var logmax : Int = SiOPMTable.LOG_TABLE_BOTTOM;
        
        src.position = 0;
        if (dstChannelCount == 2) {
            imax = src.length >> 2;
            if (dst == null) {
                dst = new Array<Int>();
            }
            else {
                while (dst.length > 0) dst.pop();
            }
            for (i in 0...imax){
                dst[i] = SiOPMTable.calcLogTableIndex(src.readFloat());
                if (dst[i] < logmax) logmax = dst[i];
            }
        }
        else {
            imax = src.length >> 3;
            if (dst == null) {
                dst = new Array<Int>();
            }
            else {
                while (dst.length > 0) dst.pop();
            }
            for (i in 0...imax) {
                dst[i] = SiOPMTable.calcLogTableIndex((src.readFloat() + src.readFloat()) * 0.5);
                if (dst[i] < logmax) logmax = dst[i];
            }
        }
        
        if (maximize && logmax > 1) _amplifyLogData(dst, logmax);
        return dst;
    }
    
    
    // amplify log data
    private static function _amplifyLogData(src : Array<Int>, gain : Int) : Void
    {
        var i : Int;
        var imax : Int = src.length;
        gain &= ~1;
        for (i in 0...imax){
            src[i] -= gain;
        }
    }
    
    
    
    
    
    // wave data
    //--------------------------------------------------
    /** put Sound.extract() result into Vector.&lt;Number&gt;. This data is used for sampler module (%10).
     *  @param src The Sound data extracting from. 
     *  @param dst The Vector.&lt;Number&gt; instance to put result. You can pass null to create new Vector.&lt;Number&gt; inside.
     *  @param dstChannelCount channel count of extracted data. 1 for monoral, 2 for stereo.
     *  @param length The maximum sample count to extract. The length of returning vector is limited by this value.
     *  @param startPosition Start position to extract. -1 to set extraction continuously.
     *  @return extracted data.
     */
    public static function extract(src : Sound, dst : Array<Float> = null, dstChannelCount : Int = 1,
                                   length : Int = 1048576, startPosition : Int = -1) : Array<Float>
    {
#if EXTRACT_ENABLED
        var wave : ByteArray = new ByteArray();
        var i : Int;
        var imax : Int;
        src.extract(wave, length, startPosition);
        if (dst == null)             dst = new Array<Float>();
        wave.position = 0;
        
        if (dstChannelCount == 2) {
            // stereo
            imax = wave.length >> 2;
            dst.length = imax;
            for (imax){
                dst[i] = wave.readFloat();
            }
        }
        else {
            // monoral
            imax = wave.length >> 3;
            dst.length = imax;
            for (imax){
                dst[i] = (wave.readFloat() + wave.readFloat()) * 0.6;
            }
        }
        return dst;
#else
        trace('***** WARNING: Unimplemented function extract() called. Empty sound data returned!!');
        return new Array<Float>();
#end
    }
    
    
    /** extract 2a03's DPCM data.<br/>
     * DPCM frequency table = [
     * 0=k14o2e,
     * 1=k18o2f+,
     * 2=k13o2g+,
     * 3=k16o2a,
     * 4=k13o2b,
     * 5=k16o3c+,
     * 6=k17o3d+,
     * 7=k14o3e,
     * 8=k18o3f+,
     * 9=k16o3a,
     * 10=k20o3b,
     * 11=k7o4c+,
     * 12=k24o4e,
     * 13=k13o4g+,
     * 14=k5o4b,
     * 15=k4o5e]
     *  @param src The DPCM ByteArray data extracting from.
     *  @param initValue initial value of $4011.
     *  @param dst The Vector.&lt;Number&gt; instance to put result. You can pass null to create new Vector.&lt;Number&gt; inside.
     *  @param dstChannelCount channel count of extracted data. 1 for monoral, 2 for stereo.
     *  @return extracted data.
     */
    public static function extractDPCM(src : ByteArray, initValue : Int = 0, dst : Array<Float> = null, dstChannelCount : Int = 1) : Array<Float>
    {
        var data : Int;
        var i : Int;
        var imax : Int;
        var j : Int;
        var sample : Float;
        var output : Int;
        
        imax = src.length * dstChannelCount * 8;
        if (dst == null) {
            dst = new Array<Float>();
        }
        else {
            while (dst.length > 0) dst.pop();
        }

        output = initValue;
        src.position = 0;
        i = 0;
        while (i < imax){
            data = src.readUnsignedByte();
            j = 7;
            while (j >= 0){
                if (((data >> j) & 1) != 0) {
                    if (output < 126) {
                        output += 2;
                    }
                }
                else if (output > 1) {
                    output -= 2;
                }
                sample = (output - 64) * 0.015625;
                dst[i] = sample;i++;
                if (dstChannelCount == 2) {
                    dst[i] = sample;i++;
                }
                --j;
            }
        }
        
        return dst;
    }
    
    
    /** extract ADPCM data (YM2151). this algorism is from x68ksound.dll's source code.
     *  _freqTable:Array = [26, 31, 38, 43, 50];
     *  @param src The ADPCM ByteArray data extracting from. 
     *  @param dst The Vector.&lt;Number&gt; instance to put result. You can pass null to create new Vector.&lt;Number&gt; inside.
     *  @param dstChannelCount channel count of extracted data. 1 for monoral, 2 for stereo.
     *  @return extracted data.
     */
    public static function extractYM2151ADPCM(src : ByteArray, dst : Array<Float> = null, dstChannelCount : Int = 1) : Array<Float>
    {
        var data : Int;
        var r : Int;
        var i : Int;
        var imax : Int;
        var pcm : Int = 0;
        var sample : Float;
        var InpPcm : Int = 0;
        var InpPcm_prev : Int = 0;
        var scale : Int = 0;
        var output : Int = 0;
        
        // chaging ratio table
        var crTable : Array<Int> = [1, 3, 5, 7, 9, 11, 13, 15, -1, -3, -5, -7, -9, -11, -13, -15];
        // from x68ksound.dll source
        var dltLTBL : Array<Int> = [16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45, 50, 55, 60, 66, 
                73, 80, 88, 97, 107, 118, 130, 143, 157, 173, 190, 209, 230, 253, 279, 307, 
                337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963, 1060, 1166, 1282, 1411, 1552];
        var DCT : Array<Int> = [-1, -1, -1, -1, 2, 4, 6, 8, -1, -1, -1, -1, 2, 4, 6, 8];
        
        imax = src.length * dstChannelCount * 2;
        if (dst == null) {
            dst = new Array<Float>();
        }
        else {
            while (dst.length > 0) dst.pop();
        }

        i = 0;
        while (i < imax){
            data = src.readUnsignedByte();
            
            r = data & 0x0f;
            pcm += (dltLTBL[scale] * crTable[r]) >> 3;
            scale += DCT[r];
            if (pcm < -2048)                 pcm = -2048
            else if (pcm > 2047)                 pcm = 2047;
            if (scale < 0)                 scale = 0
            else if (scale > 48)                 scale = 48;
            InpPcm = (pcm & 0xfffffffc) << 8;
            output = ((InpPcm << 9) - (InpPcm_prev << 9) + 459 * output) >> 9;
            InpPcm_prev = InpPcm;
            sample = output * 0.0000019073486328125;
            dst[i] = sample;i++;
            if (dstChannelCount == 2) {
                dst[i] = sample;i++;
            }
            
            r = (data >> 4) & 0x0f;
            pcm += (dltLTBL[scale] * crTable[r]) >> 3;
            scale += DCT[r];
            if (pcm < -2048)                 pcm = -2048
            else if (pcm > 2047)                 pcm = 2047;
            if (scale < 0)                 scale = 0
            else if (scale > 48)                 scale = 48;
            InpPcm = (pcm & 0xfffffffc) << 8;
            output = ((InpPcm << 9) - (InpPcm_prev << 9) + 459 * output) >> 9;
            InpPcm_prev = InpPcm;
            sample = output * 0.0000019073486328125;
            dst[i] = sample;i++;
            if (dstChannelCount == 2) {dst[i] = sample;i++;
            }
        }
        
        return dst;
    }
    
    
    /** extract ADPCM data (YM2608)
     *  @param src The ADPCM ByteArray data extracting from. 
     *  @param dst The Vector.&lt;Number&gt; instance to put result. You can pass null to create new Vector.&lt;Number&gt; inside.
     *  @param dstChannelCount channel count of extracted data. 1 for monoral, 2 for stereo.
     *  @return extracted data.
     */
    public static function extractYM2608ADPCM(src : ByteArray, dst : Array<Float> = null, dstChannelCount : Int = 1) : Array<Float>
    {
        var data : Int;
        var r0 : Int;
        var r1 : Int;
        var i : Int;
        var imax : Int;
        var sample : Float;
        var predRate : Int = 127;
        var output : Int = 0;
        
        // chaging ratio table
        var crTable : Array<Int> = [1, 3, 5, 7, 9, 11, 13, 15, -1, -3, -5, -7, -9, -11, -13, -15];
        // prediction updating table
        var puTable : Array<Int> = [57, 57, 57, 57, 77, 102, 128, 153, 57, 57, 57, 57, 77, 102, 128, 153];
        
        imax = src.length * dstChannelCount * 2;
        if (dst == null) {
            dst = new Array<Float>();
        }
        else {
            while (dst.length > 0) dst.pop();
        }

        i = 0;
        while (i < imax) {
            data = src.readUnsignedByte();
            r0 = data & 0x0f;
            r1 = (data >> 4) & 0x0f;
            
            predRate *= crTable[r0];
            predRate >>= 3;
            output += predRate;
            sample = output * 0.000030517578125;
            dst[i] = sample;i++;
            if (dstChannelCount == 2) {
                dst[i] = sample;i++;
            }
            predRate *= puTable[r0];
            predRate >>= 6;
            if (predRate > 0) {
                if (predRate < 127) predRate = 127
                else if (predRate > 24576) predRate = 24576;
            }
            else {
                if (predRate > -127) predRate = -127
                else if (predRate < -24576) predRate = -24576;
            }
            
            predRate *= crTable[r1];
            predRate >>= 3;
            output += predRate;
            sample = output * 0.000030517578125;
            dst[i] = sample;i++;
            if (dstChannelCount == 2) {dst[i] = sample;i++;
            }
            predRate *= puTable[r1];
            predRate >>= 6;
            if (predRate > 0) {
                if (predRate < 127)                     predRate = 127
                else if (predRate > 24576)                     predRate = 24576;
            }
            else {
                if (predRate > -127)                     predRate = -127
                else if (predRate < -24576)                     predRate = -24576;
            }
        }
        
        for (i in 0...imax) {
            if (dst[i] < -1)                 dst[i] = -1
            else if (dst[i] > 1)                 dst[i] = 1;
        }
        
        return dst;
    }
    
    
    
    
    // calculation
    //--------------------------------------------------
    /** Calculate sample length from 16th beat. 
     *  @param bpm Beat per minuits.
     *  @param beat16 Count of 16th beat.
     *  @return sample length.
     */
    public static function calcSampleLength(bpm : Float, beat16 : Float = 4) : Float
    {
        // 661500 = 44100*60/4
        return beat16 * 661500 / bpm;
    }
    
    
    
    /** Check silent length at the head of Sound.
     *  @param src source Sound
     *  @param rmsThreshold threshold level to detect sound.
     *  @return silent length in sample count.
     */
    public static function getHeadSilence(src : Sound, rmsThreshold : Float = 0.01) : Int
    {
#if EXTRACT_ENABLED
        var wave : ByteArray = new ByteArray();
        var i : Int;
        var imax : Int;
        var extracted : Int;
        var l : Float;
        var r : Float;
        var ms : Float;
        var sp : Int = 0;
        var msWindow : SLLNumber = SLLNumber.allocRing(22);  // 0.5ms  
        
        rmsThreshold *= rmsThreshold;
        rmsThreshold *= 22;
        
        imax = 1152;
        ms = 0;
        extracted = 0;
        while (imax == 1152){
            while (wave.length > 0) wave.pop();
            imax = src.extract(wave, 1152, sp);
            wave.position = 0;
            for (imax){
                l = wave.readFloat();
                r = wave.readFloat();
                ms -= msWindow.n;
                msWindow = msWindow.next;
                msWindow.n = l * l + r * r;
                ms += msWindow.n;
                if (ms >= rmsThreshold)                     return extracted + i - 22;
            }
            sp = -1;
            extracted += 1152;
        }
        
        SLLNumber.freeRing(msWindow);
        
        return extracted;
#else
        trace('***** WARNING: Unimplemented getHeadSilence called. Returning fixed value.');
        return 0;
#end
    }
    
    
    /** Get end gap of Sound
     *  @param src source Sound
     *  @param rmsThreshold threshold level to detect sound.
     *  @param maxLength maximum length to search [sample count]. ussually mp3's end gap is less than 1152.
     *  @return silent length in sample count.
     */
    public static function getEndGap(src : Sound, rmsThreshold : Float = 0.01, maxLength : Int = 1152) : Int
    {
#if EXTRACT_ENABLED
        var wave : ByteArray = new ByteArray();
        var ms : Array<Float> = new Array<Float>();
        var i : Int;
        var imax : Int;
        var extracted : Int;
        var l : Float;
        var r : Float;
        var sp : Int;
        
        rmsThreshold *= rmsThreshold;
        sp = Math.floor(src.length * 44.1) - 1152;
        
        extracted = 0;
        while (extracted < maxLength){
            imax = src.extract(wave, 1152, sp);
            wave.position = 0;
            for (i in 0...imax) {
                l = wave.readFloat();
                r = wave.readFloat();
                ms[i] = l * l + r * r;
            }
            i = imax - 1;
            while (i >= 0){
                if (ms[i] >= rmsThreshold) {
                    extracted += i;
                    trace(extracted);
                    return ((extracted < maxLength)) ? extracted : maxLength;
                }
                --i;
            }
            sp -= 1152;
            if (sp < 0)                 break;
            extracted += imax;
        }
        
        return maxLength;
#else
        trace('***** WARNING: Unimplemented getEndGap called. Returning fixed value.');
        return 0;
#end
    }
    
    
    /** Detect distance[ms] of 2 peaks, [estimated bpm] = 60000/getPeakDistance().
     *  @param sample stereo samples, the length must be grater than 59136*2(stereo).
     *  @return distance[ms] of 2 peaks.
     */
    public static function getPeakDistance(sample : Array<Float>) : Float
    {
        var i : Int;
        var j : Int;
        var k : Int;
        var idx : Int;
        var n : Float;
        var m : Float;
        var envAccum : Float;
        
        // 461.9375 = 59128/128, 59128 = length for 2 beats on bpm=89.5
        if (_envelop == null) _envelop = new Array<Float>();
        if (_xcorr == null) _xcorr = new Array<Float>();


        // calculate envelop
        m = envAccum = 0;
        idx=0;
        for (i in 0...462) {
            n = 0;
            j = 0;
            while (j < 128){
                n += sample[idx];
                j++;
                idx += 2;
            }
            m += n;
            envAccum *= 0.875;
            envAccum += m * m;
            _envelop[i] = envAccum;
            m = n;
        }

        // calculate cross correlation and find peak index
        idx=0;
        for (i in 0...113){
            n = 0;
            j = 0;
            k = 113 + i;
            while (j < 226){
                n += _envelop[j] * _envelop[k];
                j++;
                k++;
            }
            _xcorr[i] = n;
            if (_xcorr[idx] < n)                 idx = i;
        }

        // caluclate bpm 2.9024943310657596 = 128/44.1
        return (113 + idx) * 2.9024943310657596;
    }
    private static var _envelop : Array<Float> = null;
    private static var _xcorr : Array<Float> = null;
    
    
    
    
    // wave table
    //--------------------------------------------------
    /** create Wave table Vector from wave color.
     *  @param color wave color value
     *  @param waveType wave type (the voice number of '%5')
     *  @param dst returning Vector.&lt;Number&gt;. if null, allocate new Vector inside.
     */
    public static function waveColor(color : Int, waveType : Int = 0, dst : Array<Float> = null) : Array<Float>
    {
        if (dst == null)             dst = new Array<Float>();
        var len : Int;
        var bits : Int = 0;
        len = dst.length >> 1;
        while (len != 0){
            bits++;
            len >>= 1;
        }
        while (dst.length > 1 << bits) dst.pop();
        bits = SiOPMTable.PHASE_BITS - bits;
        
        var i : Int;
        var imax : Int;
        var j : Int;
        var gain : Int;
        var mul : Int = 0;
        var n : Float;
        var nmax : Float;
        var bars : Array<Float> = new Array<Float>();
        var barr : Array<Int> = [1, 2, 3, 4, 5, 6, 8];
        var log : Array<Int> = SiOPMTable.instance.logTable;
        var waveTable : SiOPMWaveTable = SiOPMTable.instance.getWaveTable(waveType + (color >>> 28));
        var wavelet : Array<Int> = waveTable.wavelet;
        var fixedBits : Int = waveTable.fixedBits;
        var filter : Int = SiOPMTable.PHASE_FILTER;
        var envtop : Int = (-SiOPMTable.ENV_TOP) << 3;
        var index : Int;
        var step : Int = SiOPMTable.PHASE_MAX >> bits;
        
        i = 0;
        while (i < 7){bars[i] = (color & 15) * 0.0625;
            i++;
            color >>= 4;
        }
        
        imax = SiOPMTable.PHASE_MAX;
        nmax = 0;
        
        i = 0;
        while (i < imax){
            j = i >> bits;
            dst[j] = 0;
            for (i in 0...7){
                index = (((i * barr[mul]) & filter) >> fixedBits);
                gain = wavelet[index] + envtop;
                dst[j] += log[gain] * bars[mul];
            }
            n = ((dst[j] < 0)) ? -dst[j] : dst[j];
            if (nmax < n)                 nmax = n;
            i += step;
        }
        
        if (nmax < 8192)             nmax = 8192;
        n = 1 / nmax;
        imax = dst.length;
        for (i in 0...imax){
            dst[i] *= n;
        }
        return dst;
    }

    public function new()
    {
    }
}


