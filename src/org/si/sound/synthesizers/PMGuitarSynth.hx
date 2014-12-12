// Physical Modeling Guitar Synthesizer
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.synthesizers;

import org.si.sound.synthesizers.SiOPMChannelKS;

import org.si.sion.*;
import org.si.sion.module.channels.*;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sound.SoundObject;


/** Physical Modeling Guitar Synthesizer
 */
class PMGuitarSynth extends BasicSynth
{
    public var tensoin(get, set) : Float;
    public var plunkVelocity(get, set) : Float;
    public var seedWaveShape(get, set) : Int;
    public var seedPitch(get, set) : Int;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    /** @private [protected] plunk velocity [0-1]. */
    private var _plunkVelocity : Float;
    
    /** @private [protected] tl offset by attack rate. */
    private var _tlOffsetByAR : Float;
    
    
    
    // properties
    //----------------------------------------
    /** string tensoin [0-1]. */
    private function get_tensoin() : Float{return _voice.pmsTension * 0.015873015873015872;
    }
    private function set_tensoin(t : Float) : Float{
        _voice.pmsTension = t * 63;
        _voiceUpdateNumber++;
        var i : Int;
        var imax : Int = _tracks.length;
        var ch : SiOPMChannelKS;
        for (imax){
            ch = try cast(_tracks[i].channel, SiOPMChannelKS) catch(e:Dynamic) null;
            if (ch != null)                 ch.setAllReleaseRate(_voice.pmsTension);
        }
        return t;
    }
    
    
    /** plunk velocity [0-1]. */
    private function get_plunkVelocity() : Float{return _plunkVelocity;
    }
    private function set_plunkVelocity(v : Float) : Float{
        _plunkVelocity = ((v < 0)) ? 0 : ((v > 1)) ? 1 : v;
        _voice.channelParam.operatorParam[0].tl = ((_plunkVelocity == 0)) ? 127 : (_plunkVelocity * 64 - _tlOffsetByAR);
        _voiceUpdateNumber++;
        return v;
    }
    
    
    /** wave shape of plunk noise. @default 20 (SiOPMTable.PG_NOISE_PINK) */
    private function get_seedWaveShape() : Int{return _voice.channelParam.operatorParam[0].pgType;
    }
    private function set_seedWaveShape(ws : Int) : Int{
        _voice.channelParam.operatorParam[0].setPGType(ws);
        _voiceUpdateNumber++;
        return ws;
    }
    
    
    /** pitch of plunk noise. @default 68 */
    private function get_seedPitch() : Int{return _voice.channelParam.operatorParam[0].fixedPitch;
    }
    private function set_seedPitch(p : Int) : Int{
        _voice.channelParam.operatorParam[0].fixedPitch = p;
        _voiceUpdateNumber++;
        return p;
    }
    
    
    /** attack time of plunk noise (0-1). */
    override private function get_attackTime() : Float{
        var iar : Int = _voice.channelParam.operatorParam[0].ar;
        return ((iar > 48)) ? 0 : (1 - (iar - 16) * 0.03125);
    }
    override private function set_attackTime(n : Float) : Float{
        var iar : Int = ((1 - n) * 32) + 16;
        _tlOffsetByAR = n * 16;
        _voice.channelParam.operatorParam[0].ar = iar;
        _voice.channelParam.operatorParam[0].tl = ((_plunkVelocity == 0)) ? 127 : (_plunkVelocity * 64 - _tlOffsetByAR);
        _voiceUpdateNumber++;
        return n;
    }
    
    
    /** release time of guitar synthesizer is equal to (1-tension). */
    override private function get_releaseTime() : Float{return 1 - _voice.pmsTension * 0.015625;
    }
    override private function set_releaseTime(n : Float) : Float{
        _voice.pmsTension = 64 - n * 64;
        if (_voice.pmsTension < 0)             _voice.pmsTension = 0
        else if (_voice.pmsTension > 63)             _voice.pmsTension = 63;
        return n;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor 
     *  @param tension sustain rate of the tone
     */
    public function new(tension : Float = 0.125)
    {
        super();
        _voice.setPMSGuitar(48, 48, 0, 68, 20, Math.floor(tension * 63));
        attackTime = 0;
        plunkVelocity = 1;
    }
    
    
    
    
    // operation
    //----------------------------------------
    /** Set all parameters of phisical modeling synth guitar voice.
     *  @param ar attack rate of plunk energy
     *  @param dr decay rate of plunk energy
     *  @param tl total level of plunk energy
     *  @param fixedPitch plunk noise pitch
     *  @param ws wave shape of plunk
     *  @param tension sustain rate of the tone
     */
    public function setPMSGuitar(ar : Int = 48, dr : Int = 48, tl : Int = 0, fixedPitch : Int = 68, ws : Int = 20, tension : Int = 8) : PMGuitarSynth
    {
        _voice.setPMSGuitar(ar, dr, tl, fixedPitch, ws, tension);
        _voiceUpdateNumber++;
        return this;
    }
}



