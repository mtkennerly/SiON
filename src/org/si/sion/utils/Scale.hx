//----------------------------------------------------------------------------------------------------
// Scale class
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------


package org.si.sion.utils;

import flash.errors.Error;

/** Scale class. */
class Scale
{
    public var name(get, set) : String;
    public var centerOctave(get, set) : Int;
    public var rootNote(get, set) : Int;
    public var bassNote(get, set) : Int;

    // constants
    //--------------------------------------------------
    /** Scale table of C */
    private static inline var ST_MAJOR : Int = 0x1ab5ab5;
    /** Scale table of Cm */
    private static inline var ST_MINOR : Int = 0x15ad5ad;
    /** Scale table of Chm */
    private static inline var ST_HARMONIC_MINOR : Int = 0x19ad9ad;
    /** Scale table of Cmm */
    private static inline var ST_MELODIC_MINOR : Int = 0x1aadaad;
    /** Scale table of Cp */
    private static inline var ST_PENTATONIC : Int = 0x1295295;
    /** Scale table of Cmp */
    private static inline var ST_MINOR_PENTATONIC : Int = 0x14a94a9;
    /** Scale table of Cb */
    private static inline var ST_BLUE_NOTE : Int = 0x14e94e9;
    /** Scale table of Cd */
    private static inline var ST_DIMINISH : Int = 0x1249249;
    /** Scale table of Ccd */
    private static inline var ST_COMB_DIMINISH : Int = 0x16db6db;
    /** Scale table of Cw */
    private static inline var ST_WHOLE_TONE : Int = 0x1555555;
    /** Scale table of Cc */
    private static inline var ST_CHROMATIC : Int = 0x1ffffff;
    /** Scale table of Csus4 */
    private static inline var ST_PERFECT : Int = 0x10a10a1;
    /** Scale table of Csus47 */
    private static inline var ST_DPERFECT : Int = 0x14a14a1;
    /** Scale table of C5 */
    private static inline var ST_POWER : Int = 0x1081081;
    /** Scale table of Cu */
    private static inline var ST_UNISON : Int = 0x1001001;
    /** Scale table of Cdor */
    private static inline var ST_DORIAN : Int = 0x16ad6ad;
    /** Scale table of Cphr */
    private static inline var ST_PHRIGIAN : Int = 0x15ab5ab;
    /** Scale table of Clyd */
    private static inline var ST_LYDIAN : Int = 0x1ad5ad5;
    /** Scale table of Cmix */
    private static inline var ST_MIXOLYDIAN : Int = 0x16b56b5;
    /** Scale table of Cloc */
    private static inline var ST_LOCRIAN : Int = 0x156b56b;
    /** Scale table of Cgyp */
    private static inline var ST_GYPSY : Int = 0x19b39b3;
    /** Scale table of Cspa */
    private static inline var ST_SPANISH : Int = 0x15ab5ab;
    /** Scale table of Chan */
    private static inline var ST_HANGARIAN : Int = 0x1acdacd;
    /** Scale table of Cjap */
    private static inline var ST_JAPANESE : Int = 0x14a54a5;
    /** Scale table of Cryu */
    private static inline var ST_RYUKYU : Int = 0x18b18b1;
    
    /** scale table dictionary */
    static public var _scaleTableDictionary = [
        "m"    => ST_MINOR,
        "nm"   => ST_MINOR,
        "aeo"  => ST_MINOR,
        "hm"   => ST_HARMONIC_MINOR,
        "mm"   => ST_MELODIC_MINOR,
        "p"    => ST_PENTATONIC,
        "mp"   => ST_MINOR_PENTATONIC,
        "b"    => ST_BLUE_NOTE,
        "d"    => ST_DIMINISH,
        "cd"   => ST_COMB_DIMINISH,
        "w"    => ST_WHOLE_TONE,
        "c"    => ST_CHROMATIC,
        "sus4" => ST_PERFECT,
        "sus47"=> ST_DPERFECT,
        "5"    => ST_POWER,
        "u"    => ST_UNISON,
        "dor"  => ST_DORIAN,
        "phr"  => ST_PHRIGIAN,
        "lyd"  => ST_LYDIAN,
        "mix"  => ST_MIXOLYDIAN,
        "loc"  => ST_LOCRIAN,
        "gyp"  => ST_GYPSY,
        "spa"  => ST_SPANISH,
        "han"  => ST_HANGARIAN,
        "jap"  => ST_JAPANESE,
        "ryu"  => ST_RYUKYU
    ];

