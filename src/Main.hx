// Sample for synchronized play (with preset voice).

package ;

import openfl._v2.display.BlendMode;
import openfl._v2.text.TextField;
import org.si.sion.sequencer.SiMMLTrack;
import org.si.sion.events.SiONEvent;
import org.si.sion.events.SiONTrackEvent;
import org.si.sound.Arpeggiator;
import org.si.sion.utils.Scale;
import openfl._v2.display.Stage;
import openfl._v2.filters.BlurFilter;
import openfl._v2.display.Shape;
import openfl._v2.display.BitmapData;
import openfl._v2.display.Bitmap;

#if flash
import flash.display.Sprite;
#else
import openfl._v2.display.Sprite;
#end

import org.si.sion.SiONData;
import org.si.sion.SiONDriver;
import flash.Lib;

import openfl._v2.events.*;
import org.si.sion.*;
import org.si.sion.utils.SiONPresetVoice;


class Main extends Sprite
{
	// driver
	public var driver : SiONDriver = new SiONDriver();

	// preset voice
	public var presetVoice : SiONPresetVoice = new SiONPresetVoice();

	// MML data
	public var rhythmLoop : SiONData;

	// control pad
	public var controlPad : ControlPad;

	// text
	public var startPortamentHere : TextField = new TextField();

	// arpeggiator
	public var arpeggiator : Arpeggiator;

	// constructor
	public function new()
	{
		super();
		Lib.current.addChild(driver);

		// compile
		//mainMelody = driver.compile("t132; %6@0o3l8$c2cc.c.; %6@1o3$rcrc; %6@2v8l16$[crccrrcc]; %6@3v8o3$[rc8r8];");
		// select voice from preset
		//voiceClick = Reflect.field(presetVoice, "valsound.piano8");
		//voiceKeyOn = Reflect.field(presetVoice, "valsound.wind1");

		// listen click
		//stage.addEventListener("click", _onClick);
		//stage.addEventListener("keyDown", _onKeyOn);

		// play main melody
		//driver.play(mainMelody);

		rhythmLoop = driver.compile("t132;%6@0o3l8$c2cc.c.; %6@1o3$rcrc; %6@2v8l16$[crccrrcc]; %6@3v8o3$[rc8r8];%6@4v8l16o3$aa<a8>a<ga>ararara<e8>;");

		// set voices of "%6@0-4" from preset
		var percusVoices : Array<SiONVoice> = presetVoice.categories.get("valsound.percus");
		rhythmLoop.setVoice(0, percusVoices[0]);  // bass drum
		rhythmLoop.setVoice(1, percusVoices[27]);  // snare drum
		rhythmLoop.setVoice(2, percusVoices[16]);  // close hihat
		rhythmLoop.setVoice(3, percusVoices[21]);  // open hihat
		rhythmLoop.setVoice(4, presetVoice.voices.get("valsound.bass3"));  // bass

		// listen click
		driver.addEventListener(SiONEvent.STREAM, _onStream);
		driver.addEventListener(SiONTrackEvent.BEAT, _onBeat);
		stage.addEventListener("mouseDown", _onMouseDown);
		stage.addEventListener("mouseUp", _onMouseUp);

		// arpeggiator setting
		arpeggiator = new Arpeggiator(new Scale("o1Ajap"), 1, [0, 1, 2, 5, 4, 3]);
		arpeggiator.voice = presetVoice.voices.get("valsound.lead32");
		arpeggiator.quantize = 4;
		arpeggiator.volume = 0.3;
		arpeggiator.noteQuantize = 8;

		// control pad
		controlPad = new ControlPad(stage, 320, 320, 0.5, 0.5, 0x101030);
		addChild(controlPad);

		startPortamentHere.htmlText = "<font color='#808080'>Start Portament Here</font>";
		startPortamentHere.selectable = false;
		startPortamentHere.x = 24;
		startPortamentHere.y = 24;
		startPortamentHere.width = 320;
		addChild(startPortamentHere);

		// play with an argument of resetEffector = false.
		driver.play(rhythmLoop, false);
	}

	private function _onMouseDown(e : MouseEvent) : Void
	{
		// set portament if mouseY < 40
		if (mouseY < 40)             arpeggiator.portament = 4
		else arpeggiator.portament = 0;

		// set pitch
		arpeggiator.scaleIndex = Math.floor(controlPad.controlX * 32);

		// start arpeggio
		arpeggiator.play();

		// update setup
		//arpeggiator.track.channel.setFilterResonance(3);
		//arpeggiator.track.channel.activateFilter(true);
	}


	private function _onMouseUp(e : MouseEvent) : Void
	{
		// stop arpeggio
		arpeggiator.stop();
	}

	private function _onStream(e : SiONEvent) : Void
	{
#if false
		// update arpeggiators track parameters
		var track : SiMMLTrack = arpeggiator.track;
		if (track != null) {
			// update arpeggiator pitch
			arpeggiator.scaleIndex = Math.floor(controlPad.controlX * 32);
			// update filter
			var cutoff : Int = Math.floor((controlPad.controlY - 0.1) * 192);
			if (cutoff > 128)                 cutoff = 128
			else if (cutoff < 16)                 cutoff = 16;
			track.channel.setFilterOffset(cutoff);
		}
#end
	}


	private function _onBeat(e : SiONTrackEvent) : Void
	{
		controlPad.beat(32);
	}
}


class ControlPad extends openfl._v2.display.Bitmap
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
		buffer.draw(canvas, null, null, BlendMode.ADD);
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




