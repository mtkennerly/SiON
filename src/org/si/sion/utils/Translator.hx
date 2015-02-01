//----------------------------------------------------------------------------------------------------
// Translators
//  Copyright (c) 2008 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.utils;

import openfl.errors.Error;


import org.si.sion.SiONVoice;
import org.si.sion.module.*;
import org.si.sion.sequencer.*;
import org.si.sion.effector.SiEffectModule;
import org.si.sion.effector.SiEffectBase;
import org.si.utils.SLLint;


/** Translator */
class Translator
{
    /** constructor, do nothing. */
    public function new()
    {
    }

    // mckc
    //--------------------------------------------------
    /** Translate ppmckc mml to SiOPM mml.
     *  @param mckcMML ppmckc MML text.
     *  @return translated SiON MML text
     */
    public static function mckc(mckcMML : String) : String
    {
        // If I have motivation ..., or I wish someone who know mck well would do ...
        throw new Error("This is not implemented");
        return mckcMML;
    }

    // flmml
    //--------------------------------------------------
    /** Translate flMML's mml to SiOPM mml.
     *  @param flMML flMML's MML text.
     *  @return translated SiON MML text
     */
    public static function flmml(flMML : String) : String
    {
        // If I have motivation ..., or I wish someone who know mck well would do ...
        throw new Error("This is not implemented");
        return flMML;
    }

    // tsscp
    //--------------------------------------------------
    /** Translate pTSSCP mml to SiOPM mml. 
     *  @param tsscpMML TSSCP MML text.
     *  @param volumeByX true to translate volume control to SiON MMLs 'x' command, false to translate to SiON MMLs 'v' command.
     *  @return translated SiON MML text
     */
    public static function tsscp(tsscpMML : String, volumeByX : Bool = true) : String
    {
        var mml : String;
        var com : String;
        var str1 : String;
        var str2 : String;
        var i : Int;
        var imax : Int;
        var volUp : String;
        var volDw : String;
        var rex : EReg;
        var rex_sys : EReg;
        var res : Array<String> = new Array<String>();
        
        // translate mml
        //--------------------------------------------------
        var noteLetters : String = "cdefgab";
        var noteShift : Array<Dynamic> = [0, 2, 4, 5, 7, 9, 11];
        var panTable : Array<Dynamic> = ["@v0", "p0", "p8", "p4"];
        var table : SiMMLTable = SiMMLTable.instance;
        var charCodeA : Int = "a".charCodeAt(0);
        var charCodeG : Int = "g".charCodeAt(0);
        var charCodeR : Int = "r".charCodeAt(0);
        var hex : String = "0123456789abcdef";
        var p0 : Int;
        var p1 : Int;
        var p2 : Int;
        var p3 : Int;
        var p4 : Int;
        var reql8 : Bool;
        var octave : Int;
        var revOct : Bool;
        var loopOct : Int;
        var loopMacro : Bool;
        var loopMMLBefore : String;
        var loopMMLContent : String;
        var autoAdvance : Bool;

        rex = new EReg("(;|(/:|:/|ml|mp|na|ns|nt|ph|@kr|@ks|@ml|@ns|@apn|@[fkimopqsv]?|[klopqrstvx$%<>(){}[\\]|_~^/&*]|[a-g][#+\\-]?)\\s*([\\-\\d]*)[,\\s]*([\\-\\d]+)?[,\\s]*([\\-\\d]+)?[,\\s]*([\\-\\d]+)?[,\\s]*([\\-\\d]+)?)|#(FM|[A-Z]+)=?\\s*([^;]*)|([A-Z])(\\(([a-g])([\\-+#]?)\\))?|.", "gms");
        rex_sys = new EReg('\\s*([0-9]*)[,=<\\s]*([^>]*)', "ms");

        volUp = "(";
        volDw = ")";
        mml = "";
        reql8 = true;
        octave = 5;
        revOct = false;
        loopOct = -1;
        loopMacro = false;
        loopMMLBefore = null;
        loopMMLContent = null;
        var matchString = tsscpMML;
        while (rex.match(matchString)) {

            // Reset the matching array
            res.splice(0, res.length);

            // Convert to the array format expected by all the functions
            for (i in 0...9) {
                res.push(rex.matched(i));
            }

            // By default, always automatically advance the matched string at the end
            autoAdvance = true;

            if (res[1] != null) {
                if (res[1] == ";") {
                    mml += res[0];
                    reql8 = true;
                }
                else {
                    // mml commands
                    i = res[2].charCodeAt(0);
                    if ((charCodeA <= i && i <= charCodeG) || i == charCodeR) {
                        if (reql8)                             mml += "l8" + res[0]
                        else mml += res[0];
                        reql8 = false;
                    }
                    else {
                        var _sw0_ = (res[2]);                        

                        switch (_sw0_)
                        {
                            case "l":{mml += res[0];reql8 = false;
                            }
                            case "/:":{mml += "[" + res[3];
                            }
                            case ":/":{mml += "]";
                            }
                            case "/":{mml += "|";
                            }
                            case "~":{mml += volUp + res[3];
                            }
                            case "_":{mml += volDw + res[3];
                            }
                            case "q":{mml += "q" + Std.string((Std.parseInt(res[3]) + 1) >> 1);
                            }
                            case "@m":{mml += "@mask" + Std.string(Std.parseInt(res[3]));
                            }
                            case "ml":{mml += "@ml" + Std.string(Std.parseInt(res[3]));
                            }
                            case "p":{mml += panTable[Std.parseInt(res[3]) & 3];
                            }
                            case "@p":{mml += "@p" + Std.string(Std.parseInt(res[3]) - 64);
                            }
                            case "ph":{mml += "@ph" + Std.string(Std.parseInt(res[3]));
                            }
                            case "ns":{mml += "kt" + res[3];
                            }
                            case "@ns":{mml += "!@ns" + res[3];
                            }
                            case "k":{
                                p0 = Math.floor(Std.parseFloat(res[3]) * 4);
                                mml += 'k$p0';
                            }
                            case "@k":{p0 = Math.floor(Std.parseFloat(res[3]) * 0.768);mml += 'k$p0';
                            }
                            case "@kr":{p0 = Math.floor(Std.parseFloat(res[3]) * 0.768);mml += '!@kr$p0';
                            }
                            case "@ks":{mml += "@,,,,,,," + Std.string(Std.parseInt(res[3]) >> 5);
                            }
                            case "na":{mml += "!" + res[0];
                            }
                            case "o":{mml += res[0];octave = Std.parseInt(res[3]);
                            }
                            case "<":{mml += res[0];octave += ((revOct)) ? -1 : 1;
                            }
                            case ">":{mml += res[0];octave += ((revOct)) ? 1 : -1;
                            }
                            case "%":{mml += ((res[3] == "6")) ? "%4" : res[0];
                            }
                            
                            case "@ml":{
                                p0 = Std.parseInt(res[3]) >> 7;
                                p1 = Std.parseInt(res[3]) - (p0 << 7);
                                mml += "@ml" + Std.string(p0) + "," + Std.string(p1);
                            }
                            case "mp":{
                                p0 = Std.parseInt(res[3]);
                                p1 = Std.parseInt(res[4]);
                                p2 = Std.parseInt(res[5]);
                                p3 = Std.parseInt(res[6]);
                                p4 = Std.parseInt(res[7]);
                                if (p3 == 0) p3 = 1;
                                switch (p0)
                                {
                                    case 0:mml += "mp0";
                                    case 1:mml += "@lfo" + Std.string((Math.floor(p1 / p3) + 1) * 4 * p2) + "mp" + Std.string(p1);
                                    default:mml += "@lfo" + Std.string((Math.floor(p1 / p3) + 1) * 4 * p2) + "mp0," + Std.string(p1) + "," + Std.string(p0);
                                }
                            }
                            case "v":{
                                if (volumeByX) {
                                    p0 = ((res[3].length == 0)) ? 40 : ((Std.parseInt(res[3]) << 2) + (Std.parseInt(res[3]) >> 2));
                                    if (res[4] != null) {
                                        p1 = (Std.parseInt(res[4]) << 2) + (Std.parseInt(res[4]) >> 2);
                                        p2 = ((p1 > 0)) ? (Math.floor(Math.atan(p0 / p1) * 81.48733086305041)) : 128;  // 81.48733086305041 = 128/(PI*0.5)
                                        p3 = ((p0 > p1)) ? p0 : p1;
                                        mml += "@p" + Std.string(p2) + "x" + Std.string(p3);
                                    }
                                    else {
                                        mml += "x" + Std.string(p0);
                                    }
                                }
                                else {
                                    p0 = ((res[3].length == 0)) ? 10 : (Std.parseInt(res[3]));
                                    if (res[4] != null) {
                                        p1 = Std.parseInt(res[4]);
                                        p2 = ((p1 > 0)) ? (Math.floor(Math.atan(p0 / p1) * 81.48733086305041)) : 128;  // 81.48733086305041 = 128/(PI*0.5)
                                        p3 = ((p0 > p1)) ? p0 : p1;
                                        mml += "@p" + Std.string(p2) + "v" + Std.string(p3);
                                    }
                                    else {
                                        mml += "v" + Std.string(p0);
                                    }
                                }
                            }
                            case "@v":{
                                if (volumeByX) {
                                    p0 = ((res[3].length == 0)) ? 40 : (Std.parseInt(res[3]) >> 2);
                                    if (res[4] != null) {
                                        p1 = Std.parseInt(res[4]) >> 2;
                                        p2 = ((p1 > 0)) ? (Math.floor(Math.atan(p0 / p1) * 81.48733086305041)) : 128;  // 81.48733086305041 = 128/(PI*0.5)
                                        p3 = ((p0 > p1)) ? p0 : p1;
                                        mml += "@p" + Std.string(p2) + "x" + Std.string(p3);
                                    }
                                    else {
                                        mml += "x" + Std.string(p0);
                                    }
                                }
                                else {
                                    p0 = ((res[3].length == 0)) ? 10 : (Std.parseInt(res[3]) >> 4);
                                    if (res[4] != null) {
                                        p1 = Std.parseInt(res[4]) >> 4;
                                        p2 = ((p1 > 0)) ? (Math.floor(Math.atan(p0 / p1) * 81.48733086305041)) : 128;  // 81.48733086305041 = 128/(PI*0.5)
                                        p3 = ((p0 > p1)) ? p0 : p1;
                                        mml += "@p" + Std.string(p2) + "v" + Std.string(p3);
                                    }
                                    else {
                                        mml += "v" + Std.string(p0);
                                    }
                                }
                            }
                            case "s":{
                                p0 = Std.parseInt(res[3]);p1 = Std.parseInt(res[4]);
                                mml += "s" + table.tss_s2rr[p0 & 255];
                                if (p1 != 0)                                     mml += "," + Std.string(p1 * 3);
                            }
                            case "@s":{
                                p0 = Std.parseInt(res[3]);p1 = Std.parseInt(res[4]);p3 = Std.parseInt(res[6]);
                                p2 = ((Std.parseInt(res[5]) >= 100)) ? 15 : Math.floor(Std.parseFloat(res[5]) * 0.09);
                                mml += ((p0 == 0)) ? "@,63,0,0,,0" : (
                                "@," + table.tss_s2ar[p0 & 255] + "," + table.tss_s2dr[p1 & 255] + "," + table.tss_s2sr[p3 & 255] + ",," + Std.string(p2));
                            }
                            case "{":{
                                var bracketString = rex.matchedRight();
                                mml += "/*{";
                                var index = 0;
                                i = 1;
                                do{
                                    if (bracketString.charAt(index) == "{") {
                                        i++;
                                        mml += "{";
                                    }
                                    else if (bracketString.charAt(index) == "}") {
                                        i--;
                                        mml += "}";
                                    }
                                    else throw errorTranslation("{{...} ?");
                                    index++;
                                } while (i > 0);
                                mml += "}*/";
                                matchString=rex.matchedRight().substring(index,-1);
                                autoAdvance = false;
                            }
                            
                            case "[":{
                                if (loopMMLBefore != null)                                     errorTranslation("[[...] ?");
                                loopMacro = false;
                                loopMMLBefore = mml;
                                loopMMLContent = null;
                                mml = res[3];
                                loopOct = octave;
                            }
                            case "|":{
                                if (loopMMLBefore == null) errorTranslation("'|' can be only in '[...]'");
                                loopMMLContent = mml;
                                mml = "";
                            }
                            case "]":{
                                if (loopMMLBefore == null) errorTranslation("[...]] ?");
                                if (!loopMacro && loopOct == octave) {
                                    if (loopMMLContent != null) mml = loopMMLBefore + "[" + loopMMLContent + "|" + mml + "]"
                                    else mml = loopMMLBefore + "[" + mml + "]";
                                }
                                else {
                                    if (loopMMLContent != null) mml = loopMMLBefore + "![" + loopMMLContent + "!|" + mml + "!]"
                                    else mml = loopMMLBefore + "![" + mml + "!]";
                                }
                                loopMMLBefore = null;
                                loopMMLContent = null;
                            }case "}", "@apn", "x":

                                switch (_sw0_)
                                {case "}":
                                        throw errorTranslation("{...}} ?");
                                }
                            
                            default:{
                                    mml += res[0];
                                }
                        }
                    }
                }
            }
            else if (res[10] != null) {
                // macro expansion
                if (reql8)                     mml += "l8" + res[10]
                else mml += res[10];
                reql8 = false;
                loopMacro = true;
                if (res[11] != null) {
                    // note shift
                    i = noteShift[noteLetters.indexOf(res[12])];
                    if (res[13] == "+" || res[13] == "#")                         i++
                    else if (res[13] == "-")                         i--;
                    mml += "(" + Std.string(i) + ")";
                }
            }
            else if (res[8] != null) {
                // system command
                str1 = res[8];
                switch (str1)
                {
                    case "END":{mml += "#END";
                    }
                    case "OCTAVE":{
                        if (res[9] == "REVERSE") {
                            mml += "#REV{octave}";
                            revOct = true;
                        }
                    }
                    case "OCTAVEREVERSE":{
                        mml += "#REV{octave}";
                        revOct = true;
                    }
                    case "VOLUME":{
                        if (res[9] == "REVERSE") {
                            volUp = ")";
                            volDw = "(";
                            mml += "#REV{volume}";
                        }
                    }
                    case "VOLUMEREVERSE":{
                        volUp = ")";
                        volDw = "(";
                        mml += "#REV{volume}";
                    }
                    
                    case "TABLE":{
                        if (!rex_sys.match(res[9])) throw errorTranslation("TABLE ?");
                        mml += "#TABLE" + rex_sys.matched(1) + "{" + rex_sys.matched(2) + "}*0.25";
                    }
                    
                    case "WAVB":{
                        if (!rex_sys.match(res[9])) throw errorTranslation("WAVB ?");
                        str1 = rex_sys.matched(2);
                        mml += "#WAVB" + rex_sys.matched(1) + "{";
                        for (i in 0...32) {
                            p0 = Std.parseInt("0x" + str1.substr(i << 1, 2));
                            p0 = ((p0 < 128)) ? (p0 + 127) : (p0 - 128);
                            mml += hex.charAt(p0 >> 4) + hex.charAt(p0 & 15);
                        }
                        mml += "}";
                    }
                    
                    case "FM":{
                        mml += "#FM{" + new EReg('([A-Z])([0-9])?(\\()?', "g").map(res[9],
                                function(regexp : EReg) : String{
                                    var num : Int = (regexp.matched(2) != null) ? (Std.parseInt(regexp.matched(2))) : 3;
                                    var str : String = ((regexp.matched(3)) != null) ? (num + "(") : "";
                                    return regexp.matched(1).toLowerCase() + str;
                                }
                                ) + "}";
                    }
                    case "FINENESS", "MML":
                        // skip next ";"
                        rex.match(rex.matchedRight());
                    default: {
                        if (str1.length == 1) {
                            // macro
                            mml += "#" + str1 + "=";
                            matchString = rex.matchedRight().substring(res[9].length);
                            autoAdvance = false;
                            reql8 = false;
                        }
                        else {
                            // other system events
                            if (rex_sys.match(res[9])) {
                                if (rex_sys.matched(2).length == 0) return "#" + str1 + rex_sys.matched(1);
                                mml += "#" + str1 + rex_sys.matched(1) + "{" + rex_sys.matched(2) + "}";
                            }
                        }
                    }
                }
            }
            else {
                mml += res[0];
            }

            if (autoAdvance) {
                // Update the string so we can look for the next match
                matchString = rex.matchedRight();
            }
        }
        tsscpMML = mml;
        
        return tsscpMML;
    }
    
    
    
    
    // Effector
    //--------------------------------------------------
    // parse effector MML string
    //--------------------------------------------------
    /** Parse effector mml and return an array of SiEffectBase.
     *  @param mml Effector MML text.
     *  @param postfix postfix text.
     *  @return An array of SiEffectBase.
     */
    public static function parseEffectorMML(mml : String, postfix : String = "") : Array<SiEffectBase>
    {
        var ret : Array<SiEffectBase> = new Array<SiEffectBase>();
        var rex : EReg = new EReg('([a-zA-Z_]+|,)\\s*([.\\-\\d]+)?', "g");
        var i : Int;
        var cmd : String = "";
        var argc : Int = 0;
        var args : Array<Float> = new Array<Float>();

        // connect new effector
        function _connectEffect() : Void {
            if (argc == 0) return;
            var e : SiEffectBase = SiEffectModule.getInstance(cmd);
            if (e != null) {
                e.mmlCallback(args);
                ret.push(e);
            }
        }

        // clear arguments  ;
        function _clearArgs() : Void {
            for (i in 0...16) {
                args[i] = Math.NaN;
            }
        };

        // clear
        _clearArgs();

        // parse mml
        var matchString = mml;
        while (rex.match(matchString)) {
            if (rex.matched(1) == ",") {
                args[argc++] = Std.parseFloat(rex.matched(2));
            }
            else {
                _connectEffect();
                cmd = rex.matched(1);
                _clearArgs();
                args[0] = Std.parseFloat(rex.matched(2));
                argc = 1;
            }

            matchString = rex.matchedRight();
        }
        _connectEffect();
        
        return ret;
    }
    
    
    
    
    // FM parameters
    //--------------------------------------------------
    // parse MML string
    //--------------------------------------------------
    /** parse inside of #&#64;{..}; */
    public static function parseParam(param : SiOPMChannelParam, dataString : String) : SiOPMChannelParam{
        return _setParamByArray(param, _splitDataString(param, dataString, 3, 15, "#@"));
    }
    
    
    /** parse inside of #OPL&#64;{..}; */
    public static function parseOPLParam(param : SiOPMChannelParam, dataString : String) : SiOPMChannelParam{
        return _setOPLParamByArray(param, _splitDataString(param, dataString, 2, 11, "#OPL@"));
    }
    
    
    /** parse inside of #OPM&#64;{..}; */
    public static function parseOPMParam(param : SiOPMChannelParam, dataString : String) : SiOPMChannelParam{
        return _setOPMParamByArray(param, _splitDataString(param, dataString, 2, 11, "#OPM@"));
    }
    
    
    /** parse inside of #OPN&#64;{..}; */
    public static function parseOPNParam(param : SiOPMChannelParam, dataString : String) : SiOPMChannelParam{
        return _setOPNParamByArray(param, _splitDataString(param, dataString, 2, 10, "#OPN@"));
    }
    
    
    /** parse inside of #OPX&#64;{..}; */
    public static function parseOPXParam(param : SiOPMChannelParam, dataString : String) : SiOPMChannelParam{
        return _setOPXParamByArray(param, _splitDataString(param, dataString, 2, 12, "#OPX@"));
    }
    
    
    /** parse inside of #MA&#64;{..}; */
    public static function parseMA3Param(param : SiOPMChannelParam, dataString : String) : SiOPMChannelParam{
        return _setMA3ParamByArray(param, _splitDataString(param, dataString, 2, 12, "#MA@"));
    }
    
