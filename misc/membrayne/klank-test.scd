(
SynthDef(\klank, {
    var sig, exciter, ep;

    ep = \exciterp.kr(1);
    exciter = Select.ar(
        \exciter.kr(0),
        [
            SinOsc.ar(ep),
            Pulse.ar(ep),
            Saw.ar(ep),
            // noises
            PinkNoise.ar,
            BrownNoise.ar,
            WhiteNoise.ar,
        ]
    );
    exciter = exciter * \excitera.kr(0.1);

    sig = DynKlank.ar(
        `[
            \bankf.kr([110, 220, 440, 880]),
            \banka.kr([1, 1, 1, 1]),
            \bankr.kr([1, 1, 1, 1])
        ],
        input: exciter,
        freqscale: \freqscale.kr(1),
        freqoffset: \freqoffset.kr(0),
        decayscale: \decayscale.kr(1)
    );

    sig = Pan2.ar(sig, \pan.kr(0));

    sig = sig * Env(
        [0, 1, 1, 0], 
        [\atk.kr(0.1), \sus.kr(0), \rel.kr(0.1)]
    ).ar(Done.freeSelf);

    sig = sig * \amp.kr(0.dbamp);

    Out.ar(\i_out.kr(0), sig);
}).add;
)

(
SynthDef(\super808, {
    var env, sound, freq, mod;
    env = EnvGen.ar(Env.linen(
        attackTime: \atk.kr(0.01),
        sustainTime: 0, 
        releaseTime: \rel.kr(1), 
        level: 0.3,
        curve: -3),
    timeScale: \sustain.kr(1), doneAction: 2);
    env = env * \amp.kr(1.0);

    mod = XLine.ar(
        start: \freq.kr(440).expexp(10, 2000, 200, 500), 
        end: \freq.kr(440), 
        dur: 0.025 / \rate.kr(1));
    mod = mod * WhiteNoise.ar.range(1, 1.05);
    sound = LPF.ar(in: SinOscFB.ar(freq: mod, feedback: \voice.kr(0)), freq: 9000);
    Out.ar(\out.kr(0), Pan2.ar(sound, \pan.kr(0), env));
}).add
)

(
b = 120/60;
p = ProxySpace(s)
    .makeTempoClock(b)
    .push;
)

~kd.play;
(
~kd[0] = Pbind(
    \instrument, \super808,
    \dur, Prewrite(),
    \freq, 45,
    \rate, 1,
    \atk, 0.01,
    \rel, 0.5,
    \amp, 20.dbamp,
)
)


