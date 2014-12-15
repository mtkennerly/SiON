//----------------------------------------------------------------------------------------------------
// To create flash.media.Sound class
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.utils;

#if flash
import flash.errors.Error;
import flash.display.Loader;
import flash.events.*;
import flash.utils.ByteArray;
import flash.media.Sound;
import flash.utils.Endian;
#else
import openfl.errors.Error;
import openfl.display.Loader;
import openfl.events.*;
import openfl.utils.ByteArray;
import openfl.media.Sound;
#end

/**
 * Refer from http://www.flashcodersbrighton.org/wordpress/?p=9
 * @modified Kei Mesuda
 */
@:final class SoundClass
{
    private static var _header : Array<Int> = [  // little endian  
                0x09535746, 0xFFFFFFFF, 0x5f050078, 0xa00f0000, 0x010c0000, 0x08114400, 0x43000000, 0xffffff02, 
                0x000b15bf, 0x00010000, 0x6e656353, 0x00312065, 0xc814bf00, 0x00000000, 0x00000000, 0x002e0010, 
                0x08000000, 0x756f530a, 0x6c43646e, 0x00737361, 0x616c660b, 0x6d2e6873, 0x61696465, 0x756f5305, 
                0x4f06646e, 0x63656a62, 0x76450f74, 0x44746e65, 0x61707369, 0x65686374, 0x6c660c72, 0x2e687361, 
                0x6e657665, 0x05067374, 0x16021601, 0x16011803, 0x07050007, 0x03070102, 0x05020704, 0x03060507, 
                0x00020000, 0x00020000, 0x00020000, 0x02010100, 0x01000408, 0x01000000, 0x04010102, 0x00030001, 
                0x06050101, 0x4730d003, 0x01010000, 0x06070601, 0x49d030d0, 0x00004700, 0x01010202, 0x30d01f05, 
                0x035d0065, 0x5d300366, 0x30046604, 0x0266025d, 0x66025d30, 0x1d005802, 0x01681d1d, 0xbf000047, 
                0xFFFFFF03, 0x3f0001FF];  // The last byte of "3f" means 44.1kHz/16bit/stereo
    private static var _footer : Array<Int> = [  // little endian  
                0x000f133f, 0x00010000, 0x6f530001, 0x43646e75, 0x7373616c, 0x0f0b4400, 0x40000000];
    
    
    private static var _bitRateList : Array<Int> = [
                0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 0, 0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0];
    private static var _frequencyList : Array<Int> = [44100, 48000, 32000, 0];
    
    
    
    
    /** load Sound class from mp3 data.
     *  @param src source byteArray.
     *  @param onComplete callback function when finished to create. the format is function(sound:Sound) : void
     */
    public static function loadMP3FromByteArray(bytes : ByteArray, onComplete : Sound->Void) : Void{
        var head : Int;
        var version : Int;
        var bitrate : Int;
        var frequency : Int = 0;
        var padding : Int;
        var channels : Int = 0;
        var frameLength : Int;
        bytes.position = 0;
        var id : String;
        if (bytes.readMultiByte(3, "us-ascii") == "ID3") {
            bytes.position += 3;  // slip version and flag  
            bytes.position += ((bytes.readByte() & 127) << 21) | ((bytes.readByte() & 127) << 14) | ((bytes.readByte() & 127) << 7) | (bytes.readByte() & 127);
        }
        else {
            bytes.position -= 3;
        }
        var frameCount : Int = 0;
        var byteCount : Int = 0;
        var headPosition : Int = bytes.position;
        while (bytes.bytesAvailable > 0) {
            head = bytes.readUnsignedInt();
            if ((head & 0xffe60000) != 0xffe20000) throw new Error("frame data broken");  // check frameSync & layerIII
            version = [2, -1, 1, 0][(head >> 19) & 3];  // 0=v1, 1=v2, 2=v2.5  
            bitrate = _bitRateList[((head >> 12) & 15) + (((version == 0)) ? 0 : 16)];
            frequency = _frequencyList[((head >> 10) & 3)] >> version;
            padding = (head >> 9) & 1;
            channels = ((((head >> 6) & 3) > 2)) ? 1 : 2;
            frameLength = Math.floor(((version == 0) ? 144000 : 72000) * bitrate / frequency + padding);
            byteCount += frameLength;
            bytes.position += frameLength - 4;
            frameCount++;
        }
        var src : ByteArray = new ByteArray();
#if flash
        src.endian = LITTLE_ENDIAN;
#else
        src.endian = "littleEndian";
#end
        src.writeInt(frameCount * 1152);
        src.writeShort(0);
        src.writeBytes(bytes, headPosition, byteCount);
        loadPCMFromByteArray(src, onComplete, true, frequency, 16, channels);
    }
    
    
    /** load Sound class from PCM data.
     *  @param src source byteArray.
     *  @param onComplete callback function when finished to create. the format is function(sound:Sound) : void
     *  @param compressed compressed flag, true = mp3, false = raw wave.
     *  @param sampleRate sampling rate
     *  @param bitRate bit rate
     *  @param channels channels 
     */
    public static function loadPCMFromByteArray(src : ByteArray, onComplete : Sound->Void, compressed : Bool = false, sampleRate : Int = 44100, bitRate : Int = 16, channels : Int = 2) : Void{
        var size : Int = src.length - (((compressed)) ? 4 : 0);
        var typeDef : Int;

        typeDef = ((compressed)) ? 0x20 : 0x30;
        typeDef |= ((channels == 2)) ? 0x01 : 0x00;
        switch (sampleRate)
        {
            case 44100:typeDef |= 0xc;
            case 22050:typeDef |= 0x8;
            case 11025:typeDef |= 0x4;
            case 5512:
            default:throw new Error("sampleRate not valid.");
        }
        switch (bitRate)
        {
            case 16:typeDef |= 0x2;
            case 8:
            default:throw new Error("bitRate not valid.");
        }
        var bytes : ByteArray = new ByteArray();

        function _write(vu : Array<Int>) : Void{
            for (i in 0...vu.length) {
                bytes.writeUnsignedInt(vu[i]);
            }
        };

#if flash
        bytes.endian = LITTLE_ENDIAN;
#else
        bytes.endian = "littleEndian";
#end
        bytes.position = 0;
        _write(_header);
        bytes.position = 257;
        bytes.writeInt(size + 7);
        bytes.position = 263;
        bytes.writeByte(typeDef);
        bytes.writeBytes(src);
        _write(_footer);
        bytes.writeByte(0);
        bytes.writeByte(0);
        bytes.writeByte(0);
        bytes.position = 4;
        bytes.writeInt(bytes.length);
        bytes.position = 0;
        
        var loader : Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e : Event) : Void {
                    var soundClass : Class<Dynamic> = Type.getClass(loader.contentLoaderInfo.applicationDomain.getDefinition("SoundClass"));
                    var createdSound = Type.createInstance(soundClass, []);
                    var castedSound : Sound;
                    try {
                        castedSound = cast(createdSound, Sound);
                    }
                    catch (e : Dynamic) {
                        castedSound = null;
                    }
                    onComplete(castedSound);
                });
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e : Event) : Void {
                    throw new Error(Std.string(e));
                });
        loader.loadBytes(bytes);
    }
    
    
    /** create Sound class from Vector of Number (44.1kHz stereo only).
     *  @param samples The Vector.&lt;Number&gt; wave data creating from. The LRLR type 44.1kHz stereo data.
     *  @param onComplete callback function when finished to create. the format is function(sound:Sound) : void
     */
    public static function create(samples : Array<Float>, onComplete : Sound->Void) : Void{
        var size : Int = samples.length * 2;  // *2(16bit)  
        var bytes : ByteArray = new ByteArray();

        function _write(vu : Array<Int>) : Void {
            for (ui in vu) {
                bytes.writeUnsignedInt(ui);
            }
        };

#if flash
        bytes.endian = LITTLE_ENDIAN;
#else
        bytes.endian = "littleEndian";
#end
        bytes.position = 0;
        _write(_header);
        bytes.position = 4;
        bytes.writeInt(size + 295);
        bytes.position = 257;
        bytes.writeInt(size + 7);
        bytes.position = 264;
        var i : Int;
        var imax : Int = samples.length;
        for (i in 0...imax) {
            bytes.writeShort(Std.int(samples[i] * 32767));
        }
        _write(_footer);
        bytes.writeByte(0);
        bytes.writeByte(0);
        bytes.writeByte(0);
        bytes.position = 0;
        
        var loader : Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e : Event) : Void{
                    var soundClass : Class<Dynamic> = Type.getClass(loader.contentLoaderInfo.applicationDomain.getDefinition("SoundClass"));
                    var createdSound = Type.createInstance(soundClass, []);
                    var castedSound = cast(createdSound, Sound);
                    onComplete(castedSound);
                });
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e : Event) : Void{
                    throw new Error(Std.string(e));
                });
        loader.loadBytes(bytes);
        
    }

    public function new()
    {
    }
}


