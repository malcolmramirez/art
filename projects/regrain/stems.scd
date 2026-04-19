(
b = 150/60;
p = ProxySpace(s)
    .fadeTime_(1)
    .quant_(4)
    .makeTempoClock(b)
    .push;
)

~snare.play;
(
~snare[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu][3],
    // \dur, Pseq([Rest(1), 1/4, Rest(3/4)], inf),
    \dur, Pwrand([
        Pseq([Rest(1), 1/4, Rest(3/4)]),
        Pseq([Rest(1), 1/4, Rest(2/4), 1/4]),
        Pseq([Rest(1), Pn(1/4, 4)])
    ], [5, 4, 1].normalizeSum, inf),
    \amp, -17.dbamp,
);
)

~kick.play;
(
~kick[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu2][0],
    \__ghost, Pwrand([0, 1], [8, 1].normalizeSum, inf),
    \dur, Pswitch([
        Pseq([1]),
        Pseq([1/4, 3/4]),
    ], Pkey(\__ghost), inf),
    \amp, Pswitch([
        -15.dbamp,
        Pseq([-15, -30, -15].collect(_.dbamp))
    ], Pkey(\__ghost))
);
)

~glitch.play;
(
~glitch[0] = { 
    var sig = Convolution.ar(~kick, ~grained) * 0.5;
    sig = CombC.ar(sig, b/2, b/6, b/4);
    sig = PitchShift.ar(
        in: sig,
        windowSize: b/8,
        pitchRatio: 4,
        pitchDispersion: 2,
        timeDispersion: TChoose.ar(
            Impulse.ar(b), 
            [b/8, b/16, b/32].collect{|i| DC.ar(i)}));
    sig = sig * 0.25;
    sig;
}
)

~out.play;
(
~pulsar[0] = Pbind(
    \instrument, \pulsar,
    // \buf, d[\sigs][0],
    \buf, Pwrand([d[\sigs][0], d[\cpu][0]], [4, 1].normalizeSum, inf),
    // \degree, [1, 5, 8],
    \degree, Pwrand([[1, 5, 8], [3, 9, 12]], [4, 1].normalizeSum, inf),
    \octave, Pwrand([1, 2, 3], [1, 4, 2].normalizeSum, inf),
    // \octave, 2,
    \sust, Pwhite(1/32, 1/4),
    \atk, 1/32,
    \rel, 1/32,
    \dur, 1/4,
    \amp, -15.dbamp
);
~pulsar.reshaping = \elastic;
~formant = {
    LFNoise2.ar(b).range(1, 4) + Saw.ar(b/4).range(1, 2);
};
~pulsar.set(\formant, ~formant);

~break[0] = Pbind(
    \instrument, \slicer,
    \buf, d[\break][13],
    \slices, 8,
    \slice, Pwrand([
        Pseq([
            Pseq([0, Prand([1, 0]), 2, 3, 4, 5, 6, 7]),
            Pseq([0, 2, 2, 3, 4, 5, 6, 7])
        ], 1),
        Pseq([Pn(2, 8), Pwrand((0..7), (1..8).normalizeSum.reverse, 8)], 1)
    ], [4, 1].normalizeSum, inf),
    \tempo, b,
    \bars, 8,
    \amp, -2.dbamp,
    // \amp, 0, 
    \dur, Pkey(\bars) / Pkey(\slices)
);
~break.reshaping = \elastic;

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
~lfo3 = { 
    SinOsc.ar(b/4).unipolar;
};

~grained = {
    var sig, grained;

    sig = Convolution.ar(~pulsar, ~break, 4096);
    grained = GrainIn.ar(1, Dust.ar(\dens.ar(1)), b/8, sig);
    grained = PitchShift.ar(
        grained,
        b/8,
        4,
        timeDispersion: SinOsc.ar(b/4).range(b/8, b/64)
    );
    grained = grained * -50.dbamp;
    grained;
};
~grained.reshaping = \elastic;
~grained.set(\dens, ~lfo2);

~out = {
    var sig, mix, pan;

    mix = \mix.ar(1.0);
    pan = (1 - mix) * TChoose.ar(Impulse.ar(b), [DC.ar(-1), DC.ar(1), DC.ar(0)]);

    sig = [
        Pan2.ar(~pulsar.ar(1), pan) * (1 - mix) * (1/2),
        Pan2.ar(~break.ar(1), -1 * pan) * (1 - mix) * (1/2),
        ~grained.ar(2) * mix
    ].sum;

    sig;
};
~out.set(\mix, ~lfo1);
)