    /** parse inside of #AL&#64;{..}; */
    public static function parseALParam(param : SiOPMChannelParam, dataString : String) : SiOPMChannelParam{
        return _setALParamByArray(param, _splitDataString(param, dataString, 9, 0, "#AL@"));
    }
    
    
    
    
    // set by Array
    //--------------------------------------------------
    /** set inside of #&#64;{..}; */
    public static function setParam(param : SiOPMChannelParam, data : Array<Dynamic>) : SiOPMChannelParam{
        return _setParamByArray(_checkOpeCount(param, data.length, 3, 15, "#@"), data);
    }
    
    
    /** set inside of #OPL&#64;{..}; */
    public static function setOPLParam(param : SiOPMChannelParam, data : Array<Dynamic>) : SiOPMChannelParam{
        return _setOPLParamByArray(_checkOpeCount(param, data.length, 2, 11, "#OPL@"), data);
    }
    
    
    /** set inside of #OPM&#64;{..}; */
    public static function setOPMParam(param : SiOPMChannelParam, data : Array<Dynamic>) : SiOPMChannelParam{
        return _setOPMParamByArray(_checkOpeCount(param, data.length, 2, 11, "#OPM@"), data);
    }
    
    
    /** set inside of #OPN&#64;{..}; */
    public static function setOPNParam(param : SiOPMChannelParam, data : Array<Dynamic>) : SiOPMChannelParam{
        return _setOPNParamByArray(_checkOpeCount(param, data.length, 2, 10, "#OPN@"), data);
    }
    
    
    /** set inside of #OPX&#64;{..}; */
    public static function setOPXParam(param : SiOPMChannelParam, data : Array<Dynamic>) : SiOPMChannelParam{
        return _setOPXParamByArray(_checkOpeCount(param, data.length, 2, 12, "#OPX@"), data);
    }
    
    
    /** set inside of #MA&#64;{..}; */
    public static function setMA3Param(param : SiOPMChannelParam, data : Array<Dynamic>) : SiOPMChannelParam{
        return _setMA3ParamByArray(_checkOpeCount(param, data.length, 2, 12, "#MA@"), data);
    }
    
