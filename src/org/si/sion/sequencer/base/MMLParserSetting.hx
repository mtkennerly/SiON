//----------------------------------------------------------------------------------------------------
// MML parser setting class
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
// ----------------------------------------------------------------------------------------------------

package org.si.sion.sequencer.base;

/** Informations for MMLParser
 *  @see org.si.sion.sequencer.base.MMLParser
 */

class MMLParserSetting {
    public var mml2nn(get, never):Int;
    public var defaultLength(get, never):Int;
    public var defaultOctave(get, set):Int;
    // variables
    // --------------------------------------------------

    /** Resolution of note length. 'resolution/4' is a length of a beat. */
    public var resolution : Int;private var _mml2nn : Int;

    /** Default value of beat per minutes. */
    public var defaultBPM : Float;

    /** Default value of the l command. */
    public var defaultLValue : Int;

    /** Minimum ratio of the q command. */
    public var minQuantRatio : Int;

    /** Maximum ratio of the q command. */
    public var maxQuantRatio : Int;

    /** Default value of the q command. */
    public var defaultQuantRatio : Int;

    /** Minimum value of the @q command. */
    public var minQuantCount : Int;

    /** Maximum value of the @q command. */
    public var maxQuantCount : Int;

    /** Default value of the @q command. */
    public var defaultQuantCount : Int;

    /** Maximum value of the v command. */
    public var maxVolume : Int;

    /** Default value of the v command. */
    public var defaultVolume : Int;

    /** Maximum value of the @v command. */
    public var maxFineVolume : Int;

    /** Default value of the @v command. */
    public var defaultFineVolume:Int;

    /** Minimum value of the o command. */
    public var minOctave:Int;

    /** Maximum value of the o command. */
    public var maxOctave:Int;
    private var _defaultOctave:Int;

    /** Polarization of the ( and ) command. 1=x68k/-1=pc98. */
    public var volumePolarization:Int;

    /** Polarization of the &lt; and &gt; command. 1=x68k/-1=pc98. */
    public var octavePolarization:Int;

    // properties
    // --------------------------------------------------
    /** Offset from mml notes to MIDI note numbers. Calculated from defaultOctave. */
    private function get_mml2nn() : Int{
        return _mml2nn;
    }

    /** Default value of length in mml event. */
    private function get_defaultLength() : Int{
        return Math.floor(resolution / defaultLValue);
    }

     /** Default value of the o command. */
    private function set_defaultOctave(o : Int) : Int{
        _defaultOctave = o;
        _mml2nn = 60 - _defaultOctave * 12;

        var octaveLimit : Int = Math.floor((128 - _mml2nn) / 12) - 1;
        if (maxOctave > octaveLimit) maxOctave = octaveLimit;
        return o;
    }

    private function get_defaultOctave() : Int{
        return _defaultOctave;
    }

    // functions
    // --------------------------------------------------
    /** Constructor
    * @param initializer Initializing parameters by Object.
    **/
    public function new(initializer : Dynamic = null)
    {
        initialize(initializer);
    }

     /** Initialize. Settings not specifyed in initializer are set as default.
     *  @param initializer Initializing parameters by Object.
     */
    public function initialize(initializer : Dynamic = null) : Void{
        resolution = 1920;
        defaultBPM = 120;
        defaultLValue = 4;
        minQuantRatio = 0;
        maxQuantRatio = 8;
        defaultQuantRatio = 10;
        minQuantCount = - 192;
        maxQuantCount = 192;
        defaultQuantCount = 0;
        maxVolume = 15;
        defaultVolume = 10;
        maxFineVolume = 127;
        defaultFineVolume = 127;
        minOctave = 0;
        maxOctave = 9;
        defaultOctave = 5;
        volumePolarization = 1;
        octavePolarization = 1;
        update(initializer);
    }

    /** update. Settings not specifyed in initializer are not changing.
    *  @param initializer Initializing parameters by Object.
    */
    public function update(initializer : Dynamic) : Void{
        if (initializer == null) return;
        if (initializer.resolution != null) resolution = initializer.resolution;
        if (initializer.defaultBPM != null) defaultBPM = initializer.defaultBPM;
        if (initializer.defaultLValue != null) defaultLValue = initializer.defaultLValue;
        if (initializer.minQuantRatio != null) minQuantRatio = initializer.minQuantRatio;
        if (initializer.maxQuantRatio != null) maxQuantRatio = initializer.maxQuantRatio;
        if (initializer.defaultQuantRatio != null) defaultQuantRatio = initializer.defaultQuantRatio;
        if (initializer.minQuantCount != null) minQuantCount = initializer.minQuantCount;
        if (initializer.maxQuantCount != null) maxQuantCount = initializer.maxQuantCount;
        if (initializer.defaultQuantCount != null) defaultQuantCount = initializer.defaultQuantCount;
        if (initializer.maxVolume != null) maxVolume = initializer.maxVolume;
        if (initializer.defaultVolume != null) defaultVolume = initializer.defaultVolume;
        if (initializer.maxFineVolume != null) maxFineVolume = initializer.maxFineVolume;
        if (initializer.defaultFineVolume != null) defaultFineVolume = initializer.defaultFineVolume;
        if (initializer.minOctave != null) minOctave = initializer.minOctave;
        if (initializer.maxOctave != null) maxOctave = initializer.maxOctave;
        if (initializer.defaultOctave != null) defaultOctave = initializer.defaultOctave;
        if (initializer.volumePolarization != null) volumePolarization = initializer.volumePolarization;
        if (initializer.octavePolarization != null) octavePolarization = initializer.volumePolarization;
    }
}