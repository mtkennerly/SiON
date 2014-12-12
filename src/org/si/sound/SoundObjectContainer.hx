//----------------------------------------------------------------------------------------------------
// Sound object container
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound;

import org.si.sound.SiONVoice;

import org.si.sion.*;
import org.si.sound.synthesizers.*;
import org.si.sound.core.EffectChain;



/** The SoundObjectContainer class is the base class for all objects that can serve as sound object containers on the sound list. 
 */
class SoundObjectContainer extends SoundObject
{
    public var numChildren(get, never) : Int;

    // namespace
    //----------------------------------------
    
    
    
    
    
    // variables
    //----------------------------------------
    /** @private [protected] the list of child sound objects. */
    private var _soundList : Array<SoundObject>;
    
    /** @private [protected] playing flag of this container */
    private var _isPlaying : Bool;
    
    
    
    
    // properties
    //----------------------------------------
    /** Returns the number of children of this object. */
    private function get_numChildren() : Int{return _soundList.length;
    }
    
    
    
    
    
    
    // properties
    //----------------------------------------
    /** @private */
    override private function get_isPlaying() : Bool{return _isPlaying;
    }
    
    
    /** @private */
    override private function set_note(n : Int) : Int{
        _note = n;
        for (sound in _soundList)sound.note = n;
        return n;
    }
    
    /** @private */
    override private function set_voice(v : SiONVoice) : SiONVoice{
        super.voice = v;
        for (sound in _soundList)sound.voice = v;
        return v;
    }
    
    /** @private */
    override private function set_synthesizer(s : VoiceReference) : VoiceReference{
        super.synthesizer = s;
        for (sound in _soundList)sound.synthesizer = s;
        return s;
    }
    
