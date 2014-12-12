//----------------------------------------------------------------------------------------------------
// Singly linked list of int
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------




package org.si.utils;


/** Singly linked list of int. */
class SLLint
{
    // variables
    //------------------------------------------------------------
    /** int data */
    public var i : Int = 0;
    /** Next pointer of list */
    public var next : SLLint = null;
    
    // free list
    private static var _freeList : SLLint = null;


    // constructor
    //------------------------------------------------------------
    /** Constructor */
    public function new(i : Int = 0)
    {
        this.i = i;
    }
    
    
    
    
    // allocator
    //------------------------------------------------------------
    /** Allocator */
    public static function alloc(i : Int = 0) : SLLint
    {
        var ret : SLLint;
        if (_freeList != null) {
            ret = _freeList;
            _freeList = _freeList.next;
            ret.i = i;
            ret.next = null;
        }
        else {
            ret = new SLLint(i);
        }
        return ret;
    }
    
    /** Allocator of linked list */
    public static function allocList(size : Int, defaultData : Int = 0) : SLLint
    {
        var ret : SLLint = alloc(defaultData);
        var elem : SLLint = ret;
        for (i in 1...size){
            elem.next = alloc(defaultData);
            elem = elem.next;
        }
        return ret;
    }
    
    /** Allocator of ring-linked list */
    public static function allocRing(size : Int, defaultData : Int = 0) : SLLint
    {
        var ret : SLLint = alloc(defaultData);
        var elem : SLLint = ret;
        for (i in 1...size){
            elem.next = alloc(defaultData);
            elem = elem.next;
        }
        elem.next = ret;
        return ret;
    }
    
    /** Ring-linked list with initial values. */
    public static function newRing(args:Array<Int>) : SLLint
    {
        var size : Int = args.length;
        var ret : SLLint = alloc(args[0]);
        var elem : SLLint = ret;
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
    public static function free(elem : SLLint) : Void
    {
        elem.next = _freeList;
        _freeList = elem;
    }
    
    /** Deallocator of linked list */
    public static function freeList(firstElem : SLLint) : Void
    {
        if (firstElem == null) {
            return;
        }

        var lastElem : SLLint = firstElem;

        while (lastElem.next != null) {
            lastElem = lastElem.next;
        }

        lastElem.next = _freeList;
        _freeList = firstElem;
    }
    
    /** Deallocator of ring-linked list */
    public static function freeRing(firstElem : SLLint) : Void
    {
        if (firstElem == null) {
            return;
        }

        var lastElem : SLLint = firstElem;
        while (lastElem.next == firstElem) {
            lastElem = lastElem.next;
        }
        lastElem.next = _freeList;
        _freeList = firstElem;
    }
    
    
    
    
    // carete pager
    //------------------------------------------------------------
    /** Create pager of linked list */
    public static function createListPager(firstElem : SLLint, fixedSize : Bool) : Array<SLLint>
    {
        if (firstElem == null)             return null;
        var elem : SLLint;
        var i : Int;
        var size : Int;

        size = 1;
        elem = firstElem;
        while (elem.next != null){
            size++;
            elem = elem.next;
        }
        var pager : Array<SLLint> = new Array<SLLint>();
        elem = firstElem;
        for (i in 0...size) {
            pager[i] = elem;
            elem = elem.next;
        }
        return pager;
    }
    
    /** Create pager of ring-linked list */
    public static function createRingPager(firstElem : SLLint, fixedSize : Bool) : Array<SLLint>
    {
        if (firstElem == null)             return null;
        var elem : SLLint;
        var i : Int;
        var size : Int;
        size = 1;
        elem = firstElem;
        while (elem.next != firstElem){
            size++;
            elem = elem.next;
        }
        var pager : Array<SLLint> = new Array<SLLint>();
        elem = firstElem;
        for (i in 0...size){
            pager[i] = elem;
            elem = elem.next;
        }
        return pager;
    }
}


