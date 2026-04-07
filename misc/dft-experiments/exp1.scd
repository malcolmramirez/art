(
b = 150/60;
p = ProxySpace(s)
    .fadeTime_(1)
    .quant_(1)
    .makeTempoClock(b)
    .push;
)

~k.play;
(
~k[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu2][0],
    \dur, Pseq([
            1/2,
            Rest(3),
            Rest(1/4),
            1/4,
            Rest(1/2),
            1/2,
            Rest(3),
            Rest(1/4),
            1/4,
            Rest(1/2),
            1/2,
            Rest(3),
            Rest(1/4),
            1/4,
        ], inf),
    \amp, -2.dbamp
);
)

~h.play;
(
~h[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu][3],
    \dur, Pseq([Rest(1), 1], inf),
    \amp, -2.dbamp
)
)

~hh.play;
(
~hh[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu][4],
    \dur, Pseq([Rest(3/2), 1/2], inf),
    \amp, -2.dbamp
)
)

~s.play;
(
~s[0] = Pbind(
    \instrument, \slicer,
    \tempo, b,
    \buf, d[\break][16],
    \slices, 16,
    \slice, Pseq((0..15), inf),
    \bars, 8, 
    \amp, -10.dbamp,
    \dur, Pkey(\bars) / Pkey(\slices),
);

~s[1] = \filterIn -> {
    |in|
    var buf = LocalBuf(1024.dup(2));
    var sig = FFT(buf, in);
    sig = PV_Freeze(sig, Pulse.ar(b, width: LFTri.ar(b*2).range(0.25, 0.75)));
    sig = IFFT(sig);
}
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
    \dur, 1/4,
    \scale, Scale.chromatic,
    // \octave, Pwrand([3, 5], [1, 8].normalizeSum, inf),
    \octave, 5,
    \atk, 0.3,
    \sus, 0.6,
    \rel, 0.3,
    \degree, Pseq(
        [
            0, 3, 5, 8,
            0, 5, 8, -2
        ],
        inf
    ),
    \pan, 0,
    \vol, 10.dbamp
);

~p[2] = \filterIn -> { |in| HPF.ar(in, 600) };

~p[3] = \filterIn -> { |in| in - BPF.ar(in, SinOsc.ar(b/4).range(700, 1100) + LFNoise2.ar(b).range(0, 100)) };

~p[4] = \filterIn -> { |in| RLPF.ar(in, 1200, SinOsc.ar(b*4).range(0.25, 0.9) ) };

)
