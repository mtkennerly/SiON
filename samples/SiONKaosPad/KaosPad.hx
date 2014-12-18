// SiON KAOS PAD

package siONKaosPad;

import openfl.display.Sprite;
import openfl.events.*;
import org.si.sion.*;
import org.si.sion.events.*;
import org.si.sion.effector.*;
import org.si.sion.utils.SiONPresetVoice;
import openfl.display.*;
import openfl.filters.BlurFilter;

class KaosPad extends Sprite
{
    // driver
    public var driver : SiONDriver = new SiONDriver();
    
    // preset voice
    public var presetVoice : SiONPresetVoice = new SiONPresetVoice();
    
    // MML data
    public var drumLoop : SiONData;
    
    // low pass filter effector
    public var lpf : SiCtrlFilterLowPass = new SiCtrlFilterLowPass();
    
    // control pad
    public var controlPad : ControlPad;
    
    
    // constructor
    public function new()
    {
        super();
        driver.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addChild(driver);
    }

    private function onAddedToStage (event:Event):Void {
        // compile mml.
        drumLoop =driver.compile("t132; %6@0o3l8$c2cc.c.; %6@1o3$rcrc; %6@2v8l16$[crccrrcc]; %6@3v8o3$[rc8r8];")  // set voices of "%6@0-3" from preset  ;

        rhythmLoop.setVoice(0, presetVoice.voices.get("valsound.percus1"));  // bass drum
        var percusVoices : Array<Dynamic> = Reflect.field(presetVoice, "valsound.percus");
        drumLoop.setVoice(0, percusVoices[0]);  // bass drum  
        drumLoop.setVoice(1, percusVoices[27]);  // snare drum  
        drumLoop.setVoice(2, percusVoices[16]);  // close hihat  
        drumLoop.setVoice(3, percusVoices[21]);  // open hihat  
        
        // listen click
        driver.addEventListener(SiONEvent.STREAM, _onStream);
        driver.addEventListener(SiONTrackEvent.BEAT, _onBeat);
        
        // set parameters of low pass filter
        lpf.initialize();
        lpf.control(1, 0.5);
        
        // connect low pass filter on slot0.
        driver.effector.initialize();
        driver.effector.connect(0, lpf);
        
        // control pad
        controlPad = new ControlPad(stage, 320, 320, 0.5, 1, 0x301010);
        addChild(controlPad);
        
        // play with an argument of resetEffector = false.
        driver.play(drumLoop, false);
    }
    
    
    private function _onStream(e : SiONEvent) : Void
    {
        var x : Float = 1 - controlPad.controlX;
        lpf.control(controlPad.controlY * 0.9 + 0.1, (1 - x * x) * 0.96);
    }
    
    
    private function _onBeat(e : SiONTrackEvent) : Void
    {
        controlPad.beat(32);
    }
}





class ControlPad extends Bitmap
{
    public var controlX : Float;
    public var controlY : Float;
    public var isDragging : Bool;
    public var color : Int;
    
    private var buffer : BitmapData;
    private var ratX : Float;private var ratY : Float;
    private var prevX : Float;private var prevY : Float;
    private var clsDrawer : Shape = new Shape();
    private var canvas : Shape = new Shape();
    private var blur : BlurFilter = new BlurFilter(5, 5);
    private var pointerSize : Float = 8;
    
    
    public function new(stage : Stage, width : Int, height : Int, initialX : Float = 0, initialY : Float = 0, color : Int = 0x101030)
    {
        super(new BitmapData(width + 32, height + 32, false, 0));
        buffer = new BitmapData(width + 32, height + 32, false, 0);
        
        clsDrawer.graphics.clear();
        clsDrawer.graphics.lineStyle(1, 0xffffff);
        clsDrawer.graphics.drawRect(16, 16, width, height);
        
        bitmapData.draw(clsDrawer);
        buffer.fillRect(buffer.rect, 0);
        
        this.color = color;
        controlX = initialX;
        controlY = initialY;
        ratX = 1 / width;
        ratY = 1 / height;
        prevX = buffer.width * controlX;
        prevY = buffer.height * controlY;
        addEventListener("enterFrame", _onEnterFrame);
        stage.addEventListener("mouseMove", _onMouseMove);
        stage.addEventListener("mouseDown", function(e : Event) : Void{isDragging = true;
                });
        stage.addEventListener("mouseUp", function(e : Event) : Void{isDragging = false;
                });
    }
    
    
    private function _onEnterFrame(e : Event) : Void{
        var x : Float = (buffer.width - 32) * controlX + 16;
        var y : Float = (buffer.height - 32) * (1 - controlY) + 16;
        canvas.graphics.clear();
        canvas.graphics.lineStyle(pointerSize, color);
        canvas.graphics.moveTo(prevX, prevY);
        canvas.graphics.lineTo(x, y);
        buffer.applyFilter(buffer, buffer.rect, buffer.rect.topLeft, blur);
        buffer.draw(canvas, null, null, "add");
        bitmapData.copyPixels(buffer, buffer.rect, buffer.rect.topLeft);
        bitmapData.draw(clsDrawer);
        prevX = x + Math.random();
        prevY = y;
        pointerSize *= 0.96;
    }
    
    
    private function _onMouseMove(e : MouseEvent) : Void{
        if (isDragging) {
            controlX = (mouseX - 16) * ratX;
            controlY = 1 - (mouseY - 16) * ratY;
            if (controlX < 0)                 controlX = 0
            else if (controlX > 1)                 controlX = 1;
            if (controlY < 0)                 controlY = 0
            else if (controlY > 1)                 controlY = 1;
        }
    }
    
    
    public function beat(size : Int) : Void{
        pointerSize = size;
    }
}

