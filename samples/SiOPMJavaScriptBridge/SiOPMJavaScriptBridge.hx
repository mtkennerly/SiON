import ErrorEvent;
import SiONData;
import SiONDriver;
import SiONEvent;
import Sprite;

import openfl.display.Sprite;
import openfl.external.ExternalInterface;
import openfl.system.Security;
import openfl.events.*;

import org.si.sion.*;
import org.si.sion.events.*;
import org.si.sion.utils.Translator;




class SiOPMJavaScriptBridge extends Sprite
{
    // variables
    //--------------------------------------------------
    public var driver : SiONDriver;
    public var data : SiONData;
    
    
    
    
    // constructor
    //--------------------------------------------------
    public function new()
    {
        super();
        Security.allowDomain("*");
        driver = new SiONDriver();
        data = new SiONData();
        driver.autoStop = true;
        
        //new pcmExample(driver);
        
        // register javascript interfaces
        ExternalInterface.addCallback("_compile", _compile);
        ExternalInterface.addCallback("_play", _play);
        ExternalInterface.addCallback("_stop", driver.stop);
        ExternalInterface.addCallback("_pause", driver.pause);
        ExternalInterface.addCallback("_trans", Translator.tsscp);
        ExternalInterface.addCallback("_volume", _volume);
        ExternalInterface.addCallback("_pan", _pan);
        ExternalInterface.addCallback("_position", _position);
        
        // register handlers
        driver.addEventListener(SiONEvent.QUEUE_PROGRESS, _onCompileProgress);
        driver.addEventListener(SiONEvent.QUEUE_COMPLETE, _onCompileComplete);
        driver.addEventListener(ErrorEvent.ERROR, _onError);
        driver.addEventListener(SiONEvent.STREAM, _onStream);
        driver.addEventListener(SiONEvent.STREAM_START, _onStreamStart);
        driver.addEventListener(SiONEvent.STREAM_STOP, _onStreamStop);
        driver.addEventListener(SiONEvent.FADE_IN_COMPLETE, _onFadeInComplete);
        driver.addEventListener(SiONEvent.FADE_OUT_COMPLETE, _onFadeOutComplete);
        
        // callback onLoad
        ExternalInterface.call("SIOPM._internal_onLoad", SiONDriver.VERSION);
    }
    
    
    
    
    // event handlers
    //--------------------------------------------------
    private function _onCompileProgress(e : SiONEvent) : Void{ExternalInterface.call("SIOPM._internal_onCompileProgress", driver.jobProgress);
    }
    private function _onError(e : ErrorEvent) : Void{ExternalInterface.call("SIOPM._internal_onError", e.text);
    }
    private function _onStream(e : SiONEvent) : Void{ExternalInterface.call("SIOPM._internal_onStream");
    }
    private function _onStreamStart(e : SiONEvent) : Void{ExternalInterface.call("SIOPM._internal_onStreamStart");
    }
    private function _onStreamStop(e : SiONEvent) : Void{ExternalInterface.call("SIOPM._internal_onStreamStop");
    }
    private function _onCompileComplete(e : SiONEvent) : Void{ExternalInterface.call("SIOPM._internal_onCompileComplete", data.title);
    }
    private function _onFadeInComplete(e : SiONEvent) : Void{ExternalInterface.call("SIOPM._internal_onFadeInComplete");
    }
    private function _onFadeOutComplete(e : SiONEvent) : Void{ExternalInterface.call("SIOPM._internal_onFadeOutComplete");
    }
    
    
    
    
    // callback function
    //--------------------------------------------------
    private function _compile(mml : Dynamic) : Bool
    {
        if (mml != null) {
            driver.compileQueue(mml, data);
            driver.startQueue(200);
            return true;
        }
        return false;
    }
    
    
    private function _play() : Void
    {
        driver.play(data);
    }
    
    
    private function _volume(v : Dynamic) : Float
    {
        var vol : Float = Std.parseFloat(v);
        if (!Math.isNaN(vol)) {
            driver.volume = ((vol < 0)) ? 0 : ((vol > 1)) ? 1 : vol;
        }
        return driver.volume;
    }
    
    
    private function _pan(p : Dynamic) : Float
    {
        var pan : Float = Std.parseFloat(p);
        if (!Math.isNaN(pan)) {
            driver.pan = ((pan < -1)) ? -1 : ((pan > 1)) ? 1 : pan;
        }
        return driver.pan;
    }
    
    
    private function _position(p : Dynamic) : Float
    {
        var pos : Float = Std.parseFloat(p);
        if (!Math.isNaN(pos)) {
            driver.position = pos;
        }
        return driver.position;
    }
    
    
    private function _fadeIn(t : Dynamic) : Void
    {
        var time : Float = Std.parseFloat(t);
        if (!Math.isNaN(time)) {
            driver.fadeIn(time);
        }
        else {
            driver.fadeIn(3);
        }
    }
    
    
    private function _fadeOut(t : Dynamic) : Void
    {
        var time : Float = Std.parseFloat(t);
        if (!Math.isNaN(time)) {
            driver.fadeOut(time);
        }
        else {
            driver.fadeOut(3);
        }
    }
}




/*
// special features for sample
import org.si.sion.SiONDriver;
class pcmExample {
[Embed(source="hit.mp3")]   private var hit_mp3:Class;
[Embed(source="kick.mp3")]  private var kick_mp3:Class;
[Embed(source="sdw.mp3")]   private var sdw_mp3:Class;
[Embed(source="sds.mp3")]   private var sds_mp3:Class;
[Embed(source="toml.mp3")]  private var toml_mp3:Class;
[Embed(source="tomh.mp3")]  private var tomh_mp3:Class;
[Embed(source="hatc.mp3")]  private var hatc_mp3:Class;
[Embed(source="hath.mp3")]  private var hath_mp3:Class;
[Embed(source="hato.mp3")]  private var hato_mp3:Class;
[Embed(source="crash.mp3")] private var crash_mp3:Class;
[Embed(source="bell.mp3")]  private var bell_mp3:Class;


function pcmExample(driver:SiONDriver)
{
driver.setPCMSound(0, new hit_mp3());
driver.setSamplerSound(60, new kick_mp3()); //o5c
driver.setSamplerSound(62, new sdw_mp3());  //o5d
driver.setSamplerSound(64, new sds_mp3());  //o5e
driver.setSamplerSound(65, new toml_mp3()); //o5f
driver.setSamplerSound(67, new tomh_mp3()); //o5g
driver.setSamplerSound(48, new hatc_mp3()); //o4c
driver.setSamplerSound(50, new hath_mp3()); //o4d
driver.setSamplerSound(52, new hato_mp3()); //o4e
driver.setSamplerSound(53, new crash_mp3()); //o4f
driver.setSamplerSound(55, new bell_mp3());  //o4g
}
}
*/

