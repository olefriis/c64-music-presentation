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

while true
  channel, synth_type, note, attack, decay, sustain_level = sync "/osc*/trigger"
  if synth_type == 0 && gates[channel]
    # Release the current sync
    gates[channel] = false
    control synths[channel], amp: 0, amp_slide: attack # attack is (mis)used for release here...
  elsif gates[channel]
    # Change the note on the currently playing synth
    control synths[channel], note: note
  else
    # Start a new synth
    gates[channel] = true
    kill synths[channel] if synths[channel]
    waveform = [:tri, :saw, :pulse, :noise][synth_type - 1]
    synths[channel] = synth waveform, note: note, attack: attack, decay: decay, sustain_level: sustain_level, sustain: 100
  end
end
```

## Great Songs!
Play songs by calling `bundle exec ruby play.rb <file> <song_number>`. These are some great songs:
* Commando: `C64Music/MUSICIANS/H/Hubbard_Rob/Commando.sid 1`
* Paperboy: `C64Music/MUSICIANS/C/Cooksey_Mark/Paperboy.sid`
* Last Ninja - The Wastelands: `C64Music/MUSICIANS/D/Daglish_Ben/Last_Ninja.sid 6`
* 1942: `C64Music/MUSICIANS/C/Cooksey_Mark/1942.sid`
* International Karate: `C64Music/MUSICIANS/H/Hubbard_Rob/International_Karate.sid`
* International Karate +: `C64Music/MUSICIANS/H/Hubbard_Rob/IK_plus.sid`
* Bubble Bobble: `C64Music/MUSICIANS/C/Clarke_Peter/Bubble_Bobble.sid 1`
* Outrun: `C64Music/MUSICIANS/C/Crabtree_Ian/Outrun.sid`
* Ocean Loader 1: `C64Music/MUSICIANS/G/Galway_Martin/Ocean_Loader_1.sid`
* Ocean Loader 2: `C64Music/MUSICIANS/G/Galway_Martin/Ocean_Loader_2.sid`
* Thing on a Spring: `C64Music/MUSICIANS/H/Hubbard_Rob/Thing_on_a_Spring.sid`
