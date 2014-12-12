//----------------------------------------------------------------------------------------------------
// Class for sound object playing MML
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound;

import org.si.sound.SoundObject;

import org.si.sion.*;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sion.sequencer.SiMMLSequencer;
import org.si.sion.sequencer.base.MMLSequence;
import org.si.sound.synthesizers.SynthesizerInternal;


/** MML Player provides sequence sound written by MML, and you can control all tracks during playing sequence. */
class MMLPlayer extends SoundObject
{
    public var mml(get, set) : String;
    public var data(get, never) : SiONData;
    public var controlTrackNumber(get, set) : Int;
    public var trackCount(get, never) : Int;
    public var soloTrackNumber(get, set) : Int;

    // variables
    //----------------------------------------
    /** @private [protected] mml text. */
    private var _mml : String;
    
    /** @private [protected] sequence data. */
    private var _data : SiONData;
    
    /** @private [protected] flag that mml text is compiled to data */
    private var _compiled : Bool;
    
    /** @private [protected] current controling track number */
    private var _controlTrackNumber : Int;
    
    /** @private [protected] track muting status */
    private var _trackMute : Array<Bool>;
    
    /** @private [protected] solo track number */
    private var _soloTrackNumber : Int;
    
    
    
    
    // properties
    //----------------------------------------
    /** MML text */
    private function get_mml() : String{return _mml;
    }
    private function set_mml(str : String) : String{
        _mml = str || "";
        _compiled = false;
        _compile();
        return str;
    }
    
    
    /** sequence data to play */
    private function get_data() : SiONData{return _data;
    }
    
    
    /** current controling track number */
    private function get_controlTrackNumber() : Int{return _controlTrackNumber;
    }
    private function set_controlTrackNumber(n : Int) : Int{
        _controlTrackNumber = n;
        if (_tracks) {
            var trackNumber : Int = _controlTrackNumber;
            if (trackNumber < 0)                 trackNumber = 0
            else if (trackNumber >= _tracks.length)                 trackNumber = _tracks.length - 1;
            _track = _tracks[trackNumber];
        }
        return n;
    }
    
    
    /** number of MML playing tracks */
    private function get_trackCount() : Int{return ((_tracks)) ? _tracks.length : 0;
    }
    
    
    /** Solo track number, this value reset when call start() method. -1 sets no solo tracks. @default -1 */
    private function get_soloTrackNumber() : Int{return _soloTrackNumber;
    }
    private function set_soloTrackNumber(n : Int) : Int{
        var i : Int;
        if (_soloTrackNumber != n && _tracks) {
            _soloTrackNumber = n;
            if (_soloTrackNumber < 0) {
                for (_tracks.length){_track.channel.mute = _trackMute[i];
                }
            }
            else {
                for (_tracks.length){
                    _trackMute[i] = _track.channel.mute;
                    _track.channel.mute = (i != _soloTrackNumber);
                }
            }
        }
        return n;
    }
    
    
    /** @private */
    override private function get_coarseTune() : Int{return ((_track)) ? _track.noteShift : _noteShift;
    }
    /** @private */
    override private function get_fineTune() : Float{return ((_track)) ? (_track.pitchShift * 0.015625) : _pitchShift;
    }
    /** @private */
    override private function get_gateTime() : Float{return ((_track)) ? _track.quantRatio : _gateTime;
    }
    /** @private */
    override private function get_eventMask() : Int{return ((_track)) ? _track.eventMask : _eventMask;
    }
    
    /** @private */
    override private function get_mute() : Bool{return ((_track)) ? _track.channel.mute : _thisMute;
    }
    /** @private */
    override private function get_volume() : Float{return ((_track)) ? _track.channel.masterVolume : _thisVolume;
    }
    /** @private */
    override private function get_pan() : Float{return ((_track)) ? _track.channel.pan : _thisPan;
    }
    /** @private */
    override private function get_effectSend1() : Float{return ((_track)) ? _track.channel.getStreamSend(1) : (_volumes[1] * 0.0078125);
    }
    /** @private */
    override private function get_effectSend2() : Float{return ((_track)) ? _track.channel.getStreamSend(2) : (_volumes[2] * 0.0078125);
    }
    /** @private */
    override private function get_effectSend3() : Float{return ((_track)) ? _track.channel.getStreamSend(3) : (_volumes[3] * 0.0078125);
    }
    /** @private */
    override private function get_effectSend4() : Float{return ((_track)) ? _track.channel.getStreamSend(4) : (_volumes[4] * 0.0078125);
    }
    /** @private */
    override private function get_pitchBend() : Float{return ((_track)) ? (_track.pitchBend * 0.015625) : _pitchBend;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor */
    public function new(mml : String = null)
    {
        _data = new SiONData();
        this.mml = mml;
        super(_data.title);
        _controlTrackNumber = 0;
        _trackMute = new Array<Bool>();
    }
    
    
    
    
    // operations
    //----------------------------------------
    /** Play mml data. */
    override public function play() : Void{
        _compile();
        stop();
        _soloTrackNumber = -1;
        _tracks = _sequenceOn(_data, false);
        if (_tracks) {
            _trackMute.length = _tracks.length;
            for (i in 0..._tracks.length){_trackMute[i] = false;
            }
            _synthesizer._registerTracks(_tracks);
            var trackNumber : Int = _controlTrackNumber;
            if (trackNumber < 0)                 trackNumber = 0
            else if (trackNumber >= _tracks.length)                 trackNumber = _tracks.length - 1;
            _track = _tracks[trackNumber];
        }
    }
    
    
    /** Stop mml data. */
    override public function stop() : Void{
        if (_tracks) {
            _synthesizer._unregisterTracks(_tracks[0], _tracks.length);
            for (t/* AS3HX WARNING could not determine type for var: t exp: EIdent(_tracks) type: null */ in _tracks)t.setDisposable();
            _tracks = null;
            _sequenceOff(false);
        }
        _stopEffect();
    }
    
    
    
    
    // internal
    //----------------------------------------
    /** @private [protected] call this after the update mml */
    private function _compile() : Void{
        if (!driver || _compiled)             return;
        if (_mml != "") {
            driver.compile(_mml, _data);
            name = _data.title;
        }
        else {
            _data.clear();
            name = "";
        }
        _compiled = true;
    }
}


