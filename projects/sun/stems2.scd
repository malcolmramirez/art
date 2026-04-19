(
b = 90/60;
p = ProxySpace(s)
    .quant_(2)
    .fadeTime_(2)
    .makeTempoClock(b)
    .push;
)

(
// alloc a buffer for the FFT
var buf = d[\cpu2][1];
var abuf = Buffer.alloc(s,2048,1);
{
    var in, chain;
    in = PlayBuf.ar(1,buf, BufRateScale.kr(buf), loop:1);
    chain = FFT(abuf, in);
    chain = PV_MagFreeze(chain, LFPulse.kr(1, 0.75));
    0.5 * IFFT(chain);
}.scope(1);
)

(
SynthDef(\p, {
    var sig, freq, dur, atk, sust, rel;

    // base
    freq = \freq.kr(440);
    sig = Saw.ar(freq);

    // envelope
    dur = \dur.kr(1) / b;
    atk = dur / 2;
    rel = dur / 3;
    sust = dur / 4;
    sig = sig * Env([0, 1, 1, 0], [atk, sust, rel]).ar(Done.freeSelf);

    // filter
    sig = RLPF.ar(sig, freq*2, SinOsc.ar(b/4).range(0.5, 1));

    // volume
    sig = sig * \vol.kr(-6.dbamp);
    

    Out.ar(\i_out.kr(0), sig!2);
}).add;
)

~p.end;
(
~p[0] = Pbind(
    \instrument, \p,
    \dur, 8,
    \scale, Scale.chromatic,
    \degree, [0, 2, 5],
);
)

~d.play;
(
~d[0] = Pbind(
    \instrument, \oneshot,
    \buf, d[\cpu2][0],
    \dur, 1/8,
    \rate, 1,
    \amp, -8.dbamp,
);

~d[10] = \filterIn -> { 
    |in|

    var abuf, chain;
    abuf = LocalBuf(2048);
    chain = FFT(abuf, in);
    chain = PV_MagFreeze(chain, LFPulse.kr(b*8, 0.75));
    chain = PV_Freeze(chain, LFNoise0.ar(b));
    chain = IFFT(chain);
    chain = chain.sum;
    chain = chain ! 2;
    chain = chain / 2;
};

)
