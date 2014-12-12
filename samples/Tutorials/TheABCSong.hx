// the simplest example
import SiONDriver;

import openfl.display.Sprite;
import org.si.sion.*;

class TheABCSong extends Sprite
{
    public var driver : SiONDriver = new SiONDriver();
    
    public function new()
    {
        super();
        driver.play("t100 l8 [ccggaag4 ffeeddc4 | [ggffeed4]2 ]2");
    }
}


