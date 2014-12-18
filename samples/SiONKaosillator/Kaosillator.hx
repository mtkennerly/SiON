// SiON Kaoscillator for ver0.58
package siONKaosillator;

import openfl.text.TextFormat;
import flash.display.*;
import flash.events.*;
import flash.ui.Keyboard;
import flash.text.TextField;
import org.si.sion.*;
import org.si.sion.events.*;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sion.utils.SiONPresetVoice;
import org.si.sion.utils.Scale;
import org.si.sound.Arpeggiator;
import com.bit101.components.*;
import flash.display.*;
import flash.events.*;
import flash.filters.BlurFilter;
import flash.geom.*;



class Kaosillator extends Sprite {
    // driver
    public var driver:SiONDriver = new SiONDriver();

    // preset voice
    public var presetVoice:SiONPresetVoice = new SiONPresetVoice();

    // MML data
    public var rhythmLoop:SiONData;

    // control pad
    public var controlPad:ControlPad;

    // arpeggiator
    public var arpeggiator:Arpeggiator;


    // constructor
    public function new() {
        super();
        driver.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addChild(driver);
    }

    private function onAddedToStage (event:Event):Void {
        // compile mml.
        var mml:String = "t132;";
        mml += "%6@0o3l8$c2cc.c.; %6@1o3$rcrc; %6@2v8l16$[crccrrcc]; %6@3v8o3$[rc8r8];";
        mml += "%6@4v8l16o3$aa<a8>a<ga>ararara<e8>;";
        rhythmLoop = driver.compile(mml);

        // set voices of "%6@0-4" from preset
        rhythmLoop.setVoice(0, presetVoice.voices.get("valsound.percus1"));  // bass drum
        rhythmLoop.setVoice(1, presetVoice.voices.get("valsound.percus28"));  // snare drum
        rhythmLoop.setVoice(2, presetVoice.voices.get("valsound.percus17"));  // close hihat
        rhythmLoop.setVoice(3, presetVoice.voices.get("valsound.percus23"));  // open hihat
        rhythmLoop.setVoice(4, presetVoice.voices.get("valsound.bass3"));  // bass

        // listen click
        driver.addEventListener(SiONEvent.STREAM,    _onStream);
        driver.addEventListener(SiONTrackEvent.BEAT, _onBeat);
        stage.addEventListener("mouseDown", _onMouseDown);
        stage.addEventListener("mouseUp",   _onMouseUp);
        stage.addEventListener("keyDown",   _onKeyDown);
        stage.addEventListener("keyUp",     _onKeyUp);

        // arpeggiator setting
        arpeggiator = new Arpeggiator(new Scale("o1Ajap"), 1, [0,1,2,5,4,3]);
        arpeggiator.voice = presetVoice.voices.get("valsound.lead32");
        arpeggiator.quantize = 4;
        arpeggiator.volume = 0.3;
        arpeggiator.noteQuantize = 8;

        // background
        var back:Shape = new Shape();
        back.graphics.beginFill(0);
        back.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
        back.graphics.endFill();
        addChild(back);

        // control pad
        controlPad = new ControlPad(stage, stage.stageWidth - 32, stage.stageHeight - 32, 0.5, 0.5, 0x4040B0); //0x101030);
        addChild(controlPad);

        // labels
        var ts = new TextFormat();
        ts.font = "Arial";  // set the font
        ts.size = 24; // set the font size
        ts.color=0xFFFFFF;  // set the color

        var label = new TextField();
        label.text = "[Ctrl]:  Staccato  /  [Shift]: Portament";
        label.setTextFormat(ts);
        label.x = Std.int((stage.stageWidth - label.textWidth) / 2);
        label.y = 20;
        label.width = label.textWidth + 10;
        label.height = label.textHeight + 10;
        addChild(label);

        // play rhythmLoop
        driver.play(rhythmLoop);
    }


