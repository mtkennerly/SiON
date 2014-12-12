//----------------------------------------------------------------------------------------------------  // NES configuration  
//  Copyright (c) 2009 keim All rights reserved.  //  Distributed under BSD-style license (see org.si.license.txt).    //--------------------------------------------------------------------------------  
package org.si.sound.nsf;

class NESconfig
{
    public static var NTSC : NESconfig = new NESconfig(1789772.5, 262, 1364, 1024, 340, 4, 29830, 60);
    public static var PAL : NESconfig = new NESconfig(1662607.125, 312, 1278, 960, 318, 2, 33252, 50);
    
    public var cpuClock : Float;public var frameRate : Int;public var framePeriod : Float;public var totalScanlines : Int;public var scanlineCycles : Int;public var hDrawCycles : Int;public var hBlankCycles : Int;public var scanlineEndCycles : Int;public var frameCycles : Int;public var frameIrqCycles : Int;public function new(cl : Float, sl : Int, slc : Int, hdc : Int, hbc : Int, sec : Int, fic : Int, fr : Int)
    {
        cpuClock = cl;
        totalScanlines = sl;
        scanlineCycles = slc;
        hDrawCycles = hdc;
        hBlankCycles = hbc;
        scanlineEndCycles = sec;
        frameCycles = sl * slc;
        frameIrqCycles = fic;
        frameRate = fr;
        framePeriod = 1000 / fr;
    }
}

