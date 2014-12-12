//----------------------------------------------------------------------------------------------------
// SiON effect basic class
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;

import org.si.sion.effector.SiEffectBase;

/** Composite effector class. */
class SiCompositeEffector extends SiEffectBase
{
    public var slot0(never, set) : Array<Dynamic>;
    public var slot1(never, set) : Array<Dynamic>;
    public var slot2(never, set) : Array<Dynamic>;
    public var slot3(never, set) : Array<Dynamic>;
    public var slot4(never, set) : Array<Dynamic>;
    public var slot5(never, set) : Array<Dynamic>;
    public var slot6(never, set) : Array<Dynamic>;
    public var slot7(never, set) : Array<Dynamic>;
    public var dry(never, set) : Float;
    public var masterVolume(never, set) : Float;

    // variables
    //------------------------------------------------------------
    private var _effectorSlot : Array<Array<Dynamic>> = null;
    private var _buffer : Array<Array<Float>> = null;
    private var _sendLevel : Array<Float> = null;
    private var _mixLevel : Array<Float> = null;
    
    
    
    // properties
    //--------------------------------------------------------------------------------
    /** effector slot 0 */
    private ‰function set_slot0(list : Array<Dynamic>) : Array<Dynamic>{_effectorSlot[0] = list;
        return list;
    }
    
    /** effector slot 1 */
    private function set_slot1(list : Array<Dynamic>) : Array<Dynamic>{_effectorSlot[1] = list;
        return list;
    }
    
    /** effector slot 2 */
    private function set_slot2(list : Array<Dynamic>) : Array<Dynamic>{_effectorSlot[2] = list;
        return list;
    }
    
    /** effector slot 3 */
    private function set_slot3(list : Array<Dynamic>) : Array<Dynamic>{_effectorSlot[3] = list;
        return list;
    }
    
    /** effector slot 4 */
    private function set_slot4(list : Array<Dynamic>) : Array<Dynamic>{_effectorSlot[4] = list;
        return list;
    }
    
    /** effector slot 5 */
    private function set_slot5(list : Array<Dynamic>) : Array<Dynamic>{_effectorSlot[5] = list;
        return list;
    }
    
    /** effector slot 6 */
    private function set_slot6(list : Array<Dynamic>) : Array<Dynamic>{_effectorSlot[6] = list;
        return list;
    }
    
    /** effector slot 7 */
    private function set_slot7(list : Array<Dynamic>) : Array<Dynamic>{_effectorSlot[7] = list;
        return list;
    }
    
    /** dry level*/
    private function set_dry(n : Float) : Float{_sendLevel[0] = n;
        return n;
    }
    
    /** master output level */
    private function set_masterVolume(n : Float) : Float{_mixLevel[0] = n;
        return n;
    }
    
    
    
    
    // constructor
    //------------------------------------------------------------
    /** Constructor. do nothing. */
    public function new()
    {
        super();
        
    }
    
    
    
    
    // callback functions
    //------------------------------------------------------------
    /** set effect input/output level of one slot */
    public function setLevel(slotNum : Int, inputLevel : Float, outputLevel : Float) : Void
    {
        _sendLevel[slotNum] = inputLevel;
        _mixLevel[slotNum] = outputLevel;
    }
    
    
    /** @private */
    override public function initialize() : Void
    {
        _effectorSlot = new Array<Array<Dynamic>>();
        _buffer = new Array<Array<Float>>();
        _sendLevel = new Array<Float>();
        _mixLevel = new Array<Float>();
        for (i in 0...8){
            _effectorSlot[i] = null;
            _buffer[i] = Array/*Vector.<T> call?*/();
            _mixLevel[i] = _sendLevel[i] = 1;
        }
    }
    
    
    /** @private */
    override public function mmlCallback(args : Array<Float>) : Void
    {
        
    }
    
    
    /** @private */
    override public function prepareProcess() : Int
    {
        var i : Int;
        var imax : Int;
        var slotNum : Int;
        var list : Array<Dynamic>;
        for (8){
            if (_effectorSlot[slotNum]) {
                list = _effectorSlot[slotNum];
                imax = list.length;
                for (imax){list[i].prepareProcess();
                }
            }
        }
        return 2;
    }
    
    
    /** @private */
    override public function process(channels : Int, buffer : Array<Float>, startIndex : Int, length : Int) : Int
    {
        var i : Int;
        var j : Int;
        var imax : Int;
        var slotNum : Int;
        var list : Array<Dynamic>;
        var str : Array<Float>;
        var ch : Int;
        var lvl : Float;
        for (8){
            if (_effectorSlot[slotNum]) {
                str = _buffer[slotNum];
                lvl = _sendLevel[slotNum];
                if (str.length < buffer.length)                     str.length = buffer.length;
                i = 0;
j = startIndex;
                while (i < length){str[j] = buffer[j] * lvl;
                    i++;
                    j++;
                }
            }
        }
        lvl = _sendLevel[0];
        i = 0;
j = startIndex;
        while (i < length){buffer[j] *= lvl;
            i++;
            j++;
        }
        for (8){
            if (_effectorSlot[slotNum]) {
                ch = channels;
                list = _effectorSlot[slotNum];
                imax = list.length;
                for (imax){ch = list[i].process(ch, str[slotNum], startIndex, length);
                }
                lvl = _mixLevel[slotNum];
                i = 0;
j = startIndex;
                while (i < length){buffer[j] += str[j] * lvl;
                    i++;
                    j++;
                }
            }
        }
        if (_effectorSlot[0]) {
            list = _effectorSlot[0];
            imax = list.length;
            for (imax){channels = list[i].process(channels, buffer, startIndex, length);
            }
            if (_mixLevel[0] != 1) {
                lvl = _mixLevel[0];
                i = 0;
j = startIndex;
                while (i < length){buffer[j] *= lvl;
                    i++;
                    j++;
                }
            }
        }
        
        return channels;
    }
}


