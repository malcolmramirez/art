(
b = 85/60;
p = ProxySpace(s)
    .makeTempoClock(b)
    .fadeTime_(0)
    .quant_(1)
    .push;
)

~pout.play;
~pgrain.play;

(
~p[0] = Pbind(
    \instrument, \saw,
    \degree, Pseq([
        Pn([0, 3, 7], 4),
        Pn([0, 3, 9], 1),
    ], inf),
    \atk, b,
    \sus, b/2,
    \rel, b*2,
    \dur, 4,
    \amp, -10.dbamp
);

~p[1] = \filterIn -> {|in|
    RLPF.ar(in, LFNoise2.ar(b/8).range(440, 880));
};

~pgrain[0] = { |in| 
    var freq, hasFreq, mix;
    var imp = Impulse.ar(b/4);
    var grain = GrainIn.ar(
        1,
        imp,
        b/16,
        ~p.ar,
    );
    grain = PitchShift.ar(
        grain,
        windowSize: b/4,
        pitchRatio: TChoose.ar(
            imp,
            [1,2,3].collect { |n| DC.ar(n) }
        ),
        timeDispersion: SinOsc.ar(b).range(b/128, b/64)
    );
    grain = FreeVerb.ar(grain, mix: 1, room: 0.99);
    #freq, hasFreq = Pitch.kr(Mix.ar(~p.ar));
    grain = Resonz.ar(grain, freq*2);
    grain * 12.dbamp;
};

~pout[0] = {
    var sig = ~p.ar * -4.dbamp;
    HPF.ar(sig, LFNoise2.ar(b).range(150, 300));
};
)

~b.play;
(
~b[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu2][1],
    \dur, Pseq([
        Rest(1/2), 1/2,
        Rest(1/2), 1/2,
        Pn(1/8, 4),
        Rest(1/2), 1/2,
        Rest(1/2), 1/2,
        Pn(1/8, 4),
        Rest(1/2), 1/2,
        Pn(1/8, 4),
    ], inf),
    \amp, -18.dbamp,
    // Make deterministic
    \rate, Pwrand([1, 8], [1, 10].normalizeSum, inf)
);
~b[1] = \filterIn -> { |in|
    var freq, hasFreq, sig;

    #freq, hasFreq = Pitch.kr(Mix.ar(~p.ar));
    sig = Resonz.ar(in, freq*LFNoise2.ar(b*8).range(2, 8));
    sig = Mix.ar(sig);
    sig = Pan2.ar(in, SinOsc.ar(b*8).range(-0.5, 0.5));
    sig;
};
)

~h.play;
(
~h[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu2][4],
    \dur, Pseq([
        1/4, 1/4, 1/4,
        Rest(3/4),
        Rest(3/4)
    ], inf),
    \rate, 8,
);
)

~break.end