    /** note names */
    private static var _noteNames : Array<Dynamic> = ["C", "C+", "D", "D+", "E", "F", "F+", "G", "G+", "A", "A+", "B"];
    
    
    
    
    // valiables
    //--------------------------------------------------
    /** scale table */
    private var _scaleTable : Int;
    /** notes on the scale */
    private var _scaleNotes : Array<Int>;
    /** notes on 1octave upper scale*/
    private var _tensionNotes : Array<Int>;
    /** scale name */
    private var _scaleName : String;
    /** default center octave, this apply when there are no octave specification. */
    private var _defaultCenterOctave : Int;
    
    
    
    
    // properties
    //--------------------------------------------------
    /** Scale name.
     *  The regular expression of name is /(o[0-9])?([A-Ga-g])([+#\-])?([a-z0-9]+)?/.<br/>
     *  The 1st letter means center octave. default octave = 5 (when omit).<br/>
     *  The 2nd letter means root note.<br/>
     *  The 3nd letter (option) means note shift sign. "+" and "#" shift +1, "-" shifts -1.<br/>
     *  The 4th letters (option) means scale as follows.<br/>
     *  <table>
     *  <tr><th>the 3rd letters</th><th>scale</th></tr>
     *  <tr><td>(no matching), ion</td><td>Major scale</td></tr>
     *  <tr><td>m, nm, aeo</td><td>Natural minor scale</td></tr>
     *  <tr><td>hm</td><td>Harmonic minor scale</td></tr>
     *  <tr><td>mm</td><td>Melodic minor scale</td></tr>
     *  <tr><td>p</td><td>Pentatonic scale</td></tr>
     *  <tr><td>mp</td><td>Minor pentatonic scale</td></tr>
     *  <tr><td>b</td><td>Blue note scale</td></tr>
     *  <tr><td>d</td><td>Diminish scale</td></tr>
     *  <tr><td>cd</td><td>Combination of diminish scale</td></tr>
     *  <tr><td>w</td><td>Whole tone scale</td></tr>
     *  <tr><td>c</td><td>Chromatic scale</td></tr>
     *  <tr><td>sus4</td><td>table of sus4 chord</td></tr>
     *  <tr><td>sus47</td><td>table of sus47 chord</td></tr>
     *  <tr><td>5</td><td>Power chord</td></tr>
     *  <tr><td>u</td><td>Unison (octave scale)</td></tr>
     *  <tr><td>dor</td><td>Dorian mode</td></tr>
     *  <tr><td>phr</td><td>Phrigian mode</td></tr>
     *  <tr><td>lyd</td><td>Lydian mode</td></tr>
     *  <tr><td>mix</td><td>Mixolydian mode</td></tr>
     *  <tr><td>loc</td><td>Locrian mode</td></tr>
     *  <tr><td>gyp</td><td>Gypsy scale</td></tr>
     *  <tr><td>spa</td><td>Spanish scale</td></tr>
     *  <tr><td>han</td><td>Hangarian scale</td></tr>
     *  <tr><td>jap</td><td>Japanese scale (Ritsu mode)</td></tr>
     *  <tr><td>ryu</td><td>Japanese scale (Ryukyu mode)</td></tr>
     *  </table>
     *  If you want to set "G sharp harmonic minor scale", name = "G+hm".
     */
    private function get_name() : String {
        return _noteNames[_scaleNotes[0] % 12] + _scaleName;
    }
    private function set_name(str : String) : String
    {
        if (str == null || str == "") {
            _scaleName = "";
            _scaleTable = ST_MAJOR;
            this.rootNote = _defaultCenterOctave * 12;
            return _scaleName;
        }
        
        var rex : EReg = new EReg('(o[0-9])?([A-Ga-g])([+#\\-b])?([a-z0-9]+)?', "");
        var i : Int;
        if (rex.match(str)) {
            _scaleName = str;
            var note : Int = [9, 11, 0, 2, 4, 5, 7][Std.string(rex.matched(2)).toLowerCase().charCodeAt(0) - "a".charCodeAt(0)];
            if (rex.matched(3) != null) {
                if (rex.matched(3) == "+" || rex.matched(3) == "#") note++
                else if (rex.matched(3) == "-")                     note--;
            }
            if (note < 0) note += 12
            else if (note > 11)  note -= 12;
            if (rex.matched(1) != null)  note += Std.parseInt(rex.matched(1).charAt(1)) * 12
            else note += _defaultCenterOctave * 12;
            
            if (rex.matched(4) != null) {
                if (!_scaleTableDictionary.exists(rex.matched(4))) throw _errorInvalidScaleName(str);
                _scaleTable = _scaleTableDictionary.get(rex.matched(4));
                _scaleName = rex.matched(4);
            }
            else {
                _scaleTable = ST_MAJOR;
                _scaleName = "";
            }
            this.rootNote = note;
        }
        else {
            throw _errorInvalidScaleName(str);
        }
        return str;
    }
    
    
    /** center octave */
    private function get_centerOctave() : Int{
        return Math.floor(_scaleNotes[0] / 12);
    }
    private function set_centerOctave(oct : Int) : Int{
        _defaultCenterOctave = oct;
        var prevoct : Int = Math.floor(_scaleNotes[0] / 12);
        if (prevoct == oct) return oct;
        var i : Int;
        var offset : Int = (oct - prevoct) * 12;
        for (i in 0..._scaleNotes.length) {
            _scaleNotes[i] += offset;
        }
        for (i in 0..._tensionNotes.length) {
            _tensionNotes[i] += offset;
        }
        return oct;
    }
    
    
    /** root note number */
    private function get_rootNote() : Int {
        return _scaleNotes[0];
    }
    private function set_rootNote(note : Int) : Int{
        _scaleNotes.splice(0, _scaleNotes.length);
        _tensionNotes.splice(0, _tensionNotes.length);
        for (i in 0...12) {
            if (_scaleTable & (1 << i) != 0) _scaleNotes.push(i + note);
        }
        for (i in 12...24) {
            if (_scaleTable & (1 << i) != 0) _tensionNotes.push(i + note);
        }
        return note;
    }
    
    
    /** bass note number */
    private function get_bassNote() : Int {
        return _scaleNotes[0];
    }
    private function set_bassNote(note : Int) : Int {
        rootNote = note;
        return note;
    }
    
    
    
    
    
