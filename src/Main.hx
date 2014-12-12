// the simplest example

package ;

import org.si.sion.SiONDriver;
import lime.app.Application;

class Main extends Application
{
	public var driver : SiONDriver = new SiONDriver();

	public function new () {
		super ();
		driver.play("t100 l8 [ccggaag4 ffeeddc4 | [ggffeed4]2 ]2");
	}
}
