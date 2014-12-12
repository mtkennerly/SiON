//----------------------------------------------------------------------------------------------------
// Mapper class
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//--------------------------------------------------------------------------------


package org.si.sound.nsf;


class Mapper
{
    public var bank3WRAM : Int = 0;
    public function new()
    {
    }
    public function write(addr : Int, data : Int) : Void{
    }
    public function readLow(addr : Int) : Int{
        var a : Int = (addr & 8191) + (bank3WRAM << 13);
        var i : Int = a >> 2;
        var s : Int = (a & 3) << 3;
        return (MMU.__DOLLAR__.WRAM[i] >> s) & 0xff;
    }
    public function writeLow(addr : Int, data : Int) : Void{
        var a : Int = (addr & 8191) + (bank3WRAM << 13);
        var i : Int = a >> 2;
        var s : Int = (a & 3) << 3;
        MMU.__DOLLAR__.WRAM[i] = (MMU.__DOLLAR__.WRAM[i] & ~(255 << s)) | (data << s);
    }
    public function ExCmdRead(cmd : Int) : Int{return 0x00;
    }
    public function ExCmdWrite(cmd : Int, data : Int) : Void{
    }
    public function ExRead(addr : Int) : Int{return 0;
    }
    public function ExWrite(addr : Int, data : Int) : Void{
    }
    public function sync(cycles : Int) : Void{
    }
    public function HSync(scanline : Int) : Void{
    }
    public function VSync() : Void{
    }
    public function PPU_Latch(addr : Int) : Void{
    }
    public function PPU_ChrLatch(addr : Int) : Void{
    }
    public function PPU_ExtLatchX(x : Int) : Void{
    }
    public function PPU_ExtLatch(addr : Int) : Dynamic{return {
            chr_l : 0,
            chr_h : 0,
            attr : 0,

        };
    }
}


