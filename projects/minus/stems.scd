(
b = 120/60;
p = ProxySpace(s)
    .makeTempoClock(b)
    .fadeTime_(4)
    .quant_(1)
    .push;

SynthDef(\p, {
    var freq = \freq.kr(440);
    var dur = \dur.kr(0) / b;
    var rdur = dur.reciprocal;
    var lfo = SinOsc.ar(
        rdur * Line.ar(1, \hacc.kr(1), dur)
    );
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

    sig = RHPF.ar(sig, freq, 1);
    sig = RLPF.ar(sig, freq*9, 1);
    sig = sig * \vol.kr(1);

    Out.ar(\i_out.kr(0), sig);
}).add;
)

~p.stop(16);
(
~p[0] = Pbind(
    \instrument, \p,
    \dur, 16,
    \atk, 0.8,
    \sus, 0,
    \rel, 0.8,
    // \hindex, Prand([1, 2, 1/2, 1/4], inf),
    \hacc, Prand([8, 16, 32, 64], inf),
    \scale, Scale.mixolydian,
    \degree, Pseq([
        [0, 3],
        [0, 5]
    ], inf),
    \octave, 5
)
)

~h.end(16);
(
~h[0] = Pbind(
    \instrument, \oneshot,
    \dur, Pwrand([1/4, Rest(1)], [4, 1].normalizeSum, inf),
    \buf, d[\cpu][4],
    \amp, 0.dbamp,
    \rate, 4
);

~h[10] = \filterIn -> { |in| Pan2.ar(in.sum / 2, SinOsc.ar(b/16).range(-0.5, 0.5)) };

~h[20] = \filterIn -> { |in| in * SinOsc.ar(b/9).range(0.75, 1) };

~h[30] = \filterIn -> { |in| PitchShift.ar(in, b*4, pitchDispersion: 1, timeDispersion: b*4) };
)

~k.end(4); 
~d.end(4);
(
~k[0] = Pbind(
    \instrument, \oneshot,
    \dur, Pseq([Rest(1/2), 1, Rest(16)], inf),
    \buf, d[\cpu][0],
    \rate, 2,
    \amp, -20.dbamp
);

~d = {
    var sig = CombC.ar(~k.ar, b*4, b/6, b*2);
    sig = ~k.ar + sig;
    sig = Convolution.ar(sig, ~p.ar, 4096) * -5.dbamp;

    PitchShift.ar(
        sig, 
        b*4,
        TChoose.ar(
            Impulse.ar(b*6),
            [3/4, 1].collect{|n|DC.ar(n)}
        ),
        0,
        b/2
    );
}
)

