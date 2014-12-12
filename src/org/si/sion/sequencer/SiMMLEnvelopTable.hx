//----------------------------------------------------------------------------------------------------
// SiMMLTrack Envelop table
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer;


import org.si.utils.SLLint;
import org.si.sion.utils.Translator;



/** Tabel evnelope data. */
class SiMMLEnvelopTable
{
    // variables
    //--------------------------------------------------------------------------------
    /** Head element of single linked list. */
    public var head : SLLint;
    /** Tail element of single linked list. */
    public var tail : SLLint;
    
    
    
    
    
    // constructor
    //--------------------------------------------------------------------------------
    /** constructor. 
     *  @param table envelop table vector.
     *  @param loopPoint returning point index of looping. -1 sets no loop.
     */
    public function new(table : Array<Int> = null, loopPoint : Int = -1)
    {
        if (table != null) {
            var loop : SLLint;
            var i : Int;
            var imax : Int = table.length;
            head = tail = SLLint.allocList(imax);
            loop = null;
            i = 0;
            while (i < imax - 1) {
                if (loopPoint == i) loop = tail;
                tail.i = table[i];
                tail = tail.next;
                i++;
            }
            tail.i = table[i];
            tail.next = loop;
        }
        else {
            head = null;
            tail = null;
        }
    }
    
    
    
    
    // operations
    //--------------------------------------------------------------------------------
    /** convert to Vector.&lt;int&gt; */
    public function toVector(length : Int, min : Int = -65536, max : Int = 65536, dst : Array<Int> = null) : Array<Int>
    {
        if (dst == null) dst = new Array<Int>();
        var i : Int;
        var n : Int;
        var ptr : SLLint = head;
        for (i in 0...length){
            if (ptr != null) {
                n = ptr.i;
                ptr = ptr.next;
            }
            else {
                n = 0;
            }
            if (n < min)                 n = min
            else if (n > max)                 n = max;
            dst[i] = n;
        }
        return dst;
    }
    
    
    
    /** free */
    public function free() : Void
    {
        if (head != null) {
            tail.next = null;
            SLLint.freeList(head);
            head = null;
            tail = null;
        }
    }
    
    
    /** copy 
     *  @return this instance
     */
    public function copyFrom(src : SiMMLEnvelopTable) : SiMMLEnvelopTable
    {
        free();
        if (src.head != null) {
            var pSrc : SLLint = src.head;
            var pDst : SLLint = null;
            while (pSrc != src.tail) {
                var p : SLLint = SLLint.alloc(pSrc.i);
                if (pDst != null) {
                    pDst.next = p;
                    pDst = p;
                }
                else {
                    head = p;
                    pDst = head;
                }
                pSrc = pSrc.next;
            }
        }
        return this;
    }
    
    
    
    /** parse mml text 
     *  @param tableNumbers String of table numbers
     *  @param postfix String of postfix
     *  @param maxIndex maximum size of envelop table
     *  @return this instance
     */
    public function parseMML(tableNumbers : String, postfix : String, maxIndex : Int = 65536) : SiMMLEnvelopTable
    {
        var res : Dynamic = Translator.parseTableNumbers(tableNumbers, postfix, maxIndex);
        if (res.head) _initialize(res.head, res.tail);
        return this;
    }
    
    
    
    
    // internal functions
    //--------------------------------------------------------------------------------
    /** @private [sion internal] set by pointers. */
    private function _initialize(head_ : SLLint, tail_ : SLLint) : Void
    {
        head = head_;
        tail = tail_;
        // looping last data
        if (tail.next == null)             tail.next = tail;
    }
}


