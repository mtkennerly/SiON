//----------------------------------------------------------------------------------------------------
//  MMLExecutor connector.
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.base;

import openfl.errors.Error;
import org.si.sion.sequencer.base.MMLSequence;
import org.si.sion.sequencer.base.MMLSequenceGroup;

import org.si.sion.module.SiOPMModule;
import org.si.sion.module.channels.SiOPMChannelBase;


/** @private MML executor connector. this class is used for #FM connection. */
class MMLExecutorConnector
{
    public var executorCount(get, never) : Int;
    public var sequenceCount(get, never) : Int;

    // variables
    //--------------------------------------------------
    private var _sequenceCount : Int;  // sequence count  
    private var _executorCount : Int;  // executor count  
    private var _firstElem : MECElement;  // first information of connection  

    // properties
    //--------------------------------------------------
    /** The count of require executor. */
    private function get_executorCount() : Int{
        return _executorCount;
    }
    /** The count of require sequence. */
    private function get_sequenceCount() : Int{
        return _sequenceCount;
    }

    // constructor
    //--------------------------------------------------
    public function new()
    {
        _firstElem = null;
        _executorCount = 0;
        _sequenceCount = 0;
    }
    
    
    
    
    // operation
    //--------------------------------------------------
    /** Free all elements. */
    public function clear() : Void
    {
        function _free(elem : MECElement) : Void {
            if (elem.firstChild != null) _free(elem.firstChild);
            if (elem.next       != null) _free(elem.next);
            MECElement.free(elem);
        };

        if (_firstElem != null) _free(_firstElem);
        _firstElem = null;
        _executorCount = 0;
        _sequenceCount = 0;
    }
    
    
    /** Parse connection formula. */
    public function parse(form : String) : Void
    {
        var i : Int;
        var imax : Int;
        var prev : MECElement = null;
        var elem : MECElement;
        var alp : String = "abcdefghijklmnopqrstuvwxyz";
        var rex : EReg = new EReg('(\\()?([a-zA-Z])([0-7])?(\\)+)?', "g");
        
        // initialize
        clear();
        
        // parse
        while (rex.match(form)) {
            // get current oscillator number
            i = alp.indexOf(rex.matched(2).toLowerCase());
            if (_sequenceCount <= i) _sequenceCount = i + 1;
            _executorCount++;
            elem = MECElement.alloc(i);
            if (rex.matched(3) != null) elem.modulation = Std.parseInt(rex.matched(3))
            else elem.modulation = 5;
            
            // modulation start "("
            if (rex.matched(1) != null) {
                if (prev == null) throw _errorWrongFormula("'(' in " + form);
                prev.firstChild = elem;
                elem.parent = prev;
            }
            else {
                if (prev != null) {
                    prev.next = elem;
                    elem.parent = prev.parent;
                }
                else {
                    _firstElem = elem;
                }
            }

            // modulation end ")+"
            if (rex.matched(4) != null) {
                imax = rex.matched(4).length;
                for (i in 0...imax) {
                    if (elem.parent == null) throw _errorWrongFormula("')' in " + form);
                    elem = elem.parent;
                }
            }
            prev = elem;
        }
        
        if (prev == null || prev.parent != null) {
            throw _errorWrongFormula(form);
        }
    }
    
    
    /** Connect executors. */
    public function connect(seqGroup : MMLSequenceGroup, prev : MMLSequence) : MMLSequence
    {
        var seqList : Array<MMLSequence> = new Array<MMLSequence>();

        // connection sub
        function _connect(elem : MECElement, firstOsc : Bool, outPipe : Int) : Void {
            var inPipe : Int = 0;
            // modulator before carrior
            if (elem.firstChild != null) {
                inPipe = outPipe + (((firstOsc)) ? 0 : 1);
                _connect(elem.firstChild, true, inPipe);
            }

            // assign sequence to executor
            var preprocess : MMLSequence = seqGroup._newSequence();
            preprocess.initialize();
            //trace("#FM "+elem.number+";");

            // out pipe
            if (outPipe != -1) {
                preprocess.appendNewEvent(MMLEvent.OUTPUT_PIPE, ((firstOsc)) ? SiOPMChannelBase.OUTPUT_OVERWRITE : SiOPMChannelBase.OUTPUT_ADD);
                preprocess.appendNewEvent(MMLEvent.PARAMETER, outPipe);
            }
            else {
                preprocess.appendNewEvent(MMLEvent.OUTPUT_PIPE, SiOPMChannelBase.OUTPUT_STANDARD);
                preprocess.appendNewEvent(MMLEvent.PARAMETER, 0);
            }

            // in pipe
            if (elem.firstChild != null) {
                preprocess.appendNewEvent(MMLEvent.INPUT_PIPE, elem.modulation);
                preprocess.appendNewEvent(MMLEvent.PARAMETER, inPipe);
            }
            else {
                preprocess.appendNewEvent(MMLEvent.INPUT_PIPE, 0);
                preprocess.appendNewEvent(MMLEvent.PARAMETER, 0);
            }

            // connect preprocess and main sequence
            preprocess.connectBefore(seqList[elem.number].headEvent.next);
            // connect preprocess on sequence chain
            preprocess._insertAfter(prev);
            prev = preprocess;
            //trace(preprocess);

            // next oscillator
            if (elem.next != null)                 _connect(elem.next, false, outPipe);
        };

        // create sequence list
        for (i in 0..._sequenceCount){
            if (prev.nextSequence == null)                 throw _errorSequenceNotEnough();
            seqList[i] = prev.nextSequence;
            prev.nextSequence._removeFromChain();
        }

        // set executors connections
        _connect(_firstElem, false, -1);
        
        return prev;
    }
    
    
    
    
    // errors
    //--------------------------------------------------
    private function _errorWrongFormula(form : String) : Error
    {
        return new Error("MMLExecutorConnector error : Wrong connection formula. " + form);
    }
    
    
    private function _errorSequenceNotEnough() : Error
    {
        return new Error("MMLExecutorConnector error: Not enough sequences to connect.");
    }
}





// MMLExecutorConnector element class
class MECElement
{
    public var number : Int;
    public var modulation : Int;
    public var parent : MECElement = null;
    public var next : MECElement = null;
    public var firstChild : MECElement = null;
    
    public function new()
    {
    }
    
    public function initialize(num : Int) : MECElement
    {
        number = num;
        parent = null;
        next = null;
        firstChild = null;
        modulation = 3;
        return this;
    }
    
    
    // Factory
    private static var _freeList : Array<Dynamic> = [];
    public static function free(elem : MECElement) : Void{
        _freeList.push(elem);
    }
    public static function alloc(number : Int) : MECElement{
        var elem : MECElement = _freeList.pop();
        if (elem == null) elem = new MECElement();
        return elem.initialize(number);
    }
}





