//----------------------------------------------------------------------------------------------------  
// Chord class    
//  Copyright (c) 2008 keim All rights reserved.    
//  Distributed under BSD-style license (see org.si.license.txt).    
// ----------------------------------------------------------------------------------------------------  

package org.si.sion.utils;

import openfl.errors.Error;
import org.si.sion.utils.Scale;

/** Chord class. */
class Chord extends Scale {
    // constants    
    // --------------------------------------------------    
    // /** Chord table of C */  
    private static inline var CT_MAJOR:Int = 0x1091091;

    /** Chord table of Cm */
    private static inline var CT_MINOR:Int = 0x1089089;

    /** Chord table of C7 */
    private static inline var CT_7TH:Int = 0x0490491;

    /** Chord table of Cm7 */
    private static inline var CT_MIN7:Int = 0x0488489;

    /** Chord table of CM7 */
    private static inline var CT_MAJ7:Int = 0x0890891;

    /** Chord table of CmM7 */
    private static inline var CT_MM7:Int = 0x0888889;

    /** Chord table of C9 */
    private static inline var CT_9TH:Int = 0x0484491;

    /** Chord table of Cm9 */
    private static inline var CT_MIN9:Int = 0x0484489;

    /** Chord table of CM9 */
    private static inline var CT_MAJ9:Int = 0x0884891;

    /** Chord table of CmM9 */
    private static inline var CT_MM9:Int = 0x0884889;

    /** Chord table of Cadd9 */
    private static inline var CT_ADD9:Int = 0x1084091;

    /** Chord table of Cmadd9 */
    private static inline var CT_MINADD9:Int = 0x1084089;

    /** Chord table of C69 */
    private static inline var CT_69TH:Int = 0x1204211;

    /** Chord table of Cm69 */
    private static inline var CT_MIN69:Int = 0x1204209;

    /** Chord table of Csus4 */
    private static inline var CT_SUS4:Int = 0x10a10a1;

    /** Chord table of Csus47 */
    private static inline var CT_SUS47:Int = 0x04a04a1;

    /** Chord table of Cdim */
    private static inline var CT_DIM:Int = 0x1489489;

    /** Chord table of Carg */
    private static inline var CT_AUG:Int = 0x1111111;

    /** chord table dictionary */
    private static var _chordTableDictionary:Map<String, Int> = {
    "m" => CT_MINOR,
    "7" => CT_7TH,
    "m7" => CT_MIN7,
    "M7" => CT_MAJ7,
    "mM7" => CT_MM7,
    "9" => CT_9TH,
    "m9" => CT_MIN9,
    "M9" => CT_MAJ9,
    "mM9" => CT_MM9,
    "add9" => CT_ADD9,
    "madd9" => CT_MINADD9,
    "69" => CT_69TH,
    "m69" => CT_MIN69,
    "sus4" => CT_SUS4,
    "sus47" => CT_SUS47,
    "dim" => CT_DIM,
    "arg" => CT_AUG,
    };

    /** bass note offset from root */
    //--------------------------------------------------    
    // variables  ;
    private var _bassNoteOffset:Int;

