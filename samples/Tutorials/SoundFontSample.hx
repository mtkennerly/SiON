package tutorials;

import openfl.events.ErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoader;
import openfl.events.KeyboardEvent;
import org.si.sion.utils.soundloader.SoundLoader;
import openfl.net.URLRequest;
import openfl.events.Event;
import org.si.sion.SiONDriver;
import openfl.display.Sprite;

class SoundFontSample extends Sprite {
    // driver
    public var driver : SiONDriver = new SiONDriver();

    //private var SOUND_FONT_URL:String = "http://assets.wonderfl.net/images/related_images/a/aa/aa9a/aa9a00df008e71a100500b5c90da9b71734af5e8";
    private var SOUND_FONT_URL:String = "http://www.gunnbr.org/NomlTest-SoundFont.png";
    private var checkPolicyFile:Bool = true;

    public function new() {
        super();
        driver.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        addChild(driver);
    }

    public var myLoader:URLLoader;

    function onLoadComplete(e:Event):Void {
        trace('onLoadComplete');
        trace(myLoader.data);
    }

    private function onAddedToStage (event:Event):Void {
        //trace('Testing URLLoder');
        //make a new loader
        //myLoader = new URLLoader();
        //new request - for a file in the same folder called 'someTextFile.txt'
        //var myRequest:URLRequest = new URLRequest(SOUND_FONT_URL);

        //wait for the load
        //myLoader.addEventListener(Event.COMPLETE, onLoadComplete);

        //trace('Starting the load...');
        //load!
        //myLoader.load(myRequest);

        //trace('The load is going!');

        var loader:SoundLoader = new SoundLoader();
        loader.setURL(new URLRequest(SOUND_FONT_URL), "sample", "ssfpng", checkPolicyFile);
        loader.addEventListener(Event.COMPLETE, onLoaderComplete);
        loader.addEventListener(ErrorEvent.ERROR, onLoaderError);
        trace('Starting loader loading');
        loader.loadAll();
    }

    private function onLoaderComplete(e:Event):Void {
        trace('Loader complete: $e');
        trace('target is ${e.target}');

        var loader = cast(e.target, SoundLoader);
        if (loader == null)
        {
            trace('Invalid target type returned');
        }
        var data = loader.hash;
        trace('data is $data');

        driver.noteOnExceptionMode = SiONDriver.NEM_IGNORE;

        var sampleData = data["sample"];
        if (sampleData == null) {
            trace('No sampleData returned');
        }
        else {
            driver.setSamplerTable(0, sampleData.samplerTables[0]);
        }

        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    }

    private function onLoaderError(e:ErrorEvent):Void {
        trace('Failed to load sounds: ${e.text}');
    }

    private function onKeyDown(event:KeyboardEvent) {
        trace('key down: ${event.keyCode}');
        switch (event.keyCode) {
            case 40: // arrow down
                // bullet
                driver.playSound(4, 1, 0, 0, 4);


            case 38: // arrow up


            case 13: // return
                // Player
                driver.playSound(2, 1, 0, 0, 2);

        }
    }

}
