(
b = 90/60;
p = ProxySpace(s)
    .fadeTime_(4)
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
        \curve.kr([0, 0, 0])
    ).ar(Done.freeSelf);

    Out.ar(\i_out.kr(0), sig);
}).add;
)

Scale.directory

~kd.play;
(
~kd = Pbind(
    \instrument, \oneshot,
    \dur, 1/2,
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

~break.play;
~break.end(2)
(
~break = Pbind(
    \instrument, \slicer,
    \tempo, b,
    \buf, d[\break][8],
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
            Pseq([0,1,2,3,4,5]),
        ])
    ], inf),
    \bars, 2, 
    \amp, -10.dbamp,
    \dur, Pkey(\bars) / Pkey(\slices),
)
)

~out.play;
(
~out[0] = Pbind(
    // \dur, Pwrand([1/4, 1/2], [2, 1].normalizeSum, inf),
    \dur, 1/8,
    \instrument, \saw,
    \scale, Scale.partch_o2,
    \degree, Pseq([0, 3, 2, 1, 2, 3, Prand([5, 0]), 0], inf),
    \atk, 0.1,
    \rel, 0.1,
    \amp, 2.dbamp,
    \pan, Pfuncn({ p.clock.beats.sin / 2 + (1 - 2.0.rand) }, inf),
    \octave, Pwrand([4, 5, 6], [1, 2, 2].normalizeSum, inf)
);

~lpff = {
    SinOsc.ar(b).range(440, 1220)
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
        framesize: 2048,
    );

    sig = sig * -20.dbamp;

    sig;
};
~wet3 = {
    SinOsc.ar(b).range(0.9, 1);
};
~out.set(\wet3, ~wet3);

)

d.keys;
