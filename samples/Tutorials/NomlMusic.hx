package tutorials;

import openfl.events.Event;
import openfl.display.Sprite;
import org.si.sion.SiONDriver;

// Test of a full song -- the background music from NomlTest
class NomlMusic extends Sprite {
    public var driver : SiONDriver = new SiONDriver();

    public function new() {
        super();
        driver.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        driver.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
        addChild(driver);
    }

    private function onAddedToStage (event:Event):Void {
        driver.play(nomlBackground);
    }

    private function onRemovedFromStage (event:Event):Void {
        driver.stop();
    }

    var nomlBackground:String = "#TITLE{Nomltest main theme};t152;
    #A = v12c4v6c8;#C= e.f.dc4d;#B =C>a1rg4.<c4.;#T= s28dd8ff8gg8aa8<crd8s24[>d<c>d<cd8]20>d<c>d<c;
    #S = s20[dfgagf]8s28aa8<cc8dd8ff8s25grars20[[a8gfd8]s25a8a8]a8gfdefgfedc>a<c>agfgfededc>a<c>agfaf<c;
    % 1r1r1$[@4q1s24o6l8[r4A(5)A(4)A(0)A(2)v12>a<rr4A(5)A(4)A(7)A(5)v12cr] |
    @2q2s22l4[d2r8ef2rgf2rgfedc |d2ref2rga2rgagfer8]d2ref2rga2r<cdc>agf8
    @3q3s20l8B>f4.e2.r<Ca1rg4.a4.<c1rr>Bf4.e2.re.f.dc.d.>ag.<c.>ag.a.fd.f.ab - .<d.f(c+ .e.g ar4.
    @2q2s22f2.ef2.rgf4e4d4c4>a2.rfg2.fag2.fecde4f4g4a4<c + 4d4e4.f2.ef2.rga4g4f4e4c2.r>fg2.fal4gfec.d.a.<d.q5a2.r8]4
    @3q0s20l16S[>a<c>a<cd8>a<c>a<cd8erf8]3Td8d8;
    #A = v8a4v4a8;#B = degfgea4degf<c4d4>degf;#C = l8a.a.fe4f;#D = v10q0s24a8a8r4v8q3s20;#E = d>a<cd4>a<cd4>a<cdfecl4dc>ag;
    % 1r1r1$[@4q1s24v8l8[r4AAAAv8gr | r4AAA(2)A(3)v8gr]
v4q0o4l16a<(cdega<(cdl32s28edgeag<(c>a<dcedgeag<(cd>(a<c>gaegdecd>))a<c>gal16s24edc>))agedc |
v8s20o5l8[aB<c4>a4gaegde | f4B<c4d4cd>a<c>gec]f4B<e4f4egdecd>a
q3o5Cd1rl4c.f.d.c.DC<d1rl4c.d.e2.>DCd1rl4c.f.a.g.Dl8a.a.fe.f.dc.e.ec.e.c>a.<c.df.a.<d>(g.a.<d(er4.
v8o6Efedcl8d4ced4ced4cfe4c>ga b - <l4cdefab - <c + l8c+ Eagfel8d4ced4cfl4edc>a.b - .<g.b - .<q5g2.l8r]4
@1v6q0l16r8.S[>a<c>a<cd8>a<c>a<v12crdrv6erf]3Td;
    #A = v8d4v4d8;#B = [aaeeffdd];
    % 1l8r1r1$[@4q1s24v8l8[r4AA( - 2)AA(3)v8err4AA( - 2)AA(7)v8er] |
@1q1s32o7v8l16B32[B4[ggddeecc]3v10q0s24>c8c8<v8q1s32aacc]3B[ggddeecc]
@4q0s20o4v6l8f.g.a<d.g.ad.g.b<d.e.g
@4q1s24o5v8[a4A(3)A(2)AA( - 2)v8drr4A(3)A(2)A( - 2)A( - 5)v8>a<rr4A( - 7)A( - 9)A( - 5)A( - 7) |
>v8efgl4ab - <c + defgl8g]v8grs20>l4f.<d.g.q5<d2.l8r]4
@4q1s24o5v8l8[r4AA(- 2)AA(3)v8err4AA( -2)AA(7)v8gr]5;
    #A = dd<d>d<d>d<cd>;#B = >b - b - <b -> b - <b -> b - <ab - ;#C= >g8.g<g8>g8rrgg<g8g8;#D = dd<d8>dr<d8>;#M = [A]3d<cd>a<cd>a<c>;
    % 1@2v10q0s30o3l16M$[[M]4 | [[B]3>b - <ab -> b - <ab- ab - [B(2)]3c - b<c>cb - <c>c<c>[M]]
q1s24[[C(3)][C(2)]]3CC(2)l8>b - .b - .<b ->e - .e - .<e - l8e.e.eq0s26(a.((a.((l16aa
v10[[D]4[D( - 4)]4[D( - 7)][D( - 5)] | [D( - 4)][D( - 5)]][D(1)]4]4
[[>b - b - <b -> b - <b -> b - <ab - ][cc<c>c<c>cb - <c>][dd<d>d<d>d<cd>]4]5;
    #B = o2v10c;#W = o2v6c;#S = o4v12c;#H = o6v6g;#F = o4v10c))c(c(c(c(c(c;
    #A = BHHWSHHBr))c)cHSHHB;#C = BS))cWSr))ccBF;#D = BHHWSHBrHrB))cSHBr;
    % 2@0q0s29l16AC$[[A]7C |[[D]7C][BrHHo2v8crHHSrv6cHrrHHo2v10rrcHrro2v7crSr |v10cHrrgg]4
o4v6crc((c((c((c[BrHHSrHHrHB))cSo2v10rcHBrHo2v8cSrHHrHB))cSrHH]3
BrHo2v12crHo4v10cro2v12crHo2v12crHSv9cs28(c8.s28(c8.s27(c8 s26c8 s29o2v12rc o4v10c(c(c(c
[[A]6 | S8c8Brs27S4c8s29Brs27o4v13c4c8s29Brs27o4v15c4c8s29Bro4v13c((c]AC]4
[D]7C[BHHWSHBrHrB))cSrcH]3S))cWS))cWS))cWS))cWSrv14s27c8s29[[D]3C];";

}
