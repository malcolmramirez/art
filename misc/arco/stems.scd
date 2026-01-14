(
b = 90/60;
p = ProxySpace(s)
    .fadeTime_(1)
    .quant_(4)
    .makeTempoClock(b)
    .push;

SynthDef(\saw, {
    var sig;

    sig = Saw.ar(\freq.kr(440));
    sig = sig * \amp.kr(0.dbamp);
    sig = Pan2.ar(sig, \pan.kr(0));
    sig = sig * Env(
        [0, 1, 1, 0], 
        [\atk.kr(0.1), \sus.kr(0), \rel.kr(0.1)], 
        [\acurve.kr(0), 0, \rcurve.kr(0)]
    ).ar(Done.freeSelf);

    Out.ar(\i_out.kr(0), sig);
}).add;
)

Scale.directory

~kd.play;
(
~kd = Pbind(
    \instrument, \oneshot,
    \dur, Pseq([
        1, 
        Rest(1/2), Rest(1/8), 1/8, Rest(1/4),
        1,
        1,
        1, 
        Rest(1),
        1,
        Rest(1/2), 1/2
    ], inf),
    \buf, d[\cpu2][0]
)
)

~sn.play;
(
~sn = Pbind(
    \instrument, \oneshot,
    \dur, Pseq([
        Rest(1), 
        Pseq([Rest(3/4), 1/4]),
        Rest(2),
        Pseq([Rest(3/4), 1/8, 1/8])
    ], inf),
    \buf, d[\bssnare][2],
    \amp, -15.dbamp,
)
)

~cp.play;
(
~cp = Pbind(
    \instrument, \oneshot,
    \dur, Pseq([
        Rest(1/2), 1/4, Rest(1/4),
        Rest(1),
        Rest(1/4), Pn(1/12, 3), Rest(1/2),
        Rest(1),
        Rest(1/2), 1/4, Rest(1/4),
        Rest(1)
    ], inf),
    \buf, d[\cpu2][3],
    \amp, -20.dbamp,
)
)

~hh.play;
(
~hh[0] = Pbind(
    \instrument, \slicer,
    \tempo, b,
    \buf, d[\break][11],
    \slices, 16,
    \slice, Pseq([
        Prand([0, 1, 2, 3]),
        Pwrand([
            Pseq([1, 2, 3, 4]),
            Pseq([4, 4, 4, 4]),
            Pseq([3, 2, 1, 0])
        ], [4, 1, 2].normalizeSum),
        5,
        2,
        3,
        1,
        0,
        Prand([
            Pseq([10,11,12,13,14,15]),
            Pseq([0,1,2,3,4,5]),
        ])
    ], inf),
    \bars, 2, 
    \amp, -10.dbamp,
    \dur, Pkey(\bars) / Pkey(\slices),
);

~hh[1] = \filterIn -> { |in| 
    HPF.ar(in, LFNoise2.ar(b*8).range(440, 1220));
};
)

~hh.end;

~out.play;
(
~out[0] = Pbind(
    \dur, Pwrand([1/8, 1/4, 1/2], [8, 4, 1].normalizeSum, inf),
    \instrument, \saw,
    \scale, Scale.phrygian,
    \degree, Pseq([
        [0, 3, 2], 
        Prand([[1, 2, 3], [0, 3, 7]]),
        Prand([0, 5]),
        0,
    ], inf),
    \atk, 0.1,
    \sus, 0.8,
    \sus, Pwhite(0.01, 0.5),
    \acurve, Prand([-2, -3, 5, 11], inf),
    \rcurve, Prand([2, 3, 5, -11], inf),
    \rel, 0.1,
    \amp, 2.dbamp,
    \pan, Pfuncn({ p.clock.beats.sin / 2 + (1 - 2.0.rand) }, inf),
    // \octave, 2,
    \octave, Pwrand([4, 5, 6], [1, 2, 2].normalizeSum, inf)
);

~lpff = {
    TChoose.ar(
        Dust.ar(200),
        [
            SinOsc.ar(b*8).range(440, 1220),
            DC.ar(880),
            LFNoise2.ar(b*4).range(880, 1220),
            Saw.ar(b*4).range(660, 880),
        ]);
};
~lpfq = {
    SinOsc.ar(b/8).range(1, 2);
};
~out[1] = \filterIn -> { |in| 
    var sig;

    sig = RLPF.ar(
        in,
        freq: ~lpff.ar,
        rq: ~lpfq.ar
    );

    sig;
};
~wet1 = {
    ToggleFF.ar(Dust.ar(b*2)).range(0.5, 1);
};
~out.set(\wet1, ~wet1);

~kern = Pbind(
    \dur, 1/8, 
    \instrument, \slicer,
    \buf, Pfuncn({
        var bufs = d[\foley];
        bufs[bufs.size.rand].normalize;
    }, inf),
    \tempo, b,
    \bars, Pkey(\dur) 
);
~out[3] = \filterIn -> { |in| 
    var sig;

    sig = Convolution.ar(
        in,
        kernel: ~kern.ar,
        framesize: 4096,
    );

    sig = sig * -30.dbamp;

    sig;
};
~out.set(\wet3, 1);
)

d.keys;
