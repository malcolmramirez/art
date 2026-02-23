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
    \vol, 5,
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
    \rate, 2,
    \amp, 0.75,
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
        Pn(0.75, 3),
        0.25,
        Pn(0.75, 2),
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
    \amp, 0.75
)
)

~singrain.play;
(
~singrain = {
    var sig;

    sig = GrainFM.ar()
}
)

