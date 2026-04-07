(
b = 140/60;
p = ProxySpace(s)
    .makeTempoClock(b)
    .fadeTime_(0)
    .quant_(1)
    .push;
)

~k.play;
(
~k[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu2][4],
    \rate, Pwrand([1, 2, 1/2], [4, 2, 1].normalizeSum, inf),
    \dur, Prewrite(
        1/2,
        IdentityDictionary[
            1/2 -> [1/2, Rest(1/4), 1/4],
            1/4 -> [1/4, Rest(1/4), 1/2],
            Rest(1/4) -> [1/8, 1/2],
        ],
        4
    ),
    \amp, -8.dbamp * Prewrite(
        1/2,
        IdentityDictionary[
            1/2 -> [1/8, 1/2, 1/4],
            1/4 -> [1/4, 1/8, 1/2],
            1/8 -> [1/4, 1/2],
        ],
        4
    ),
);
)

~s.play;
(
~s[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu2][11],
    \dur, Pseq([
        1, Rest(4),
    ], inf),
    // \dur, Pseq([Rest(1/2), 1/2], inf),
    \rate, 0.5,
    \amp, -5.dbamp,
);
)

~p.end;
(
~p[0] = Pbind(
    \instrument, \slicer,
    \slices, 16,
    \slice, Pseq((0..15), inf),
    \bars, 16,
    // \bars, Pseq([
    //     Pseq([16, 16, 8, 16], 1),
    //     Pn(16, 2),
    //     Pseq([16, 8, 16, 8], 1),
    // ], inf),
    \dur, Pkey(\bars) / Pkey(\slices),
    \buf, d[\clubcode1][2],
    // \buf, d[\clubcode1][12],
    \amp, 0.dbamp,
    \tempo, b,
)
)

d.keys.postln;
~saw.play;
(
~saw[0] = Pbind(
    \instrument, \saw,
    \dur, Prewrite(
        1,
        IdentityDictionary[
            1 -> [1, Rest(1/2), 1/2],
            1/2 -> [1/2, Rest(1/2), 1],
            Rest(1/2) -> [1, 1],
        ],
        4
    ),
    \scale, Scale.dorian,
    \octave, 5,
    \degree, Pseq(
        [
            [0, 3, 5],
            [0, 3, 8],
            [-2, 0, 8],
            [3, 8, 13]
        ], 
        inf
    ),
    \amp, 0.dbamp,
);

~kern = Pbind(
    \instrument, \oneshot,
    \dur, 1/2,
    \buf, Pfuncn({
        var bufs = d[\cpu2];
        var i = 11.rand;
        i.postln;
        bufs[i]
    }, inf),
    \rate, 1,
    \amp, 0.dbamp,
);

~saw[2] = \filterIn -> { |in| Convolution.ar(~kern.ar, in, 4096) * -50.dbamp };

~saw[3] = \filterIn -> { |in| RLPF.ar(in, SinOsc.ar(b/4).range(100, 2400)) };

~saw[4] = \filterIn -> { |in| 
    PitchShift.ar(
        in,
        windowSize: b*2,
        pitchRatio: TChoose.ar(
             Impulse.ar(b*8),
             [2, 1].collect{|n| DC.ar(n)}
        ), 
        timeDispersion: b/16,
    )
};

~saw[100] = \filterIn -> { |in| Normalizer.ar(in) }

)

~saw.clear

