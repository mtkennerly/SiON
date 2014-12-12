package org.si.utils;

import org.si.utils.DisplayObjectContainer;
import org.si.utils.TextField;

import openfl.display.DisplayObjectContainer;
import openfl.text.TextField;
import openfl.events.Event;



/** static timer class */
class Timer
{
    public static var title : String = "";
    private static var _text : TextField = null;
    private static var _time : Array<Int>;
    private static var _sum : Array<Int>;
    private static var _stat : Array<String>;
    private static var _cnt : Int;
    private static var _avc : Int;
    
    
    /** initialize timer.
     *  @param parent parent object
     *  @param averagingCount averaging frames
     *  @param stat texts to display measured times. "##" is replaced with measured time.
     */
    public static function initialize(parent : DisplayObjectContainer, averagingCount : Int) : Void{
        if (_text == null)             parent.addChild(_text = new TextField());
        _avc = averagingCount;
        _stat = stat;
        _time = new Array<Int>();
        _sum = new Array<Int>();
        _cnt = new Array<Int>();
        _text.background = true;
        _text.backgroundColor = 0x80c0f0;
        _text.autoSize = "left";
        _text.multiline = true;
        parent.addEventListener("enterFrame", _onEnterFrame);
    }
    
    /** start timer */
    public static function start(slot : Int = 0) : Void{_time[slot] = Math.round(haxe.Timer.stamp() * 1000);
    }
    
    /** pause timer */
    public static function pause(slot : Int = 0) : Void{_sum[slot] += Math.round(haxe.Timer.stamp() * 1000) - _time[slot];
    }
    
    // enter frame event handler
    private static function _onEnterFrame(e : Event) : Void{
        if (++_cnt == _avc) {
            _cnt = 0;
            var str : String = "";
            var line : String;
            for (slot in 0..._sum.length){
                line = _stat[slot].replace("##", Std.string(_sum[slot] / _avc).substr(0, 3));
                str += line + "\n";
                _sum[slot] = 0;
            }
            _text.text = title + "\n" + str;
        }
    }

    public function new()
    {
    }
}


