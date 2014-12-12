//----------------------------------------------------------------------------------------------------
// SiOPM effect table
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;


/** @private Tables used in effectors. */
class SiEffectTable
{
    public static var instance(get, never) : SiEffectTable;

    /** sin table */
    public var sinTable : Array<Float>;
    
    
    /** constructor. */
    public function new()
    {
        var i : Int;
        sinTable = new Array<Float>();
        
        for (i in 0...384) {
            sinTable[i] = Math.sin(i * 0.02454369260617026);
        }
    }
    
    
    /** instance */
    private static var _instance : SiEffectTable = null;
    
    
    /** static initializer */
    private static function get_instance() : SiEffectTable
    {
        if (_instance == null)             _instance = new SiEffectTable();
        return _instance;
    }
}


