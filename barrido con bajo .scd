s.boot;

(
s.waitForBoot {

    SynthDef(\mobiusVoice, { |freq = 440, amp = 0.2, pan = 0, cutoff = 400, gate = 1|
        var sig, env;
        env = EnvGen.kr(Env.asr(0.05, 1, 0.3), gate, doneAction: 2);
        freq   = freq.lag(0.05);
        pan    = pan.lag(0.1);
        cutoff = cutoff.lag(0.05);
        sig = SinOsc.ar(freq)
            + (0.15 * SinOsc.ar(freq * 2))
            + (0.05 * SinOsc.ar(freq * 3));
        sig = RLPF.ar(sig, cutoff.clip(261.62, 493.88), 0.3);
        Out.ar(0, Pan2.ar(sig, pan.clip(-1, 1), amp * env));
    }).add;

    SynthDef(\mobiusBass, { |freq = 55, amp = 0.25, cutoff = 250, gate = 1|
        var sig, sub, env;
        env    = EnvGen.kr(Env.asr(3, 1, 4), gate, doneAction: 2);
        freq   = freq.lag(0.5);
        cutoff = cutoff.lag(0.3);
        sig = SinOsc.ar(freq);
        sub = SinOsc.ar(freq * 0.5) * 0.5;
        sig = sig + sub + (Saw.ar(freq * [1, 1.003]).sum * 0.08);
        sig = LPF.ar(sig, cutoff.clip(60, 800));
        sig = sig * (1 + (0.1 * SinOsc.kr(0.2)));
        Out.ar(0, (sig ! 2) * amp * env);
    }).add;

    s.sync;

    ~mobiusPoint = { |u, v|
        var r = 1 + ((v / 2) * cos(u / 2));
        [r * cos(u), r * sin(u), (v / 2) * sin(u / 2)]
    };

    ~scale = Scale.minorPentatonic.degrees ++ [12];
    ~quantize = { |freq, root = 220|
        var rootMidi = root.cpsmidi;
        var rel      = freq.cpsmidi - rootMidi;
        var oct      = (rel / 12).floor;
        var pc       = rel - (oct * 12);
        var nearest  = ~scale.minItem({ |d| (d - pc).abs });
        (rootMidi + (oct * 12) + nearest).midicps
    };

    ~mobiusSynth = Synth(\mobiusVoice, [\amp, 0.25]);
    ~mobiusBass  = Synth(\mobiusBass, [\freq, 55, \amp, 0.25, \cutoff, 200]);

    ~mobiusEdgeRoutine = Routine({
        var steps = 1200, dur = 0.08, bassEvery = 20;
        var u, pt, freq, pan, cutoff, bFreq;

        (steps + 1).do { |i|
            u  = (i / steps) * 4pi;
            pt = ~mobiusPoint.value(u, 1);

            freq = pt[2].linlin(-0.5, 0.5, 200, 1200)
                 + pt[0].linlin(-1.5, 1.5, 0, 50);
            freq   = ~quantize.value(freq);
            pan    = pt[1].clip(-1, 1);
            cutoff = pt[0].linexp(-1.5, 1.5, 261.62, 493.88);
            ~mobiusSynth.set(\freq, freq, \pan, pan, \cutoff, cutoff);

            if (i % bassEvery == 0) {
                bFreq = pt[2].linlin(-0.5, 0.5, 55, 110);
                bFreq = ~quantize.value(bFreq, 55);
                ~mobiusBass.set(
                    \freq,   bFreq,
                    \cutoff, pt[1].linexp(-1.5, 1.5, 120, 500)
                );
            };

            dur.wait;
        };

        ~mobiusSynth.set(\gate, 0);
        ~mobiusBass.set(\gate, 0);
    }).play;
};
)