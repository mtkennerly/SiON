// Sample for event trigger
import DisplayObject;
import Event;
import Shape;
import SiONData;
import SiONDriver;
import SiONTrackEvent;

import openfl.display.*;
import openfl.events.*;
import org.si.sion.*;
import org.si.sion.events.*;


class EventTrigger extends Sprite
{
    // driver
    public var driver : SiONDriver = new SiONDriver();
    
    // MML data
    public var mainMelody : SiONData;
    
    
    // constructor
    public function new()
    {
        super();
        // compile with event trigger command (%t)
        mainMelody = driver.compile("%t0,1,1 t100 l8 [ccggaag4 ffeeddc4 | [ggffeed4]2 ]2");
        
        // listen triggers
        driver.addEventListener(SiONTrackEvent.NOTE_ON_FRAME, _onNoteOn);
        driver.addEventListener(SiONTrackEvent.NOTE_OFF_FRAME, _onNoteOff);
        addEventListener("enterFrame", _onEnterFrame);
        
        // play main melody
        driver.play(mainMelody);
    }
    
    
    // This event dispatched when note on
    private function _onNoteOn(e : SiONTrackEvent) : Void{
        _createNoteShape(e.note);
    }
    
    
    // This event dispatched when note off
    private function _onNoteOff(e : SiONTrackEvent) : Void{
        
    }
    
    
    // create shape
    private function _createNoteShape(noteNumber : Int) : Shape{
        var shape : Shape = new Shape();
        shape.graphics.beginFill([0xff8080, 0x80ff80, 0x8080ff, 0xffff80][Math.floor(Math.random() * 4)]);
        shape.graphics.drawCircle(0, 0, Math.random() * 20 + 10);
        shape.graphics.endFill();
        shape.x = (noteNumber - 60) * 30 + 100;
        shape.y = 300;
        addChild(shape);
        return shape;
    }
    
    
    // on each frame
    private function _onEnterFrame(e : Event) : Void{
        var imax : Int = numChildren;
        for (i in 0...imax){
            var child : DisplayObject = getChildAt(i);
            child.y -= 2;
            child.alpha *= 0.98;
            if (child.y < -30 || child.alpha < 0.1) {
                removeChild(child);
                imax--;
                i--;
            }
        }
    }
}


