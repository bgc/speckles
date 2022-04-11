Engine_Speckles : CroneEngine {
  var speckle;

  	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

  alloc {
    		SynthDef.new(\speckles,
			{
				arg out, density = 1, amp = 1, filter = 0, filter_freq = 440, reso = 0, panning = 0, rate = 0.01, amount = 0;
				var eng, sig, lfo, finalPanning;
				lfo = LFNoise0.ar(rate, amount);
				eng = Dust2.ar(density);

        sig = Select.ar(filter, [
          eng,
          RLPF.ar(eng, freq: filter_freq, rq: 1-reso),
          Resonz.ar(eng, freq: filter_freq, rq: 8-(8*reso)),
          RHPF.ar(eng, freq: filter_freq, rq: 1-reso)
        ]);

				finalPanning = (panning + lfo).clip2;

				sig = Pan2.ar(sig, finalPanning);
				Out.ar(out, LeakDC.ar(sig * amp));
		}).add;

    context.server.sync;
    speckle = Synth(\speckles, [\out, context.out_b]);

    this.addCommand(\density, "f", { arg msg;
			var val = msg[1].asFloat;
			speckle.set(\density, val);
		});
		
		this.addCommand(\amp, "f", { arg msg;
			var val = msg[1].asFloat;
			speckle.set(\amp, val);
		});

		this.addCommand(\panning, "f", { arg msg;
			var val = msg[1].asFloat;
			speckle.set(\panning, val);
		});

		this.addCommand(\filter, "i", { arg msg;
			var val = msg[1].asInteger;
			speckle.set(\filter, val);
		});

    this.addCommand(\filter_freq, "f", { arg msg;
			var val = msg[1].asFloat;
			speckle.set(\filter_freq, val);
		});

    this.addCommand(\reso, "f", { arg msg;
			var val = msg[1].asFloat;
			speckle.set(\reso, val);
		});

		this.addCommand(\rate, "f", { arg msg;
			var val = msg[1].asFloat;
			speckle.set(\rate, val);
		});

		this.addCommand(\amount, "f", { arg msg;
			var val = msg[1].asFloat;
			speckle.set(\amount, val);
		});
		
		
		// noteOn(id, freq, vel)
    // this.addCommand(\noteOn, "iff", { arg msg;
    //   var id = msg[1], freq = msg[2], vel = msg[3];
    //	 speckle.set(\filter_freq, freq, \reso, vel);
    // });
		
		
  }

  	free {
		speckle.free;
	}
}