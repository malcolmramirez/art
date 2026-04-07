(
b = 120/60;
p = ProxySpace(s)
    .makeTempoClock(b)
    .fadeTime_(4)
    .quant_(1)
    .push;
)

(
SynthDef(\p, {
    var freq = \freq.kr(440);
    var dur = \dur.kr(0) / b;
    var rdur = dur.reciprocal;
    var lfo = SinOsc.ar(rdur);
    var sig = [
        Formant.ar(
            freq, 
            formfreq: freq * 3/2,
            bwfreq: lfo.range(freq*8, freq*32),
        ),
        Saw.ar(freq * lfo.range(1.0001, 1.001)),
        Pulse.ar(freq, lfo.range(0.1, 0.5)),
        RLPF.ar(
            WhiteNoise.ar,
            freq * 10, 
            lfo.range(1, 2) + LFNoise2.ar(b*4).range(0.01, 0.5)
        )
    ];
    sig = sig * [4, 2, 2, 1].normalizeSum;
    sig = sig.sum / sig.size;

    sig = Pan2.ar(sig, \pan.kr(0));
    sig = sig * Env(
        [0, 1, 1, 0], 
        [\atk.kr(0.1), \sus.kr(0.8), \rel.kr(0.1)] * dur, 
        \curve.kr([0, 0, 0])
    ).ar(Done.freeSelf);

    // sig = RHPF.ar(sig, freq, 1);
    // sig = RLPF.ar(sig, freq*9, 1);
    sig = sig * \vol.kr(1);

    Out.ar(\i_out.kr(0), sig);
}).add;
)

~p.play;
(
~p = Pbind(
    \instrument, \p,
    \dur, Pseq([8, 8, 4], inf),
    \scale, Scale.chromatic,
    \octave, Pwrand([4, 5], [1, 8].normalizeSum, inf),
    \atk, 0.3,
    \sus, 0.6,
    \rel, 0.3,
    \degree, Pseq(
        [
            Pn([0, 3, 5, 8], 2),
            [0, 5, 8, -2]
        ],
        inf
    ),
    \pan, 0
);

~p[1] = \filterIn -> { |in| PitchShift.ar(in, windowSize: b/2, pitchRatio: SinOsc.ar(b*8).range(0.995, 1.005), timeDispersion: b/8) };

~p[2] = \filterIn -> { |in| HPF.ar(in, 600) };

~p[3] = \filterIn -> { |in| in - BPF.ar(in, SinOsc.ar(b/4).range(700, 1100) + LFNoise2.ar(b).range(0, 100)) };

~p[4] = \filterIn -> { |in| RLPF.ar(in, 1200, SinOsc.ar(b/4).range(0.5, 0.9) ) };

~p[100] = \filterIn -> { |in| Normalizer.ar(in, -5.dbamp) }
)
