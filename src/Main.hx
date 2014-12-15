// the simplest example

package ;

#if flash
import flash.display.Sprite;
#else
import openfl._v2.display.Sprite;
#end

import org.si.sion.SiONDriver;
import flash.Lib;

class Main extends Sprite
{
	public var driver : SiONDriver = new SiONDriver();

	public function new () {
		super ();
		Lib.current.addChild(driver);

		driver.play("t100 l8 [ccggaag4 ffeeddc4 | [ggffeed4]2 ]2");
	}
}
