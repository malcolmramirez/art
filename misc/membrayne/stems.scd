(
b = 150/60;
p = ProxySpace(s)
    .quant_(1)
    .fadeTime_(0)
    .makeTempoClock(b)
    .push;
)

Ndef(\mic, { SoundIn.ar(0) ! 2 }).gui;

~kd.play;
(
~kd[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu2][0],
    \dur, Prand([
        2,
        Pseq([1, Rest(1/2), 1/2]),
        Pseq([1, Rest(1)])
    ], inf),
    \amp, -8.dbamp
);
)

~bg.play;
(
Pdefn(\a, 1);
Pdefn(\b, Pseq([1/4, Rest(1/4)]));
Pdefn(\c, Pseq([Rest(1/4), 1/8, Rest(1/8)]));
Pdefn(\d, Pseq([
        1,
        Pseq([1/2, 1/2, Rest(1)]),
        Pseq([Rest(1/2), 1/2, Rest(1)]),
        1,
    ])
);

~bg[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu2][1],
    \dur, Pnsym(
        Prewrite(
            \a,
            (
                \a: #[\a, \c],
                \b: #[\b, \d],
                \c: #[\a, \b],
                \d: #[\c, \b]
            ),
            4
        )
    ),
    \rate, Prand([0.75, 1, 1.5], inf),
    \amp, Pwhite(-30.dbamp, -10.dbamp),
);
)

~hit.play;
(
var dur = 1/2;

~hit[0] = Pbind(
    \instrument, \oneshot,
    \buf, Prand([
        d[\cpu][17],
        d[\cpu][18],
        d[\cpu][19]
    ], inf),
    \dur, dur,
    \rate, Prand([2, 4, 8], inf),
    \amp, Pwhite(-3.dbamp, 3.dbamp)
);
~hit[1] = \filterIn -> { |in|
    var sig, imp;

    imp = Impulse.ar(b * dur);

    sig = CombC.ar(
        in,
        maxdelaytime: b,
        delaytime: b / TChoose.ar(
            imp,
            [4, 1, 8, 2].collect { |n| DC.ar(n) }
        ),
        decaytime: b / 4 
    );

    SelectX.ar(
        LFNoise2.ar(b*8).range(0, 0.25),
        [in, sig]
    );
};
// ~hit[1] = nil
~hit[2] = \filterIn -> { |in| 
    PitchShift.ar(
        in,
        b,
        pitchRatio: TChoose.ar(
            Impulse.ar(b * dur),
            [0, 1, 2, 3, 4].collect { |n| DC.ar(n) }
        ),
        timeDispersion: TChoose.ar(
            Impulse.ar(b * dur),
            [0,b,b*2].collect { |n| DC.ar(n) }
        )
    );
};
~hit[3] = \filterIn -> { |in| 
    GrainIn.ar(
        2,
        Impulse.ar(b*4),
        LFSaw.ar(b/2).range(b/32, b/8),
        in
    );
};
~hit[4] = \filterIn -> { |in|
    var sig;
    sig = Resonz.ar(
        in,
        [440, 110 * sqrt(2), 880], 
        SinOsc.ar(b*4).range(1, 4)
    );
    sig = Ringz.ar(in, 220 * LFNoise2.ar(b).range(2, 4), b/256) * 0.1;
    Splay.ar(sig);
};
)

~sn.play;
(
~sn[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu][2],
    \dur, Pseq([
        Pseq([Rest(1/4), 1/4, Rest(3/2)], 5),
        Pseq([Rest(1/4), 1/4, Rest(1/2), 1/4, Rest(3/4)]),
        Pseq([Rest(1/4), 1/4, Rest(3/2)]),
        Pseq([Rest(1/4), 1/4, Rest(1/2), 1/4, Rest(3/4)]),
    ], inf),
    \rate, 4,
    \amp, -1.dbamp
);
~sn[1] = \filterIn -> { |in|
    var sig;

    sig = HPF.ar(in, 600);

    LPF.ar(sig, 2000);
};
)

~bg.play;

~pd.play; ~kd.play; ~hit.play; ~sn.play;

~hit.play

~hit.stop; ~bg.stop;

~kd.stop;
~sn.stop;

~pd.stop;

~pd.play;
(
var amp = -12.dbamp;

~pd[0] = Pbind(
    \instrument, \saw,
    \scale, Scale.minor,
    \root, 1,
    \octave, 4,
    \degree, [0, 3, 5, 11],
    \dur, 48,
    \atk, 0.01,
    \rel, b/2,
    \amp, amp,
);
~pd[1] = \filterIn -> { |in| 
    RLPF.ar(in, 880, 0.6);
};
~pd[2] = \filterIn -> { |in| 
    in + CombC.ar(
        in,
        maxdelaytime: b*32,
        delaytime: b/12, 
        decaytime: b*16
    );
};
~pd[3] = \filterIn -> { |in| 
    PitchShift.ar(
        in,
        b,
        pitchRatio: TChoose.ar(
            Impulse.ar(b * 12),
            [0, 2, 4].collect { |n| DC.ar(n) }
        ),
        timeDispersion: TChoose.ar(
            Impulse.ar(b * 12),
            [0, b/4, b].collect { |n| DC.ar(n) }
        )
    );
};
~pd.set(\wet3, 0.25);

~pd[4] = \filterIn -> { |in|
    var sig;

    sig = RLPF.ar(
        PinkNoise.ar,
        LFNoise2.ar(b).range(100, 800),
        LFNoise2.ar(b).range(0.5, 1.0)
    );
    sig = sig * amp;

    sig = SelectX.ar(
        LFTri.ar(b).range(0, 1),
        [
            XFade2.ar(Convolution.ar(sig, in, 4096) * -20.dbamp, in),
            XFade2.ar(Convolution.ar(in, sig, 4096) * -20.dbamp, sig)
        ]
    );

    sig;
};
)
