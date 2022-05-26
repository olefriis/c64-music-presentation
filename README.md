# C64 Music Presentation

## Preparation
Download and install [Sonic Pi](https://sonic-pi.net). Install Ruby 3.1.0. Run `bundle install` in your terminal.
Download the newest version of the [High Voltage SID Collection](https://www.hvsc.c64.org), unarchive it (this may
require you to install a tool to unpack 7zip or rar files), and put it in the `C64Music` directory.

## Sonic Pi Code
Start up Sonic Pi, copy-paste the code below into the editor, and hit the "run" button. Now Sonic Pi is ready to be
driven by the `play.rb` script!

```ruby
synths = [nil, nil, nil]
gates = [false, false, false]

loop do
  channel, synth_type, note, attack_rate, decay_rate, sustain_level = sync "/osc*/trigger"
  
  control synths[channel], note: note if synths[channel]
  
  if synth_type == 0 && gates[channel]
    # Release the current sync - (mis)use attack_rate as release rate
    control synths[channel], amp: 0, amp_slide: attack_rate if synths[channel]
    gates[channel] = false
  elsif synth_type > 0 && !gates[channel]
    # Start a new synth
    kill synths[channel] if synths[channel]
    waveform = [:tri, :saw, :pulse, :noise][synth_type - 1]
    synths[channel] = synth waveform, note: note, attack: attack_rate, decay: decay_rate, sustain_level: sustain_level, sustain: 100
    gates[channel] = true
  end
end
```

## Great Songs!
Play songs by calling `./play.rb <file> [song_number]`. These are some great songs:
* Commando: `C64Music/MUSICIANS/H/Hubbard_Rob/Commando.sid 1`
* Paperboy: `C64Music/MUSICIANS/C/Cooksey_Mark/Paperboy.sid`
* Last Ninja - The Wastelands (loader): `C64Music/MUSICIANS/D/Daglish_Ben/Last_Ninja.sid`
* Last Ninja - The Wastelands: `C64Music/MUSICIANS/D/Daglish_Ben/Last_Ninja.sid 6`
* 1942: `C64Music/MUSICIANS/C/Cooksey_Mark/1942.sid`
* International Karate: `C64Music/MUSICIANS/H/Hubbard_Rob/International_Karate.sid`
* International Karate +: `C64Music/MUSICIANS/H/Hubbard_Rob/IK_plus.sid`
* Bubble Bobble: `C64Music/MUSICIANS/C/Clarke_Peter/Bubble_Bobble.sid 1`
* Outrun: `C64Music/MUSICIANS/C/Crabtree_Ian/Outrun.sid`
* Ocean Loader 1: `C64Music/MUSICIANS/G/Galway_Martin/Ocean_Loader_1.sid`
* Ocean Loader 2: `C64Music/MUSICIANS/G/Galway_Martin/Ocean_Loader_2.sid`
* Thing on a Spring: `C64Music/MUSICIANS/H/Hubbard_Rob/Thing_on_a_Spring.sid`

## Unsupported Songs
We only support SID files in the `PSID` format. Unfortunately some noticeable classics are in the `RSID` format, which requires
a more thorough Commodore 64 emulation:
* Great Giana Sisters: `C64Music/MUSICIANS/H/Huelsbeck_Chris/Great_Giana_Sisters.sid`
* Myth - History in the Making: `C64Music/MUSICIANS/T/Tel_Jeroen/Myth.sid`

## Branches to try out!
It's interesting to try to turn features on and off and see what happens. So we have a few branches with stuff disabled.
* `only-on-and-off`: Only start a sample when the gate is on, stop it when the gate is off. Don't care about the ADSR envelope.
  The "Thing on a Spring" swoop sound is gone. The main "Last Ninja - The Wastelands (loader)" song sounds really terrible!!
  "Paperboy" sounds pretty good, but the backgound sound is weird. "Bubble Bobble" is outright missing some notes because it
  switches the frequency of playing synths.
* `no-envelope`: Allow the frequencies to be changed while the gate is on, but do not respect envelopes. "Paperboy" now sounds
  pretty good with vibrato etc., but there is a clear quality difference between this version and the one on `master`. This
  version is much more "staccato". "Ocean Loader 1" sounds very basic in this version. "Bubble Bobble" sounds much better than
  before.
