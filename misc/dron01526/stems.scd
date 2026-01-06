(
b = 90/60;
p = ProxySpace(s)
    .fadeTime_(1)
    .quant_(4)
    .makeTempoClock(b)
    .push;
)

Scale.directory;


s.record(PathName(thisProcess.nowExecutingPath).pathOnly +/+ Date.localtime.secStamp ++ ".wav")

s.stopRecording

~out.play;
(
~out[0] = Pbind(
    \instrument, \pulsar,
    \buf, Prand((0..40).collect { |i| d[\rash][i] }, inf),
    \scale, Scale.partch_o1,
    \degree, Pseq([0, 3, 5, 8, 12, 13], inf),
    \octave, Pwrand([3, 4], [1, 4].normalizeSum, inf),
    \sust, 0.5,
    \atk, 0.05,
    \rel, Pexprand(0.25, 0.5),
    \amp, 0.5,
    \dur, 1/2,
);

~lfo = { 
    TWChoose.ar(
        Impulse.ar(b/4),
        [
            SinOsc.ar(b).range(2, 4),
            LFNoise2.ar(b).range(1.5, 3),
            Saw.ar(b*8).range(1.5, 5)
        ],
        [4, 8, 1].normalizeSum
    );
};

~out.map(\formant, ~lfo1);

~out[1] = \filterIn -> { |in|
    RLPF.ar(in, SinOsc.ar(b/4).range(440, 880), LFNoise2.ar(b).range(1, 2));
};

~out[2] = \filterIn -> { |in| 
    FreeVerb.ar(in, mix: 1, room: 0.9);
};

~out[3] = \filterIn -> { |in| 
    in * 10;
}
)


