s.boot;

(
SynthDef(\mobiusVoice, {|freq= 400, amp=0.2,pan=0, cutoff=2000, gate=1|
  var sig, env;
	env= EnvGen.kr(Env.asr(0.05,1,0.3),gate,doneAction: 2);
	sig= SinOsc.ar(freq)+(0.3*LFTri.ar(freq+1.005));
	sig=RLPF.ar(sig, cutoff.clip(32.7,987.7),0.3);
	sig=Pan2.ar(sig,pan.clip(-1,1),amp * env);
	Out.ar(0,sig);
}).add;

SynthDef(\mobiusGrain, { |freq = 440, amp = 0.15, pan = 0, cutoff = 987.7, dur = 0.15|
    var sig, env;
    env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
    sig = SinOsc.ar(freq) * env;
    sig = RLPF.ar(sig, cutoff.clip(32.7,987.7), 0.4);
    sig = Pan2.ar(sig, pan.clip(-1, 1), amp);
    Out.ar(0, sig);
}).add;
)


(
~mobiusPoint = { |u, v|
var x,y,z;
	x=(1+(v/2*cos(u/2)))*cos(u);
	y=(1+(v/2*cos(u/2)))*sin(u);
	z=(v/2)*sin(u/2);
	[x,y,z];
};
)

(
~mobiusEdgeRoutine = Routine({
    var steps = 800, dur = 0.02, u, pt, freq, pan, cutoff, amp;
    var synth = Synth(\mobiusVoice);

    (steps + 1).do { |i|
        u = i.linlin(0, steps, 0, 4pi);
        pt = ~mobiusPoint.(u, 1); // recorre el borde (v = 1)

        freq = pt[2].linlin(-0.5, 0.5, 200, 800)
             + pt[0].linlin(-1.5, 1.5, 0, 200);
        pan = pt[1].clip(-1, 1);
        cutoff = pt[0].linlin(-1.5, 1.5, 32.7,987.7);
        amp = 0.25;

        synth.set(\freq, freq, \pan, pan, \cutoff, cutoff, \amp, amp);
        dur.wait;
    };
    synth.set(\gate, 0);
}).play;
)




 
