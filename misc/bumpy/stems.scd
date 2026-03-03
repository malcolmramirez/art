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
    \buf, d[\cpu][0],
    \rate, 1,
    // \dur, Pseq([
    //     1, 1, 1, 1,
    //     1, 1, 1, 1,
    //     1, 1, 1, 1,
    //     Rest(1/2), 1/2, 1, 1, 1,
    //     1, 1, 1, 1,
    //     1, 1, 1, 1,
    //     1, 1, 1, 1,
    //     1/6, 1/6, 1/6, 1, 1, 1,
    // ], inf),
    // \dur, Prewrite(
    //     1/2,
    //     IdentityDictionary[
    //         1/2 -> [1/2, Rest(1/4), 1/4],
    //         1/4 -> [1/4, Rest(1/4), 1/2],
    //         Rest(1/4) -> [1/2, 1/2],
    //     ],
    //     4
    // ),
    \dur, 1,
    \amp, -4.dbamp,
);
)

~s.play;
(
~s[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu2][4],
    // \dur, Pseq([
    //     1, 1, 1, 1,
    //     1, 1, 1, 1,
    //     1, 1, 1, 1,
    //     Rest(1/2), 1/2, 1, 1, 1,
    //     1, 1, 1, 1,
    //     1, 1, 1, 1,
    //     1, 1, 1, 1,
    //     1/6, 1/6, 1/6, 1, 1, 1,
    // ], inf),
    \dur, Pseq([Rest(1/2), 1/2], inf),
    \rate, 3,
    \amp, 0.dbamp,
);
)

~p.play;
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

~saw.play;
(
~saw[0] = Pbind(
    \instrument, \saw,
    \dur, 4,
    \scale, Scale.dorian,
    \octave, 5,
    \degree, 1,
    \amp, -2.dbamp,
);

~kern = Pbind(
    \instrument, \oneshot,
    \dur, 4,
    \buf, d[\bsperc][4],
    \rate, 2,
    \amp, -2.dbamp,
);


~saw[2] = \filterIn -> { |in| Convolution.ar(in, ~kern.ar, 4096) * -2.dbamp };

~saw[3] = \filterIn -> { |in| RHPF.ar(in, SinOsc.ar(b/SinOsc.ar(b).range(1/4, 2)).range(400, 2400)) };

~saw[4] = \filterIn -> { |in| 
    PitchShift.ar(
        in,
        windowSize: b,
        // pitchRatio: 2,
        pitchRatio: TChoose.ar(
             Impulse.ar(b*4),
             [1, 2].collect{|n| DC.ar(n)}
        ), 
        timeDispersion: b/4,
    )
};

~saw[5] = \filterIn -> { |in| 
    GrainIn.ar(
        numChannels: 2,
        trigger: Impulse.ar(b*4),
        dur: TChoose.ar(
            Impulse.ar(b*16),
            [b/16, b/32, b/128].collect{|n|DC.ar(n)}
        ),
        in: in,
        pan: TRand.ar(-0.5, 0.5, Impulse.ar(b*2))
    );
};

~saw[6] = \filterIn -> { |in| 
    FreeVerb.ar(
        in,
        mix: SinOsc.ar(b/4).range(0.05, 0.25),
        room: 0.5
    )
};

~saw[7] = \filterIn -> { |in| LPF.ar(in, 20000) };
~saw[8] = \filterIn -> { |in| HPF.ar(in, 99) };

~saw[9] = \filterIn -> { |in| Normalizer.ar(in, -2.dbamp) }

)
