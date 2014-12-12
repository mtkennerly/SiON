//----------------------------------------------------------------------------------------------------
// SiON Effect Module
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;

import org.si.sion.module.SiOPMModule;
import org.si.sion.module.SiOPMStream;



/** Effect Module. */

import org.si.sion.effector.SiEffectBase;

class SiEffectModule
{
    public var globalEffectCount(get, never) : Int;
    public var slot0(never, set) : Array<SiEffectBase>;
    public var slot1(never, set) : Array<SiEffectBase>;
    public var slot2(never, set) : Array<SiEffectBase>;
    public var slot3(never, set) : Array<SiEffectBase>;
    public var slot4(never, set) : Array<SiEffectBase>;
    public var slot5(never, set) : Array<SiEffectBase>;
    public var slot6(never, set) : Array<SiEffectBase>;
    public var slot7(never, set) : Array<SiEffectBase>;

    // constant
    //--------------------------------------------------------------------------------
    
    
    
    
    // variables
    //--------------------------------------------------------------------------------
    private var _module : SiOPMModule;
    private var _freeEffectStreams : Array<SiEffectStream>;
    private var _localEffects : Array<SiEffectStream>;
    private var _globalEffects : Array<SiEffectStream>;
    private var _masterEffect : SiEffectStream;
    private var _globalEffectCount : Int;
    private static var _effectorInstances : Map<String, EffectorInstances> = new Map<String, EffectorInstances>();
    
    
    
    
    // properties
    //--------------------------------------------------------------------------------
    /** Number of global effect */
    private function get_globalEffectCount() : Int{return _globalEffectCount;
    }
    
    
    /** effector slot 0 */
    private function set_slot0(list : Array<SiEffectBase>) : Array<SiEffectBase>{
        setEffectorList(0, list);
        return list;
    }
    
    /** effector slot 1 */
    private function set_slot1(list : Array<SiEffectBase>) : Array<SiEffectBase>{setEffectorList(1, list);
        return list;
    }
    
    /** effector slot 2 */
    private function set_slot2(list : Array<SiEffectBase>) : Array<SiEffectBase>{setEffectorList(2, list);
        return list;
    }
    
    /** effector slot 3 */
    private function set_slot3(list : Array<SiEffectBase>) : Array<SiEffectBase>{setEffectorList(3, list);
        return list;
    }
    
    /** effector slot 4 */
    private function set_slot4(list : Array<SiEffectBase>) : Array<SiEffectBase>{setEffectorList(4, list);
        return list;
    }
    
    /** effector slot 5 */
    private function set_slot5(list : Array<SiEffectBase>) : Array<SiEffectBase>{setEffectorList(5, list);
        return list;
    }
    
    /** effector slot 6 */
    private function set_slot6(list : Array<SiEffectBase>) : Array<SiEffectBase> {
        setEffectorList(6, list);
        return list;
    }
    
