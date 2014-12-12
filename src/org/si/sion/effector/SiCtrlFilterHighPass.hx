//----------------------------------------------------------------------------------------------------
// SiOPM effect controlable HPF
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;


/** controlable HPF. */
class SiCtrlFilterHighPass extends SiCtrlFilterBase
{
    /** constructor. 
     *  @param cutoff cutoff(0-1).
     *  @param resonance resonance(0-1).
     */
    public function new(cutoff : Float = 1, resonance : Float = 0)
    {
        super();
        initialize();
        control(cutoff, resonance);
    }
    
    
    /** @private */
    override private function processLFO(buffer : Array<Float>, startIndex : Int, length : Int) : Void
    {
        var i : Int;
        var n : Float;
        var imax : Int = startIndex + length;
        var cut : Float = _table.filter_cutoffTable[_cutIndex];
        var fb : Float = _res * _table.filter_feedbackTable[_cutIndex];
        i = startIndex;
        while (i < imax){
            n = buffer[i];
            _p0l += cut * (n - _p0l + fb * (_p0l - _p1l));
            _p1l += cut * (_p0l - _p1l);
            buffer[i] = n - _p0l;i++;
            n = buffer[i];
            _p0r += cut * (n - _p0r + fb * (_p0r - _p1r));
            _p1r += cut * (_p0r - _p1r);
            buffer[i] = n - _p0r;i++;
        }
    }
}


