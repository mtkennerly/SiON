// SiON TENORION
import Bitmap;
import BitmapData;
import ColorTransform;
import Event;
import Point;
import Shape;
import SiONDriver;
import SiONPresetVoice;
import SiONTrackEvent;
import SiONVoice;
import Sprite;
import Stage;

import openfl.display.Sprite;
import openfl.events.*;
import openfl.text.TextField;
import org.si.sion.*;
import org.si.sion.events.*;
import org.si.sion.utils.SiONPresetVoice;



import openfl.display.*;

import openfl.geom.*;

class Tenorion extends Sprite
{
    // driver
    public var driver : SiONDriver = new SiONDriver();
    
    // preset voice
    public var presetVoice : SiONPresetVoice = new SiONPresetVoice();
    
    // voices, notes and tracks
    public var voices : Array<SiONVoice> = new Array<SiONVoice>();
    public var notes : Array<Int> = [36, 48, 60, 72, 43, 48, 55, 60, 65, 67, 70, 72, 77, 79, 82, 84];
    public var length : Array<Int> = [1, 1, 1, 1, 1, 1, 1, 1, 4, 4, 4, 4, 4, 4, 4, 4];
    
    // beat counter
    public var beatCounter : Int;
    
    // control pad
    public var matrixPad : MatrixPad;
    
    // constructor
    public function new()
    {
        super();
        var i : Int;
        
        // set voices from preset
        var percusVoices : Array<Dynamic> = Reflect.field(presetVoice, "valsound.percus");
        voices[0] = percusVoices[0];  // bass drum  
        voices[1] = percusVoices[27];  // snare drum  
        voices[2] = percusVoices[16];  // close hihat  
        voices[3] = percusVoices[22];  // open hihat  
        for (8){voices[i] = Reflect.field(presetVoice, "valsound.bass18");
        }  // others  
        
        // listen
        driver.setBeatCallbackInterval(1);
        driver.addEventListener(SiONTrackEvent.BEAT, _onBeat);
        driver.setTimerInterruption(1, _onTimerInterruption);
        
        // control pad
        matrixPad = new MatrixPad(stage);
        addChild(matrixPad);
        
        // start streaming
        beatCounter = 0;
        driver.play();
    }
    
    
    // _onBeat (SiONTrackEvent.BEAT) is called back in each beat at the sound timing.
    private function _onBeat(e : SiONTrackEvent) : Void
    {
        matrixPad.beat(e.eventTriggerID & 15);
    }
    
    
    // _onTimerInterruption (SiONDriver.setTimerInterruption) is called back in each beat at the buffering timing.
    private function _onTimerInterruption() : Void
    {
        var beatIndex : Int = beatCounter & 15;
        for (i in 0...16){
            if (matrixPad.sequences[i] & (1 << beatIndex) != 0)                 driver.noteOn(notes[i], voices[i], length[i]);
        }
        beatCounter++;
    }
}





class MatrixPad extends Bitmap
{
    public var sequences : Array<Int> = new Array<Int>();
    private var canvas : Shape = new Shape();
    private var buffer : BitmapData = new BitmapData(320, 320, true, 0);
    private var padOn : BitmapData = _pad(0x303050, 0x6060a0);
    private var padOff : BitmapData = _pad(0x303050, 0x202040);
    private var pt : Point = new Point();
    private var colt : ColorTransform = new ColorTransform(1, 1, 1, 0.1);
    
    
    public function new(stage : Stage)
    {
        super(new BitmapData(320, 320, false, 0));
        var i : Int;
        for (256){
            pt.x = (i & 15) * 20;
            pt.y = (i & 240) * 1.25;
            buffer.copyPixels(padOff, padOff.rect, pt);
            bitmapData.copyPixels(padOff, padOff.rect, pt);
        }
        for (16){sequences[i] = 0;
        }
        addEventListener("enterFrame", _onEnterFrame);
        stage.addEventListener("click", _onClick);
    }
    
    
    private function _pad(border : Int, face : Int) : BitmapData{
        var pix : BitmapData = new BitmapData(20, 20, false, 0);
        canvas.graphics.clear();
        canvas.graphics.lineStyle(1, border);
        canvas.graphics.beginFill(face);
        canvas.graphics.drawRect(1, 1, 17, 17);
        canvas.graphics.endFill();
        pix.draw(canvas);
        return pix;
    }
    
    
    private function _onEnterFrame(e : Event) : Void{
        bitmapData.draw(buffer, null, colt);
    }
    
    
    private function _onClick(e : Event) : Void{
        if (mouseX >= 0 && mouseX < 320 && mouseY >= 0 && mouseY < 320) {
            var track : Int = 15 - Math.round(mouseY * 0.05);
            var beat : Int = Math.round(mouseX * 0.05);
            sequences[track] ^= 1 << beat;
            pt.x = beat * 20;
            pt.y = (15 - track) * 20;
            if (sequences[track] & (1 << beat) != 0)                 buffer.copyPixels(padOn, padOn.rect, pt)
            else buffer.copyPixels(padOff, padOff.rect, pt);
        }
    }
    
    
    public function beat(beat16th : Int) : Void{
        pt.x = beat16th * 20;
pt.y = 0;
        while (pt.y < 320){bitmapData.copyPixels(padOn, padOn.rect, pt);
            pt.y += 20;
        }
    }
}


