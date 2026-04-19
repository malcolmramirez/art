(
b = 85/60;
p = ProxySpace(s)
    .makeTempoClock(b)
    .fadeTime_(0)
    .quant_(1)
    .push;
)

(
SynthDef(\grain, {
    var bufDur = BufDur.kr(\buf.kr);
    var trig = Impulse.ar(\density.kr(10));
    var dur = \size.ar(1);
    var pos = TRand.ar(0, 1, trig);
    
    var sig = GrainBuf.ar(
        numChannels: 1,
        trigger: trig,
        dur: dur,
        sndbuf: \buf.kr,
        rate: \rate.kr(1),
        pos: pos,
        interp: 2,
        envbufnum: \envbufnum.kr(-1) 
    );
    sig = sig * \vol.kr(1);
    sig = sig!2;
    
    Out.ar(\i_out.kr(0), sig);
}).add;
)

(
var loadSamples = { |path|
    PathName(path)
        .entries
        .select { |f| SoundFile.openRead(f.fullPath) != nil }
        .collect { |f|
            Buffer.readChannel(s, f.fullPath, channels: [0]);
        };
};
d = Dictionary[];

// load samples
PathName("../../startup/samples".resolveRelative)
    .entries
    .select { |f| f.isFolder }
    .do { |f|
        d[f.folderName.asSymbol] = loadSamples.(f.fullPath);
    };
)

~b.play;

d[\break][15];
d[\break][5];
d[\clubcode1][8];

f = Buffer.alloc(s, s.sampleRate);

(
~b[0] = \grain;

~b.set(\buf, f);
~b.set(\vol, 8);

~b.set(\size, 0.025);

~ds = { SinOsc.ar(b/8).range(1, 20) };
~b.set(\density, ~ds);

~ra = { LFNoise2.ar(b*4).range(1, 4) };
~b.set(\rate, ~ra)
)

(
~p[0] = Pbind(
    \instrument, \saw,
    \dur, 1,
    \scale, Scale.gong,
    \degree, Pseq([
        [0, 1, 5],
        [3, 5, 9],
        [0, 1, 5],
        [5, 8, 12],
    ], inf),
    \octave, Pwrand([4, 5, 6], [2, 2, 1].normalizeSum, inf),
    \atk, b/4,
    \sus, 0,
    \rel, b/4,
    \amp, -10.dbamp
);

~p[2] = \filterIn -> { |in|
    BPF.ar(in, LFNoise2.ar(b).range(110, 1200));
};

~p[3] = \filterIn -> { |in|
    var imp = Impulse.ar([
        b,
        b/LFNoise2.ar(b*4).range(1, 4),
        b/SinOsc.ar(b).range(2, 8),
        b/SinOsc.ar(b/4).range(6, 16),
    ]);
    var grain = GrainIn.ar(
        1,
        imp,
        b/4,
        in
    );
    grain = FreeVerb.ar(
        grain,
        [1/3, 1/2, 1, 1/8],
        [1/3, 1/6, 1/2, 0],
        0,
    );
    grain = PitchShift.ar(
        grain,
        b,
        [3/4, 0.5, 1, 3/2],
        0,
        [
            b/2,
            b/LFNoise2.ar(b*4).range(0.25, 2),
            b/LFTri.ar(b*2).range(2, 8),
            b*SinOsc.ar(b).range(1/4, 2)
        ]
    );
    grain = grain.sum / 4;
};


~p[100] = \filterIn -> { |in| Normalizer.ar(in) };


~p[200] = { |in| 
    BufWr.ar(
        ~p.ar, 
        f, 
        Phasor.ar(0, BufRateScale.kr(f) * SampleRate.ir, 0, BufFrames.kr(f))
    ) 
};
)

