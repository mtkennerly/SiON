// Sample for synchronized play (with preset voice).
import Event;
import KeyboardEvent;
import SiONData;
import SiONDriver;
import SiONVoice;

import openfl.display.Sprite;
import openfl.events.*;
import org.si.sion.*;
import org.si.sion.utils.SiONPresetVoice;


class SyncSequence extends Sprite
{
    // driver
    public var driver : SiONDriver = new SiONDriver();
    
    // preset voice
    public var presetVoice : SiONPresetVoice = new SiONPresetVoice();
    
    // voice
    public var voiceClick : SiONVoice;
    public var voiceKeyOn : SiONVoice;
    
    // MML data
    public var mainMelody : SiONData;
    public var clickSequence : SiONData;
    
    
    // constructor
    public function new()
    {
        super();
        // compile
        mainMelody = driver.compile("t100 l8 [ccggaag4 ffeeddc4 | [ggffeed4]2 ]2");
        clickSequence = driver.compile("l16v8o6cg<c>g1");
        
        // select voice from preset
        voiceClick = Reflect.field(presetVoice, "valsound.piano8");
        voiceKeyOn = Reflect.field(presetVoice, "valsound.wind1");
        
        // listen click
        stage.addEventListener("click", _onClick);
        stage.addEventListener("keyDown", _onKeyOn);
        
        // play main melody
        driver.play(mainMelody);
    }
    
    
    // click to play sequence. with synchronizaion.
    private function _onClick(e : Event) : Void{
        // play with length=0(play all of sequence), delay=0(no delay), quantize=2(8th beat)
        driver.sequenceOn(clickSequence, voiceClick, 0, 0, 2);
    }
    
    
    // key down ("1" to "9") to play single note
    private function _onKeyOn(e : KeyboardEvent) : Void{
        // calculate note number (60=o5c=key"1")
        var noteNum : Int = e.charCode - ("1".charCodeAt()) + 60;
        // key 1-9 to play note
        if (60 <= noteNum && noteNum <= 68) {
            // play with length=1(8th note), delay=0(no delay), quantize=2(8th beat)
            driver.noteOn(noteNum, voiceKeyOn, 2, 0, 2);
        }
    }
}


