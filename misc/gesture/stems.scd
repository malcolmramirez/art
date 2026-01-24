(
b = 120/60;
p = ProxySpace(s)
    .makeTempoClock(b)
    .quant_(1)
    .fadeTime_(1)
    .push;
)

~out.play;
(
~out[0] = {
    var sig;

    sig = DemandEnvGen.ar(
        Dseq([Dseries(0, [Dbrown(-1, 1, Dbrown(-1, 1)), Dbrown(-1, 1, Dwhite(-1, 1))], 30)], inf),
        Dseq([SampleRate.ir.reciprocal * Dwhite(0.5, 1)], inf),
        4
    );
    // sig = sig * SampleDur.ir;
    sig = sig.tanh;
    sig = LeakDC.ar(sig);

    sig = sig * Env.perc(0.001, 0.01).ar(gate: Impulse.ar(b*LFSaw.ar(b).range(10, 100)));


    sig;
};

~out[1] = \filterIn -> { |in|
    RLPF.ar(
        in,
        1200,
        LFNoise2.ar(b).range(0.5, 0.95));
};

~out[2] = \filterIn -> { |in|
    GrainIn.ar(
        2,
        Impulse.ar(b*4),
        0.025,
        in);
};

~out[4] = \filterIn -> { |in|
    var sig;

    sig = PitchShift.ar(
        in,
        windowSize: 0.5,
        pitchRatio: TChoose.ar(Impulse.ar(b*4), [0, 1, 2, 3].collect { |n| DC.ar(n) }),
        timeDispersion: SinOsc.ar(b).range(0.01, 0.1)
    );

    sig * 0.5;
};

)

~kd.end;
(
~kd[0] = Pbind(
    \instrument, \slicer,
    \buf, d[\break][19],
    \tempo, b,
    \slices, 16,
    \slice, Prand([
        Pseq((0..15)),
        Pn(16, 1),
    ], inf),
    \bars, 4,
    \dur, Pkey(\bars) / Pkey(\slices)
);

~kd[1] = \filterIn -> { |in|
    var sig;

    sig = Convolution.ar(~out.ar, in, framesize: 4096);

    sig * 0.5;
};
)

~kick.play;
(
~kick[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu2][0],
    \dur, Pseq([1/4, Rest(1/4), 1/8, 1/8], inf),
)
)

~sd.play;
(
~sd[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu2][3],
    \dur, Pseq([Rest(1/4), 1/4, Rest(1/4)], inf),
    \rate, 1,
)
)

~pulsar.play;
(
~pulsar[0] = Pbind(
    \instrument, \pulsar,
    // \buf, d[\sigs][0],
    \buf, d[\cpu][1],
    \degree, [-1, 5, 12],
    // \degree, Pwrand([[1, 5, 8], [-1, 3, 3]], [4, 1].normalizeSum, inf),
    \octave, 4,
    \sust, Pwhite(1/32, 1/16),
    \atk, 1/32,
    \rel, 1/32,
    \dur, 1/4,
    \amp, -15.dbamp
);
~pulsar.reshaping = \elastic;
~formant = {
    SinOsc.ar(b*LFNoise2.ar(b).range(1, 5)).range(2, 4);
};
~pulsar.set(\formant, ~formant);
)

s.scope;
