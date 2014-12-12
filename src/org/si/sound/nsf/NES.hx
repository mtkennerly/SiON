//----------------------------------------------------------------------------------------------------
// NES Emulator
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//--------------------------------------------------------------------------------


package org.si.sound.nsf;

import org.si.sound.nsf.CPU;
import org.si.sound.nsf.NESconfig;
import org.si.sound.nsf.PAD;
import org.si.sound.nsf.PPU;
import org.si.sound.nsf.ROM;

class NES
{
    public static var cpu : CPU = new CPU();
    public static var apu : APU = new APU();
    public static var ppu : PPU = new PPU();
    public static var pad : PAD = new PAD();
    public static var rom : ROM;
    public static var map : Mapper;
    public static var cfg : NESconfig;

    public function new()
    {
    }
}



