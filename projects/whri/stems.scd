(
b = 120/60;
p = ProxySpace(s)
    .makeTempoClock(b)
    .fadeTime_(0)
    .quant_(1)
    .push;
)

(
SynthDef(\p, {
    var freq = \freq.kr(440);
    var dur = \dur.kr(0) / b;
    var rdur = dur.reciprocal;
    var sig = SinOscFB.ar(
        freq, 
        feedback: SinOsc.ar(rdur/2).range(0, \fbmax.kr(0.3))
    );

    sig = Pan2.ar(sig, \pan.kr(0));
    sig = sig * Env(
        [0, 1, 1, 0], 
        [\atk.kr(0.1), \sus.kr(0.8), \rel.kr(0.1)] * dur, 
        \curve.kr([0, 0, 0])
    ).ar(Done.freeSelf);

    sig = RLPF.ar(sig, freq, 1);
    sig = RHPF.ar(sig, freq * 4, 1);
    sig = sig.sum ! 2;

    sig = sig * \vol.kr(1);

    Out.ar(\i_out.kr(0), sig);
}).add;
)

~p.play;
(
~p[0] = Pbind(
    \instrument, \p,
    \dur, Pseq([8, 8, 16], inf),
    \scale, Scale.dorian,
    \atk, 0.5,
    \sus, 0.2,
    \rel, Pexprand(0.8, 1.5, inf),
    \degree, Pseq([
        [0, 1, 4],
        [0, 1, 3],
        [-1, 1, 4],
    ], inf),
    \vol, 0.5.dbamp,
    \fbmax, Pexprand(0.2, 0.5, inf)
);

~p[10] = \filterIn -> { |in|
    FreeVerb.ar(in, mix: 0.4, room: 0.5, damp: 0.1);
};

)

~k.play;
(
~k[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu2][1],
    \rate, 1,
    \amp, -20.dbamp,
    \dur, Pseq([
        4, 
        2,
        1/4,
        Pwrand([0, 4], [1, 2].normalizeSum)
    ], inf),
)
)

~s.play;
(
~s[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu2][4],
    \rate, 4,
    \amp, Pseq([
        Pn(-20.dbamp, 3),
        -30.dbamp,
        Pn(-20.dbamp, 2),
    ], inf),
    \dur, Pseq([
        Rest(1), 
        2,
        Rest(2),
        1/4,
        2,
        Rest(2)
    ], inf),
)
)

~h.play;
( 
~h[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu2][9],
    \rate, Prewrite(
        8,
        (
            8: #[4, 8],
            4: #[8, 8]
        ),
        4
    ),
    \dur, Pseq([
        Pwrand([1/4, Rest(1/4)], [1, 2].normalizeSum), 
        1/4
    ], inf),
    \amp, -17.dbamp
)
)

~singrain.play;
(
~singrain = {
    var sig, carf, imp;

    imp = Impulse.ar(b*4);
    carf = SinOsc.ar(b).range(2000, 2400);
    sig = GrainFM.ar(
        numChannels: 2,
        trigger: PulseDivider.ar(imp, TRand.ar(1, 4, imp)),
        dur: TRand.ar(1/256, 1/128, imp),
        carfreq: carf,
        modfreq: carf*LFNoise2.ar(b*2).range(1, 2),
        index: LFNoise2.ar(b).range(1, 10),
        pan: TRand.ar(-1, 1, imp),
    );

    // sig = PitchShift.ar(
    //     in: sig,
    //     windowSize: b,
    //     pitchDispersion: SinOsc.ar(b).range(0, 1),
    //     timeDispersion: LFNoise2.ar(b*16).range(b/64, b/2)
    // );

    // sig = Mix.ar(Hilbert.ar(sig));
    sig = Slew.ar(sig, 2000, 2000);

    sig;
}
)

~saw.play;
(
~saw[0] = Pbind(
    \instrument, \p,
    \dur, 4,
    \atk, 0.5,
    \sus, 0,
    \rel, Pexprand(0.25, 0.5, inf),
    \scale, Scale.dorian,
    \octave, 3,
    \degree, [1, 0, 2],
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
        pitchRatio: 2, 
        timeDispersion: b/4,
    )
};

// ~saw[5] = \filterIn -> { |in| 
//     GrainIn.ar(
//         numChannels: 2,
//         trigger: Impulse.ar(b*4),
//         dur: TChoose.ar(
//             Impulse.ar(b*16),
//             [b/16, b/32, b/128].collect{|n|DC.ar(n)}
//         ),
//         in: in,
//         pan: TRand.ar(-0.5, 0.5, Impulse.ar(b*2))
//     );
// };

// ~saw[6] = \filterIn -> { |in| 
//     FreeVerb.ar(
//         in,
//         mix: SinOsc.ar(b/4).range(0.05, 0.25),
//         room: 0.9
//     )
// };

// ~saw[6] = \filterIn -> { |in| RLPF.ar(in, LFNoise2.ar(b).range(0, 50) + SinOsc.ar(b/16).range(10000, 4000)) };

~saw[6] = \filterIn -> { |in| LPF.ar(in, 20000) };
~saw[7] = \filterIn -> { |in| HPF.ar(in, 99) };

~saw[8] = \filterIn -> { |in| Normalizer.ar(in, -10.dbamp) }

)