    /** effector slot 7 */
    private function set_slot7(list : Array<SiEffectBase>) : Array<SiEffectBase> {
        setEffectorList(7, list);
        return list;
    }
    
    
    
    
    // constructor
    //--------------------------------------------------------------------------------
    /** Constructor. */
    public function new(module : SiOPMModule)
    {
        _module = module;
        _freeEffectStreams = new Array<SiEffectStream>();
        _localEffects = new Array<SiEffectStream>();
        _globalEffects = new Array<SiEffectStream>();
        _masterEffect = new SiEffectStream(_module, _module.outputStream);
        _globalEffects[0] = _masterEffect;
        _globalEffectCount = 0;
        
        // initialize table
        var dummy : SiEffectTable = SiEffectTable.instance;
        
        // register default effectors
        register("ws", SiEffectWaveShaper);
        register("eq", SiEffectEqualiser);
        register("delay", SiEffectStereoDelay);
        register("reverb", SiEffectStereoReverb);
        register("chorus", SiEffectStereoChorus);
        register("autopan", SiEffectAutoPan);
        register("ds", SiEffectDownSampler);
        register("speaker", SiEffectSpeakerSimulator);
        register("comp", SiEffectCompressor);
        register("dist", SiEffectDistortion);
        register("stereo", SiEffectStereoExpander);
        register("vowel", SiFilterVowel);
        
        register("lf", SiFilterLowPass);
        register("hf", SiFilterHighPass);
        register("bf", SiFilterBandPass);
        register("nf", SiFilterNotch);
        register("pf", SiFilterPeak);
        register("af", SiFilterAllPass);
        register("lb", SiFilterLowBoost);
        register("hb", SiFilterHighBoost);
        
        register("nlf", SiCtrlFilterLowPass);
        register("nhf", SiCtrlFilterHighPass);
    }
    
    
    
    
    // operations
    //--------------------------------------------------------------------------------
    /** Initialize all effectors. This function is called from SiONDriver.play() with the 2nd argment true. 
     *  When you want to connect effectors by code, you have to call this first, then call connect() and SiONDriver.play() with the 2nd argment false.
     */
    public function initialize() : Void
    {
        var es : SiEffectStream;
        var i : Int;
        
        // local effects
        for (es in _localEffects){
            es.free();
            _freeEffectStreams.push(es);
        }
        _localEffects.splice(0,_localEffects.length);
        
        // global effects
        for (i in 0...SiOPMModule.STREAM_SEND_SIZE){
            if (_globalEffects[i] != null) {
                _globalEffects[i].free();
                _freeEffectStreams.push(_globalEffects[i]);
                _globalEffects[i] = null;
            }
        }
        _globalEffectCount = 0;
        
        // master effect
        _masterEffect.initialize(0);
        _globalEffects[0] = _masterEffect;
    }
    
    
    /** @private [sion internal] reset all buffers */
    public function _reset() : Void
    {
        var es : SiEffectStream;
        var i : Int;
        
        // local effects
        for (es in _localEffects)es.reset();
        
        // global effects
        for (i in 0...SiOPMModule.STREAM_SEND_SIZE) {
            if (_globalEffects[i] != null) _globalEffects[i].reset();
        }

        // master effect
        _masterEffect.reset();
        _globalEffects[0] = _masterEffect;
    }
    
    
    /** @private [sion internal] prepare for processing. */
    public function _prepareProcess() : Void
    {
        var slot : Int;
        var channelCount : Int;
        var slotMax : Int = _localEffects.length;
        
        // do nothing on local effect
        
        // global effect (slot1-slot7)
        _globalEffectCount = 0;
        for (slot in 1...SiOPMModule.STREAM_SEND_SIZE){
            _module.streamSlot[slot] = null;  // reset module's stream slot  
            if (_globalEffects[slot] != null) {
                channelCount = _globalEffects[slot].prepareProcess();
                if (channelCount > 0) {
                    _module.streamSlot[slot] = _globalEffects[slot]._stream;
                    _globalEffectCount++;
                }
            }
        }

        // master effect (slot0)
        _masterEffect.prepareProcess();
    }
    
    
    /** @private [sion internal] Clear output buffer. */
    public function _beginProcess() : Void
    {
        var slot : Int;
        var leLength : Int = _localEffects.length;
        
        // local effect
        for (slot in 0...leLength) {
            _localEffects[slot]._stream.clear();
        }

        // global effect (slot1-slot7)
        for (slot in 1...SiOPMModule.STREAM_SEND_SIZE) {
            if (_globalEffects[slot] != null) _globalEffects[slot]._stream.clear();
        }

        // do nothing on master effect
    }
    
    
    /** @private [sion internal] processing. */
    public function _endProcess() : Void
    {
        var i : Int;
        var slot : Int;
        var leLength : Int = _localEffects.length;
        var buffer : Array<Float>;
        var effect : SiEffectStream;
        var bufferLength : Int = _module.bufferLength;
        var output : Array<Float> = _module.output;
        var imax : Int = output.length;
        
        // local effect
        for (slot in 0...leLength){
            _localEffects[slot].process(0, bufferLength);
        }

        // global effect (slot1-slot7)
        for (slot in 1...SiOPMModule.STREAM_SEND_SIZE){
            effect = _globalEffects[slot];
            if (effect != null) {
                if (effect._outputDirectly) {
                    effect.process(0, bufferLength, false);
                    buffer = effect._stream.buffer;
                    for (i in 0...imax) {
                        output[i] += buffer[i];
                    }
                }
                else {
                    effect.process(0, bufferLength, true);
                }
            }
        }

        // master effect (slot0)
        _masterEffect.process(0, bufferLength, false);
    }
    
    
    
    
    // effector instance manager
    //--------------------------------------------------------------------------------
    /** Register effector class
     *  @param name Effector name.
     *  @param cls SiEffectBase based class.
     */
    public static function register(name : String, cls : Class<Dynamic>) : Void
    {
        _effectorInstances[name] = new EffectorInstances(cls);
    }
    
    
    /** Get effector instance by name 
     *  @param name Effector name in mml.
     */
    public static function getInstance(name : String) : SiEffectBase
    {
        if (!_effectorInstances.exists(name)) return null;
        
        var effect : SiEffectBase;
        var factory : EffectorInstances = _effectorInstances[name];
        for (effect in factory._instances) {
            if (effect._isFree) {
                effect._isFree = false;
                effect.initialize();
                return effect;
            }
        }
        effect = Reflect.callMethod(factory._classInstance, Reflect.field(factory._classInstance, "new"), []);
        factory._instances.push(effect);
        
        effect._isFree = false;
        effect.initialize();
        return effect;
    }
    
