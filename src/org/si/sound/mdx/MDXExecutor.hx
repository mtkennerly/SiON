package org.si.sound.mdx;

import org.si.sound.mdx.MDXTrack;
import org.si.sound.mdx.SiMMLSequencer;

import org.si.sion.SiONDriver;
import org.si.sion.SiONVoice;
import org.si.sion.sequencer.SiMMLSequencer;
import org.si.sion.sequencer.base.MMLSequence;
import org.si.sion.sequencer.base.MMLEvent;


/** @private [internal] */
class MDXExecutor
{
    @:allow(org.si.sound.mdx)
    private var mdxtrack : MDXTrack;
    @:allow(org.si.sound.mdx)
    private var mmlseq : MMLSequence;
    @:allow(org.si.sound.mdx)
    private var clock : Int;
    @:allow(org.si.sound.mdx)
    private var pointer : Int;
    @:allow(org.si.sound.mdx)
    private var pointerMax : Int;
    
    @:allow(org.si.sound.mdx)
    private var noiseVoiceNumber : Int;
    @:allow(org.si.sound.mdx)
    private var lastRestMML : MMLEvent;
    @:allow(org.si.sound.mdx)
    private var lastNoteMML : MMLEvent;
    @:allow(org.si.sound.mdx)
    private var voiceID : Int;
    @:allow(org.si.sound.mdx)
    private var adpcmID : Int;
    @:allow(org.si.sound.mdx)
    private var anFreq : Int;
    @:allow(org.si.sound.mdx)
    private var repeatStac : Array<Dynamic>;
    @:allow(org.si.sound.mdx)
    private var lfoDelay : Int;
    @:allow(org.si.sound.mdx)
    private var lfofq : Int;
    @:allow(org.si.sound.mdx)
    private var lfows : Int;
    @:allow(org.si.sound.mdx)
    private var mp : Int;
    @:allow(org.si.sound.mdx)
    private var ma : Int;
    @:allow(org.si.sound.mdx)
    private var gateTime : Int;
    @:allow(org.si.sound.mdx)
    private var waitSync : Bool;
    @:allow(org.si.sound.mdx)
    private var volume : Int;
    @:allow(org.si.sound.mdx)
    private var fineVolumeFlag : Bool;
    @:allow(org.si.sound.mdx)
    private var isPCM8 : Bool;
    
    private static var _panTable : Array<Dynamic> = [4, 0, 8, 4];
    private static var _freqTable : Array<Dynamic> = [26, 31, 38, 43, 50];
    private static var _volTable : Array<Dynamic> = [85, 87, 90, 93, 95, 98, 101, 103, 106, 109, 111, 114, 117, 119, 122, 125];
    private static var _volTablePCM8 : Array<Dynamic> = [2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 64, 80];
    private static var _tlTable : Array<Dynamic>;
    
    private var eventIDFadeOut : Int;
    private var eventIDPan : Int;
    private var eventIDExp : Int;
    private var eventIDPShift : Int;
    private var eventIDLFO : Int;
    private var eventIDAMod : Int;
    private var eventIDPMod : Int;
    private var eventIDIndex : Int;
    
