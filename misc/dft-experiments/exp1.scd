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
    \dur, Pseq([
        Pseq([Rest(3/2), 1/2]), 
        Pseq([Rest(3/2), 1/2]), 
        Pseq([Rest(3/2), 1/4, 1/4])
    ], inf),
    \amp, Pexprand(-10.dbamp, -3.dbamp, inf)
)
)

~p.play;
(
~p = Pbind(
    \instrument, \saw,
    \dur, 16,
    \scale, Scale.chromatic,
    \octave, 5,
    \atk, Pexprand(0.1, 0.3, inf),
    \sus, 0.2,
    \rel, 0.4,
    \degree, Pseq([
        [0, 3, 5, 8],
        [0, 3, 7, 10],
    ], inf),
    \pan, 0,
    \amp, -10.dbamp
);

~p[2] = \filterIn -> { |in| HPF.ar(in, 600) };

~p[3] = \filterIn -> { |in| in - BPF.ar(in, SinOsc.ar(b/4).range(700, 1100) + LFNoise2.ar(b).range(0, 100)) };

~p[4] = \filterIn -> { |in| RLPF.ar(in, 1200, SinOsc.ar(b*4).range(0.25, 0.9) ) };

~p[5] = \filterIn -> { |in| CombC.ar(in, b*8, b/3, b*4) };

~p[6] = \filterIn -> { |in| FreeVerb.ar(in, SinOsc.ar(b*2).range(0.5, 1), room: 0.9) };

)
