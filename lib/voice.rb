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
  attr_reader :synths

  def initialize(channel)
    @channel = channel
    @frequency_low = @frequency_high = 0
    @pulse_low = @pulse_high = 0
    @attack_decay = @sustain_release = 0
    @control_register = 0
    @playing = false

    @old_frequency = 0
  end

  def finish_frame(osc_client)
    if gate
      if frequency > 0 && (!@playing || @old_frequency != frequency)
        osc_client.send OSC::Message.new('/trigger', @channel, waveform, midi_note, attack, decay, sustain_level)
        @old_frequency = frequency

        @playing = true
      end
    elsif @playing
      osc_client.send OSC::Message.new('/trigger', @channel, 0, 0, release, 0, 0) if @playing
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
    return 3 if @control_register & 128 != 0 # Noise
    STDERR.puts "Unknown waveform: #{@control_register}"
    return :noise
  end

  def sustain_level
    (@sustain_release >> 4) / 15.0
  end

  def decay
    # Approximated... should be multiplied by 1.000.000 / clock
    convert_decay_or_release(@attack_decay & 0xF)
  end

  def release
    # Approximated... should be multiplied by 1.000.000 / clock
    convert_decay_or_release(@sustain_release & 0xF)
  end

  def attack
    # Approximated... should be multiplied by 1.000.000 / clock

    case @attack_decay >> 4
    when 0 then 0.002
    when 1 then 0.008
    when 2 then 0.016
    when 3 then 0.024
    when 4 then 0.038
    when 5 then 0.056
    when 6 then 0.068
    when 7 then 0.08
    when 8 then 0.1
    when 9 then 0.25
    when 10 then 0.5
    when 11 then 0.8
    when 12 then 1
    when 13 then 3
    when 14 then 5
    when 15 then 8
    else raise "Unknown value: #{attack}"
    end
  end

  def convert_decay_or_release(decay_or_release)
    case decay_or_release
    when 0 then 0.006
    when 1 then 0.024
    when 2 then 0.048
    when 3 then 0.072
    when 4 then 0.114
    when 5 then 0.168
    when 6 then 0.204
    when 7 then 0.240
    when 8 then 0.3
    when 9 then 0.75
    when 10 then 1.5
    when 11 then 2.4
    when 12 then 3
    when 13 then 9
    when 14 then 15
    when 15 then 24
    end
  end
end