    @:allow(org.si.sound.mdx)
    public function new()
    {
        var i : Int;
        if (_tlTable == null) {
            _tlTable = new Array<Dynamic>(128);
            for (128){_tlTable[127 - i] = ((1 << (i >> 3)) * (8 + (i & 7))) >> 12;
            }
            for (16){_volTable[i] = _tlTable[127 - _volTable[i]];
            }
        }
    }
    
    
    @:allow(org.si.sound.mdx)
    private function initialize(mmlseq : MMLSequence, mdxtrack : MDXTrack, noiseVoiceNumber : Int, isPCM8 : Bool) : Void
    {
        this.mmlseq = mmlseq;
        this.mdxtrack = mdxtrack;
        this.noiseVoiceNumber = noiseVoiceNumber;
        this.isPCM8 = isPCM8;
        clock = 0;
        pointer = 0;
        pointerMax = mdxtrack.sequence.length;
        
        lastRestMML = null;
        lastNoteMML = null;
        voiceID = 0;
        adpcmID = -1;
        anFreq = ((mdxtrack.channelNumber < 8)) ? -1 : 4;
        repeatStac = [];
        lfoDelay = 0;
        lfofq = 0;
        lfows = 2;
        mp = ma = 0;
        gateTime = 0;
        waitSync = false;
        volume = 8;
        fineVolumeFlag = false;
        
        if (mmlseq != null) {
            var sequencer : SiMMLSequencer = SiONDriver.mutex.sequencer;
            eventIDFadeOut = sequencer.getEventID("@fadeout");
            eventIDExp = sequencer.getEventID("x");
            eventIDPan = sequencer.getEventID("p");
            eventIDPShift = sequencer.getEventID("k");
            eventIDLFO = sequencer.getEventID("@lfo");
            eventIDAMod = sequencer.getEventID("ma");
            eventIDPMod = sequencer.getEventID("mp");
            eventIDIndex = sequencer.getEventID("i");
            
            if (mdxtrack.channelNumber < 8) {
                mmlseq.appendNewEvent(MMLEvent.MOD_TYPE, 6);  // use FM voice  
                mmlseq.appendNewEvent(MMLEvent.QUANT_RATIO, 8);
            }
            else {
                mmlseq.appendNewEvent(MMLEvent.MOD_TYPE, 7);  // use PCM voice  
                mmlseq.appendNewEvent(MMLEvent.QUANT_RATIO, 8);
                mmlseq.appendNewEvent(eventIDPShift, 40);
            }
        }
    }
    
    
    // return next events clock
    @:allow(org.si.sound.mdx)
    private function exec(totalClock : Int, bpm : Float) : Int
    {
        if (mmlseq == null)
            return Int.MAX_VALUE;
        
        var e : MDXEvent = null;
        var me : MMLEvent;
        var v : Int;
        var l : Int;
        
        while (clock <= totalClock && pointer < pointerMax && !waitSync){
            e = mdxtrack.sequence[pointer];
            if (mdxtrack.segnoPointer == e)
                mmlseq.appendNewEvent(MMLEvent.REPEAT_ALL, 0);
            
            if (e.type < 0x80) {
                lastNoteMML = null;
                if (lastRestMML != null)
                    lastRestMML.length += e.deltaClock * 10
                else
                    lastRestMML = mmlseq.appendNewEvent(MMLEvent.REST, 0, e.deltaClock * 10);
            }
            else if (e.type < 0xe0) {
                lastRestMML = null;
                if (mdxtrack.channelNumber < 8 && anFreq == -1) {
                    // FM
                    if (lastNoteMML != null && lastNoteMML.data == e.data + 15)
                        lastNoteMML.length = e.deltaClock * 10
                    else
                        mmlseq.appendNewEvent(MMLEvent.NOTE, e.data + 15, e.deltaClock * 10);
                }
                else if (mdxtrack.channelNumber == 7) {
                    // FM/Noise
                    mmlseq.appendNewEvent(MMLEvent.NOTE, anFreq, e.deltaClock * 10);
                }
                else {
                    // ADPCM
                    if (adpcmID != e.data) {
                        adpcmID = e.data;
                        mmlseq.appendNewEvent(MMLEvent.MOD_PARAM, adpcmID);
                    }
                    mmlseq.appendNewEvent(MMLEvent.NOTE, _freqTable[anFreq], e.deltaClock * 10);
                }
                lastNoteMML = null;
            }
            else {
                lastNoteMML = lastRestMML = null;
                var _sw0_ = (e.type);                

                switch (_sw0_)
                {
                    case MDXEvent.PORTAMENT:  // ...?  
                        if (mdxtrack.sequence[pointer + 1].type == MDXEvent.SLUR)
                            pointer++;
                        if (mdxtrack.sequence[pointer + 1].type == MDXEvent.NOTE) {
                            v = e.data;
                            pointer++;
                            e = mdxtrack.sequence[pointer];
                            mmlseq.appendNewEvent(MMLEvent.NOTE, e.data + 15, 0);
                            mmlseq.appendNewEvent(MMLEvent.PITCHBEND, 0, e.deltaClock * 10);
                            lastNoteMML = mmlseq.appendNewEvent(MMLEvent.NOTE, e.data + 15 + (v * e.deltaClock + 8192) / 16384, 0);
                        }
                    case MDXEvent.REGISTER:
                        mmlseq.appendNewEvent(MMLEvent.REGISTER, e.data);
                        mmlseq.appendNewEvent(MMLEvent.PARAMETER, e.data2);
                    case MDXEvent.FADEOUT:
                        mmlseq.appendNewEvent(eventIDFadeOut, e.data2);
                    case MDXEvent.VOICE:
                        if (mdxtrack.channelNumber < 8) {  // ...?  
                            voiceID = e.data;
                            mmlseq.appendNewEvent(MMLEvent.MOD_PARAM, voiceID);
                        }
                    case MDXEvent.PAN:
                        if (e.data == 0) {
                            mmlseq.appendNewEvent(eventIDExp, 0);
                        }
                        else {
                            _vol();
                            mmlseq.appendNewEvent(eventIDPan, _panTable[e.data]);
                        }
                    case MDXEvent.VOLUME:
                        if (e.data < 16) {
                            volume = e.data;
                            fineVolumeFlag = false;
                        }
                        else {
                            volume = e.data & 127;
                            fineVolumeFlag = true;
                        }
                        _vol();
                    case MDXEvent.VOLUME_DEC:
                        if (--volume == 0)
                            volume = 0;
                        _vol();
                    case MDXEvent.VOLUME_INC:
                        l = ((fineVolumeFlag)) ? 127 : 15;
                        if (++volume == l)
                            volume = l;
                        _vol();
                    case MDXEvent.GATE:
                        if (e.data < 9) {
                            gateTime = e.data;
                            mmlseq.appendNewEvent(MMLEvent.QUANT_RATIO, gateTime);
                            mmlseq.appendNewEvent(MMLEvent.QUANT_COUNT, 0);
                        }
                        else {
                            gateTime = -(256 - e.data) * 10;
                            mmlseq.appendNewEvent(MMLEvent.QUANT_RATIO, 8);
                            mmlseq.appendNewEvent(MMLEvent.QUANT_COUNT, -gateTime);
                        }
                    case MDXEvent.KEY_ON_DELAY:
                        mmlseq.appendNewEvent(MMLEvent.KEY_ON_DELAY, e.data * 10);
                    case MDXEvent.SLUR:
                        if (mdxtrack.sequence[pointer + 1].type == MDXEvent.NOTE) {
                            pointer++;
                            e = mdxtrack.sequence[pointer];
                            mmlseq.appendNewEvent(MMLEvent.NOTE, e.data + 15, 0);
                            mmlseq.appendNewEvent(MMLEvent.SLUR, 0, e.deltaClock * 10);
                        }
                    case MDXEvent.REPEAT_BEGIN:
                        repeatStac.unshift(mmlseq.appendNewEvent(MMLEvent.REPEAT_BEGIN, e.data));
                    case MDXEvent.REPEAT_BREAK:
                        me = mmlseq.appendNewEvent(MMLEvent.REPEAT_BREAK, 0);
                        me.jump = repeatStac[0];
                    case MDXEvent.REPEAT_END:
                        me = mmlseq.appendNewEvent(MMLEvent.REPEAT_END, 0);
                        me.jump = repeatStac.shift();
                        me.jump.jump = me;
                    case MDXEvent.DETUNE:
                        mmlseq.appendNewEvent(eventIDPShift, e.data);
                    case MDXEvent.LFO_DELAY:
                        lfoDelay = e.data * 75 / bpm;
                        if (mp > 0)
                            _mod(eventIDPMod, mp, lfows, lfofq);
                        if (ma > 0)
                            _mod(eventIDAMod, ma, lfows, lfofq);
                    case MDXEvent.PITCH_LFO:
                        if ((e.data & 0x80) != 0) {
                            if ((e.data & 0xff) == 0x80)
                                mmlseq.appendNewEvent(eventIDPMod, 0)
                            else
                                _mod(eventIDPMod, mp, lfows, lfofq);
                        }
                        else {
                            l = e.data >> 8;
                            mp = ((e.data2 >> ((((e.data & 4) == 0)) ? 8 : 0)) * l) >> 1;
                            _mod(eventIDPMod, mp, e.data & 3, l * 75 / bpm * (((lfows != 0)) ? 2 : 1));
                        }
                    case MDXEvent.VOLUME_LFO:
                        /* ...
                            if ((e.data & 0x80) != 0) {
                            if ((e.data & 0xff) == 0x80) mmlseq.appendNewEvent(eventIDAMod, 0);
                            else _mod(eventIDAMod, ma, lfows, lfofq);
                            } else {
                            l = e.data>>8;
                            ma = (e.data2 * l) >> 1;
                            _mod(eventIDAMod, ma, e.data&3, l*75/bpm * ((lfows)?2:1));
                            }
                            */
                    case MDXEvent.FREQUENCY:
                        if (mdxtrack.channelNumber == 7) {
                            if (e.data & 128) {
                                if (noiseVoiceNumber != -1) {
                                    mmlseq.appendNewEvent(MMLEvent.MOD_PARAM, noiseVoiceNumber);
                                    anFreq = e.data & 31;
                                }
                            }
                            else {
                                mmlseq.appendNewEvent(MMLEvent.MOD_PARAM, voiceID);
                                anFreq = -1;
                            }
                        }
                        else 
                        if (mdxtrack.channelNumber >= 8) {
                            anFreq = e.data;
                        }
                    case MDXEvent.SYNC_WAIT:
                        //trace("wait", clock);
                        waitSync = true;
                    case MDXEvent.SYNC_SEND:
                        trace("send", clock);
                    case MDXEvent.TIMERB, MDXEvent.DATA_END, MDXEvent.SET_PCM8:
                        // do nothing
                    case MDXEvent.OPM_LFO:
                        // not supported
                    default:
                        // not supported
                }
            }
            
            clock += e.deltaClock;
            pointer++;
        }
        
        return ((pointer >= pointerMax || waitSync)) ? Int.MAX_VALUE : clock;
        
        function _vol() : Void {
            if (mdxtrack.channelNumber < 8)
                mmlseq.appendNewEvent(eventIDExp, ((fineVolumeFlag)) ? _tlTable[volume] : _volTable[volume])
            else
                mmlseq.appendNewEvent(eventIDExp, ((fineVolumeFlag)) ? (127 - volume) : _volTable[volume]);
        };
        
        function _mod(eventID : Int, data : Int, ws : Int, fq : Int) : Void{
            if (lfows != ws || lfofq != fq) {
                lfofq = fq;
                lfows = ws;
                mmlseq.appendNewEvent(eventIDLFO, lfofq);
                mmlseq.appendNewEvent(MMLEvent.PARAMETER, lfows);
            }
            if (lfoDelay > 0) {
                mmlseq.appendNewEvent(eventID, 0);
                mmlseq.appendNewEvent(MMLEvent.PARAMETER, data);
                mmlseq.appendNewEvent(MMLEvent.PARAMETER, lfoDelay);
            }
            else {
                mmlseq.appendNewEvent(eventID, data);
            }
        };
    }
    
    
    @:allow(org.si.sound.mdx)
    private function globalExec(totalClock : Int, data : MDXData) : Void{
        var e : MDXEvent;
        var syncWaitSync : Bool = waitSync;
        var syncClock : Int = clock;
        var syncPointer : Int = pointer;
        while (syncClock <= totalClock && syncPointer < pointerMax && !syncWaitSync){
            e = mdxtrack.sequence[syncPointer];
            var _sw1_ = (e.type);            

            switch (_sw1_)
            {
                case MDXEvent.SYNC_SEND:
                    data.onSyncSend(e.data, syncClock);
                case MDXEvent.TIMERB:
                    data.onTimerB(e.data, syncClock);
                case MDXEvent.SYNC_WAIT:
                    syncWaitSync = true;
            }
            syncClock += e.deltaClock;
            syncPointer++;
        }
    }
    
    
    @:allow(org.si.sound.mdx)
    private function sync(currentClock : Int) : Void{
        //trace(currentClock, clock);
        if (currentClock > clock) {
            mmlseq.appendNewEvent(MMLEvent.REST, 0, (currentClock - clock) * 10);
            clock = currentClock;
        }
        waitSync = false;
    }
}