    /** set inside of #AL&#64;{..}; */
    public static function setALParam(param : SiOPMChannelParam, data : Array<Dynamic>) : SiOPMChannelParam{
        if (data.length != 9)             throw errorToneParameterNotValid("#AL@", 9, 0);
        return _setALParamByArray(param, data);
    }
    
    
    
    
    
    
    // internal functions
    //--------------------------------------------------
    // split dataString of #@ macro
    private static function _splitDataString(param : SiOPMChannelParam, dataString : String, chParamCount : Int, opParamCount : Int, cmd : String) : Array<Dynamic>
    {
        var data : Array<Dynamic>;
        var i : Int;
        
        // parse parameters
        if (dataString == "") {
            param.opeCount = 0;
        }
        else {
            // TODO: haxeport: make sure this works like we expect!
            var comrex : EReg = new EReg("/\\*.*?\\*/|//.*?[\\r\\n]+", "gms");
            var replacedString = comrex.replace(dataString, "");
            replacedString = new EReg('^[^\\d\\-.]+|[^\\d\\-.]+$', "g").replace(replacedString, "");
            replacedString = new EReg('[^\\d\\-.]+', "gm").replace(replacedString, ",");
            data = replacedString.split(",");
            for (i in 0...5) {
                if (data.length == chParamCount + opParamCount * i) {
                    param.opeCount = i;
                    return data;
                }
            }
            throw errorToneParameterNotValid(cmd, chParamCount, opParamCount);
        }
        return null;
    }
    
    
    // check param.opeCount
    private static function _checkOpeCount(param : SiOPMChannelParam, dataLength : Int, chParamCount : Int, opParamCount : Int, cmd : String) : SiOPMChannelParam
    {
        var opeCount : Int = Math.floor((dataLength - chParamCount) / opParamCount);
        if (opeCount > 4 || opeCount * opParamCount + chParamCount != dataLength) throw errorToneParameterNotValid(cmd, chParamCount, opParamCount);
        param.opeCount = opeCount;
        return param;
    }
    
    
    // #@
    // alg[0-15], fb[0-7], fbc[0-3],
    // (ws[0-511], ar[0-63], dr[0-63], sr[0-63], rr[0-63], sl[0-15], tl[0-127], ksr[0-3], ksl[0-3], mul[], dt1[0-7], detune[], ams[0-3], phase[-1-255], fixedNote[0-127]) x operator_count
    private static function _setParamByArray(param : SiOPMChannelParam, data : Array<Dynamic>) : SiOPMChannelParam
    {
        if (param.opeCount == 0)             return param;
        
        param.alg = Std.parseInt(data[0]);
        param.fb = Std.parseInt(data[1]);
        param.fbc = Std.parseInt(data[2]);
        var dataIndex : Int = 3;
        var n : Float;
        var i : Int;
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            opp.setPGType(Std.parseInt(data[dataIndex++]) & 511);  // 1  
            opp.ar = Std.parseInt(data[dataIndex++]) & 63;  // 2  
            opp.dr = Std.parseInt(data[dataIndex++]) & 63;  // 3  
            opp.sr = Std.parseInt(data[dataIndex++]) & 63;  // 4  
            opp.rr = Std.parseInt(data[dataIndex++]) & 63;  // 5  
            opp.sl = Std.parseInt(data[dataIndex++]) & 15;  // 6  
            opp.tl = Std.parseInt(data[dataIndex++]) & 127;  // 7  
            opp.ksr = Std.parseInt(data[dataIndex++]) & 3;  // 8  
            opp.ksl = Std.parseInt(data[dataIndex++]) & 3;  // 9  
            n = Std.parseFloat(data[dataIndex++]);
            opp.fmul = ((n == 0)) ? 64 : Math.floor(n * 128);  // 10
            opp.dt1 = Std.parseInt(data[dataIndex++]) & 7;  // 11  
            opp.detune = Std.parseInt(data[dataIndex++]);  // 12  
            opp.ams = Std.parseInt(data[dataIndex++]) & 3;  // 13  
            i = Std.parseInt(data[dataIndex++]);
            opp.phase = ((i == -1)) ? i : (i & 255);  // 14  
            opp.fixedPitch = (Std.parseInt(data[dataIndex++]) & 127) << 6;
        }
        return param;
    }
    
    
    // #OPL@
    // alg[0-5], fb[0-7],
    // (ws[0-7], ar[0-15], dr[0-15], rr[0-15], egt[0,1], sl[0-15], tl[0-63], ksr[0,1], ksl[0-3], mul[0-15], ams[0-3]) x operator_count
    private static function _setOPLParamByArray(param : SiOPMChannelParam, data : Array<Dynamic>) : SiOPMChannelParam
    {
        if (param.opeCount == 0)             return param;
        
        var alg : Int = SiMMLTable.instance.alg_opl[param.opeCount - 1][Std.parseInt(data[0]) & 15];
        if (alg == -1)             throw errorParameterNotValid("#OPL@ algorism", data[0]);
        
        param.fratio = 133;
        param.alg = alg;
        param.fb = Std.parseInt(data[1]);
        var dataIndex : Int = 2;
        var i : Int;
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            opp.setPGType(SiOPMTable.PG_MA3_WAVE + (Std.parseInt(data[dataIndex++]) & 31));  // 1  
            opp.ar = (Std.parseInt(data[dataIndex++]) << 2) & 63;  // 2  
            opp.dr = (Std.parseInt(data[dataIndex++]) << 2) & 63;  // 3  
            opp.rr = (Std.parseInt(data[dataIndex++]) << 2) & 63;  // 4  
            // egt=0;decay tone / egt=1;holding tone           5
            opp.sr = ((Std.parseInt(data[dataIndex++]) != 0)) ? 0 : opp.rr;
            opp.sl = Std.parseInt(data[dataIndex++]) & 15;  // 6  
            opp.tl = Std.parseInt(data[dataIndex++]) & 63;  // 7  
            opp.ksr = (Std.parseInt(data[dataIndex++]) << 1) & 3;  // 8  
            opp.ksl = Std.parseInt(data[dataIndex++]) & 3;  // 9  
            i = Std.parseInt(data[dataIndex++]) & 15;  // 10  
            opp.mul = ((i == 11 || i == 13)) ? (i - 1) : ((i == 14)) ? (i + 1) : i;
            opp.ams = Std.parseInt(data[dataIndex++]) & 3;
        }
        return param;
    }
    
    
    // #OPM@
    // alg[0-7], fb[0-7],
    // (ar[0-31], dr[0-31], sr[0-31], rr[0-15], sl[0-15], tl[0-127], ks[0-3], mul[0-15], dt1[0-7], dt2[0-3], ams[0-3]) x operator_count
    private static function _setOPMParamByArray(param : SiOPMChannelParam, data : Array<Dynamic>) : SiOPMChannelParam
    {
        if (param.opeCount == 0)             return param;
        
        var alg : Int = SiMMLTable.instance.alg_opm[param.opeCount - 1][Std.parseInt(data[0]) & 15];
        if (alg == -1)             throw errorParameterNotValid("#OPN@ algorism", data[0]);
        
        param.alg = alg;
        param.fb = Std.parseInt(data[1]);
        var dataIndex : Int = 2;
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            opp.ar = (Std.parseInt(data[dataIndex++]) << 1) & 63;  // 1  
            opp.dr = (Std.parseInt(data[dataIndex++]) << 1) & 63;  // 2  
            opp.sr = (Std.parseInt(data[dataIndex++]) << 1) & 63;  // 3  
            opp.rr = ((Std.parseInt(data[dataIndex++]) << 2) + 2) & 63;  // 4  
            opp.sl = Std.parseInt(data[dataIndex++]) & 15;  // 5  
            opp.tl = Std.parseInt(data[dataIndex++]) & 127;  // 6  
            opp.ksr = Std.parseInt(data[dataIndex++]) & 3;  // 7  
            opp.mul = Std.parseInt(data[dataIndex++]) & 15;  // 8  
            opp.dt1 = Std.parseInt(data[dataIndex++]) & 7;  // 9  
            opp.detune = SiOPMTable.instance.dt2Table[data[dataIndex++] & 3];  // 10  
            opp.ams = Std.parseInt(data[dataIndex++]) & 3;
        }
        return param;
    }
    
    
    // #OPN@
    // alg[0-7], fb[0-7],
    // (ar[0-31], dr[0-31], sr[0-31], rr[0-15], sl[0-15], tl[0-127], ks[0-3], mul[0-15], dt1[0-7], ams[0-3]) x operator_count
    private static function _setOPNParamByArray(param : SiOPMChannelParam, data : Array<Dynamic>) : SiOPMChannelParam
    {
        if (param.opeCount == 0)             return param;
        
        var alg : Int = SiMMLTable.instance.alg_opm[param.opeCount - 1][Std.parseInt(data[0]) & 15];
        if (alg == -1)             throw errorParameterNotValid("#OPN@ algorism", data[0]);
        
        param.alg = alg;
        param.fb = Std.parseInt(data[1]);
        var dataIndex : Int = 2;
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            opp.ar = (Std.parseInt(data[dataIndex++]) << 1) & 63;  // 1  
            opp.dr = (Std.parseInt(data[dataIndex++]) << 1) & 63;  // 2  
            opp.sr = (Std.parseInt(data[dataIndex++]) << 1) & 63;  // 3  
            opp.rr = ((Std.parseInt(data[dataIndex++]) << 2) + 2) & 63;  // 4  
            opp.sl = Std.parseInt(data[dataIndex++]) & 15;  // 5  
            opp.tl = Std.parseInt(data[dataIndex++]) & 127;  // 6  
            opp.ksr = Std.parseInt(data[dataIndex++]) & 3;  // 7  
            opp.mul = Std.parseInt(data[dataIndex++]) & 15;  // 8  
            opp.dt1 = Std.parseInt(data[dataIndex++]) & 7;  // 9  
            opp.ams = Std.parseInt(data[dataIndex++]) & 3;
        }
        return param;
    }
    
    
    // #OPX@
    // alg[0-15], fb[0-7],
    // (ws[0-7], ar[0-31], dr[0-31], sr[0-31], rr[0-15], sl[0-15], tl[0-127], ks[0-3], mul[0-15], dt1[0-7], detune[], ams[0-3]) x operator_count
    private static function _setOPXParamByArray(param : SiOPMChannelParam, data : Array<Dynamic>) : SiOPMChannelParam
    {
        if (param.opeCount == 0)             return param;
        
        var alg : Int = SiMMLTable.instance.alg_opx[param.opeCount - 1][Std.parseInt(data[0]) & 15];
        if (alg == -1)             throw errorParameterNotValid("#OPX@ algorism", data[0]);
        
        param.alg = (alg & 15);
        param.fb = Std.parseInt(data[1]);
        param.fbc = ((alg & 16) != 0) ? 1 : 0;
        var dataIndex : Int = 2;
        var i : Int;
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            i = Std.parseInt(data[dataIndex++]);
            opp.setPGType(((i < 7)) ? (SiOPMTable.PG_MA3_WAVE + (i & 7)) : (SiOPMTable.PG_CUSTOM + (i - 7)));  // 1  
            opp.ar = (Std.parseInt(data[dataIndex++]) << 1) & 63;  // 2  
            opp.dr = (Std.parseInt(data[dataIndex++]) << 1) & 63;  // 3  
            opp.sr = (Std.parseInt(data[dataIndex++]) << 1) & 63;  // 4  
            opp.rr = ((Std.parseInt(data[dataIndex++]) << 2) + 2) & 63;  // 5  
            opp.sl = Std.parseInt(data[dataIndex++]) & 15;  // 6  
            opp.tl = Std.parseInt(data[dataIndex++]) & 127;  // 7  
            opp.ksr = Std.parseInt(data[dataIndex++]) & 3;  // 8  
            opp.mul = Std.parseInt(data[dataIndex++]) & 15;  // 9  
            opp.dt1 = Std.parseInt(data[dataIndex++]) & 7;  // 10  
            opp.detune = Std.parseInt(data[dataIndex++]);  // 11  
            opp.ams = Std.parseInt(data[dataIndex++]) & 3;
        }
        return param;
    }
    
    
    // #MA@
    // alg[0-15], fb[0-7],
    // (ws[0-31], ar[0-15], dr[0-15], sr[0-15], rr[0-15], sl[0-15], tl[0-63], ksr[0,1], ksl[0-3], mul[0-15], dt1[0-7], ams[0-3]) x operator_count
    private static function _setMA3ParamByArray(param : SiOPMChannelParam, data : Array<Dynamic>) : SiOPMChannelParam
    {
        if (param.opeCount == 0)             return param;
        
        var alg : Int = SiMMLTable.instance.alg_ma3[param.opeCount - 1][Std.parseInt(data[0]) & 15];
        if (alg == -1)             throw errorParameterNotValid("#MA@ algorism", data[0]);
        
        param.fratio = 133;
        param.alg = alg;
        param.fb = Std.parseInt(data[1]);
        var dataIndex : Int = 2;
        var i : Int;
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            opp.setPGType(SiOPMTable.PG_MA3_WAVE + (Std.parseInt(data[dataIndex++]) & 31));  // 1  
            opp.ar = (Std.parseInt(data[dataIndex++]) << 2) & 63;  // 2  
            opp.dr = (Std.parseInt(data[dataIndex++]) << 2) & 63;  // 3  
            opp.sr = (Std.parseInt(data[dataIndex++]) << 2) & 63;  // 4  
            opp.rr = (Std.parseInt(data[dataIndex++]) << 2) & 63;  // 5  
            opp.sl = Std.parseInt(data[dataIndex++]) & 15;  // 6  
            opp.tl = Std.parseInt(data[dataIndex++]) & 63;  // 7  
            opp.ksr = (Std.parseInt(data[dataIndex++]) << 1) & 3;  // 8  
            opp.ksl = Std.parseInt(data[dataIndex++]) & 3;  // 9  
            i = Std.parseInt(data[dataIndex++]) & 15;  // 10  
            opp.mul = ((i == 11 || i == 13)) ? (i - 1) : ((i == 14)) ? (i + 1) : i;
            opp.dt1 = Std.parseInt(data[dataIndex++]) & 7;  // 11  
            opp.ams = Std.parseInt(data[dataIndex++]) & 3;
        }
        return param;
    }
    
    
    // #AL@
    // con[0-2], ws1[0-511], ws2[0-511], balance[-64-+64], vco2pitch[]
    // ar[0-63], dr[0-63], sl[0-15], rr[0-63]
    private static function _setALParamByArray(param : SiOPMChannelParam, data : Array<Dynamic>) : SiOPMChannelParam
    {
        var opp0 : SiOPMOperatorParam = param.operatorParam[0];
        var opp1 : SiOPMOperatorParam = param.operatorParam[1];
        var tltable : Array<Int> = SiOPMTable.instance.eg_lv2tlTable;
        var connectionType : Int = Std.parseInt(data[0]);
        var balance : Int = Std.parseInt(data[3]);
        param.opeCount = 5;
        param.alg = ((connectionType >= 0 && connectionType <= 2)) ? connectionType : 0;
        opp0.setPGType(Std.parseInt(data[1]));
        opp1.setPGType(Std.parseInt(data[2]));
        if (balance > 64)             balance = 64
        else if (balance < -64)             balance = -64;
        opp0.tl = tltable[64 - balance];
        opp1.tl = tltable[balance + 64];
        opp0.detune = 0;
        opp1.detune = data[4];
        
        opp0.ar = (Std.parseInt(data[5])) & 63;
        opp0.dr = (Std.parseInt(data[6])) & 63;
        opp0.sr = 0;
        opp0.rr = (Std.parseInt(data[8])) & 15;
        opp0.sl = (Std.parseInt(data[7])) & 63;
        
        return param;
    }
    
    
    
    
    // get by Array
    //--------------------------------------------------
    /** get number list inside of #&#64;{..}; */
    public static function getParam(param : SiOPMChannelParam) : Array<Dynamic> {
        if (param.opeCount == 0)             return null;
        var res : Array<Dynamic> = [param.alg, param.fb, param.fbc];
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            res.push(opp.pgType);
            res.push(opp.ar);
            res.push(opp.dr);
            res.push(opp.sr);
            res.push(opp.rr);
            res.push(opp.sl);
            res.push(opp.tl);
            res.push(opp.ksr);
            res.push(opp.ksl);
            res.push(opp.mul);
            res.push(opp.dt1);
            res.push(opp.detune);
            res.push(opp.ams);
            res.push(opp.phase);
            res.push(opp.fixedPitch >> 6);
        }
        return res;
    }
    
    
    /** get number list inside of #OPL&#64;{..}; */
    public static function getOPLParam(param : SiOPMChannelParam) : Array<Dynamic>{
        if (param.opeCount == 0)             return null;
        var alg : Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opl);
        if (alg == -1)             throw errorParameterNotValid("#OPL@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
        var res : Array<Dynamic> = [alg, param.fb];
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            var ws : Int = _pgTypeMA3(opp.pgType);
            var egt : Int = ((opp.sr == 0)) ? 1 : 0;
            var tl : Int = ((opp.tl < 63)) ? opp.tl : 63;
            if (ws == -1) throw errorParameterNotValid("#OPL@", "SiOPM ws" + Std.string(opp.pgType));
            res.push(ws);
            res.push(opp.ar >> 2);
            res.push(opp.dr >> 2);
            res.push(opp.rr >> 2);
            res.push(egt);
            res.push(opp.sl);
            res.push(tl);
            res.push(opp.ksr >> 1);
            res.push(opp.ksl);
            res.push(opp.mul);
            res.push(opp.ams);
        }
        return res;
    }
    
    
    /** get number list inside of #OPM&#64;{..}; */
    public static function getOPMParam(param : SiOPMChannelParam) : Array<Dynamic>{
        if (param.opeCount == 0)             return null;
        var alg : Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opm);
        if (alg == -1)             throw errorParameterNotValid("#OPM@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
        var res : Array<Dynamic> = [alg, param.fb];
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            var dt2 : Int = _dt2OPM(opp.detune);
            res.push(opp.ar >> 1);
            res.push(opp.dr >> 1);
            res.push(opp.sr >> 1);
            res.push(opp.rr >> 2);
            res.push(opp.sl);
            res.push(opp.tl);
            res.push(opp.ksr);
            res.push(opp.mul);
            res.push(opp.dt1);
            res.push(dt2);
            res.push(opp.ams);
        }
        return res;
    }
    
    
    /** get number list inside of #OPN&#64;{..}; */
    public static function getOPNParam(param : SiOPMChannelParam) : Array<Dynamic>{
        if (param.opeCount == 0)             return null;
        var alg : Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opm);
        if (alg == -1)             throw errorParameterNotValid("#OPN@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
        var res : Array<Dynamic> = [alg, param.fb];
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            res.push(opp.ar >> 1);
            res.push(opp.dr >> 1);
            res.push(opp.sr >> 1);
            res.push(opp.rr >> 2);
            res.push(opp.sl);
            res.push(opp.tl);
            res.push(opp.ksr);
            res.push(opp.mul);
            res.push(opp.dt1);
            res.push(opp.ams);
        }
        return res;
    }
    
    
    /** get number list inside of #OPX&#64;{..}; */
    public static function getOPXParam(param : SiOPMChannelParam) : Array<Dynamic>{
        if (param.opeCount == 0)             return null;
        var alg : Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opx);
        if (alg == -1)             throw errorParameterNotValid("#OPX@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
        var res : Array<Dynamic> = [alg, param.fb];
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            var ws : Int = _pgTypeMA3(opp.pgType);
            if (ws == -1)                 throw errorParameterNotValid("#OPX@", "SiOPM ws" + Std.string(opp.pgType));
            res.push(ws);
            res.push(opp.ar >> 1);
            res.push(opp.dr >> 1);
            res.push(opp.sr >> 1);
            res.push(opp.rr >> 2);
            res.push(opp.sl);
            res.push(opp.tl);
            res.push(opp.ksr);
            res.push(opp.mul);
            res.push(opp.dt1);
            res.push(opp.detune);
            res.push(opp.ams);
        }
        return res;
    }
    
    
    /** get number list inside of #MA&#64;{..}; */
    public static function getMA3Param(param : SiOPMChannelParam) : Array<Dynamic>{
        if (param.opeCount == 0)             return null;
        var alg : Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_ma3);
        if (alg == -1)             throw errorParameterNotValid("#MA@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
        var res : Array<Dynamic> = [alg, param.fb];
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            var ws : Int = _pgTypeMA3(opp.pgType);
            var tl : Int = ((opp.tl < 63)) ? opp.tl : 63;
            if (ws == -1)                 throw errorParameterNotValid("#MA@", "SiOPM ws" + Std.string(opp.pgType));
            res.push(ws);
            res.push(opp.ar >> 2);
            res.push(opp.dr >> 2);
            res.push(opp.sr >> 2);
            res.push(opp.rr >> 2);
            res.push(opp.sl);
            res.push(tl);
            res.push(opp.ksr >> 1);
            res.push(opp.ksl);
            res.push(opp.mul);
            res.push(opp.dt1);
            res.push(opp.ams);
        }
        return res;
    }
    
    
    /** get number list inside of #AL&#64;{..}; */
    public static function getALParam(param : SiOPMChannelParam) : Array<Dynamic>{
        if (param.opeCount != 5)             return null;
        var opp0 : SiOPMOperatorParam = param.operatorParam[0];
        var opp1 : SiOPMOperatorParam = param.operatorParam[1];
        return [param.alg, opp0.pgType, opp1.pgType, _balanceAL(opp0.tl, opp1.tl), opp1.detune, opp0.ar, opp0.dr, opp0.sl, opp0.rr];
    }
    
    
    
    
    // reconstruct MML string from channel parameters
    //--------------------------------------------------
    /** reconstruct mml text of #&#64;{..}.
     *  @param param SiOPMChannelParam for MML reconstruction
     *  @param separator String to separate each number
     *  @param lineEnd String to separate line end
     *  @param comment comment text inserting after 'fbc' number
     *  @return text formatted as "{..}".
     */
    public static function mmlParam(param : SiOPMChannelParam, separator : String = " ", lineEnd : String = "\n", comment : String = null) : String
    {
        if (param.opeCount == 0)             return "";
        
        var mml : String = "";
        var res : Dynamic = _checkDigit(param);
        mml += "{";
        mml += Std.string(param.alg) + separator;
        mml += Std.string(param.fb) + separator;
        mml += Std.string(param.fbc);
        if (comment != null) {
            if (lineEnd == "\n")                 mml += " // " + comment
            else mml += "/* " + comment + " */";
        }
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            mml += lineEnd;
            mml += _str(opp.pgType, res.ws) + separator;
            mml += _str(opp.ar, 2) + separator;
            mml += _str(opp.dr, 2) + separator;
            mml += _str(opp.sr, 2) + separator;
            mml += _str(opp.rr, 2) + separator;
            mml += _str(opp.sl, 2) + separator;
            mml += _str(opp.tl, res.tl) + separator;
            mml += Std.string(opp.ksr) + separator;
            mml += Std.string(opp.ksl) + separator;
            mml += _str(opp.mul, 2) + separator;
            mml += Std.string(opp.dt1) + separator;
            mml += _str(opp.detune, res.dt) + separator;
            mml += Std.string(opp.ams) + separator;
            mml += _str(opp.phase, res.ph) + separator;
            mml += _str(opp.fixedPitch >> 6, res.fn);
        }
        mml += "}";
        
        return mml;
    }
    
    
    /** reconstruct mml text of #OPL&#64;{..}; 
     *  @param param SiOPMChannelParam for MML reconstruction
     *  @param separator String to separate each number
     *  @param lineEnd String to separate line end
     *  @param comment comment text inserting after 'fbc' number
     *  @return text formatted as "{..}".
     */
    public static function mmlOPLParam(param : SiOPMChannelParam, separator : String = " ", lineEnd : String = "\n", comment : String = null) : String
    {
        if (param.opeCount == 0)             return "";
        
        var alg : Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opl);
        if (alg == -1)             throw errorParameterNotValid("#OPL@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
        
        var mml : String = "";
        var res : Dynamic = _checkDigit(param);
        mml += "{" + Std.string(alg) + separator + Std.string(param.fb);
        if (comment != null) {
            if (lineEnd == "\n")                 mml += " // " + comment
            else mml += "/* " + comment + " */";
        }
        
        var pgType : Int;
        var tl : Int;
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            mml += lineEnd;
            pgType = _pgTypeMA3(opp.pgType);
            if (pgType == -1)                 throw errorParameterNotValid("#OPL@", "SiOPM ws" + Std.string(opp.pgType));
            mml += Std.string(pgType) + separator;  // ws  
            mml += _str(opp.ar >> 2, 2) + separator;  // ar  
            mml += _str(opp.dr >> 2, 2) + separator;  // dr  
            mml += _str(opp.rr >> 2, 2) + separator;  // rr  
            mml += (((opp.sr == 0)) ? "1" : "0") + separator;  // egt  
            mml += _str(opp.sl, 2) + separator;  // sl  
            mml += _str(((opp.tl < 63)) ? opp.tl : 63, 2) + separator;  // tl  
            mml += Std.string(opp.ksr >> 1) + separator;  // ksr  
            mml += Std.string(opp.ksl) + separator;  // ksl  
            mml += _str(opp.mul, 2) + separator;  // mul  
            mml += Std.string(opp.ams);
        }
        mml += "}";
        
        return mml;
    }
    
    
    /** reconstruct mml text of #OPM&#64;{..}; 
     *  @param param SiOPMChannelParam for MML reconstruction
     *  @param separator String to separate each number
     *  @param lineEnd String to separate line end
     *  @param comment comment text inserting after 'fbc' number
     *  @return text formatted as "{..}".
     */
    public static function mmlOPMParam(param : SiOPMChannelParam, separator : String = " ", lineEnd : String = "\n", comment : String = null) : String
    {
        if (param.opeCount == 0)             return "";
        
        var alg : Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opm);
        if (alg == -1)             throw errorParameterNotValid("#OPM@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
        
        var mml : String = "";
        var res : Dynamic = _checkDigit(param);
        mml += "{" + Std.string(alg) + separator + Std.string(param.fb);
        if (comment != null) {
            if (lineEnd == "\n")                 mml += " // " + comment
            else mml += "/* " + comment + " */";
        }
        
        var pgType : Int;
        var tl : Int;
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            mml += lineEnd;
            // if (opp.pgType != 0) throw errorParameterNotValid("#OPM@", "SiOPM ws" + String(opp.pgType));
            mml += _str(opp.ar >> 1, 2) + separator;  // ar  
            mml += _str(opp.dr >> 1, 2) + separator;  // dr  
            mml += _str(opp.sr >> 1, 2) + separator;  // sr  
            mml += _str(opp.rr >> 2, 2) + separator;  // rr  
            mml += _str(opp.sl, 2) + separator;  // sl  
            mml += _str(opp.tl, res.tl) + separator;  // tl  
            mml += Std.string(opp.ksl) + separator;  // ksl  
            mml += _str(opp.mul, 2) + separator;  // mul  
            mml += Std.string(opp.dt1) + separator;  // dt1  
            mml += Std.string(_dt2OPM(opp.detune)) + separator;  // dt2  
            mml += Std.string(opp.ams);
        }
        mml += "}";
        
        return mml;
    }
    
    
    /** reconstruct mml text of #OPN&#64;{..}; 
     *  @param param SiOPMChannelParam for MML reconstruction
     *  @param separator String to separate each number
     *  @param lineEnd String to separate line end
     *  @param comment comment text inserting after 'fbc' number
     *  @return text formatted as "{..}".
     */
    public static function mmlOPNParam(param : SiOPMChannelParam, separator : String = " ", lineEnd : String = "\n", comment : String = null) : String
    {
        if (param.opeCount == 0)             return "";
        
        var alg : Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opm);
        if (alg == -1)             throw errorParameterNotValid("#OPN@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
        
        var mml : String = "";
        var res : Dynamic = _checkDigit(param);
        mml += "{" + Std.string(alg) + separator + Std.string(param.fb);
        if (comment != null) {
            if (lineEnd == "\n")                 mml += " // " + comment
            else mml += "/* " + comment + " */";
        }
        
        var pgType : Int;
        var tl : Int;
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            mml += lineEnd;
            // if (opp.pgType != 0) throw errorParameterNotValid("#OPN@", "SiOPM ws" + String(opp.pgType));
            mml += _str(opp.ar >> 1, 2) + separator;  // ar  
            mml += _str(opp.dr >> 1, 2) + separator;  // dr  
            mml += _str(opp.sr >> 1, 2) + separator;  // sr  
            mml += _str(opp.rr >> 2, 2) + separator;  // rr  
            mml += _str(opp.sl, 2) + separator;  // sl  
            mml += _str(opp.tl, res.tl) + separator;  // tl  
            mml += Std.string(opp.ksl) + separator;  // ksl  
            mml += _str(opp.mul, 2) + separator;  // mul  
            mml += Std.string(opp.dt1) + separator;  // dt1  
            mml += Std.string(opp.ams);
        }
        mml += "}";
        
        return mml;
    }
    
    
    /** reconstruct mml text of #OPX&#64;{..}; 
     *  @param param SiOPMChannelParam for MML reconstruction
     *  @param separator String to separate each number
     *  @param lineEnd String to separate line end
     *  @param comment comment text inserting after 'fbc' number
     *  @return text formatted as "{..}".
     */
    public static function mmlOPXParam(param : SiOPMChannelParam, separator : String = " ", lineEnd : String = "\n", comment : String = null) : String
    {
        if (param.opeCount == 0)             return "";
        
        var alg : Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_opx);
        if (alg == -1)             throw errorParameterNotValid("#OPX@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
        
        var mml : String = "";
        var res : Dynamic = _checkDigit(param);
        mml += "{" + Std.string(alg) + separator + Std.string(param.fb);
        if (comment != null) {
            if (lineEnd == "\n")                 mml += " // " + comment
            else mml += "/* " + comment + " */";
        }
        
        var pgType : Int;
        var tl : Int;
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            mml += lineEnd;
            pgType = _pgTypeMA3(opp.pgType);
            if (pgType == -1)                 throw errorParameterNotValid("#OPX@", "SiOPM ws" + Std.string(opp.pgType));
            mml += Std.string(pgType) + separator;  // ws  
            mml += _str(opp.ar >> 1, 2) + separator;  // ar  
            mml += _str(opp.dr >> 1, 2) + separator;  // dr  
            mml += _str(opp.sr >> 1, 2) + separator;  // sr  
            mml += _str(opp.rr >> 2, 2) + separator;  // rr  
            mml += _str(opp.sl, 2) + separator;  // sl  
            mml += _str(opp.tl, res.tl) + separator;  // tl  
            mml += Std.string(opp.ksl) + separator;  // ksl  
            mml += _str(opp.mul, 2) + separator;  // mul  
            mml += Std.string(opp.dt1) + separator;  // dt1  
            mml += _str(opp.detune, res.dt) + separator;  // det  
            mml += Std.string(opp.ams);
        }
        mml += "}";
        
        return mml;
    }
    
    
    /** reconstruct mml text of #MA&#64;{..}; 
     *  @param param SiOPMChannelParam for MML reconstruction
     *  @param separator String to separate each number
     *  @param lineEnd String to separate line end
     *  @param comment comment text inserting after 'fbc' number
     *  @return text formatted as "{..}".
     */
    public static function mmlMA3Param(param : SiOPMChannelParam, separator : String = " ", lineEnd : String = "\n", comment : String = null) : String
    {
        if (param.opeCount == 0)             return "";
        
        var alg : Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance.alg_ma3);
        if (alg == -1)             throw errorParameterNotValid("#MA@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
        
        var mml : String = "";
        var res : Dynamic = _checkDigit(param);
        mml += "{" + Std.string(alg) + separator + Std.string(param.fb);
        if (comment != null) {
            if (lineEnd == "\n")                 mml += " // " + comment
            else mml += "/* " + comment + " */";
        }
        
        var pgType : Int;
        var tl : Int;
        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            mml += lineEnd;
            pgType = _pgTypeMA3(opp.pgType);
            if (pgType == -1)                 throw errorParameterNotValid("#MA@", "SiOPM ws" + Std.string(opp.pgType));
            mml += _str(pgType, 2) + separator;  // ws  
            mml += _str(opp.ar >> 2, 2) + separator;  // ar  
            mml += _str(opp.dr >> 2, 2) + separator;  // dr  
            mml += _str(opp.sr >> 2, 2) + separator;  // sr  
            mml += _str(opp.rr >> 2, 2) + separator;  // rr  
            mml += _str(opp.sl, 2) + separator;  // sl  
            mml += _str(((opp.tl < 63)) ? opp.tl : 63, 2) + separator;  // tl  
            mml += Std.string(opp.ksr >> 1) + separator;  // ksr  
            mml += Std.string(opp.ksl) + separator;  // ksl  
            mml += _str(opp.mul, 2) + separator;  // mul  
            mml += Std.string(opp.dt1) + separator;  // dt1  
            mml += Std.string(opp.ams);
        }
        mml += "}";
        
        return mml;
    }
    
    
    
    /** reconstruct mml text of #AL&#64;{..}; 
     *  @param param SiOPMChannelParam for MML reconstruction
     *  @param separator String to separate each number
     *  @param lineEnd String to separate line end
     *  @param comment comment text inserting after 'fbc' number
     *  @return text formatted as "{..}".
     */
    public static function mmlALParam(param : SiOPMChannelParam, separator : String = " ", lineEnd : String = "\n", comment : String = null) : String
    {
        if (param.opeCount != 5)             return null;
        
        var opp0 : SiOPMOperatorParam = param.operatorParam[0];
        var opp1 : SiOPMOperatorParam = param.operatorParam[1];
        var mml : String = "";
        mml += "{" + Std.string(param.alg) + separator;
        mml += Std.string(opp0.pgType) + separator;
        mml += Std.string(opp1.pgType) + separator;
        mml += Std.string(_balanceAL(opp0.tl, opp1.tl)) + separator;
        mml += Std.string(opp1.detune) + separator;
        if (comment != null) {
            if (lineEnd == "\n")                 mml += " // " + comment
            else mml += "/* " + comment + " */";
        }
        mml += lineEnd + Std.string(opp0.ar) + separator;
        mml += Std.string(opp0.dr) + separator;
        mml += Std.string(opp0.sl) + separator;
        mml += Std.string(opp0.rr);
        mml += "}";
        
        return mml;
    }
    
    
    
    
    // extract system command from mml
    //------------------------------------------------------------
    /** extract system command from mml 
     *  @param mml mml text
     *  @return extracted command list. the mml of "#CMD1{cont}pfx;" is converted to the Object as {command:"CMD", number:1, content:"cont", postfix:"pfx"}.
     */
    public static function extractSystemCommand(mml : String) : Array<Dynamic>
    {
        var comrex : EReg = new EReg("/\\*.*?\\*/|//.*?[\\r\\n]+", "gms");
        var seqrex : EReg = new EReg('(#[A-Z@]+)([^;{]*({.*?})?[^;]*);', "gms");  //}
        var prmrex : EReg = new EReg('\\s*(\\d*)\\s*(\\{(.*?)\\})?(.*)', "ms");
        var res : Dynamic;
        var res2 : Dynamic;
        var cmd : String;
        var num : Int = 0;
        var dat : String = null;
        var pfx : String = null;
        var cmds : Array<Dynamic> = new Array<Dynamic>();
        
        // remove comments
        mml += "\n";
        mml = comrex.replace(mml, "") + ";";
        
        // parse system command
        while (seqrex.match(mml)){
            cmd = Std.string(seqrex.matched(1));
            if (seqrex.matched(2) != "") {
                if (prmrex.match(seqrex.matched(2))) {
                    num = Std.parseInt(prmrex.matched(1));
                    dat = ((prmrex.matched(2) == null)) ? "" : Std.string(prmrex.matched(3));
                    pfx = Std.string(prmrex.matched(4));
                }
            }
            else {
                num = 0;
                dat = "";
                pfx = "";
            }
            cmds.push({
                        command : cmd,
                        number : num,
                        content : dat,
                        postfix : pfx
                      });
        }
        return cmds;
    }
    
    
    
    
    
    // Voice parameters (filter, lfo, portament, gate time, sweep)
    //------------------------------------------------------------
    /** parse voice setting mml 
     *  @param voice voice to update
     *  @param mml setting mml
     *  @param envelopes envelope list to pickup envelope
     *  @return same as argument of 'voice'.
     */
    public static function parseVoiceSetting(voice : SiMMLVoice, mml : String, envelopes : Array<SiMMLEnvelopTable> = null) : SiMMLVoice{
        var i : Int;
        var j : Int;
        var cmd : String = "(%[fvx]|@[fpqv]|@er|@lfo|kt?|m[ap]|_?@@|_?n[aptf]|po|p|q|s|x|v)";
        var ags : String = "(-?\\d*)";
        for (i in 0...10){
            ags += "(\\s*,\\s*(-?\\d*))?";
        }
        var rex : EReg = new EReg(cmd + ags, "g");
        var res : Array<String> = new Array<String>();
        var param : SiOPMChannelParam = voice.channelParam;
        var matchString = mml;
        while (rex.match(matchString)) {

            // Reset the matching array
            res.splice(0,res.length);

            // Convert to the array format expected by all the functions
            for (i in 0...21) {
                res.push(rex.matched(i));
            }

            var _sw1_ = (res[1]);            

            switch (_sw1_)
            {
                case "@f":
                    param.cutoff = ((res[2] != "")) ? Std.parseInt(res[2]) : 128;
                    param.resonance = ((res[4] != "")) ? Std.parseInt(res[4]) : 0;
                    param.far = ((res[6] != "")) ? Std.parseInt(res[6]) : 0;
                    param.fdr1 = ((res[8] != "")) ? Std.parseInt(res[8]) : 0;
                    param.fdr2 = ((res[10] != "")) ? Std.parseInt(res[10]) : 0;
                    param.frr = ((res[12] != "")) ? Std.parseInt(res[12]) : 0;
                    param.fdc1 = ((res[14] != "")) ? Std.parseInt(res[14]) : 128;
                    param.fdc2 = ((res[16] != "")) ? Std.parseInt(res[16]) : 64;
                    param.fsc = ((res[18] != "")) ? Std.parseInt(res[18]) : 32;
                    param.frc = ((res[20] != "")) ? Std.parseInt(res[20]) : 128;
                case "@lfo":
                    param.lfoFrame = ((res[2] != "")) ? Std.parseInt(res[2]) : 30;
                    param.lfoWaveShape = ((res[4] != "")) ? Std.parseInt(res[4]) : SiOPMTable.LFO_WAVE_TRIANGLE;
                case "ma":
                    voice.amDepth = ((res[2] != "")) ? Std.parseInt(res[2]) : 0;
                    voice.amDepthEnd = ((res[4] != "")) ? Std.parseInt(res[4]) : 0;
                    voice.amDelay = ((res[6] != "")) ? Std.parseInt(res[6]) : 0;
                    voice.amTerm = ((res[8] != "")) ? Std.parseInt(res[8]) : 0;
                    param.amd = voice.amDepth;
                case "mp":
                    voice.pmDepth = ((res[2] != "")) ? Std.parseInt(res[2]) : 0;
                    voice.pmDepthEnd = ((res[4] != "")) ? Std.parseInt(res[4]) : 0;
                    voice.pmDelay = ((res[6] != "")) ? Std.parseInt(res[6]) : 0;
                    voice.pmTerm = ((res[8] != "")) ? Std.parseInt(res[8]) : 0;
                    param.pmd = voice.pmDepth;
                case "po":
                    voice.portament = ((res[2] != "")) ? Std.parseInt(res[2]) : 30;
                case "q":
                    voice.defaultGateTime = ((res[2] != "")) ? (Std.parseInt(res[2]) * 0.125) : Math.NaN;
                case "s":
                    //[releaseRate] = (res[2] != "") ? int(res[2]) : 0;
                    voice.releaseSweep = ((res[4] != "")) ? Std.parseInt(res[4]) : 0;
                
                case "%f":
                    voice.channelParam.filterType = ((res[2] != "")) ? Std.parseInt(res[2]) : 0;
                case "@er":
                    for (i in 0...4){
                        voice.channelParam.operatorParam[i].erst = (res[2] != "1");
                    }
                case "k":
                    voice.pitchShift = ((res[2] != "")) ? Std.parseInt(res[2]) : 0;
                case "kt":
                    voice.noteShift = ((res[2] != "")) ? Std.parseInt(res[2]) : 0;
                
                case "@v":
                    voice.channelParam.volumes[0] = ((res[2] != "")) ? (Std.parseInt(res[2]) * 0.0078125) : 0.5;
                    voice.channelParam.volumes[1] = ((res[4] != "")) ? (Std.parseInt(res[4]) * 0.0078125) : 0;
                    voice.channelParam.volumes[2] = ((res[6] != "")) ? (Std.parseInt(res[6]) * 0.0078125) : 0;
                    voice.channelParam.volumes[3] = ((res[8] != "")) ? (Std.parseInt(res[8]) * 0.0078125) : 0;
                    voice.channelParam.volumes[4] = ((res[10] != "")) ? (Std.parseInt(res[10]) * 0.0078125) : 0;
                    voice.channelParam.volumes[5] = ((res[12] != "")) ? (Std.parseInt(res[12]) * 0.0078125) : 0;
                    voice.channelParam.volumes[6] = ((res[14] != "")) ? (Std.parseInt(res[14]) * 0.0078125) : 0;
                    voice.channelParam.volumes[7] = ((res[16] != "")) ? (Std.parseInt(res[16]) * 0.0078125) : 0;
                case "p":
                    voice.channelParam.pan = ((res[2] != "")) ? Std.parseInt(res[2]) * 16 : 64;
                case "@p":
                    voice.channelParam.pan = ((res[2] != "")) ? Std.parseInt(res[2]) : 64;
                case "v":
                    voice.velocity = ((res[2] != "")) ? (Std.parseInt(res[2]) << voice.vcommandShift) : 256;
                case "x":
                    voice.expression = ((res[2] != "")) ? Std.parseInt(res[2]) : 128;
                
                case "%v":
                    voice.velocityMode = ((res[2] != "")) ? Std.parseInt(res[2]) : 0;
                    voice.vcommandShift = ((res[4] != "")) ? Std.parseInt(res[4]) : 4;
                case "%x":
                    voice.expressionMode = ((res[2] != "")) ? Std.parseInt(res[2]) : 0;
                case "@q":
                    voice.defaultGateTicks = ((res[2] != "")) ? Std.parseInt(res[2]) : 0;
                    voice.defaultKeyOnDelayTicks = ((res[4] != "")) ? Std.parseInt(res[4]) : 0;
                
                case "@@":
                    i = Std.parseInt(res[2]);
                    if (envelopes != null && i >= 0 && i < 255) {
                        voice.noteOnToneEnvelop = envelopes[i];
                        voice.noteOnToneEnvelopStep = ((Std.parseInt(res[4]) > 0)) ? Std.parseInt(res[4]) : 1;
                    }
                case "na":
                    i = Std.parseInt(res[2]);
                    if (envelopes != null && i >= 0 && i < 255) {
                        voice.noteOnAmplitudeEnvelop = envelopes[i];
                        voice.noteOnAmplitudeEnvelopStep = ((Std.parseInt(res[4]) > 0)) ? Std.parseInt(res[4]) : 1;
                    }
                case "np":
                    i = Std.parseInt(res[2]);
                    if (envelopes != null && i >= 0 && i < 255) {
                        voice.noteOnPitchEnvelop = envelopes[i];
                        voice.noteOnPitchEnvelopStep = ((Std.parseInt(res[4]) > 0)) ? Std.parseInt(res[4]) : 1;
                    }
                case "nt":
                    i = Std.parseInt(res[2]);
                    if (envelopes != null && i >= 0 && i < 255) {
                        voice.noteOnNoteEnvelop = envelopes[i];
                        voice.noteOnNoteEnvelopStep = ((Std.parseInt(res[4]) > 0)) ? Std.parseInt(res[4]) : 1;
                    }
                case "nf":
                    i = Std.parseInt(res[2]);
                    if (envelopes != null && i >= 0 && i < 255) {
                        voice.noteOnFilterEnvelop = envelopes[i];
                        voice.noteOnFilterEnvelopStep = ((Std.parseInt(res[4]) > 0)) ? Std.parseInt(res[4]) : 1;
                    }
                case "_@@":
                    i = Std.parseInt(res[2]);
                    if (envelopes != null && i >= 0 && i < 255) {
                        voice.noteOffToneEnvelop = envelopes[i];
                        voice.noteOffToneEnvelopStep = ((Std.parseInt(res[4]) > 0)) ? Std.parseInt(res[4]) : 1;
                    }
                case "_na":
                    i = Std.parseInt(res[2]);
                    if (envelopes != null && i >= 0 && i < 255) {
                        voice.noteOffAmplitudeEnvelop = envelopes[i];
                        voice.noteOffAmplitudeEnvelopStep = ((Std.parseInt(res[4]) > 0)) ? Std.parseInt(res[4]) : 1;
                    }
                case "_np":
                    i = Std.parseInt(res[2]);
                    if (envelopes != null && i >= 0 && i < 255) {
                        voice.noteOffPitchEnvelop = envelopes[i];
                        voice.noteOffPitchEnvelopStep = ((Std.parseInt(res[4]) > 0)) ? Std.parseInt(res[4]) : 1;
                    }
                case "_nt":
                    i = Std.parseInt(res[2]);
                    if (envelopes != null && i >= 0 && i < 255) {
                        voice.noteOffNoteEnvelop = envelopes[i];
                        voice.noteOffNoteEnvelopStep = ((Std.parseInt(res[4]) > 0)) ? Std.parseInt(res[4]) : 1;
                    }
                case "_nf":
                    i = Std.parseInt(res[2]);
                    if (envelopes != null && i >= 0 && i < 255) {
                        voice.noteOffFilterEnvelop = envelopes[i];
                        voice.noteOffFilterEnvelopStep = ((Std.parseInt(res[4]) > 0)) ? Std.parseInt(res[4]) : 1;
                    }
            }

            // Update the string so we can look for the next match
            matchString = rex.matchedRight();
        }
        return voice;
    }
    
    
    /** reconstruct voice setting mml (except for channel operator parameters and envelopes) */
    public static function mmlVoiceSetting(voice : SiMMLVoice) : String{
        var mml : String = "";
        var param : SiOPMChannelParam = voice.channelParam;
        var i : Int;
        if (voice.channelParam.filterType > 0)             mml += "%f" + Std.string(voice.channelParam.filterType);
        if (param.cutoff < 128 || param.resonance > 0 || param.far > 0 || param.frr > 0) {
            mml += "@f" + Std.string(param.cutoff) + "," + Std.string(param.resonance);
            if (param.far > 0 || param.frr > 0) {
                mml += "," + Std.string(param.far) + "," + Std.string(param.fdr1) + "," + Std.string(param.fdr2) + "," + Std.string(param.frr);
                mml += "," + Std.string(param.fdc1) + "," + Std.string(param.fdc2) + "," + Std.string(param.fsc) + "," + Std.string(param.frc);
            }
        }
        if (voice.amDepth > 0 || voice.amDepthEnd > 0 || param.amd > 0 || voice.pmDepth > 0 || voice.pmDepthEnd > 0 || param.pmd > 0) {
            var lfo : Int = param.lfoFrame;
            var ws : Int = param.lfoWaveShape;
            if (lfo != 30 || ws != SiOPMTable.LFO_WAVE_TRIANGLE) {
                mml += "@lfo" + Std.string(lfo);
                if (ws != SiOPMTable.LFO_WAVE_TRIANGLE)                     mml += "," + Std.string(ws);
            }
            if (voice.amDepth > 0 || voice.amDepthEnd > 0) {
                mml += "ma" + Std.string(voice.amDepth);
                if (voice.amDepthEnd > 0)                     mml += "," + Std.string(voice.amDepthEnd);
                if (voice.amDelay > 0 || voice.amTerm > 0)                     mml += "," + Std.string(voice.amDelay);
                if (voice.amTerm > 0)                     mml += "," + Std.string(voice.amTerm);
            }
            else if (param.amd > 0) {
                mml += "ma" + Std.string(param.amd);
            }
            if (voice.pmDepth > 0 || voice.pmDepthEnd > 0) {
                mml += "mp" + Std.string(voice.pmDepth);
                if (voice.pmDepthEnd > 0)                     mml += "," + Std.string(voice.pmDepthEnd);
                if (voice.pmDelay > 0 || voice.pmTerm > 0)                     mml += "," + Std.string(voice.pmDelay);
                if (voice.pmTerm > 0)                     mml += "," + Std.string(voice.pmTerm);
            }
            else if (param.pmd > 0) {
                mml += "mp" + Std.string(param.pmd);
            }
        }
        if (voice.velocityMode != 0 || voice.vcommandShift != 4) {
            mml += "%v" + Std.string(voice.velocityMode) + "," + Std.string(voice.vcommandShift);
        }
        if (voice.expressionMode != 0)             mml += "%x" + Std.string(voice.expressionMode);
        if (voice.portament > 0)             mml += "po" + Std.string(voice.portament);
        if (!Math.isNaN(voice.defaultGateTime))             mml += "q" + Math.floor(voice.defaultGateTime * 8);
        if (voice.defaultGateTicks > 0 || voice.defaultKeyOnDelayTicks > 0) {
            mml += "@q" + Std.string(voice.defaultGateTicks) + "," + Std.string(voice.defaultKeyOnDelayTicks);
        }
        if (voice.releaseSweep > 0)             mml += "s," + Std.string(voice.releaseSweep);
        if (voice.channelParam.operatorParam[0].erst)             mml += "@er1";
        if (voice.pitchShift > 0) mml += "k" + Std.string(voice.pitchShift);
        if (voice.noteShift > 0)  mml += "kt" + Std.string(voice.noteShift);
        if (voice.updateVolumes) {
            var ch : Int = ((voice.channelParam.volumes[0] == 0.5)) ? 0 : 1;
            i = 0;
            while (i < 8){
                if (voice.channelParam.volumes[i] != 0) ch = i + 1;
                i++;
            }
            if (i != 0) {
                mml += "@v";
                if (voice.channelParam.volumes[0] != 0.5) mml += Math.floor(voice.channelParam.volumes[0] * 128);
                for (i in 0...ch){
                    if (voice.channelParam.volumes[i] != 0) mml += "," + Math.floor(voice.channelParam.volumes[i] * 128);
                }
            }
            if (voice.channelParam.pan != 64) {
                if ((voice.channelParam.pan & 15) != 0) mml += "@p" + Std.string(voice.channelParam.pan - 64)
                else mml += "p" + Std.string(voice.channelParam.pan >> 4);
            }
            if (voice.velocity != 256)                 mml += "v" + Std.string(voice.velocity >> voice.vcommandShift);
            if (voice.expression != 128)                 mml += "@v" + Std.string(voice.expression);
        }
        
        return mml;
    }
    
    
    
    
    // envelop table
    //------------------------------------------------------------
    /** parse mml of envelop and wave table numbers.
     *  @param tableNumbers String of table numbers
     *  @param postfix String of postfix
     *  @param maxIndex maximum size of envelop table
     *  @return this instance
     */
    public static function parseTableNumbers(tableNumbers : String, postfix : String, maxIndex : Int = 65536) : Dynamic
    {
        var index : Int = 0;
        var i : Int;
        var imax : Int;
        var j : Int;
        var v : Int;
        var ti0 : Int;
        var ti1 : Int;
        var tr : Float;
        var t : Float;
        var s : Float;
        var r : Float = Math.NaN;
        var o : Float = Math.NaN;
        var jmax : Int = 0;
        var last : SLLint;
        var rep : SLLint;
        var regexp : EReg;
        var res : Dynamic;
        var array : Array<Dynamic>;
        var itpl : Array<Int> = new Array<Int>();
        var loopStac : Array<Dynamic> = [];
        var tempNumberList : SLLint = SLLint.alloc(0);
        var loopHead : SLLint;
        var loopTail : SLLint;
        var l : SLLint;
        
        // initialize
        last = tempNumberList;
        rep = null;
        
        // magnification
        regexp = new EReg('(\\d+)?(\\*(-?[\\d.]+))?(([+-])([\\d.]+))?', "");
        if (regexp.match(postfix)) {
            jmax = (regexp.matched(1) != null) ? Std.parseInt(regexp.matched(1)) : 1;
            r = (regexp.matched(2) != null) ? Std.parseFloat(regexp.matched(3)) : 1;
            o = (regexp.matched(4) != null) ? ((regexp.matched(5) == "+") ? Std.parseFloat(regexp.matched(6)) : -Std.parseFloat(regexp.matched(6))) : 0;
        }
        
        // res[1];(n..),m {res[2];n.., res[3];m} / res[4];n / res[5];|[] / res[6]; ]n
        regexp = new EReg('(\\(\\s*([,\\-\\d\\s]+)\\)[,\\s]*(\\d+))|(-?\\d+)|(\\||\\[|\\](\\d*))', "gm");
        while (regexp.match(tableNumbers) && index < maxIndex) {
            if (regexp.matched(1) != null) {
                // interpolation "(regexp.matched(2)..),regexp.matched(3)"
                array = new EReg("[,\\s]+","g").replace(regexp.matched(2), ",").split(",");
                imax = Std.parseInt(regexp.matched(3));
                if (imax < 2 || array.length < 1) throw errorParameterNotValid("Table MML", tableNumbers);
                for (i in 0...itpl.length) {
                    itpl[i] = Std.parseInt(array[i]);
                }
                if (itpl.length > 1) {
                    t = 0;
                    s = (itpl.length - 1) / imax;
                    i = 0;
                    while (i < imax && index < maxIndex) {
                        ti0 = Math.floor(t);
                        ti1 = ti0 + 1;
                        tr = t - ti0;
                        v = Math.floor(itpl[ti0] * (1 - tr) + itpl[ti1] * tr + 0.5);
                        v = Math.floor(v * r + o + 0.5);
                        j = 0;
                        while (j < jmax){
                            last.next = SLLint.alloc(v);
                            last = last.next;
                            j++;
                            index++;
                        }
                        t += s;
                    }
                    i++;
                }
                else {
                    // repeat
                    v = Math.floor(itpl[0] * r + o + 0.5);
                    i = 0;
                    while (i < imax && index < maxIndex) {
                        j = 0;
                        while (j < jmax){
                            last.next = SLLint.alloc(v);
                            last = last.next;
                            j++;
                            index++;
                        }
                        i++;
                    }
                }
            }
            else 
            if (regexp.matched(4) != null) {
                // single number
                v = Math.floor(Std.parseInt(regexp.matched(4)) * r + o + 0.5);
                for (j in 0...jmax){
                    last.next = SLLint.alloc(v);
                    last = last.next;
                }
                index++;
            }
            else 
            if (regexp.matched(5) != null) {
                var _sw2_ = regexp.matched(5);

                switch (_sw2_)
                {
                    case "|":  // repeat point  
                    rep = last;
                    case "[":  // begin loop  
                    loopStac.push(last);
                    default:  // end loop "]n"  
                        if (loopStac.length == 0)                             errorParameterNotValid("Table MML's Loop", tableNumbers);
                        loopHead = loopStac.pop().next;
                        if (loopHead == null)                             errorParameterNotValid("Table MML's Loop", tableNumbers);
                        loopTail = last;
                        j = Std.parseInt(regexp.matched(6));
                        if (j == 0) j = 2;
                        while (j > 0) {
                            l = loopHead;
                            while (l != loopTail.next){
                                last.next = SLLint.alloc(l.i);
                                last = last.next;
                                l = l.next;
                            }
                            --j;
                        }
                }
            }
            else {
                // unknown error
                throw errorUnknown("@parseWav()");
            }

            tableNumbers = regexp.matchedRight();
        }
        
        //for(var e:SLLint=tempNumberList.next; e!=null; e=e.next) { trace(e.i); }  
        if (rep != null)             last.next = rep.next;
        return {
            head : tempNumberList.next,
            tail : last,
            length : index,
            repeated : (rep != null)
        };
    }
    
    // wave table mml parser
    //--------------------------------------------------
    /** parse #WAV data
     *  @param tableNumbers number string of #WAV command.
     *  @param postfix postfix string of #WAV command.
     *  @return vector of Number in the range of [-1,1]
     */
    public static function parseWAV(tableNumbers : String, postfix : String) : Array<Float>
    {
        var i : Int;
        var imax : Int;
        var v : Float;
        var wav : Array<Float>;
        
        var res : Dynamic = Translator.parseTableNumbers(tableNumbers, postfix, 1024);
        var num : SLLint = res.head;
        imax = 2;
        while (imax < 1024){
            if (imax >= res.length)                 break;
            imax <<= 1;
        }
        
        wav = new Array<Float>();
        i = 0;
        while (i<imax && num!=null) {
            v = (num.i + 0.5) * 0.0078125;
            wav[i] = ((v > 1)) ? 1 : ((v < -1)) ? -1 : v;
            num = num.next;
        }

        while (i < imax) {
            wav[i] = 0;
        }
        
        return wav;
    }
    
    
    /** parse #WAVB data
     *  @param hex hex string of #WAVB command.
     *  @return vector of Number in the range of [-1,1]
     */
    public static function parseWAVB(hex : String) : Array<Float>
    {
        var ub : Int;
        var i : Int;
        var imax : Int;
        var wav : Array<Float>;
        hex = new EReg('\\s+', "gm").replace(hex, "");
        imax = hex.length >> 1;
        wav = new Array<Float>();
        for (i in 0...imax){
            ub = Std.parseInt("0x" + hex.substr(i << 1, 2));
            wav[i] = ((ub < 128)) ? (ub * 0.0078125) : ((ub - 256) * 0.0078125);
        }
        return wav;
    }
    
    
    
    
    // pcm mml parser
    //--------------------------------------------------
    /** parse mml text of sampler wave setting (#SAMPLER system command).
     *  @param table table to set sampler wave
     *  @param noteNumber note number to set sample
     *  @param mml comma separated text of #SAMPLER system command
     *  @param soundReferTable reference table of Sound instances.
     *  @return true when success to find wave from soundReferTable.
     */
    public static function parseSamplerWave(table : SiOPMWaveSamplerTable, noteNumber : Int, mml : String, soundReferTable : Map<String, Dynamic>) : Bool
    {
        var compactString = new EReg("\\s*,\\s*","g").replace(mml, ",");
        var args:Array<String> = compactString.split(",");
        var waveID : String = Std.string(args[0]);
        var ignoreNoteOff : Bool = ((args[1] != null && args[1] != "")) ? cast(args[1], Bool) : false;
        var pan : Int = ((args[2] != null && args[2] != "")) ? Std.parseInt(args[2]) : 0;
        var channelCount : Int = ((args[3] != null && args[3] != "")) ? Std.parseInt(args[3]) : 2;
        var startPoint : Int = ((args[4] != null && args[4] != "")) ? Std.parseInt(args[4]) : -1;
        var endPoint : Int = ((args[5] != null && args[5] != "")) ? Std.parseInt(args[5]) : -1;
        var loopPoint : Int = ((args[6] != null && args[6] != "")) ? Std.parseInt(args[6]) : -1;
        if (soundReferTable.exists(waveID)) {
            var sample : SiOPMWaveSamplerData = new SiOPMWaveSamplerData();
            sample.initializeFromSound(soundReferTable.get(waveID), ignoreNoteOff, pan, 2, channelCount);
            sample.slice(startPoint, endPoint, loopPoint);
            table.setSample(sample, noteNumber);
            return true;
        }
        return false;
    }
    
    
    /** parse mml text of pcm wave setting (#PCMWAVE system command).
     *  @param table table to set PCM wave
     *  @param mml comma separated values of #PCMWAVE system command
     *  @param soundReferTable reference table of Sound instances.
     *  @return true when success to find wave from soundReferTable.
     */
    public static function parsePCMWave(table : SiOPMWavePCMTable, mml : String, soundReferTable : Map<String,Dynamic>) : Bool
    {
        var args = new EReg("\\s*,\\s*","g").replace(mml, ",").split(",");
        var waveID : String = Std.string(args[0]);
        var samplingNote : Int = ((args[1] != null && args[1] != "")) ? Std.parseInt(args[1]) : 69;
        var keyRangeFrom : Int = ((args[2] != null && args[2] != "")) ? Std.parseInt(args[2]) : 0;
        var keyRangeTo : Int = ((args[3] != null && args[3] != "")) ? Std.parseInt(args[3]) : 127;
        var channelCount : Int = ((args[4] != null && args[4] != "")) ? Std.parseInt(args[4]) : 2;
        var startPoint : Int = ((args[5] != null && args[5] != "")) ? Std.parseInt(args[5]) : -1;
        var endPoint : Int = ((args[6] != null && args[6] != "")) ? Std.parseInt(args[6]) : -1;
        var loopPoint : Int = ((args[7] != null && args[7] != "")) ? Std.parseInt(args[7]) : -1;
        if (soundReferTable.exists(waveID)) {
            var sample : SiOPMWavePCMData = new SiOPMWavePCMData();
            sample.initializeFromSound(soundReferTable.get(waveID), Std.int(samplingNote * 64), 2, channelCount);
            sample.slice(startPoint, endPoint, loopPoint);
            table.setSample(sample, keyRangeFrom, keyRangeTo);
            return true;
        }
        return false;
    }
    
    
    /** parse mml text of pcm voice setting (#PCMVOICE system command)
     *  @param voice SiMMLVoice to update parameters
     *  @param mml comma separated values of #PCMVOICE system command
     *  @param postfix postfix of #PCMVOICE system command
     *  @param envelopes envelope list to pickup envelope
     *  @return true when success to update parameters
     */
    public static function parsePCMVoice(voice : SiMMLVoice, mml : String, postfix : String, envelopes : Array<SiMMLEnvelopTable> = null) : Bool
    {
        var table : SiOPMWavePCMTable = try cast(voice.waveData, SiOPMWavePCMTable) catch(e:Dynamic) null;
        if (table == null)             return false;
        var args = new EReg("\\s*,\\s*","g").replace(mml, ",").split(",");
        var volumeNoteNumber : Int = ((args[0] != null && args[0] != "")) ? Std.parseInt(args[0]) : 64;
        var volumeKeyRange : Float = ((args[1] != null && args[1] != "")) ? Std.parseFloat(args[1]) : 0;
        var volumeRange : Float = ((args[2] != null && args[2] != "")) ? Std.parseFloat(args[2]) : 0;
        var panNoteNumber : Int = ((args[3] != null && args[3] != "")) ? Std.parseInt(args[3]) : 64;
        var panKeyRange : Float = ((args[4] != null && args[4] != "")) ? Std.parseFloat(args[4]) : 0;
        var panWidth : Float = ((args[5] != null && args[5] != "")) ? Std.parseFloat(args[5]) : 0;
        var dr : Int = ((args[7] != null && args[7] != "")) ? Std.parseInt(args[7]) : 0;
        var sr : Int = ((args[8] != null && args[8] != "")) ? Std.parseInt(args[8]) : 0;
        var rr : Int = ((args[9] != null && args[9] != "")) ? Std.parseInt(args[9]) : 63;
        var sl : Int = ((args[10] != null && args[10] != "")) ? Std.parseInt(args[10]) : 0;
        var opp : SiOPMOperatorParam = voice.channelParam.operatorParam[0];
        opp.ar = ((args[6] != null && args[6] != "")) ? Std.parseInt(args[6]) : 63;
        opp.dr = ((args[7] != null && args[7] != "")) ? Std.parseInt(args[7]) : 0;
        opp.sr = ((args[8] != null && args[8] != "")) ? Std.parseInt(args[8]) : 0;
        opp.rr = ((args[9] != null && args[9] != "")) ? Std.parseInt(args[9]) : 63;
        opp.sl = ((args[10] != null && args[10] != "")) ? Std.parseInt(args[10]) : 0;
        table.setKeyScaleVolume(volumeNoteNumber, volumeKeyRange, volumeRange);
        table.setKeyScalePan(panNoteNumber, panKeyRange, panWidth);
        parseVoiceSetting(voice, postfix, envelopes);
        return true;
    }
    
    
    
    
    // register data
    //--------------------------------------------------
    /** set SiONVoice list by OPM register data
     *  @param regData int vector of register data.
     *  @param address address of the first data in regData
     *  @param enableLFO flag to enable LFO parameters
     *  @param voiceSet voice list to set parameters. When this argument is null, returning voices are allocated inside.
     *  @return voice list pick up values from register data.
     */
    public static function setOPMVoicesByRegister(regData : Array<Int>, address : Int, enableLFO : Bool = false, voiceSet : Array<Dynamic> = null) : Array<Dynamic>
    {
        var i : Int;
        var imax : Int;
        var value : Int;
        var index : Int;
        var v : Int;
        var ams : Int;
        var pms : Int;
        var chp : SiOPMChannelParam;
        var opp : SiOPMOperatorParam;
        var opi : Int;
        var _pmd : Int = 0;
        var _amd : Int = 0;
        var opia : Array<Int> = [0, 2, 1, 3];
        var table : SiOPMTable = SiOPMTable.instance;
        
        // initialize result voice list
        if (voiceSet == null) voiceSet = new Array<Int>();
        for (opi in 0...8){
            if (voiceSet[opi])                 voiceSet[opi].initialize()
            else voiceSet[opi] = new SiONVoice();
            voiceSet[opi].channelParam.opeCount = 4;
            voiceSet[opi].chipType = SiONVoice.CHIPTYPE_OPM;
        }  // pick up parameters from register data  
        
        
        
        imax = regData.length;
        i = 0;
        while (i < imax){
            value = regData[i];
            chp = voiceSet[address & 7].channelParam;
            
            // Module parameter
            if (address < 0x20) {
                switch (address)
                {
                    case 1, 8, 15:

                        switch (address)
                        {case 1:  // TEST:7-2 LFO RESET:1  
                            break;
                        }

                        switch (address)
                        {case 8:  // (KEYON) MUTE:7 OP0:6 OP1:5 OP2:4 OP3:3 CH:2-0  
                            break;
                        }  // NOIZE:7 FREQ:4-0  
                        if ((value & 128) != 0) {
                            voiceSet[7].channelParam.operatorParam[3].setPGType(SiOPMTable.PG_NOISE_PULSE);
                            voiceSet[7].channelParam.operatorParam[3].fixedPitch = ((value & 31) << 6) + 2048;
                        }
                    case 16, 17, 18, 19, 24:

                        switch (address)
                        {case 16:  // TIMER AH:7-0  
                            break;
                        }

                        switch (address)
                        {case 17:  // TIMER AL:10  
                            break;
                        }

                        switch (address)
                        {case 18:  // TIMER B :7-0  
                            break;
                        }

                        switch (address)
                        {case 19:  // TIMER FUNC ?  
                            break;
                        }  // LFO FREQ:7-0  
                        if (enableLFO) {
                            v = table.lfo_timerSteps[value];
                            for (opi in 0...8) {
                                voiceSet[opi].channelParam.lfoFreqStep = v;
                            }
                        }
                    case 25:  // A(0)/P(1):7 DEPTH:6-0  
                    if (enableLFO) {
                        if ((value & 128) != 0) _pmd = value & 127
                        else _amd = value & 127;
                    }
                    case 27:  // LFO WS:10  
                    if (enableLFO) {
                        v = value & 3;
                        for (opi in 0...8) {
                            voiceSet[opi].channelParam.lfoWaveShape = v;
                        }
                    }
                }
            }
            else 
            
            // Channel parameter
            if (address < 0x40) {
                var _sw3_ = ((address - 0x20) >> 3);                

                switch (_sw3_)
                {
                    case 0:  // L:7 R:6 FB:5-3 ALG:2-0  
                        v = value >> 6;
                        chp.volumes[0] = ((v != 0)) ? 0.5 : 0;
                        chp.pan = ((v == 1)) ? 128 : ((v == 2)) ? 0 : 64;
                        chp.fb = (value >> 3) & 7;
                        chp.alg = (value) & 7;
                    case 1, 2, 3:

                        switch (_sw3_)
                        {case 1:  // KC:6-0  
                            // channel.kc = value & 127
                            break;
                        }

                        switch (_sw3_)
                        {case 2:  // KF:6-0  
                            // channel.keyFraction = value & 127
                            break;
                        }  // PMS:6-4 AMS:10  
                        if (enableLFO) {
                            pms = (value >> 4) & 7;
                            ams = (value) & 3;
                            chp.pmd = ((pms < 6)) ? (_pmd >> (6 - pms)) : (_pmd << (pms - 5));
                            chp.amd = ((ams > 0)) ? (_amd << (ams - 1)) : 0;
                        }
                }
            }
            else 
            
            // Operator parameter
            {
                index = opia[(address >> 3) & 3];
                opp = chp.operatorParam[index];
                var _sw4_ = ((address - 0x40) >> 5);                

                switch (_sw4_)
                {
                    case 0:  // DT1:6-4 MUL:3-0  
                        opp.dt1 = (value >> 4) & 7;
                        opp.mul = (value) & 15;
                    case 1:  // TL:6-0  
                    opp.tl = value & 127;
                    case 2:  // KS:76 AR:4-0  
                        opp.ksr = (value >> 6) & 3;
                        opp.ar = (value & 31) << 1;
                    case 3:  // AMS:7 DR:4-0  
                        opp.ams = ((value >> 7) & 1) << 1;
                        opp.dr = (value & 31) << 1;
                    case 4:  // DT2:76 SR:4-0  
                        opp.detune = table.dt2Table[(value >> 6) & 3];
                        opp.sr = (value & 31) << 1;
                    case 5:  // SL:7-4 RR:3-0  
                        opp.sl = (value >> 4) & 15;
                        opp.rr = (value & 15) << 2;
                }
            }
            i++;
            address++;
        }
        
        return voiceSet;
    }
    
    
    
    
    
    // internal functions
    //--------------------------------------------------
    // int to string with 0 filling
    private static function _str(v : Int, length : Int) : String{
        if (v >= 0)             return ("0000" + Std.string(v)).substr(-length);
        return "-" + ("0000" + Std.string(-v)).substr(-length + 1);
    }
    
    
    // check parameters digit
    private static function _checkDigit(param : SiOPMChannelParam) : Dynamic{
        var res : Dynamic = {
            ws : 1,
            tl : 2,
            dt : 1,
            ph : 1,
            fn : 1
        };

        function max(a : Int, b : Int) : Int{
            return (a > b) ? a : b;
        };

        for (opeIndex in 0...param.opeCount){
            var opp : SiOPMOperatorParam = param.operatorParam[opeIndex];
            res.ws = max(res.ws, Std.string(opp.pgType).length);
            res.tl = max(res.tl, Std.string(opp.tl).length);
            res.dt = max(res.dt, Std.string(opp.detune).length);
            res.ph = max(res.ph, Std.string(opp.phase).length);
            res.fn = max(res.fn, Std.string(opp.fixedPitch >> 6).length);
        }
        return res;
    }
    
    
    // translate algorism by algorism list, return index in the list.
    private static function _checkAlgorism(oc : Int, al : Int, algList : Array<Dynamic>) : Int{
        var list : Array<Dynamic> = algList[oc - 1];
        for (i in 0...list.length){if (al == list[i])                 return i;
        }
        return -1;
    }
    
    
    // translate pgType to MA3 valid.
    private static function _pgTypeMA3(pgType : Int) : Int{
        var ws : Int = pgType - SiOPMTable.PG_MA3_WAVE;
        if (ws >= 0 && ws <= 31)             return ws;
        switch (pgType)
        {
            case 0:return 0;case 1, 2, 128, 255:return 24;case 4, 192, 191:return 16;case 5, 72:return 6;
        }
        return -1;
    }
    
    
    // find nearest dt2 value
    private static function _dt2OPM(detune : Int) : Int{
        if (detune <= 100)             return 0
        // 0
        else if (detune <= 420)             return 1
        // 384
        // 500
        else if (detune <= 550)             return 2;
        return 3;
    }
    
    
    // find nearest balance value from opp0.tl and opp1.tl
    private static function _balanceAL(tl0 : Int, tl1 : Int) : Int{
        if (tl0 == tl1)             return 0;
        if (tl0 == 0)             return -64;
        if (tl1 == 0)             return 64;
        var tltable : Array<Int> = SiOPMTable.instance.eg_lv2tlTable;
        var i : Int;
        for (i in 0...128) {
            if (tl0 >= tltable[i]) return i - 64;
        }
        return 64;
    }
    
    
    
    
    // errors
    //--------------------------------------------------
    public static function errorToneParameterNotValid(cmd : String, chParam : Int, opParam : Int) : Error
    {
        return new Error("Translator error : Parameter count is not valid in '" + cmd + "'. " + Std.string(chParam) + " parameters for channel and " + Std.string(opParam) + " parameters for each operator.");
    }
    
    
    public static function errorParameterNotValid(cmd : String, param : String) : Error
    {
        return new Error("Translator error : Parameter not valid. '" + param + "' in " + cmd);
    }
    
    
    public static function errorTranslation(str : String) : Error
    {
        return new Error("Translator Error : mml error. '" + str + "'");
    }
    
    
    public static function errorUnknown(str : String) : Error
    {
        return new Error("Translator error : Unknown. " + str);
    }
}


