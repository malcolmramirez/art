(
b = 90/60;
p = ProxySpace(s)
    .fadeTime_(1)
    .quant_(1)
    .makeTempoClock(b)
    .push
)

(
SynthDef(\piano, {
    var sig = MdaPiano.ar(
        freq: \freq.kr(440),
        stereo: \spread.kr(0.5),
        decay: \dec.kr(0.5),
        release: \rel.kr(0.8),
        gate: \gate.kr(1),
        hard: \hard.kr(0.5),
        velcurve: 3,
        vel: \vel.kr(80)
    );
    DetectSilence.ar(sig, 0.001, doneAction: 2);
    sig = sig * \vol.kr(0.25);
    Out.ar(\i_out.kr(0), sig);
}).add;
)

~piano.play;
(
~piano = Pbind(
    \instrument, \piano,

    // Humanized timing — slight swing + random micro-timing
    \dur, Pwhite(0.46, 0.52, inf),

    // Lag each note onset slightly for a softer attack feel
    \lag, Pwhite(0.0, 0.03, inf),

    \octave, 6,
    \scale, Scale.chromatic,
    \degree, Pseq([0, 2, 5, 8, 10, 12, 15], inf),

    \vel, Pclutch(
        Pn(Pseries(65, 3, 4) + Pwhite(-5, 5, inf), inf),
        Pwrand([true, false], [7, 1], inf)
    ),

    // Vary release so higher notes ring longer
    \rel, Pseq([0.5, 0.6, 0.7, 0.9, 1.1, 1.3, 1.5, 1.8], inf),

    // Vary the hammer hardness — softer at bottom, brighter at top
    \hard, Pseq([0.2, 0.25, 0.3, 0.4, 0.5, 0.6, 0.55, 0.65], inf)
        + Pwhite(-0.05, 0.05, inf),

    // Decay tracks hardness loosely
    \dec, Pkey(\hard) * 1.2,
);
)
