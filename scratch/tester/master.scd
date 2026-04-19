(
~busses = ~dirt.orbits.collect { |each|
	var bus = Bus.audio(~dirt.server, ~dirt.numChannels);
	each.outBus = bus;
	bus
}
);

(
Ndef(\master, {
	var level = 2;
	var distortion = 1;
	var reverbFeedback = 0;
	var all = ~busses.collect { |each| InBus.ar(each, each.numChannels) };
	var mix = all.sum { |x|
		var d = { 0.01.rand } ! x.size;
		DelayN.ar(x, d, d)
	};
	mix = LeakDC.ar(mix);
	mix = Compander.ar(mix, mix, 0.5, slopeBelow:1, slopeAbove:0.5, clampTime:0.01, relaxTime:0.01);
	mix = mix.tanh * level;
	mix
}).play;
);
