TempoClock.default.tempo


(
var quant = 1.0;
~dirt.receiveAction = { |e|
	var cycle = e[\cycle];
	var cps = e[\cps];
	var latency = e[\latency];
	cycle !? {
		if(cycle % quant == 0) { // set clock only quant in cycle
			TempoClock.default.beats = cycle;
		};
	};
	cps !? {
		TempoClock.default.tempo = cps;
	};
	latency !? {
		Server.default.latency = latency;
	}
}
);

(
if (currentEnvironment.isKindOf(ProxySpace).not) {
    q = currentEnvironment;
    p = ProxySpace(~dirt.server).push;
};
d = q[\dirt];
)

OSCFunc.trace(false)

(
~d1.ar(d.numChannels);
d.orbits[0].outBus = ~d1.bus;
)

~out.play;
(
~out = {
    var sig = [
        ~d1, 
        ~noise,
        Saw.ar(220)
    ];
    var weights = [
        0.5, 
        0.0001,
        LFNoise2.ar(b).range(0.00001, 0.0001)
    ];
    var feedback = LocalIn.ar(2);
    var osc = LFNoise2.ar(b).range(0, 1);
    sig = (sig * weights) + (
        feedback * SinOsc.ar(b/4).range(0.00001, 0.001)
    );
    sig = sig.sum / (weights.size + 1);
    sig = Normalizer.ar(sig);

    sig = [sig, sig.tanh] * [osc, 1 - osc];
    sig = sig.sum;
    LocalOut.ar(sig);
    sig;
};
)

~p.stop;
(
~p = Pbind(
    \instrument, \saw,
    \dur, 1/4,
    \atk, 0.01,
    \rel, 0.01,
    \amp, 0.3
)
)

~pad.play;
(
~pad[0] = { 
    var sig = MiBraids.ar(
        pitch: [50, 53, 57, 60] - 12,
        timbre: LFNoise2.ar(b/8).range(0, 1),
        color: SinOsc.ar(b/32).range(0, 1),
        model: 38,
    );
    sig / 8;
};
~pad[1] = \filterIn -> {
    |in|
    MiClouds.ar(
        in,
        pit: 24,
        fb: 0.1,
        tex: LFNoise2.ar(b/2).range(0, 1),
        drywet: SinOsc.ar(b/4).range(0.25, 0.75),
        trig: Impulse.ar(b*4)
    );
};
)
