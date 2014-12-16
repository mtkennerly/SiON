//----------------------------------------------------------------------------------------------------
// SoundObjectEvent
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.events;

import openfl.events.*;
import org.si.sion.events.SiONTrackEvent;
import org.si.sion.sequencer.SiMMLTrack;

import org.si.sound.SoundObject;


/** SoundObjectEvent is dispatched by all SoundObjects. @see org.si.sound.SoundObject */
class SoundObjectEvent extends Event
{
    public var soundObject(get, never) : SoundObject;
    public var track(get, never) : SiMMLTrack;
    public var eventTriggerID(get, never) : Int;
    public var note(get, never) : Int;
    public var bufferIndex(get, never) : Int;

    // constants
    //----------------------------------------
    /** Dispatch when the note on appears.
     * <p>The properties of the event object have the following values:</p>
     * <table class='innertable'>
     * <tr><th>Property</th><th>Value</th></tr>
     * <tr><td>cancelable</td><td>false</td></tr>
     * <tr><td>soundObject</td><td>Target SoundObject.</td></tr>
     * <tr><td>track</td><td>SiMMLTrack instance executing sequence.</td></tr>
     * <tr><td>eventTriggerID</td><td>Trigger ID specifyed by setEventTrigger().</td></tr>
     * <tr><td>note</td><td>Note number.</td></tr>
     * <tr><td>bufferIndex</td><td>Buffering index</td></tr>
     * </table>
     * @eventType soundTrigger
     */
    public static inline var NOTE_ON_STREAM : String = "noteOnStream";
    
    
    /** Dispatch when the note off appears in the sequence.
     * <p>The properties of the event object have the following values:</p>
     * <table class='innertable'>
     * <tr><th>Property</th><th>Value</th></tr>
     * <tr><td>cancelable</td><td>false</td></tr>
     * <tr><td>soundObject</td><td>Target SoundObject.</td></tr>
     * <tr><td>track</td><td>SiMMLTrack instance executing sequence.</td></tr>
     * <tr><td>eventTriggerID</td><td>Trigger ID specifyed by setEventTrigger().</td></tr>
     * <tr><td>note</td><td>Note number.</td></tr>
     * <tr><td>bufferIndex</td><td>Buffering index</td></tr>
     * </table>
     * @eventType soundTrigger
     */
    public static inline var NOTE_OFF_STREAM : String = "noteOffStream";
    
    
    /** Dispatch when the sound starts.
     * <p>The properties of the event object have the following values:</p>
     * <table class='innertable'>
     * <tr><th>Property</th><th>Value</th></tr>
     * <tr><td>cancelable</td><td>false</td></tr>
     * <tr><td>soundObject</td><td>Target SoundObject.</td></tr>
     * <tr><td>track</td><td>SiMMLTrack instance executing sequence.</td></tr>
     * <tr><td>eventTriggerID</td><td>Trigger ID specifyed by setEventTrigger().</td></tr>
     * <tr><td>note</td><td>Note number.</td></tr>
     * <tr><td>bufferIndex</td><td>Buffering index</td></tr>
     * </table>
     * @eventType frameTrigger
     */
    public static inline var NOTE_ON_FRAME : String = "noteOnFrame";
    
    
    /** Dispatch when the sound ends.
     * <p>The properties of the event object have the following values:</p>
     * <table class='innertable'>
     * <tr><th>Property</th><th>Value</th></tr>
     * <tr><td>cancelable</td><td>false</td></tr>
     * <tr><td>soundObject</td><td>Target SoundObject.</td></tr>
     * <tr><td>track</td><td>SiMMLTrack instance executing sequence.</td></tr>
     * <tr><td>eventTriggerID</td><td>Trigger ID specifyed by setEventTrigger().</td></tr>
     * <tr><td>note</td><td>Note number.</td></tr>
     * <tr><td>bufferIndex</td><td>Buffering index</td></tr>
     * </table>
     * @eventType frameTrigger
     */
    public static inline var NOTE_OFF_FRAME : String = "noteOffFrame";
    
    
    /** Dispatch in each frame in PatternSequencer.
     * <p>The properties of the event object have the following values:</p>
     * <table class='innertable'>
     * <tr><th>Property</th><th>Value</th></tr>
     * <tr><td>cancelable</td><td>false</td></tr>
     * <tr><td>soundObject</td><td>Target SoundObject.</td></tr>
     * <tr><td>track</td><td>null. no meanings.</td></tr>
     * <tr><td>eventTriggerID</td><td>Trigger ID specifyed by setEventTrigger().</td></tr>
     * <tr><td>note</td><td>Note number.</td></tr>
     * <tr><td>bufferIndex</td><td>0. no meanings</td></tr>
     * </table>
     * @eventType sequencerTrigger
     */
    public static inline var ENTER_FRAME : String = "soundObjectEnterFrame";
    
    
    /** Dispatch in each segment in PatternSequencer.
     * <p>The properties of the event object have the following values:</p>
     * <table class='innertable'>
     * <tr><th>Property</th><th>Value</th></tr>
     * <tr><td>cancelable</td><td>false</td></tr>
     * <tr><td>soundObject</td><td>Target SoundObject.</td></tr>
     * <tr><td>track</td><td>null. no meanings.</td></tr>
     * <tr><td>eventTriggerID</td><td>Trigger ID specifyed by setEventTrigger().</td></tr>
     * <tr><td>note</td><td>0. no meanings</td></tr>
     * <tr><td>bufferIndex</td><td>0. no meanings</td></tr>
     * </table>
     * @eventType sequencerTrigger
     */
    public static inline var ENTER_SEGMENT : String = "soundObjectEnterSegment";
    
    
    
    
    // variables
    //----------------------------------------
    /** @private target sound object */
    private var _soundObject : SoundObject;
    
    /** @private current track */
    private var _track : SiMMLTrack;
    
    /** @private trigger event id */
    public var _eventTriggerID : Int;
    
    /** @private note number */
    public var _note : Int;
    
    /** @private buffering index */
    private var _bufferIndex : Int;
    
    
    
    
    // properties
    //----------------------------------------
    /** Target sound object */
    private function get_soundObject() : SoundObject{return _soundObject;
    }
    
    /** Sequencer track instance. */
    private function get_track() : SiMMLTrack{return _track;
    }
    
    /** Trigger ID. */
    private function get_eventTriggerID() : Int{return _eventTriggerID;
    }
    
    /** Note number. */
    private function get_note() : Int{return _note;
    }
    
    /** Buffering index. */
    private function get_bufferIndex() : Int{return _bufferIndex;
    }
    
    
    
    
    // functions
    //----------------------------------------
    /** @private */
    public function new(type : String, soundObject : SoundObject, trackEvent : SiONTrackEvent)
    {
        super(type, false, false);
        _soundObject = soundObject;
        if (trackEvent != null) {
            _track = trackEvent.track;
            _eventTriggerID = trackEvent.eventTriggerID;
            _note = trackEvent.note;
            _bufferIndex = trackEvent.bufferIndex;
        }
    }
}