    /** @private */
    override private function set_length(l : Float) : Float{
        _length = l;
        for (sound in _soundList)sound.length = l;
        return l;
    }
    /** @private */
    override private function set_quantize(q : Float) : Float{
        _quantize = q;
        for (sound in _soundList)sound.quantize = q;
        return q;
    }
    /** @private */
    override private function set_delay(d : Float) : Float{
        _delay = d;
        for (sound in _soundList)sound.delay = d;
        return d;
    }
    
    
    /** @private */
    override private function set_eventMask(m : Int) : Int{
        _eventMask = m;
        for (sound in _soundList)sound.eventMask = m;
        return m;
    }
    /** @private */
    override private function set_eventTriggerID(id : Int) : Int{
        _eventTriggerID = id;
        for (sound in _soundList)sound.eventTriggerID = id;
        return id;
    }
    /** @private */
    override private function set_coarseTune(n : Int) : Int{
        _noteShift = n;
        for (sound in _soundList)sound.coarseTune = n;
        return n;
    }
    /** @private */
    override private function set_fineTune(p : Float) : Float{
        _pitchShift = p;
        for (sound in _soundList)sound.fineTune = p;
        return p;
    }
    /** @private */
    override private function set_gateTime(g : Float) : Float{
        _gateTime = ((g < 0)) ? 0 : ((g > 1)) ? 1 : g;
        for (sound in _soundList)sound.gateTime = g;
        return g;
    }
    
    
    /** @private */
    override private function set_effectSend1(v : Float) : Float{
        _volumes[1] = ((v < 0)) ? 0 : ((v > 1)) ? 1 : (v * 128);
        for (sound in _soundList)sound.effectSend1 = v;
        return v;
    }
    /** @private */
    override private function set_effectSend2(v : Float) : Float{
        _volumes[2] = ((v < 0)) ? 0 : ((v > 1)) ? 1 : (v * 128);
        for (sound in _soundList)sound.effectSend2 = v;
        return v;
    }
    /** @private */
    override private function set_effectSend3(v : Float) : Float{
        _volumes[3] = ((v < 0)) ? 0 : ((v > 1)) ? 1 : (v * 128);
        for (sound in _soundList)sound.effectSend3 = v;
        return v;
    }
    /** @private */
    override private function set_effectSend4(v : Float) : Float{
        _volumes[4] = ((v < 0)) ? 0 : ((v > 1)) ? 1 : (v * 128);
        for (sound in _soundList)sound.effectSend4 = v;
        return v;
    }
    /** @private */
    override private function set_pitchBend(p : Float) : Float{
        _pitchBend = p;
        for (sound in _soundList)sound.pitchBend = p;
        return p;
    }
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor. */
    public function new(name : String = "")
    {
        super(name);
        _soundList = new Array<SoundObject>();
        _thisVolume = 1;
        _isPlaying = false;
    }
    
    
    
    
    // operations
    //----------------------------------------
    /** @inheritDoc */
    override public function reset() : Void
    {
        super.reset();
        _thisVolume = 1;
        for (sound in _soundList)sound.reset();
    }
    
    
    /** Set all children's volume by index.
     *  @param slot streaming slot number.
     *  @param volume volume (0:Minimum - 1:Maximum).
     */
    override public function setVolume(slot : Int, volume : Float) : Void
    {
        _volumes[slot] = ((volume < 0)) ? 0 : ((volume > 1)) ? 128 : (volume * 128);
        for (sound in _soundList)sound.setVolume(slot, _volumes[slot]);
    }
    
    
    /** Play all children sound. */
    override public function play() : Void
    {
        _isPlaying = true;
        if (_effectChain != null && _effectChain.effectList.length > 0) {
            _effectChain._activateLocalEffect(_childDepth);
            _effectChain.setAllStreamSendLevels(_volumes);
        }
        for (sound in _soundList)sound.play();
    }
    
    
    /** Stop all children sound. */
    override public function stop() : Void
    {
        _isPlaying = false;
        for (sound in _soundList)sound.stop();
        if (_effectChain != null) {
            _effectChain._inactivateLocalEffect();
            if (_effectChain.effectList.length == 0) {
                _effectChain.free();
                _effectChain = null;
            }
        }
    }
    
    
    
    
    // operations for children
    //----------------------------------------
    /** Adds a child SoundObject instance to this SoundObjectContainer instance. The added sound object will play sound during this container is playing.
     *  The child is added to the end of all other children in this SoundObjectContainer instance. (To add a child to a specific index position, use the addChildAt() method.)
     *  If you add a child object that already has a different sound object container as a parent, the object is removed from the child list of the other sound object container. 
     *  @param sound The SoundObject instance to add as a child of this SoundObjectContainer instance.
     *  @return The SoundObject instance that you pass in the sound parameter
     */
    public function addChild(sound : SoundObject) : SoundObject
    {
        sound.stop();
        sound._setParent(this);
        _soundList.push(sound);
        if (_isPlaying)             sound.play();
        return sound;
    }
    
    
    /** Adds a child SoundObject instance to this SoundObjectContainer instance. The added sound object will play sound during this container is playing.
     *  The child is added at the index position specified. An index of 0 represents the head of the sound list for this SoundObjectContainer object. 
     *  @param sound The SoundObject instance to add as a child of this SoundObjectContainer instance.
     *  @param index The index position to which the child is added. If you specify a currently occupied index position, the child object that exists at that position and all higher positions are moved up one position in the child list.
     *  @return The child sound object at the specified index position.
     */
    public function addChildAt(sound : SoundObject, index : Int) : SoundObject
    {
        sound.stop();
        sound._setParent(this);
        if (index < _soundList.length)             _soundList.splice(index, 0, sound)
        else _soundList.push(sound);
        if (_isPlaying)             sound.play();
        return sound;
    }
    
    
    /** Removes the specified child SoundObject instance from the child list of the SoundObjectContainer instance. The removed sound object always stops.
     *  The parent property of the removed child is set to null, and the object is garbage collected if no other references to the child exist.
     *  The index positions of any sound objects after the child in the SoundObjectContainer are decreased by 1.
     *  @param sound The DisplayObject instance to remove
     *  @return The SoundObject instance that you pass in the sound parameter.
     */
    public function removeChild(sound : SoundObject) : SoundObject
    {
        var index : Int = Lambda.indexOf(_soundList, sound);
        if (index == -1)             throw cast(("SoundObjectContainer Error; Specifyed children is not in the children list."), Error);
        _soundList.splice(index, 1);
        sound.stop();
        sound._setParent(null);
        return sound;
    }
    
    
    /** Removes a child SoundObject from the specified index position in the child list of the SoundObjectContainer. The removed sound object always stops.
     *  The parent property of the removed child is set to null, and the object is garbage collected if no other references to the child exist. 
     *  The index positions of any display objects above the child in the DisplayObjectContainer are decreased by 1. 
     *  @param The child index of the SoundObject to remove. 
     *  @return The SoundObject instance that was removed. 
     */
    public function removeChildAt(index : Int) : SoundObject
    {
        if (index >= _soundList.length)             throw cast(("SoundObjectContainer Error; Specifyed index is not in the children list."), Error);
        var sound : SoundObject = _soundList.splice(index, 1)[0];
        sound.stop();
        sound._setParent(null);
        return sound;
    }
    
    
    /** Returns the child sound object instance that exists at the specified index.
     *  @param The child index of the SoundObject to find.
     *  @return founded SoundObject instance.
     */
    public function getChildAt(index : Int) : SoundObject
    {
        if (index >= _soundList.length)             throw cast(("SoundObjectContainer Error; Specifyed index is not in the children list."), Error);
        return _soundList[index];
    }
    
    
    /** Returns the child sound object that exists with the specified name. 
     *  If more than one child sound object has the specified name, the method returns the first object in the child list.
     *  @param The child name of the SoundObject to find.
     *  @return founded SoundObject instance. Returns null if its not found.
     */
    public function getChildByName(name : String) : SoundObject
    {
        for (sound in _soundList){
            if (sound.name == name)                 return sound;
        }
        return null;
    }
    
    
    /** Returns the index position of a child SoundObject instance. 
     *  @param sound The SoundObject instance want to know.
     *  @return index of specifyed SoundObject. Returns -1 if its not found.
     */
    public function getChildIndex(sound : SoundObject) : Float
    {
        return Lambda.indexOf(_soundList, sound);
    }
    
    
    /** Changes the position of an existing child in the sound object container. This affects the processing order of child objects. 
     *  @param child The child SoundObject instance for which you want to change the index number. 
     *  @param index The resulting index number for the child sound object.
     *  @param The SoundObject instance that you pass in the child parameter.
     */
    public function setChildIndex(child : SoundObject, index : Int) : SoundObject
    {
        return addChildAt(removeChild(child), index);
    }
    
    
    
    
    // oprate ancestor
    //----------------------------------------
    /** @private [internal use] */
    override @:allow(org.si.sound)
    private function _updateChildDepth() : Void
    {
        _childDepth = ((parent != null)) ? (parent._childDepth + 1) : 0;
        for (sound in _soundList)sound._updateChildDepth();
    }
    
    
    /** @private [internal use] */
    override @:allow(org.si.sound)
    private function _updateMute() : Void
    {
        super._updateMute();
        for (sound in _soundList)sound._updateMute();
    }
    
    
    /** @private [internal use] */
    override @:allow(org.si.sound)
    private function _updateVolume() : Void
    {
        super._updateVolume();
        for (sound in _soundList)sound._updateVolume();
    }
    
    
    /** @private [internal use] */
    override @:allow(org.si.sound)
    private function _limitVolume() : Void
    {
        super._limitVolume();
        for (sound in _soundList)sound._limitVolume();
    }
    
    
    /** @private [internal use] */
    override @:allow(org.si.sound)
    private function _updatePan() : Void
    {
        super._updatePan();
        for (sound in _soundList)sound._updatePan();
    }
    
    
    /** @private [internal use] */
    override @:allow(org.si.sound)
    private function _limitPan() : Void
    {
        super._limitPan();
        for (sound in _soundList)sound._limitPan();
    }
}



