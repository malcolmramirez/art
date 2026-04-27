(
q = currentEnvironment;
b = 120/60;
p = ProxySpace(~dirt.server).push;
)

~out.play;
~out.stop(16)
(
~i1 = { SinOsc.ar([LFNoise2.ar(b/8).range(220, 221)] * [1,1,3/2,2]) };
~fb1 = { LFNoise2.ar(b).range(0.4, 0.6) };
~n1 = \neuron;
~n1.set(\in, ~i1);
~n1.set(\seed, 2);
~n1.set(\fbamt, ~fb1);

~i2 = { Pulse.ar([LFNoise2.ar(b/8).range(220, 221)] * [1,1,3/2,2]) };
~n2 = \neuron;
~n2.set(\in, ~i2);
~n2.set(\seed, 5);
~n2.set(\fbamt, 0.25);

~n3 = \neuron;
~s3 = { LFNoise0.ar(b * SinOsc.ar(b/4).range(1/8, 8)).range(1, 100) };
~fb2 = { SinOsc.ar(b/6).range(0.1, 0.9) };
~n3.set(\in, [~n1, ~n2]);
~n3.set(\seed, ~s3);
~n3.set(\fbamt, ~fb2);

~out[0] = {
    ~n3.ar;
};

~out[1] = \filterIn -> {
    |in|
    BPF.ar(in, LFNoise2.ar(b*4).range(1200, 1600), LFTri.ar(b/16).range(0.5, 4));
}; 

~out[2] = \filterIn -> {
    |in|
    LPF.ar(in, SinOsc.ar(b/8).range(1000, 9000));
};

~out[4] = \filterIn -> {
    |in|
    Resonz.ar(in, LFNoise2.ar(b).range(100, 400));
};

~out[5] = \filterIn -> { |in| Normalizer.ar(in, 0.5) }

)

s.scope

