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


~kd.play;
(
~kd = Pbind(
    \instrument, \oneshot,
    \dur, 1,
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
    \buf, d[\cpu2][3],
    \amp, -45.dbamp,
)
)


~cp.play;
(
~cp = Pbind(
    \instrument, \oneshot,
    \dur, Pseq([
        Rest(1/4), 1/2, Rest(1/4),
        Rest(1/4), 1/2, Rest(1/4),
        Rest(1/4), 1/2, Rest(1/4),
        Rest(1/4), 1/4, 1/4, Rest(1/4),
    ], inf),
    \buf, d[\cpu2][3],
    \amp, Pseq([
        Pn(-15.dbamp, 3),
        Pn(-15.dbamp, 3),
        Pn(-15.dbamp, 3),
        -15.dbamp, -30.dbamp, Pn(-15.dbamp, 2)
    ], inf),
)
)

(

)

~goop.play;
(
~goop[0] = Pbind(
    \instrument, \saw,
    \dur, 1/8,
    \atk, 1/16,
    \rel, 1/16,
    \octave, 6,
    \scale, Scale.phrygian,
    \degree, Pseq([
        0, 3, 7,
        -1, 2, 5,
        -3, 5, 7,
    ], inf)
);

~goop[1] = \filterIn -> { |in|
    var sig = HPF.ar(in, 1200);
    sig = LPF.ar(in, 2400);
};

~kern = Pbind(
    \instrument, \slicer,
    \buf, d[\break][0],
    \bars, 8,
    \tempo, b,
    \dur, Pkey(\bars)
);
~goop[2] = \filterIn -> { |in| 
    Convolution.ar(in, ~kern.ar, framesize: 4096);
};
~wet2 = { SinOsc.ar(b/24).range(0.1, 0.5) };
~goop.set(\wet2, ~wet2);

~goop[3] = \filterIn -> { |in| 
    FreeVerb.ar(in, room: 0.8, mix: 0.25);
};

~goop[4] = \filterIn -> { |in| 
    LPF.ar(in, SinOsc.ar(b/16).range(220, 2400))
};

)


~acid.play;
~acid.end;
(
~acid[0] = Pbind(
    \dur, Pseq([
        // 1/4, 2, 1/4, 2,
        // 1/4, 1/4, 3/2, 1/4, 7/4
        Rest(1/4), 1/4, 
    ], inf),
    \instrument, \acid,
    \scale, Scale.phrygian,
    \atk, 0.075,
    \rel, 0.075,
    // \degree, Pseq([-3, 0, 1, 3, 5], inf),
    \degree, 0,
    \octave, 2
);
)

(
~acid[1] = \filterIn -> { |in| 
    FreeVerb.ar(in);
};

~acid[2] = \filterIn -> { |in| 
    var timeDispersion = TChoose.ar(
        Impulse.ar(b*6),
        [
            SinOsc.ar(b).unipolar,
            LFTri.ar(b*2).unipolar,
            LFSaw.ar(b*4).range(0.5, 1)
        ]);
    var pitchRatio = TWChoose.ar(
        Impulse.ar(b*8),
        [1,2,3].collect{|n| DC.ar(n)},
        [2,4,1].normalizeSum
    );

    PitchShift.ar(
        in,
        windowSize: b,
        pitchRatio: pitchRatio, 
        pitchDispersion: 0,
        timeDispersion: timeDispersion
    )
};
~acid.set(\wet2, 0.5);
)