    // properties    
    // --------------------------------------------------    
    /** Chord name.
    * The regular expression of name is / (o[0 -9])?([A - Ga -g])([ + #\-])?([a-z0-9]+)?(,[0-9]+[+#\-]?)?(,[0-9]+[+#\-]?)?/.<br/>
    * The 1st letter means center octave. default octave = 5 (when omit).<br / >
    * The 2nd letter means root note.<br/ >
    * The 3nd letter (option) means note shift sign. "+" and "#" shift + 1, "-" shifts - 1.<br / >
    * The 4th letters (option) means chord as follows.<br / >
    * <table>
    * <tr><th>the 3rd letters< / th><th>chord< / th>< / tr>
    * <tr><td>(no matching), maj< / td><td>Major chord< / td>< / tr>
    * <tr><td>m< / td><td>Minor chord< / td></ tr>
    * <tr><td>7< / td><td>7th chord< / td>< / tr>
    * <tr><td>m7< / td><td>Minor 7th chord< /td>< / tr>
    * <tr><td>M7< / td><td>Major 7th chord< / td></ tr>
    * <tr><td>mM7< / td><td>Minor major 7th chord< / td>< / tr>
    * <tr><td>9</ td><td>9th chord</ td>< / tr>
    * <tr><td>m9< / td><td>Minor 9th chord< / td>< / tr>
    * <tr><td>M9< / td><td>Major 9th chord< / td>< / tr>
    * <tr><td>mM9</ td><td>Minor major 9th chord< / td>< / tr>
    * <tr><td>add9< / td><td>Add 9th chord< /td>< / tr>
    * <tr><td>madd9< / td><td>Minor add 9th chord< / td>< / tr>
    * <tr><td>69< / td><td>6, 9th chord< / td>< /tr>
    * <tr><td>m69< / td><td>Minor 6,9th chord< / td>< / tr>
    * <tr><td>sus4</ td><td>Sus4 chord< /td>< / tr>
    * <tr><td>sus47< / td><td>Sus4 7th chord< / td></ tr>
    * <tr><td>dim< / td><td>Diminish chord< / td>< / tr>
    * <tr><td>arg< / td><td>Augment chord< / td></ tr>
    * The 5th and 6th letters (option) means tension notes.<br/ >
    * < / table>
    * If you want to set "F sharp minor 7th", chordName = "F+m7".
    */

    override private function get_name():String {
        var rn:Int = _scaleNotes[0] % 12;
        if (_bassNoteOffset == 0) return _noteNames[rn] + _scaleName;
        return _noteNames[rn] + _scaleName + "/" + _noteNames[(rn + _bassNoteOffset) % 12];
    }

    override private function set_name(str:String):String {
        if (str == null || str == "") {
            _scaleName = "";
            _scaleTable = CT_MAJOR;
            this.rootNote = 60;
            return;
        }

        var rex:EReg = new EReg('(o[0-9])?([A-Ga-g])([+#\\-b])?([adgimMsru4679]+)?(,([0-9]+[+#\\-]?))?(,([0-9]+[+#\\-]?))?', "");
        var mat:Dynamic = rex.exec(str);
        var i:Int;
        if (mat != null) {
            _scaleName = str;
            var note:Int = [9, 11, 0, 2, 4, 5, 7][Std.string(mat[2]).toLowerCase().charCodeAt() - "a".charCodeAt()];
            if (mat[3]) {
                if (mat[3] == "+" || mat[3] == "#") note++
                else if (mat[3] == "-") note--;
            }

            if (note < 0) note += 12
            else if (note > 11) note -= 12;

            if (mat[1] != null) note += Std.parseInt(mat[1].charAt(1)) * 12
            else note += 60;

            if (mat[4] != null) {
                if (!(Lambda.has(_chordTableDictionary, mat[4]))) throw _errorInvalidChordName(str);

                _scaleTable = Reflect.field(_chordTableDictionary, Std.string(mat[4]));
                _scaleName = mat[4];
            }
            else {
                _scaleTable = CT_MAJOR;
                _scaleName = "";
            }

            this.rootNote = note;
        }
        else {
            throw _errorInvalidChordName(str);
        }

        return str;
    }

    /** bass note number, lowest note of "On Chord". */
    override private function get_bassNote():Int {
        return _scaleNotes[0] + _bassNoteOffset;
    }

    override private function set_bassNote(note:Int):Int {
        _bassNoteOffset = note - _scaleNotes[0];
        return note;
    }

    // constructor
    // --------------------------------------------------
    /** constructor
    * @param chordName chord name.
    * @param defaultCenterOctave default center octave, this apply when there are no octave specification.
    * @see #chordName
    */
    public function new(chordName : String = "", defaultCenterOctave : Int = 5) {
        super("", defaultCenterOctave);this.name = chordName;_bassNoteOffset = 0;
    }

     // operations
     // --------------------------------------------------
     /** copy from another chord
    * @param src another Chord instance copy from
    */
    override public function copyFrom(src : Scale) : Scale{
        super.copyFrom(src);
        if (Std.is(src, Chord)) {
            _bassNoteOffset = (try cast(src, Chord) catch(e:Dynamic) null)._bassNoteOffset;
        }

        return this;
    }

     // errors
     // --------------------------------------------------
     /** Invalid chord name error */
    private function _errorInvalidChordName(name : String) : Error {
        return new Error("Chord; Invalid chord name. '" + name + "'");
    }
}
