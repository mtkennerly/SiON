// Sample for event trigger

package tutorials;

import openfl.events.Event;
import openfl.display.DisplayObject;
import openfl.display.Shape;
import org.si.sion.events.SiONTrackEvent;
import org.si.sion.SiONData;
import org.si.sion.SiONDriver;
import openfl.display.Sprite;

class EventTrigger extends Sprite
{
    // driver
    public var driver : SiONDriver = new SiONDriver();
    
    // MML data
    public var mainMelody : SiONData;
    
    // Note colors
    public var noteColors : Array<UInt>;

    // constructor
    public function new()
    {
        super();

        // Create colors
        noteColors = new Array<UInt>();
        noteColors.push(0xff8080);
        noteColors.push(0x80ff80);
        noteColors.push(0x8080ff);
        noteColors.push(0xffff80);

        driver.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        addChild(driver);
    }

    private function onAddedToStage (event:Event):Void {
        // compile with event trigger command (%t)
        mainMelody = driver.compile("%t0,1,1 t100 l8 [ccggaag4 ffeeddc4 | [ggffeed4]2 ]2");

        // listen triggers
        driver.addEventListener(SiONTrackEvent.NOTE_ON_FRAME, _onNoteOn);
        driver.addEventListener(SiONTrackEvent.NOTE_OFF_FRAME, _onNoteOff);
        addEventListener(Event.ENTER_FRAME, _onEnterFrame);

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

        var randomColor = Math.floor(Math.random() * noteColors.length);

        shape.graphics.beginFill(noteColors[randomColor]);
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
        var i : Int = 0;
        while (i < imax) {
            var child : DisplayObject = getChildAt(i);
            if (child == driver) {
                i++;
                continue;
            }
            child.y -= 2;
            child.alpha *= 0.98;
            if (child.y < -30 || child.alpha < 0.1) {
                removeChild(child);
                imax--;
            }
            else {
                i++;
            }
        }
    }
}


