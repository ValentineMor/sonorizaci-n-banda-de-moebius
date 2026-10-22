s.boot;

(
SynthDef(\mobiusVoice, {|freq= 440, amp=0.2,pan=0, cutoff=4186, gate=1|
  var sig, env;
	env=EnvGen.kr(Env.asr(0.05,1,0.3),gate,doneAction: 2);
	sig = SinOsc.ar(freq) + (0.15 * SinOsc.ar(freq * 2)) + (0.05 * SinOsc.ar(freq * 3));
	sig=RLPF.ar(sig, cutoff.clip(261.62,493.88),0.3);
	sig=Pan2.ar(sig,pan.clip(-1,1),amp * env);
	Out.ar(0,sig);
}).add;

SynthDef(\mobiusGrain, { |freq = 493, amp = 0.15, pan = 0, cutoff = 4186, dur = 0.15|
    var sig, env;
    env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
    sig = SinOsc.ar(freq) * env;
    sig = RLPF.ar(sig, cutoff.clip(261.62, 493.88), 0.4);
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
~scale = Scale.minorPentatonic.degrees;
~quantize = { |freq, root = 220|
    var midi, degree, scaleDeg, octave;
    midi = freq.cpsmidi;
    degree = (midi - root.cpsmidi).round(1);
    scaleDeg = ~scale[(degree.asInteger % ~scale.size)];
    octave = (degree / 12).floor;
    (root.cpsmidi + scaleDeg + (octave * 12)).midicps;
};
)
(
~mobiusEdgeRoutine = Routine({
	var prevPt;
    var steps = 1200, dur = 0.08, u, pt, freq, pan, cutoff, amp;
    var synth = Synth(\mobiusVoice);


    (steps + 3).do { |i|
        u = i.linlin(0, steps, 0, 4pi);
        pt = ~mobiusPoint.(u, 1);
		if (prevPt.notNil) {
			var delta = (pt -prevPt).abs.sum;
			cutoff= delta.linlin(0, 0.1,261.62, 493.88);
	};
		prevPt =pt;

        freq = pt[2].linlin(-0.5, 0.5, 200,1200)
             + pt[0].linlin(-1.5, 1.5, 0, 50);
        pan = pt[1].clip(-1, 1);
        cutoff = pt[0].linlin(-1.5, 1.5,261.62, 493.88);
        amp = 0.25;
		freq = ~quantize.(freq);
		freq = Lag.kr(freq, 0.05);
pan = Lag.kr(pan, 0.1);
cutoff = Lag.kr(cutoff, 0.05);

        synth.set(\freq, freq, \pan, pan, \cutoff, cutoff, \amp, amp);
        dur.wait;
    };
    synth.set(\gate, 0);
}).play;
)






 
