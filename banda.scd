s.quit;
(
x = {
    var rate, u, v, r, xCoord, yCoord, zCoord;
    var carFreq, modFreq, modIndex, mod, car, sig;

    rate = 0.05;
    r = 1.0;

    u = Phasor.ar(0, rate * 2 * pi / s.sampleRate, 0, 2 * pi);
    v = SinOsc.ar(0.08) * 0.8;

    xCoord = (r + (v * cos(u / 2))) * cos(u);
    yCoord = (r + (v * cos(u / 2))) * sin(u);
    zCoord = v * sin(u / 2);

    carFreq = ((yCoord + 1.8) * 55.5) + 100;
    modFreq = carFreq * ((v + 0.8) * 0.93 + 1.0);
    modIndex = (zCoord + 0.8) * 6.25;

    mod = SinOsc.ar(modFreq) * (modFreq * modIndex);
    car = SinOsc.ar(carFreq + mod);

    sig = Pan2.ar(car, xCoord * 0.5, 0.2);
    sig = FreeVerb.ar(sig, mix: 0.3, room: 0.8);

    sig;
}.play;
)



