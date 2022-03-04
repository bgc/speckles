Engine_Speckles : CroneEngine {
  var speckle;

  	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

  alloc {
    		SynthDef.new(\speckles,
			{
				arg out, density = 1, amp = 1, filter = 0, filter_freq = 440, reso = 0;
				var eng, sig;
				eng = Dust2.ar(density);

        sig = Select.ar(filter, [
          eng,
          RLPF.ar(eng, freq: filter_freq, rq: 1-reso),
          BPF.ar(eng, freq: filter_freq, rq: 1-reso),
          RHPF.ar(eng, freq: filter_freq, rq: 1-reso)
        ]);
        
				Out.ar(out, LeakDC.ar(sig * amp).dup);
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
  }

  	free {
		speckle.free;
	}
}