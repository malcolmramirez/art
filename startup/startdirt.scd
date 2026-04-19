(
~dirt.stop; // stop any old ones, avoid duplicate dirt (if it is nil, this won't do anything)
~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels

// load default and then custom samples
~dirt.loadSoundFiles; 
~dirt.loadSoundFiles("/Users/malcolm/dev/art/startup/samples/*");
s.sync; // optionally: wait for samples to be read

~dirt.start(57120, 0 ! 12);   // start listening on port 57120, create two busses each sending audio to channel 0
SuperDirt.default = ~dirt; // make this instance available in sclang (optional)

// optional, needed for convenient access from sclang:
(
    ~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
    ~d4 = ~dirt.orbits[3]; ~d5 = ~dirt.orbits[4]; ~d6 = ~dirt.orbits[5];
    ~d7 = ~dirt.orbits[6]; ~d8 = ~dirt.orbits[7]; ~d9 = ~dirt.orbits[8];
    ~d10 = ~dirt.orbits[9]; ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];
);

// directly below here, in your own copy of this file, you could add further code that you want to call on startup
// this makes sure the server and ~dirt are running
// you can keep this separate and make it easier to switch between setups
// by using "path/to/my/file.scd".load and if necessary commenting out different load statements
// ...

);