    // constructor
    //--------------------------------------------------
    /** constructor 
     *  @param scaleName scale name.
     *  @param defaultCenterOctave default center octave, this apply when there are no octave specification.
     *  @see #scaleName
     */
    public function new(scaleName : String = "", defaultCenterOctave : Int = 5)
    {
        _scaleNotes = new Array<Int>();
        _tensionNotes = new Array<Int>();
        _defaultCenterOctave = defaultCenterOctave;
        this.name = scaleName;
    }
    
    
    /** set scale table manualy.
     *  @param name name of this scale.
     *  @param rootNote root note of this scale.
     *  @table Boolean table of available note on this scale. The length is 12. The index of 0 is root note.
@example If you want to set "F japanese scale (1 2 4 5 b7)".<br/>
<listing version="3.0">
    var table:Array = [1,0,1,0,0,1,0,1,0,0,1,0];  // c,d,f,g,b- is available on "C japanese scale".
    scale.setScaleTable("Fjap", 65, table);       // 65="F"s note number
</listing>
     */
    public function setScaleTable(name : String, rootNote : Int, table : Array<Dynamic>) : Void
    {
        _scaleName = name;
        var i : Int;
        var imax : Int = ((table.length < 25)) ? table.length : 25;
        _scaleTable = 0;
        for (i in 0...imax) {
            if (table[i]) _scaleTable |= (1 << i);
        }
        this.rootNote = rootNote;
    }
    
    
    
    
    // operations
    //--------------------------------------------------
    /** check note availability on this scale. 
     *  @param note MIDI note number (0-127).
     *  @return Returns true if the note is on this scale.
     */
    public function check(note : Int) : Bool
    {
        note -= _scaleNotes[0];
        if (note < 0)             note = (note + 144) % 12
        else if (note > 24)             note = ((note - 12) % 12) + 12;
        return ((_scaleTable & (1 << note)) != 0);
    }
    
    
    /** shift note to the nearest note on this scale. 
     *  @param note MIDI note number (0-127).
     *  @return Returns shifted note. if the note is on this scale, no shift.
     */
    public function shift(note : Int) : Int
    {
        var n : Int = note - _scaleNotes[0];
        if (n < 0)             n = (n + 144) % 12
        else if (n > 23)             n = ((n - 12) % 12) + 12;
        if ((_scaleTable & (1 << n)) != 0)             return note;
        var up : Int;
        var dw : Int;
        up = n + 1;
        while (up < 24 && (_scaleTable & (1 << up)) == 0) {
            up++;
        }
        dw = n - 1;
        while (dw >= 0 && (_scaleTable & (1 << dw)) == 0) {
            dw--;
        }
        return note - n + ((((n - dw) <= (up - n))) ? dw : up);
    }
    
    
    /** get scale index from note. */
    public function getScaleIndex(note : Int) : Int
    {
        return 0;
    }
    
    
    /** get note by index on this scale.
     *  @param index index on this scale. You can specify both posi and nega values.
     *  @return MIDI note number on this scale.
     */
    public function getNote(index : Int) : Int
    {
        var imax : Int = _scaleNotes.length;
        var octaveShift : Int = 0;
        if (index < 0) {
            octaveShift = Math.floor((index - imax + 1) / imax);
            index -= octaveShift * imax;
            return _scaleNotes[index] + octaveShift * 12;
        }
        if (index < imax) {
            return _scaleNotes[index];
        }
        
        index -= imax;
        imax = _tensionNotes.length;
        if (index < imax) {
            return _tensionNotes[index];
        }
        
        octaveShift = Math.floor(index / imax);
        index -= octaveShift * imax;
        return _tensionNotes[index] + octaveShift * 12;
    }
    
    
    /** copy from another scale
     *  @param src another Scale instance copy from
     */
    public function copyFrom(src : Scale) : Scale
    {
        _scaleName = src._scaleName;
        _scaleTable = src._scaleTable;
        var i : Int;
        var imax : Int = src._scaleNotes.length;
        _scaleNotes.splice(0, _scaleNotes.length);
        for (i in 0...imax) {
            _scaleNotes[i] = src._scaleNotes[i];
        }
        imax = src._tensionNotes.length;
        _tensionNotes.splice(0, _tensionNotes.length);
        for (i in 0...imax) {
            _tensionNotes[i] = src._tensionNotes[i];
        }
        return this;
    }
    
    
    
    
    // errors
    //--------------------------------------------------
    /** Invalid scale name error */
    private function _errorInvalidScaleName(name : String) : Error
    {
        return new Error("Scale; Invalid scale name. '" + name + "'");
    }
}



