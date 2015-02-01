//----------------------------------------------------------------------------------------------------
// Extended ByteArray
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.utils;

#if flash
import flash.utils.CompressionAlgorithm;
import flash.net.URLLoaderDataFormat;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.net.URLLoader;
import flash.utils.Endian;
import flash.utils.ByteArray;
import flash.events.Event;
import flash.display.BitmapData;
#else
import openfl.utils.CompressionAlgorithm;
import openfl.net.URLLoaderDataFormat;
import openfl.events.IOErrorEvent;
import openfl.net.URLRequest;
import openfl.net.URLLoader;
import openfl.utils.Endian;
import openfl.utils.ByteArray;
import openfl.events.Event;
import openfl.display.BitmapData;
#end

typedef CallbackType = Event->Void;

/** Extended ByteArray, png image serialize, IFF chunk structure, FileReference operations. */
class ByteArrayExt extends ByteArray
{
    // variables
    //--------------------------------------------------
    private static var crc32 : Array<Int> = null;
    
    /** name of this ByteArray */
    public var name : String = null;
    
    
    
    
    // constructor
    //--------------------------------------------------
    /** constructor */
    public function new(copyFrom : ByteArray = null)
    {
        super();
        if (copyFrom != null) {
            this.writeBytes(copyFrom);
            this.endian = copyFrom.endian;
            this.position = 0;
        }
        else {
            // By default, use little endian, since SWF files
            // used by SoundFont are in little endian format
            endian = Endian.LITTLE_ENDIAN;
        }
    }
    
    
    
    
    // bitmap data operations
    //--------------------------------------------------
    /** translate from BitmapData 
     *  @param bmd BitmapData translating from. 
     *  @return this instance
     */
    public function fromBitmapData(bmd : BitmapData) : ByteArrayExt
    {
        var x : Int;
        var y : Int;
        var i : Int;
        var w : Int = bmd.width;
        var h : Int = bmd.height;
        var len : Int;
        var p : Int;
        this.clear();
        len = bmd.getPixel(w - 1, h - 1);
        y = 0;
        i = 0;
        while (y < h && i < len) {
            x = 0;
            while (x < w && i < len) {
                p = bmd.getPixel(x, y);
                this.writeByte(p >>> 16);
                if (++i >= len)                     break;
                this.writeByte(p >>> 8);
                if (++i >= len)                     break;
                this.writeByte(p);
                x++;
                i++;
            }
            y++;
        }
        this.position = 0;
        return this;
    }
    
    
    /** translate to BitmapData
     *  @param width same as BitmapData's constructor, set 0 to calculate automatically.
     *  @param height same as BitmapData's constructor, set 0 to calculate automatically.
     *  @param transparent same as BitmapData's constructor.
     *  @param fillColor same as BitmapData's constructor.
     *  @return translated BitmapData
     */
    public function toBitmapData(width : Int = 0, height : Int = 0, transparent : Bool = true, fillColor : Int = 0xFFFFFFFF) : BitmapData
    {
        var x : Int = 0;
        var y : Int;
        var reqh : Int;
        var bmd : BitmapData;
        var len : Int = this.length;
        var p : Int;
        if (width == 0) width = ((Math.floor(Math.sqrt(len) + 65535 / 65536)) + 15) & (~15);
        reqh = ((Math.floor(len / width + 65535 / 65536)) + 15) & (~15);
        if (height == 0 || reqh > height)             height = reqh;
        bmd = new BitmapData(width, height, transparent, fillColor);
        this.position = 0;
        y = 0;
        while (y < height) {
            x = 0;
            while (x < width) {
                if (this.bytesAvailable < 3) break;
                bmd.setPixel32(x, y, 0xff000000 | ((this.readUnsignedShort() << 8) | this.readUnsignedByte()));
                x++;
            }
            y++;
        }
        p = 0xff000000;
        if (this.bytesAvailable > 0)             p |= this.readUnsignedByte() << 16;
        if (this.bytesAvailable > 0)             p |= this.readUnsignedByte() << 8;
        if (this.bytesAvailable > 0)             p |= this.readUnsignedByte();
        bmd.setPixel32(x, y, p);
        this.position = 0;
        bmd.setPixel32(x, y, 0xff000000 | this.length);
        return bmd;
    }
    
    
    /** translate to 24bit png data 
     *  @param width png file width, set 0 to calculate automatically.
     *  @param height png file height, set 0 to calculate automatically.
     *  @return ByteArrayExt of PNG data
     */
    public function toPNGData(width : Int = 0, height : Int = 0) : ByteArrayExt
    {
        var i : Int;
        var imax : Int;
        var reqh : Int;
        var pixels : Int = Std.int((this.length + 2) / 3);
        var y : Int;
        var png : ByteArrayExt = new ByteArrayExt();
        var header : ByteArray = new ByteArray();
        var content : ByteArray = new ByteArray();

        //----- write png chunk
        function png_writeChunk(type : Int, data : ByteArray) : Void{
            png.writeUnsignedInt(data.length);
            var crcStartAt : Int = png.position;
            png.writeUnsignedInt(type);
            png.writeBytes(data);
            png.writeUnsignedInt(calculateCRC32(png, crcStartAt, png.position - crcStartAt));
        };

        //----- settings
        if (width == 0)  width = ((Math.floor(Math.sqrt(pixels) + 65535 / 65536)) + 15) & (~15);
        reqh = ((Math.floor(pixels / width + 65535 / 65536)) + 15) & (~15);
        if (height == 0 || reqh > height)             height = reqh;
        header.writeInt(width);  // width  
        header.writeInt(height);  // height  
        header.writeUnsignedInt(0x08020000);  // 24bit RGB  
        header.writeByte(0);
        imax = pixels - width;
        y = 0;
        i = 0;
        while (i < imax){
            content.writeByte(0);
            content.writeBytes(this, i * 3, width * 3);
            i += width;
            y++;
        }
        content.writeByte(0);
        content.writeBytes(this, i * 3, this.length - i * 3);
        imax = (i + width) * 3;
        for (i in this.length...imax) {
            content.writeByte(0);
        }
        imax = width * 3 + 1;
        for (y in (y+1)...height) {
            for (i in 0...imax) {
                content.writeByte(0);
            }
        }
        i = this.length;
        content.position -= 3;
        content.writeByte(i >>> 16);
        content.writeByte(i >>> 8);
        content.writeByte(i);
        content.compress();
        
        //----- write png data
        png.writeUnsignedInt(0x89504e47);
        png.writeUnsignedInt(0x0D0A1A0A);
        png_writeChunk(0x49484452, header);
        png_writeChunk(0x49444154, content);
        png_writeChunk(0x49454E44, new ByteArray());
        png.position = 0;
        
        return png;
    }
    
    
    
    
    // IFF chunk operations
    //--------------------------------------------------
    /** write IFF chunk */
    public function writeChunk(chunkID : String, data : ByteArray, listType : String = null) : Void
    {
        var isList : Bool = (chunkID == "RIFF" || chunkID == "LIST");
        var len : Int = (((data != null)) ? data.length : 0) + (((isList)) ? 4 : 0);
        this.writeMultiByte((chunkID + "    ").substr(0, 4), "us-ascii");
        this.writeInt(len);
        if (isList) {
            if (listType != null)                 this.writeMultiByte((listType + "    ").substr(0, 4), "us-ascii")
            else this.writeMultiByte("    ", "us-ascii");
        }
        if (data != null) {
            this.writeBytes(data);
            if ((len & 1) != 0) this.writeByte(0);
        }
    }
    
    
    /** read (or search) IFF chunk from current position. */
    public function readChunk(bytes : ByteArray, offset : Int = 0, searchChunkID : String = null) : Dynamic
    {
        var id : String;
        var len : Int;
        var type : String = null;
        while (this.bytesAvailable > 0){
            id = this.readMultiByte(4, "us-ascii");
            len = this.readInt();
            if (searchChunkID == null || searchChunkID == id) {
                if (id == "RIFF" || id == "LIST") {
                    type = this.readMultiByte(4, "us-ascii");
                    this.readBytes(bytes, offset, len - 4);
                }
                else {
                    this.readBytes(bytes, offset, len);
                }
                if ((len & 1) != 0) this.readByte();
                bytes.endian = this.endian;
                return {
                    chunkID : id,
                    length : len,
                    listType : type,
                };
            }
            this.position += len + (len & 1);
        }
        return null;
    }
    
    
    /** read all IFF chunks from current position. */
    public function readAllChunks() : Dynamic
    {
        var header : Dynamic;
        var ret : Dynamic = { };
        var pickup : ByteArrayExt;
        while (header = readChunk(pickup = new ByteArrayExt())){
            if (Lambda.has(ret, header.chunkID)) {
                if (Std.is(ret[header.chunkID], Array))                     ret[header.chunkID].push(pickup)
                else ret[header.chunkID] = [ret[header.chunkID]];
            }
            else {
                ret[header.chunkID] = pickup;
            }
        }
        return ret;
    }
    
    
    
    
    // URL operations
    //--------------------------------------------------
    /** load from URL 
     *  @param url URL string to load swf file.
     *  @param onComplete handler for Event.COMPLETE. The format is function(bae:ByteArrayExt) : void.
     *  @param onCancel handler for Event.CANCEL. The format is function(e:Event) : void.
     *  @param onError handler for Event.IO_ERROR. The format is function(e:IOErrorEvent) : void.
     */
    public function load(url : String, onComplete : ByteArrayExt->Void = null, onCancel : Event->Void = null, onError : Event->Void = null) : Void
    {
        var loader : URLLoader = new URLLoader();
        var bae : ByteArrayExt = this;

        var _removeAllEventListeners : Event->CallbackType->Void = null;

        function _onLoadCancel(e : Event) : Void {
            _removeAllEventListeners(e, onCancel);
        };
        function _onLoadError(e : Event) : Void {
            _removeAllEventListeners(e, onError);
        };
        function _onLoadComplete(e : Event) : Void{
            bae.clear();
            bae.writeBytes(e.target.data);
            _removeAllEventListeners(e, null);
            bae.position = 0;
            if (onComplete != null) onComplete(bae);
        };

        _removeAllEventListeners = function(e : Event, callback : CallbackType) : Void{
            loader.removeEventListener("complete", _onLoadComplete);
            loader.removeEventListener("cancel", _onLoadCancel);
            loader.removeEventListener("ioError", _onLoadError);
            if (callback != null) callback(e);
        };

        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.addEventListener("complete", _onLoadComplete);
        loader.addEventListener("cancel", _onLoadCancel);
        loader.addEventListener("ioError", _onLoadError);
        loader.load(new URLRequest(url));
    }
    
    
    
    
    // FileReference operations
    //--------------------------------------------------
    /** Call FileReference::browse().
     *  @param onComplete handler for Event.COMPLETE. The format is function(bae:ByteArrayExt) : void.
     *  @param onCancel handler for Event.CANCEL. The format is function(e:Event) : void.
     *  @param onError handler for Event.IO_ERROR. The format is function(e:IOErrorEvent) : void.
     *  @param fileFilterName name of file filter.
     *  @param extensions extensions of file filter (like "*.jpg;*.png;*.gif").
     */
    public function browse(onComplete : ByteArrayExt->Void = null, onCancel : Event->Void = null, onError : IOErrorEvent->Void = null, fileFilterName : String = null, extensions : String = null) : Void
    {
        return;
#if FILE_REFERENCE_ENABLED
        var fr : FileReference = new FileReference();
        var bae : ByteArrayExt = this;
        fr.addEventListener("select", function(e : Event) : Void{
                    e.target.removeEventListener(e.type, arguments.callee);
                    fr.addEventListener("complete", _onBrowseComplete);
                    fr.addEventListener("cancel", _onBrowseCancel);
                    fr.addEventListener("ioError", _onBrowseError);
                    fr.load();
                });
        fr.browse(((fileFilterName != null)) ? [new FileFilter(fileFilterName, extensions)] : null);
        
        function _removeAllEventListeners(e : Event, callback : Event->Void) : Void {
            fr.removeEventListener("complete", _onBrowseComplete);
            fr.removeEventListener("cancel", _onBrowseCancel);
            fr.removeEventListener("ioError", _onBrowseError);
            if (callback != null) callback(e);
        };
        function _onBrowseComplete(e : Event) : Void {
            bae.clear();
            bae.writeBytes(e.target.data);
            _removeAllEventListeners(e, null);
            bae.position = 0;
            if (onComplete != null) onComplete(bae);
        };
        function _onBrowseCancel(e : Event) : Void {
            _removeAllEventListeners(e, onCancel);
        };
        function _onBrowseError(e : Event) : Void {
            _removeAllEventListeners(e, onError);
        };
#end
    }
    
    
    /** Call FileReference::save().
     *  @param defaultFileName default file name.
     *  @param onComplete handler for Event.COMPLETE. The format is function(e:Event) : void.
     *  @param onCancel handler for Event.CANCEL. The format is function(e:Event) : void.
     *  @param onError handler for Event.IO_ERROR. The format is function(e:IOErrorEvent) : void.
     */
    public function save(defaultFileName : String = null, onComplete : Event->Void = null, onCancel : Event->Void = null, onError : IOErrorEvent->Void = null) : Void
    {
#if SAVE_IMPLEMENTED
        var fr : FileReference = new FileReference();
        fr.addEventListener("complete", _onSaveComplete);
        fr.addEventListener("cancel", _onSaveCancel);
        fr.addEventListener("ioError", _onSaveError);
        fr.save(this, defaultFileName);
        
        function _removeAllEventListeners(e : Event, callback : Event->Void) : Void{
            fr.removeEventListener("complete", _onSaveComplete);
            fr.removeEventListener("cancel", _onSaveCancel);
            fr.removeEventListener("ioError", _onSaveError);
            if (callback != null)                 callback(e);
        };
        function _onSaveComplete(e : Event) : Void{_removeAllEventListeners(e, onComplete);
        };
        function _onSaveCancel(e : Event) : Void{_removeAllEventListeners(e, onCancel);
        };
        function _onSaveError(e : Event) : Void{_removeAllEventListeners(e, onError);
        };
#else
        trace("***** Save not implemented.");
#end
    }
    
    
    
    
    // zip file operations
    //--------------------------------------------------
    /** Expand zip file including plural files.
     *  @return List of ByteArrayExt
     */
    public function expandZipFile() : Array<ByteArrayExt>
    {
        var bytes : ByteArray = new ByteArray();
        var fileName : String;
        var bae : ByteArrayExt;
        var result : Array<ByteArrayExt> = new Array<ByteArrayExt>();
        var flNameLength : Int;
        var xfldLength : Int;
        var compSize : Int;
        var compMethod : Int;
        var signature : Int;
        
        bytes.endian = Endian.LITTLE_ENDIAN;
        this.endian = Endian.LITTLE_ENDIAN;
        this.position = 0;
        while (this.position < this.length){
            this.readBytes(bytes, 0, 30);
            bytes.position = 0;
            signature = bytes.readUnsignedInt();
            if (signature != 0x04034b50) break;  // check signature
            bytes.position = 8;
            compMethod = bytes.readByte();
            bytes.position = 26;
            flNameLength = bytes.readShort();
            bytes.position = 28;
            xfldLength = bytes.readShort();
            
            this.readBytes(bytes, 30, flNameLength + xfldLength);
            bytes.position = 30;
            fileName = bytes.readUTFBytes(flNameLength);
            bytes.position = 18;
            compSize = bytes.readUnsignedInt();
            
            bae = new ByteArrayExt();
            this.readBytes(bae, 0, compSize);
            if (compMethod == 8) bae.uncompress(CompressionAlgorithm.DEFLATE);
            bae.name = fileName;
            result.push(bae);
        }
        
        return result;
    }
    
    
    
    
    // utilities
    //--------------------------------------------------
    /** calculate crc32 chuck sum */
    public static function calculateCRC32(byteArray : ByteArray, offset : Int = 0, length : Int = 0) : Int
    {
        var i : Int;
        var j : Int;
        var c : Int;
        var currentPosition : Int;
        if (crc32 == null) {
            crc32 = new Array<Int>();
            for (i in 0...256){
                c=i;
                for (j in 0...8){
                    c = Std.int((((c & 1) != 0) ? 0xedb88320 : 0) ^ (c >>> 1));
                }
                crc32[i] = c;
            }
        }
        
        if (length == 0)             length = byteArray.length;
        currentPosition = byteArray.position;
        byteArray.position = offset;
        c=0xffffffff;
        for (i in 0...length){
            j = (c ^ byteArray.readUnsignedByte()) & 255;
            c >>>= 8;
            c ^= crc32[j];
        }
        byteArray.position = currentPosition;
        
        return c ^ 0xffffffff;
    }
}


