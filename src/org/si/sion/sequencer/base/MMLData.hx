//----------------------------------------------------------------------------------------------------
// MML data class
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.base;

import org.si.sion.sequencer.base.MMLEvent;
import org.si.sion.sequencer.base.MMLSequence;
import org.si.sion.sequencer.base.MMLSequenceGroup;

import org.si.sion.module.SiOPMTable;


/** MML data class. MMLData > MMLSequenceGroup > MMLSequence > MMLEvent (">" meanse "has a"). */
class MMLData
{
    public var sequenceCount(get, never) : Int;
    public var bpm(get, set) : Float;
    public var systemCommands(get, never) : Array<Dynamic>;
    public var tickCount(get, never) : Int;
    public var hasRepeatAll(get, never) : Bool;

    // namespace
    //--------------------------------------------------
    
    
    
    
    
    // constants
    //--------------------------------------------------
    /** specify tcommand argument by BPM */
    public static inline var TCOMMAND_BPM : Int = 0;
    /** specify tcommand argument by OPNA's TIMERB with 48ticks/beat */
    public static inline var TCOMMAND_TIMERB : Int = 1;
    /** specify tcommand argument by frame count */
    public static inline var TCOMMAND_FRAME : Int = 2;
    
    
    
    // variables
    //--------------------------------------------------
    /** Sequence group */
    public var sequenceGroup : MMLSequenceGroup;
    /** Global sequence */
    public var globalSequence : MMLSequence;
    
    /** default FPS */
    public var defaultFPS : Int;
    /** Title */
    public var title : String;
    /** Author */
    public var author : String;
    /** mode of t command */
    public var tcommandMode : Int;
    /** resolution of t command */
    public var tcommandResolution : Float;
    /** default velocity command shift */
    public var defaultVCommandShift : Int;
    /** default velocity mode */
    public var defaultVelocityMode : Int;
    /** default expression mode */
    public var defaultExpressionMode : Int;
    
    /** @private [sion sequencer internal] default BPM of this data */
    public var _initialBPM : BeatPerMinutes;
    /** @private [sion sequencer internal] system commands that can not be parsed by system */
    private var _systemCommands : Array<Dynamic>;
    
    
    
    
    // properties
    //--------------------------------------------------
    /** sequence count */
    private function get_sequenceCount() : Int{return sequenceGroup.sequenceCount;
    }
    
    
    /** Beat per minutes, set 0 when this data depends on driver's BPM. */
    private function set_bpm(t : Float) : Float{
        _initialBPM = ((t > 0)) ? (new BeatPerMinutes(t, 44100)) : null;
        return t;
    }
    private function get_bpm() : Float{
        return ((_initialBPM != null)) ? _initialBPM.bpm : 0;
    }
    
    /** system commands that can not be parsed. Examples are for mml string "#ABC5{def}ghi;".<br/>
     *  the array elements are Object, and it has following properties.<br/>
     *  <ul>
     *  <li>command: command name. this always starts with "#". ex) command = "#ABC"</li>
     *  <li>number:  number after command. ex) number = 5</li>
     *  <li>content: content inside {...}. ex) content = "def"</li>
     *  <li>postfix: number after command. ex) postfix = "ghi"</li>
     *  </ul>
     */
    private function get_systemCommands() : Array<Dynamic>{return _systemCommands;
    }
    
    
    /** Get song length by tick count (1920 for wholetone). */
    private function get_tickCount() : Int{return sequenceGroup.tickCount;
    }
    
    
    /** does this song have all repeat comand ? */
    private function get_hasRepeatAll() : Bool{return sequenceGroup.hasRepeatAll;
    }
    
    
    
    
    // constructor
    //--------------------------------------------------
    public function new()
    {
        sequenceGroup = new MMLSequenceGroup(this);
        globalSequence = new MMLSequence();
        
        _initialBPM = null;
        tcommandMode = TCOMMAND_BPM;
        tcommandResolution = 1;
        defaultVCommandShift = 4;
        defaultVelocityMode = 0;
        defaultExpressionMode = 0;
        defaultFPS = 60;
        title = "";
        author = "";
        _systemCommands = [];
    }
    
    
    
    
    // operation
    //--------------------------------------------------
    /** Clear all parameters and free all sequence groups. */
    public function clear() : Void
    {
        var i : Int;
        var imax : Int;
        
        sequenceGroup.free();
        globalSequence.free();
        
        _initialBPM = null;
        tcommandMode = TCOMMAND_BPM;
        tcommandResolution = 1;
        defaultVelocityMode = 0;
        defaultExpressionMode = 0;
        defaultFPS = 60;
        title = "";
        author = "";
        _systemCommands = new Array<Dynamic>();
        
        globalSequence.initialize();
    }
    
    
    /** Append new sequence.
     *  @param sequence event list for new sequence. when null, create empty sequence.
     *  @return created sequence
     */
    public function appendNewSequence(sequence : Array<MMLEvent> = null) : MMLSequence
    {
        var seq : MMLSequence = sequenceGroup.appendNewSequence();
        if (sequence != null)             seq.fromVector(sequence);
        return seq;
    }
    
    
    /** Get sequence. 
     *  @param index The index of seuence
     */
    public function getSequence(index : Int) : MMLSequence
    {
        return sequenceGroup.getSequence(index);
    }
    
    
    /** @private calculate bpm from t command paramater */
    public function _calcBPMfromTcommand(param : Int) : Float
    {
        switch (tcommandMode)
        {
            case TCOMMAND_BPM:
                return param * tcommandResolution;
            case TCOMMAND_FRAME:
                return ((param != 0)) ? (tcommandResolution / param) : 120;
            case TCOMMAND_TIMERB:
                return ((param >= 0 && param < 256)) ? (tcommandResolution / (256 - param)) : 120;
        }
        return 0;
    }
}



