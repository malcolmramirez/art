(
s.reboot { // server options are only updated on reboot
	// configure the sound server: here you could add hardware specific options
	// see http://doc.sccode.org/Classes/ServerOptions.html
    s.options.inDevice_("agg in");
    s.options.outDevice_("blackhole+phones");
	s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
	s.options.memSize = 8192 * 32; // increase this if you get "alloc failed" messages
	s.options.numWireBufs = 2048; // increase this if you get "exceeded number of interconnect buffers" messages
	s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
	s.options.numOutputBusChannels = 2; // set this to your hardware output channel size, if necessary
	s.options.numInputBusChannels = 2; // set this to your hardware output channel size, if necessary
	s.latency = 0.1; // increase this if you get "late" messages
    
    // Safety settings
    s.options.safetyClipThreshold = 1;

    s.waitForBoot {
        // load dirt
        "startdirt.scd".loadRelative;

        d = SuperDirt.default.buffers.copy;
        d[\sigs] = [
            // sin
            {
                var sig = Array.newFrom(Signal.sineFill(s.sampleRate, [1.0]));
                sig = [sig, sig];
                sig = sig.lace(s.sampleRate.asInteger * 2);
                Buffer.loadCollection(s, sig, 2)
            }.()
        ];

        // load synthdefs
        "synthdefs.scd".loadRelative;
    }
};
);

