//----------------------------------------------------------------------------------------------------
// Multi track Sound object
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound;

import org.si.sound.SoundObject;
import org.si.sound.VoiceReference;

import org.si.sion.*;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sound.namespaces.SoundObjectInternal;
import org.si.sound.synthesizers.*;


/** The MultiTrackSoundObject class is the base class for all objects that can control plural tracks. 
 */
class MultiTrackSoundObject extends SoundObject
{
    public var trackCount(get, never) : Int;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    /** @private [protected] mask for tracks operation. */
    private var _trackOperationMask : Int;
    
    
    
    
    // properties
    //----------------------------------------
    /** Returns the number of tracks. */
    private function get_trackCount() : Int{return ((_tracks)) ? _tracks.length : 0;
    }
    
    
    
    
    // properties
    //----------------------------------------
    /** @private */
    override private function get_isPlaying() : Bool{return (_tracks != null);
    }
    
    
    /** @private */
    override private function set_coarseTune(n : Int) : Int{
        super.coarseTune = n;
        if (_tracks) {
            var i : Int;
            var f : Int;
            var imax : Int = _tracks.length;
            i = 0;
f = _trackOperationMask;
            while (i < imax){
                if ((f & 1) == 0)                     _tracks[i].noteShift = _noteShift;
                i++;
                f >>= 1;
            }
        }
        return n;
    }
    
    /** @private */
    override private function set_fineTune(p : Float) : Float{
        super.fineTune = p;
        if (_tracks) {
            var i : Int;
            var f : Int;
            var imax : Int = _tracks.length;
            var ps : Int = _pitchShift * 64;
            i = 0;
f = _trackOperationMask;
            while (i < imax){
                if ((f & 1) == 0)                     _tracks[i].pitchShift = ps;
                i++;
                f >>= 1;
            }
        }
        return p;
    }
    
    /** @private */
    override private function set_gateTime(g : Float) : Float{
        super.gateTime = g;
        if (_tracks) {
            var i : Int;
            var f : Int;
            var imax : Int = _tracks.length;
            i = 0;
f = _trackOperationMask;
            while (i < imax){
                if ((f & 1) == 0)                     _tracks[i].quantRatio = _gateTime;
                i++;
                f >>= 1;
            }
        }
        return g;
    }
    
    /** @private */
    override private function set_eventMask(m : Int) : Int{
        super.eventMask = m;
        if (_tracks) {
            var i : Int;
            var f : Int;
            var imax : Int = _tracks.length;
            i = 0;
f = _trackOperationMask;
            while (i < imax){
                if ((f & 1) == 0)                     _tracks[i].eventMask = _eventMask;
                i++;
                f >>= 1;
            }
        }
        return m;
    }
    
    /** @private */
    override private function set_mute(m : Bool) : Bool{
        super.mute = m;
        if (_tracks) {
            var i : Int;
            var f : Int;
            var imax : Int = _tracks.length;
            i = 0;
f = _trackOperationMask;
            while (i < imax){
                if ((f & 1) == 0)                     _tracks[i].channel.mute = _mute;
                i++;
                f >>= 1;
            }
        }
        return m;
    }
    
    /** @private */
    override private function set_pan(p : Float) : Float{
        super.pan = p;
        if (_tracks) {
            var i : Int;
            var f : Int;
            var imax : Int = _tracks.length;
            i = 0;
f = _trackOperationMask;
            while (i < imax){
                if ((f & 1) == 0)                     _tracks[i].channel.pan = _pan * 64;
                i++;
                f >>= 1;
            }
        }
        return p;
    }
    
    
    /** @private */
    override private function set_pitchBend(p : Float) : Float{
        super.pitchBend = p;
        if (_tracks) {
            var i : Int;
            var f : Int;
            var pb : Int = p * 64;
            var imax : Int = _tracks.length;
            i = 0;
f = _trackOperationMask;
            while (i < imax){
                if ((f & 1) == 0)                     _tracks[i].pitchBend = pb;
                i++;
                f >>= 1;
            }
        }
        return p;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** @private [protected] constructor */
    public function new(name : String = null, synth : VoiceReference = null)
    {
        super(name, synth);
        _tracks = null;
        _trackOperationMask = 0;
    }
    
    
    
    
    // operations
    //----------------------------------------
    /** @private [protected] Reset */
    override public function reset() : Void
    {
        super.reset();
        _trackOperationMask = 0;
    }
    
    
    /** you cannot call play() in MultiTrackSoundObject. */
    override public function play() : Void{
        _errorNotAvailable("play()");
    }
    
    
    /** you cannot call stop() in MultiTrackSoundObject. */
    override public function stop() : Void{
        _errorNotAvailable("stop()");
    }
    
    
    /** @private [protected] Stop all sound belonging to this sound object. */
    private function _stopAllTracks() : Void{
        if (_tracks) {
            for (t/* AS3HX WARNING could not determine type for var: t exp: EIdent(_tracks) type: null */ in _tracks){
                _synthesizer._unregisterTracks(t);
                t.setDisposable();
            }
            _tracks = null;
        }
        _stopEffect();
    }
    
    
    /** @private [protected] update stream send level */
    override private function _updateStreamSend(streamNum : Int, level : Float) : Void{
        if (_tracks) {
            if (_effectChain)                 _effectChain.setStreamSend(streamNum, level)
            else {
                var i : Int;
                var f : Int;
                var imax : Int = _tracks.length;
                i = 0;
f = _trackOperationMask;
                while (i < imax){
                    if ((f & 1) == 0)                         _tracks[i].channel.setStreamSend(streamNum, level);
                    i++;
                    f >>= 1;
                }
            }
        }
    }
}