    // effector connection
    //--------------------------------------------------------------------------------
    /** Clear effector slot. 
     *  @param slot Effector slot number.
     */
    public function clear(slot : Int) : Void
    {
        if (slot == 0) {
            _masterEffect.initialize(0);
        }
        else {
            if (_globalEffects[slot] != null) _freeEffectStreams.push(_globalEffects[slot]);
            _globalEffects[slot] = null;
        }
    }
    
    
    /** Get effector list of specifyed slot
     *  @param slot Effector slot number.
     *  @return Vector of Effector list.
     */
    public function getEffectorList(slot : Int) : Array<SiEffectBase>
    {
        if (_globalEffects[slot] == null)             return null;
        return _globalEffects[slot].chain;
    }
    
    
    /** Set effector list of specifyed slot
     *  @param slot Effector slot number.
     *  @param list Effector list to set
     */
    public function setEffectorList(slot : Int, list : Array<SiEffectBase>) : Void
    {
        var es : SiEffectStream = _globalEffector(slot);
        es.chain = list;
        es.prepareProcess();
    }
    
    
    /** Connect effector to the global/master slot.
     *  @param slot Effector slot number.
     *  @param effector Effector instance.
     */
    public function connect(slot : Int, effector : SiEffectBase) : Void
    {
        _globalEffector(slot).chain.push(effector);
        effector.prepareProcess();
    }
    
    
    /** Parse MML for global/master effectors
     *  @param slot Effector slot number.
     *  @param mml MML string.
     *  @param postfix Postfix string.
     */
    public function parseMML(slot : Int, mml : String, postfix : String) : Void
    {
        _globalEffector(slot).parseMML(slot, mml, postfix);
    }
    
    
    /** Create new local effector connector. deeper effectors executes first. */
    public function newLocalEffect(depth : Int, list : Array<SiEffectBase>) : SiEffectStream
    {
        var inst : SiEffectStream = _allocStream(depth);
        inst.chain = list;
        inst.prepareProcess();
        if (depth == 0) {
            _localEffects.push(inst);
            return inst;
        }
        else {
            var slot : Int = _localEffects.length - 1;
            while (slot >= 0){
                if (_localEffects[slot]._depth >= depth) {
                    _localEffects.insert(slot, inst);
                    return inst;
                }
                --slot;
            }
        }
        _localEffects.unshift(inst);
        return inst;
    }
    
    
    /** Delete local effector connector */
    public function deleteLocalEffect(inst : SiEffectStream) : Void
    {
        var i : Int = Lambda.indexOf(_localEffects, inst);
        if (i != -1)             _localEffects.splice(i, 1);
        _freeEffectStreams.push(inst);
    }
    
    
    // get and alloc SiEffectStream if its null
    private function _globalEffector(slot : Int) : SiEffectStream{
        if (_globalEffects[slot] == null) {
            var es : SiEffectStream = _allocStream(0);
            _globalEffects[slot] = es;
            _module.streamSlot[slot] = es._stream;
            _globalEffectCount++;
        }
        return _globalEffects[slot];
    }
    
    
    
    
    // functory
    //--------------------------------------------------------------------------------
    private function _allocStream(depth : Int) : SiEffectStream
    {
        var es : SiEffectStream = _freeEffectStreams.pop();
        if (es == null) es = new SiEffectStream(_module);
        es.initialize(depth);
        return es;
    }
}





// effector instance manager
class EffectorInstances
{
    public var _instances : Array<Dynamic> = [];
    public var _classInstance : Class<Dynamic>;
    
    public function new(cls : Class<Dynamic>)
    {
        _classInstance = cls;
    }
}