    private function _onMouseDown(e:MouseEvent) : Void
    {
        // set pitch and length
        arpeggiator.scaleIndex = Std.int(controlPad.controlX * 32);
        arpeggiator.noteLength = [0.5,1,1,2,4][Std.int(controlPad.controlY * 4 + 0.99)];
        trace('arp scale: ${arpeggiator.scaleIndex} note: ${arpeggiator.noteLength}');
        // start arpeggio
        arpeggiator.play();
    }


    private function _onMouseUp(e:MouseEvent) : Void
    {
        // stop arpeggio
        arpeggiator.stop();
    }


    private function _onKeyDown(e:KeyboardEvent) : Void
    {
        switch (e.keyCode) {
            case Keyboard.SHIFT:
                arpeggiator.portament = 4;  // set portament
            case Keyboard.CONTROL:
                arpeggiator.gateTime = 0.25;  // set staccart
        }
    }


    private function _onKeyUp(e:KeyboardEvent) : Void
    {
        switch (e.keyCode) {
            case Keyboard.SHIFT:
                arpeggiator.portament = 0; // reset portament
            case Keyboard.CONTROL:
                arpeggiator.gateTime = 1;  // reset staccart
        }
    }

    private function _onStream(e:SiONEvent) : Void
    {
        // update arpeggiator pitch and length
        arpeggiator.scaleIndex = Std.int(controlPad.controlX * 24 + 4);
        arpeggiator.noteLength = [0.5,1,1,2,4][Std.int(controlPad.controlY * 4 + 0.99)];
    }


    private function _onBeat(e:SiONTrackEvent) : Void
    {
        controlPad.beat(6);
    }
}



class ControlPad extends Bitmap {
    public var controlX:Float;
    public var controlY:Float;
    public var isDragging:Bool;
    public var color:Int;
    
    private var buffer:BitmapData;
    private var ratX:Float;
    private var ratY:Float;
    private var prevX:Float;
    private var prevY:Float;
    private var blurX:Int;
    private var clsDrawer:Shape = new Shape();
    private var canvas:Shape = new Shape();
    private var blur:BlurFilter = new BlurFilter(2, 2);
    private var pointerSize:Float = 2;


    public function new(stage:Stage, width:Int, height:Int, initialX:Float=0, initialY:Float=0, color:Int=0x303090) {
        super(new BitmapData(width+32, height+32, false, 0));
        buffer = new BitmapData(Std.int(width*0.125+4), Std.int(height*0.125+4), false, 0);
        
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
        blurX = 0;
        addEventListener("enterFrame", _onEnterFrame);
        stage.addEventListener("mouseMove",  _onMouseMove);
        stage.addEventListener("mouseDown",  function(e:Event):Void { isDragging = true; } );
        stage.addEventListener("mouseUp",    function(e:Event):Void { isDragging = false; });
    }


    private var matrix:Matrix = new Matrix(8, 0, 0, 8, 0, 0);
    private function _onEnterFrame(e:Event) : Void {
        var x:Float = (buffer.width  - 4) * controlX + 2;
        var y:Float = (buffer.height - 4) * (1-controlY) + 2;
        canvas.graphics.clear();
        canvas.graphics.lineStyle(pointerSize, color);
        canvas.graphics.moveTo(prevX, prevY);
        canvas.graphics.lineTo(x, y);
        buffer.applyFilter(buffer, buffer.rect, buffer.rect.topLeft, blur);
        buffer.draw(canvas, null, null, BlendMode.ADD);
        bitmapData.draw(buffer, matrix);
        bitmapData.draw(clsDrawer);
        prevX = x + blurX;
        prevY = y;
        blurX = 1 - blurX;
        pointerSize *= 0.75;
    }


    private function _onMouseMove(e:MouseEvent) : Void {
        if (isDragging) {
            controlX = (mouseX - 16) * ratX;
            controlY = 1 - (mouseY - 16) * ratY;
            if (controlX < 0) controlX = 0;
            else if (controlX > 1) controlX = 1;
            if (controlY < 0) controlY = 0;
            else if (controlY > 1) controlY = 1;
        }
    }


    public function beat(size:Int) : Void {
        pointerSize = size;
    }
}
