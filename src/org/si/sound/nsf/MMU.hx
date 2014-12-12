//--------------------------------------------------------------------------------
// Memory management unit
//  Copyright (c) 2009 keim All rights reserved.  //  Distributed under BSD-style license (see org.si.license.txt).    //--------------------------------------------------------------------------------  
package org.si.sound.nsf;

import org.si.sound.nsf.ByteArray;
import openfl.utils.ByteArray;



import org.si.sound.nsf.MMU;
import org.si.sound.nsf.NES;

class MMU
{
    public var RAM : Array<Int> = new Array<Int>();  // internal RAM;      2k  
    public var WRAM : Array<Int> = new Array<Int>();  // Working RAM;     128k  
    public var DRAM : Array<Int> = new Array<Int>();  // RAM of disk sys;  40k  
    public var ERAM : Array<Int> = new Array<Int>();  // RAM of exp.unit;  32k  
    public var CRAM : Array<Int> = new Array<Int>();  // Ch.pattern RAM;   32k  public var VRAM : Array<Int> = new Array<Int>();  // name and attr.;    4k  public var SPRAM : Array<Int> = new Array<Int>();  // Sprite RAM;      256b  public var BGPAL : Array<Int> = new Array<Int>();  // BG Pallete;       16b  public var SPPAL : Array<Int> = new Array<Int>();  // Sprite Pallete;   16b  public var PROM : ByteArray;  // ROM pointer  
    public var VROM : ByteArray;  // VROM pointer  
    public var onReadPPUport : Function;public var onReadCPUport : Function;
    public var onWritePPUport : Function;public var onWriteCPUport : Function;
    public var CPU_MEM_BANK : Array<MMUBank> = new Array<MMUBank>();
    public static var __DOLLAR__ : MMU;  // unique instance  
    
    public function new()
    {
        $ = this;
        CPU_MEM_BANK[0] = new MMUBankRAM();  // $0000-1ffff: internal RAM  
        CPU_MEM_BANK[1] = new PPUIOPort();  // $2000-3ffff: I/O port for PPU  
        CPU_MEM_BANK[2] = new CPUIOPort();  // $4000-5ffff: I/O port for APU,DMA,PAD etc..  
        CPU_MEM_BANK[3] = new MMUBankROMLow();  // $6000-7ffff: ROM area (low address)  
        for (i in 4...8){CPU_MEM_BANK[i] = new MMUBankROM();
        }
    }
    
    public function reset(ram : Int = 0, clearWRAM : Bool = false) : Void{
        var i : Int;
        for (RAM.length){RAM[i] = ram;
        }
        if (clearWRAM)             for (WRAM.length){WRAM[i] = 0xff;
        };
        for (DRAM.length){DRAM[i] = 0;
        }
        for (ERAM.length){ERAM[i] = 0;
        }
        for (CRAM.length){CRAM[i] = 0;
        }
        for (VRAM.length){VRAM[i] = 0;
        }
        for (SPRAM.length){SPRAM[i] = 0;
        }
        for (BGPAL.length){BGPAL[i] = 0;
        }
        for (SPPAL.length){SPPAL[i] = 0;
        }
    }
}class MMUBank
{
    // -------- bank types
    public static inline var ROM : Int = 0x00;
    public static inline var RAM : Int = 0xff;
    public static inline var DRAM : Int = 0x01;
    public static inline var MAPPER : Int = 0x80;
    // -------- variables
    public var type : Int;
    // -------- functions
    public function new(type : Int = ROM)
    {this.type = type;
    }
    public function read(addr : Int) : Int{return 0;
    }
    public function readW(addr : Int) : Int{return read(addr) | (read(addr + 1) << 8);
    }
    public function write(addr : Int, data : Int) : Void{
    }
}

class MMUBankRAM extends MMUBank
{  // $0000-$1fff  
    public function new()
    {super(MMUBank.RAM);
    }
    override public function read(addr : Int) : Int{var i : Int = addr & 2047;return MMU.__DOLLAR__.RAM[i];
    }
    override public function write(addr : Int, data : Int) : Void{var i : Int = addr & 2047;MMU.__DOLLAR__.RAM[i] = data;
    }
}

class PPUIOPort extends MMUBank
{  // $2000-$3fff  
    override public function read(addr : Int) : Int{return MMU.__DOLLAR__.onReadPPUport(addr & 7);
    }
    override public function write(addr : Int, data : Int) : Void{MMU.__DOLLAR__.onWritePPUport(addr, data);
    }

    public function new()
    {
        super();
    }
}

class CPUIOPort extends MMUBank
{  // $4000-$5fff  
    override public function read(addr : Int) : Int{return ((addr < 0x4020)) ? MMU.__DOLLAR__.onWriteCPUport(addr & 31) : NES.map.ExRead(addr);
    }
    override public function write(addr : Int, data : Int) : Void{
        if (addr < 0x4020)             MMU.__DOLLAR__.onWriteCPUport(addr, data)
        else NES.map.ExWrite(addr, data);
    }

    public function new()
    {
        super();
    }
}

class MMUBankROM extends MMUBank
{  // $8000-$ffff  
    // -------- variables
    public var offset : Int = 0;
    // -------- functions
    public function new()
    {super(MMUBank.MAPPER);
    }
    override public function read(addr : Int) : Int{
        MMU.__DOLLAR__.PROM.position = (addr & 8191) + offset;
        return MMU.__DOLLAR__.PROM.readUnsignedByte();
    }
    override public function write(addr : Int, data : Int) : Void{
        NES.map.write(addr, data);
    }
}

class MMUBankROMLow extends MMUBankROM
{  // $6000-$7fff  
    override public function read(addr : Int) : Int{return NES.map.readLow(addr);
    }
    override public function write(addr : Int, data : Int) : Void{NES.map.writeLow(addr, data);
    }

    public function new()
    {
        super();
    }
}

