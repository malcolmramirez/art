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

~acid.play;
(
~acid[0] = Pbind(
    \dur, Pwrand([1/4, Rest(2)], [4, 1].normalizeSum, inf),
    \instrument, \acid,
    \scale, Scale.partch_o1,
    \atk, 0.1,
    \rel, 0.1,
    \degree, Pseq([0, 1, 3, 10], inf),
    \octave, 2
);

~acid[1] = \filterIn -> { |in|
    var sig;
    sig = CombC.ar(
        in,
        maxdelaytime: b,
        delaytime: b/3,
        decaytime: b
    );
    sig;
};

~pitchRatio = {
    TWChoose.ar(
        Dust.ar(b*8),
        [1,2,3,4].collect{|n| DC.ar(n)},
        [2,4,1,1].normalizeSum
    );
};
~timeDispersion = {
    Select.ar(
        ToggleFF.ar(Dust.ar(b)),
        [
            SinOsc.ar(b).unipolar,
            LFTri.ar(b*2).unipolar,
            LFSaw.ar(b*4).range(0.5, 1)
        ]);
};
~acid[2] = \filterIn -> { |in| 
    PitchShift.ar(
        in,
        windowSize: b,
        pitchRatio: ~pitchRatio.ar,
        pitchDispersion: 0,
        timeDispersion: ~timeDispersion.ar
    )
};

)

