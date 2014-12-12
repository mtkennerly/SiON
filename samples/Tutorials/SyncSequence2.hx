// Sample for synchronized play 2 (start and stop)
import MouseEvent;
import SiONData;
import SiONDriver;
import SiONVoice;

import openfl.display.*;
import openfl.events.*;
import org.si.sion.*;
import org.si.sion.events.*;


class SyncSequence2 extends Sprite
{
    // driver
    public var driver : SiONDriver = new SiONDriver();
    
    // voice (%5,0(sine wave) with attackRate=63 and releaseRate=32)
    public var sinVoice : SiONVoice = new SiONVoice(5, 0, 63, 32);
    
    // MML data
    public var mainMelody : SiONData;
    public var arpegio : SiONData;
    
    
    // constructor
    public function new()
    {
        super();
        // compile with event trigger command (%t)
        mainMelody = driver.compile("t100 l8 [ccggaag4 ffeeddc4 | [ggffeed4]2 ]2");
        // loops infinitly by "$" command
        arpegio = driver.compile("o6q1l16$c<c>g<g>;o4l4s28,-32q0$c");
        
        // listen triggers
        stage.addEventListener("mouseDown", _onMouseDown);
        stage.addEventListener("mouseUp", _onMouseUp);
        
        // play main melody
        driver.play(mainMelody);
    }
    
    
    private function _onMouseDown(e : MouseEvent) : Void{
        // play sequence with track id of 1. And you can get delay time from returned value.
        var delay : Float = driver.sequenceOn(arpegio, sinVoice, 0, 0, 4, 1) / 44.1;
    }
    
    
    private function _onMouseUp(e : MouseEvent) : Void{
        // stop track with the id of 1. stop without synchronization.
        driver.sequenceOff(1);
    }
}


