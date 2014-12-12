//----------------------------------------------------------------------------------------------------
// Singly linked list of Number
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------




package org.si.utils;


/** Singly linked list of Number. */
class SLLNumber
{
    // variables
    //------------------------------------------------------------
    /** Number data */
    public var n : Float = 0;
    /** Nest pointer of list */
    public var next : SLLNumber = null;
    
    // free list
    private static var _freeList : SLLNumber = null;
    
    
    
    
    // constructor
    //------------------------------------------------------------
    /** Constructor */
    public function new(n : Float = 0)
    {
        this.n = n;
    }
    
    
    
    
    // allocator
    //------------------------------------------------------------
    /** Allocator */
    public static function alloc(n : Float = 0) : SLLNumber
    {
        var ret : SLLNumber;
        if (_freeList != null) {
            ret = _freeList;
            _freeList = _freeList.next;
            ret.n = n;
            ret.next = null;
        }
        else {
            ret = new SLLNumber(n);
        }
        return ret;
    }
    
    /** Allocator of linked list */
    public static function allocList(size : Int, defaultData : Float = 0) : SLLNumber
    {
        var ret : SLLNumber = alloc(defaultData);
        var elem : SLLNumber = ret;
        for (i in 1...size){
            elem.next = alloc(defaultData);
            elem = elem.next;
        }
        return ret;
    }
    
    /** Allocator of ring-linked list */
    public static function allocRing(size : Int, defaultData : Float = 0) : SLLNumber
    {
        var ret : SLLNumber = alloc(defaultData);
        var elem : SLLNumber = ret;
        for (i in 1...size){
            elem.next = alloc(defaultData);
            elem = elem.next;
        }
        elem.next = ret;
        return ret;
    }
    
    /** Ring-linked list with initial values. */
    public static function newRing(args:Array<Float>) : SLLNumber
    {
        var size : Int = args.length;
        var ret : SLLNumber = alloc(args[0]);
        var elem : SLLNumber = ret;
        for (i in 1...size){
            elem.next = alloc(args[i]);
            elem = elem.next;
        }
        elem.next = ret;
        return ret;
    }
    
    
    
    
    // deallocator
    //------------------------------------------------------------
    /** Deallocator */
    public static function free(elem : SLLNumber) : Void
    {
        elem.next = _freeList;
        _freeList = elem;
    }
    
    /** Deallocator of linked list */
    public static function freeList(firstElem : SLLNumber) : Void
    {
        if (firstElem == null)             return;
        var lastElem : SLLNumber = firstElem;
        while (lastElem.next != null) {
            lastElem = lastElem.next;
        }
        lastElem.next = _freeList;
        _freeList = firstElem;
    }
    
    /** Deallocator of ring-linked list */
    public static function freeRing(firstElem : SLLNumber) : Void
    {
        if (firstElem == null)             return;
        var lastElem : SLLNumber = firstElem;
        while (lastElem.next == firstElem) {
            lastElem = lastElem.next;
        }
        lastElem.next = _freeList;
        _freeList = firstElem;
    }
    
    
    
    
    // carete pager
    //------------------------------------------------------------
    /** Create pager of linked list */
    public static function createListPager(firstElem : SLLNumber, fixedSize : Bool) : Array<SLLNumber>
    {
        if (firstElem == null)             return null;
        var elem : SLLNumber;
        var i : Int;
        var size : Int;
        size = 1;
        elem = firstElem;
        while (elem.next != null){size++;
            elem = elem.next;
        }
        var pager : Array<SLLNumber> = new Array<SLLNumber>();
        elem = firstElem;
        for (i in 0...size) {
            pager[i] = elem;
            elem = elem.next;
        }
        return pager;
    }
    
    /** Create pager of ring-linked list */
    public static function createRingPager(firstElem : SLLNumber, fixedSize : Bool) : Array<SLLNumber>
    {
        if (firstElem == null)             return null;
        var elem : SLLNumber;
        var i : Int;
        var size : Int;
        size = 1;
        elem = firstElem;
        while (elem.next != firstElem) {
            size++;
            elem = elem.next;
        }
        var pager : Array<SLLNumber> = new Array<SLLNumber>();
        elem = firstElem;
        for (i in 0...size) {
            pager[i] = elem;
            elem = elem.next;
        }
        return pager;
    }
}


