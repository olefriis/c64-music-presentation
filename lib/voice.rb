class Voice
  CLOCK_FREQUENCY = 985248.0
  # If the clock frequency were 1_000_000 exactly, a SID frequency of 7382 would match an actual frequency
  # of 440 Hz. The clock frequency is a bit less, so we need to adjust. (Probably not super important...)
  FREQUENCY_FACTOR = 440.0 / 7382.0 * CLOCK_FREQUENCY / 1_000_000.0

  attr_writer :channel
  attr_writer :frequency_low
  attr_writer :frequency_high
  attr_writer :pulse_low
  attr_writer :pulse_high
  attr_writer :control_register
  attr_writer :attack_decay
  attr_writer :sustain_release

  def initialize(channel)
    @channel = channel
    @frequency_low = @frequency_high = 0
    @pulse_low = @pulse_high = 0
    @attack_decay = @sustain_release = 0
    @control_register = 0
    @playing = false
  end

  def finish_frame(osc_client)
    if gate && !@playing
      osc_client.send OSC::Message.new('/trigger', @channel, waveform, midi_note, 0, 0, 1)
      @playing = true
    elsif !gate && @playing
      osc_client.send OSC::Message.new('/trigger', @channel, 0, midi_note, 0, 0, 0)
      @playing = false
    end
  end

  private
  def gate
    @control_register & 1 == 1
  end

  def frequency
    (@frequency_high << 8) + @frequency_low
  end

  def midi_note
    (12 * Math.log(actual_frequency / 440.0, 2) + 69).round(2)
  end

  def actual_frequency
    frequency * FREQUENCY_FACTOR
  end

  def waveform
    return 1 if @control_register & 16 != 0 # Triangle
    return 2 if @control_register & 32 != 0 # Sawtooth
    return 3 if @control_register & 64 != 0 # Pulse
    return 4 if @control_register & 128 != 0 # Noise
    STDERR.puts "Unknown waveform: #{@control_register}"
    return :noise
  end
end