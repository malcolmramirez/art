(
b = 150/60;
p = ProxySpace(s)
    .fadeTime_(0)
    .quant_(4)
    .makeTempoClock(b)
    .push;
)

(
~pulsar[0] = Pbind(
    \instrument, \pulsar,
    \buf, d[\sigs][0],
    \degree, Pseq([[1, 5, 8]], inf),
    \octave, 3,
    \sust, Pwhite(1/32, 1/4),
    \atk, 1/32,
    \rel, 1/32,
    \dur, 1/4,
    \amp, -12.dbamp
);
~formant = {
    LFNoise2.ar(b).range(1, 4) + Saw.ar(b/4).range(1, 2);
};
~pulsar.set(\formant, ~formant);

~pulsar.reshaping = \elastic;

~break[0] = Pbind(
    \instrument, \slicer,
    \buf, d[\break][13],
    \slices, 8,
    \slice, Pseq([
        Pseq([0, Prand([1, 0]), 2, 3, 4, 5, 6, 7]),
        Pseq([0, 2, 2, 3, 4, 5, 6, 7])
    ], inf),
    \tempo, b,
    \bars, 8,
    \amp, -2.dbamp,
    \dur, Pkey(\bars) / Pkey(\slices)
);
~break.reshaping = \elastic;
)

~out.play;
(
~lfo1 = {
    TChoose.ar(Impulse.ar(b), [
        SinOsc.ar(b, phase: 2*pi).unipolar,
        LFTri.ar(b, iphase: 2*pi).unipolar,
        SinOsc.ar(b*4, phase: 2*pi).range(0.2, 0.8),
        LFNoise2.ar(b*2).unipolar
    ]);
};
~lfo2 = {
    SinOsc.ar(b/32).range(1, 5)
};

~convolved = {
    var sig, grained;

    sig = Convolution.ar(~pulsar, ~break, 4096);
    grained = GrainIn.ar(1, Dust.ar(\dens.ar(1)), b/8, sig);
    grained = PitchShift.ar(
        grained,
        b/8,
        4,
        timeDispersion: SinOsc.ar(b/4).range(b/8, b/64)
    );
    grained = grained * -40.dbamp;
    grained;
};
~convolved.reshaping = \elastic;
~convolved.set(\dens, ~lfo2);

~out = {
    var sig, mix, pan;

    mix = \mix.ar(1.0);
    pan = (1 - mix) * TChoose.ar(Impulse.ar(b), [DC.ar(-1), DC.ar(1), DC.ar(0)]);

    sig = [
        Pan2.ar(~pulsar.ar(1), pan) * (1 - mix) * (1/2),
        Pan2.ar(~break.ar(1), -1 * pan) * (1 - mix) * (1/2),
        ~convolved.ar(2) * mix
    ].sum;

    sig;
};
~out.set(\mix, ~lfo1);
)
