
(
b = 90/60;
p = ProxySpace(s)
    .fadeTime_(1)
    .quant_(4)
    .makeTempoClock(b)
    .push;
)


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
    ) / 4,
    \atk, b/32,
    \rel, b/32,
    \scale, Scale.chromatic,
    \octave, 4,
    \degree, Pseq(
        [
            0, 3, 5,
            0, 3, 8,
            -2, 0, 8,
            3, 8, 13
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
        bufs[4]
    }, inf),
    \rate, Pseq([1, 2, 3, 4, 1/2], inf),
    \amp, 0.dbamp,
);

~saw[2] = \filterIn -> { |in| Convolution.ar(~kern.ar, in, 4096) * -50.dbamp };
~saw[3] = \filterIn -> { |in| RLPF.ar(in, SinOsc.ar(b/4).range(100, 1200), LFSaw.ar(b).range(0.5, 1)) };

~saw[4] = \filterIn -> { |in| 
    PitchShift.ar(
        in,
        windowSize: b/4,
        pitchRatio: TChoose.ar(
             Impulse.ar(b*8),
             [2, 3/2, 1, 3/4].collect{|n| DC.ar(n)}
        ), 
        timeDispersion: b/16,
    )
};

~saw[100] = \filterIn -> { |in| Normalizer.ar(in) }

)

