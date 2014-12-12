//----------------------------------------------------------------------------------------------------
// Events for SiON Track
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.events;


import openfl.events.Event;
//import openfl.media.Sound;
//import openfl.utils.ByteArray;
import org.si.sion.SiONDriver;
import org.si.sion.SiONData;
import org.si.sion.sequencer.SiMMLTrack;



/** SiON Track Event class. */
class SiONTrackEvent extends SiONEvent
{
    public var track(get, never) : SiMMLTrack;
    public var eventTriggerID(get, never) : Int;
    public var note(get, never) : Int;
    public var bufferIndex(get, never) : Int;
    public var frameTriggerDelay(get, never) : Float;

    // constants
    //----------------------------------------
    /** Dispatch when the note on appears in the sequence with "%t" command.
     * <p>The properties of the event object have the following values:</p>
     * <table class='innertable'>
     * <tr><th>Property</th><th>Value</th></tr>
     * <tr><td>cancelable</td><td>true; mute the note</td></tr>
     * <tr><td>driver</td><td>SiONDriver instance.</td></tr>
     * <tr><td>data</td><td>SiONData instance. This property is null if you call SiONDriver.play() with null of the 1st argument.</td></tr>
     * <tr><td>streamBuffer</td><td>null</td></tr>
     * <tr><td>track</td><td>SiMMLTrack instance executing sequence.</td></tr>
     * <tr><td>eventTriggerID</td><td>Trigger ID specifyed in "%t" commands 1st argument.</td></tr>
     * <tr><td>note</td><td>Note number.</td></tr>
     * <tr><td>bufferIndex</td><td>Buffering index</td></tr>
     * </table>
     * @eventType soundTrigger
     */
    public static inline var NOTE_ON_STREAM : String = "noteOnStream";
    
    
    /** Dispatch when the note off appears in the sequence with "%t" command.
     * <p>The properties of the event object have the following values:</p>
     * <table class='innertable'>
     * <tr><th>Property</th><th>Value</th></tr>
     * <tr><td>cancelable</td><td>true; mute the note</td></tr>
     * <tr><td>driver</td><td>SiONDriver instance.</td></tr>
     * <tr><td>data</td><td>SiONData instance. This property is null if you call SiONDriver.play() with null of the 1st argument.</td></tr>
     * <tr><td>streamBuffer</td><td>null</td></tr>
     * <tr><td>track</td><td>SiMMLTrack instance executing sequence.</td></tr>
     * <tr><td>eventTriggerID</td><td>Trigger ID specifyed in "%t" commands 1st argument.</td></tr>
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
     * <tr><td>driver</td><td>SiONDriver instance.</td></tr>
     * <tr><td>data</td><td>SiONData instance. This property is null if you call SiONDriver.play() with null of the 1st argument.</td></tr>
     * <tr><td>streamBuffer</td><td>null</td></tr>
     * <tr><td>track</td><td>SiMMLTrack instance executing sequence.</td></tr>
     * <tr><td>eventTriggerID</td><td>Trigger ID specifyed in "%t" commands 1st argument.</td></tr>
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
     * <tr><td>driver</td><td>SiONDriver instance.</td></tr>
     * <tr><td>data</td><td>SiONData instance. This property is null if you call SiONDriver.play() with null of the 1st argument.</td></tr>
     * <tr><td>streamBuffer</td><td>null</td></tr>
     * <tr><td>track</td><td>SiMMLTrack instance executing sequence.</td></tr>
     * <tr><td>eventTriggerID</td><td>Trigger ID specifyed in "%t" commands 1st argument.</td></tr>
     * <tr><td>note</td><td>Note number.</td></tr>
     * <tr><td>bufferIndex</td><td>Buffering index</td></tr>
     * </table>
     * @eventType frameTrigger
     */
    public static inline var NOTE_OFF_FRAME : String = "noteOffFrame";
    
    
    /** Dispatch on beat while streaming. This event is called in each beat timing on frame. When you want to listen this event, you have to set addEventListener() before SiONDriver.play().
     * <p>The properties of the event object have the following values:</p>
     * <table class='innertable'>
     * <tr><th>Property</th><th>Value</th></tr>
     * <tr><td>cancelable</td><td>false</td></tr>
     * <tr><td>driver</td><td>SiONDriver instance playing now.</td></tr>
     * <tr><td>data</td><td>SiONData instance playing now. This property is null if you call SiONDriver.play() with null of the 1st argument.</td></tr>
     * <tr><td>streamBuffer</td><td>null.</td></tr>
     * <tr><td>track</td><td>null</td></tr>
     * <tr><td>eventTriggerID</td><td>Counter in 16th beat.</td></tr>
     * <tr><td>note</td><td>0</td></tr>
     * <tr><td>bufferIndex</td><td>Buffering index</td></tr>
     * </table>
     * @eventType stream
     */
    public static inline var BEAT : String = "beat";
    
    
    /** Dispatch when the bpm changes.
     * <p>The properties of the event object have the following values:</p>
     * <table class='innertable'>
     * <tr><th>Property</th><th>Value</th></tr>
     * <tr><td>cancelable</td><td>false</td></tr>
     * <tr><td>driver</td><td>SiONDriver instance.</td></tr>
     * <tr><td>data</td><td>SiONData instance. This property is null if you call SiONDriver.play() with null of the 1st argument.</td></tr>
     * <tr><td>streamBuffer</td><td>null</td></tr>
     * <tr><td>track</td><td>null</td></tr>
     * <tr><td>eventTriggerID</td><td>null</td></tr>
     * <tr><td>note</td><td>0</td></tr>
     * <tr><td>bufferIndex</td><td>Buffering index</td></tr>
     * </table>
     * @eventType changeBPM
     */
    public static inline var CHANGE_BPM : String = "changeBPM";
    
    
    /** Dispatch when SiONDriver.dispatchUserDefinedTrackEvent() is called.
     * <p>The properties of the event object have the following values:</p>
     * <table class='innertable'>
     * <tr><th>Property</th><th>Value</th></tr>
     * <tr><td>cancelable</td><td>false</td></tr>
     * <tr><td>driver</td><td>SiONDriver instance.</td></tr>
     * <tr><td>data</td><td>SiONData instance. This property is null if you call SiONDriver.play() with null of the 1st argument.</td></tr>
     * <tr><td>streamBuffer</td><td>null</td></tr>
     * <tr><td>track</td><td>null</td></tr>
     * <tr><td>eventTriggerID</td><td>1st argument of SiONDriver.dispatchUserDefinedTrackEvent()</td></tr>
     * <tr><td>note</td><td>2nd argument of SiONDriver.dispatchUserDefinedTrackEvent()</td></tr>
     * <tr><td>bufferIndex</td><td>Buffering index</td></tr>
     * </table>
     * @eventType changeBPM
     */
    public static inline var USER_DEFINED : String = "userDefined";
    
    
    
    
    // variables
    //----------------------------------------
    /** @private current track */
    private var _track : SiMMLTrack;
    
