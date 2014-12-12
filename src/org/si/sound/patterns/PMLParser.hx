//----------------------------------------------------------------------------------------------------
// PML (Pattern/Primitive Macro Language) parser
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sound.patterns;


/** PML (Pattern/Primitive Macro Language) parser, this class provides quite simple pattern generator. 
@example The PML string is translated by rule property's key to Note instance. The letter "^" extends previous Note's length and the letter "[...]n" is translated as a loop. The letters not included in the rule property are translated to rest.
<listing version="3.0">
var pp:PMLParser = new PMLParser();
pp.rule = {"A":new Note(60), "B":new Note(72)}; // set rule. letter "A" as Note(60) and letter "B" as Note(72).
var pat1:Vector.&lt;Note&gt; = pp.parse("A B AABB");  // generate pattern. The PML "A B AABB" is simply translated by rule.
// The whitespaces are translated to rest.
for (var i:int=0; i&lt;pat1.length; i++) {
trace(pat1[i].note);                        // output "60 -1  72 -1  60  60  72  72" (rest's note property is -1)
}
var pat2:Vector.&lt;Note&gt; = pp.parse("A B A^^^");  // generate pattern. The letter "^" extends previous Note's length.
var pat3:Vector.&lt;Note&gt; = pp.parse("[A B ]2");   // generate pattern. The letter "[...]n" is translated as a loop. you cannot nest loops.
</listing>
 */
class PMLParser
{
    // variables
    //----------------------------------------
    /** parsing rule. */
    public var rule : Dynamic;
    
    
    
    
    // constructor
    //----------------------------------------
    /** constructor */
    public function new(rule : Dynamic = null)
    {
        this.rule = rule || { };
    }
    
    
    
    
    // operation
    //----------------------------------------
    /** generate pattern from PML.
     *  @param pml pattern as string.
     */
    public function parse(pml : String) : Array<Dynamic>
    {
        pml = pml.replace(new EReg('\\[(.+?)\\](\\d*)', ""), function() : String{
                            var rep : Int = Std.parseInt(arguments[2]);
                            var text : String = "";
                            var i : Int = rep || 2;
                            while (i > 0){text += arguments[1];
                                --i;
                            }
                            return text;
                        });
        var imax : Int = pml.length;
        var pattern : Array<Dynamic> = new Array<Dynamic>(imax);
        var i : Int;
        var l : String;
        var org : Note;
        var prev : Note = null;
        for (imax){
            l = pml.charAt(i);
            org = try cast(Reflect.field(rule, l), Note) catch(e:Dynamic) null;
            if (org != null) {
                pattern[i] = (new Note()).copyFrom(org);
                prev = pattern[i];
            }
            else if (l == "^" && prev != null && !Math.isNaN(prev.length)) {
                prev.length += 1;
            }
        }
        
        return pattern;
    }
}



