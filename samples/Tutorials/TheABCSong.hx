// the simplest example

package tutorials;

import openfl.events.Event;
import org.si.sion.SiONDriver;
import openfl.display.Sprite;

class TheABCSong extends Sprite
{
    public var driver : SiONDriver = new SiONDriver();
    
    public function new()
    {
        super();
        driver.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        driver.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
        addChild(driver);
    }

    private function onAddedToStage (event:Event):Void {
        driver.play("t100 l8 [ccggaag4 ffeeddc4 | [ggffeed4]2 ]2");
    }

    private function onRemovedFromStage (event:Event):Void {
        driver.stop();
    }
}