    /** @private trigger event id */
    private var _eventTriggerID : Int;
    
    /** @private note number */
    private var _note : Int;
    
    /** @private buffering index */
    private var _bufferIndex : Int;
    
    /** @private frame trigger delay */
    private var _frameTriggerDelay : Float;
    
    /** @private Delay frame timer */
    private var _frameTriggerTimer : Int;
    
    
    
    
    // properties
    //----------------------------------------
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
    
    /** Delay time to dispatch frame trigger event [ms]. */
    private function get_frameTriggerDelay() : Float{return _frameTriggerDelay;
    }
    
    
    
    
    // functions
    //----------------------------------------
    /** This event can be created only in the callback function inside. @private */
    public function new(type : String, driver : SiONDriver, track : SiMMLTrack, bufferIndex : Int = 0, note : Int = 0, id : Int = 0)
    {
        super(type, driver, null, true);
        _track = track;
        if (track != null) {
            _note = track.note;
            _eventTriggerID = track.eventTriggerID;
            _bufferIndex = track.channel.bufferIndex;
            _frameTriggerDelay = track.channel.bufferIndex / driver.sequencer.sampleRate + driver.latency;
            _frameTriggerTimer = Math.floor(_frameTriggerDelay);
        }
        else {
            _note = note;
            _eventTriggerID = id;
            _bufferIndex = bufferIndex;
            _frameTriggerDelay = bufferIndex / driver.sequencer.sampleRate + driver.latency;
            _frameTriggerTimer = Math.floor(_frameTriggerDelay);
        }
    }
    
    
    /** clone. */
    override public function clone() : Event
    {
        var event : SiONTrackEvent = new SiONTrackEvent(type, _driver, _track);
        event._eventTriggerID = _eventTriggerID;
        event._note = _note;
        event._bufferIndex = _bufferIndex;
        event._frameTriggerDelay = _frameTriggerDelay;
        event._frameTriggerTimer = _frameTriggerTimer;
        return event;
    }
    
    
    /** @private [sion internal] */
    public function _decrementTimer(frameRate : Int) : Bool
    {
        _frameTriggerTimer -= frameRate;
        return (_frameTriggerTimer <= 0);
    }
}


