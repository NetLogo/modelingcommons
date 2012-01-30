package org.nlogo.extensions.sound;

import java.net.URL;

import org.nlogo.api.ExtensionManager;

public class SoundExtension extends org.nlogo.api.DefaultClassManager {

  /**
   * Names of the drums. <p>
   * The drums on the MIDI percussion channel start at 35,
   * so the indexes in this array are off by -35.
   */
  static final java.util.List DRUM_NAMES = java.util.Arrays.asList(
      new String[]
          {
              "ACOUSTIC BASS DRUM", "BASS DRUM 1", "SIDE STICK",
              "ACOUSTIC SNARE", "HAND CLAP", "ELECTRIC SNARE", "LOW FLOOR TOM",
              "CLOSED HI HAT", "HI FLOOR TOM", "PEDAL HI HAT", "LOW TOM",
              "OPEN HI HAT", "LOW MID TOM", "HI MID TOM", "CRASH CYMBAL 1",
              "HI TOM", "RIDE CYMBAL 1", "CHINESE CYMBAL", "RIDE BELL",
              "TAMBOURINE", "SPLASH CYMBAL", "COWBELL", "CRASH CYMBAL 2",
              "VIBRASLAP", "RIDE CYMBAL 2", "HI BONGO", "LOW BONGO",
              "MUTE HI CONGA", "OPEN HI CONGA", "LOW CONGA", "HI TIMBALE",
              "LOW TIMBALE", "HI AGOGO", "LOW AGOGO", "CABASA", "MARACAS",
              "SHORT WHISTLE", "LONG WHISTLE", "SHORT GUIRO", "LONG GUIRO",
              "CLAVES", "HI WOOD BLOCK", "LOW WOOD BLOCK", "MUTE CUICA",
              "OPEN CUICA", "MUTE TRIANGLE", "OPEN TRIANGLE"
          }
  );

  /**
   * Names of the instruments. <p>
   * According to the specification, MIDI instrument numbers start at 1, so the the
   * index of the instruments in this array should be off by -1. But it seems
   * that it's indexing from zero.
   */
  static final java.util.List INSTRUMENT_NAMES = java.util.Arrays.asList(
      new String[]{
          "ACOUSTIC GRAND PIANO", "BRIGHT ACOUSTIC PIANO",
          "ELECTRIC GRAND PIANO", "HONKY-TONK PIANO", "ELECTRIC PIANO 1",
          "ELECTRIC PIANO 2", "HARPSICHORD", "CLAVI", "CELESTA", "GLOCKENSPIEL",
          "MUSIC BOX", "VIBRAPHONE", "MARIMBA", "XYLOPHONE", "TUBULAR BELLS",
          "DULCIMER", "DRAWBAR ORGAN", "PERCUSSIVE ORGAN", "ROCK ORGAN",
          "CHURCH ORGAN", "REED ORGAN", "ACCORDION", "HARMONICA",
          "TANGO ACCORDION", "NYLON STRING GUITAR",
          "STEEL ACOUSTIC GUITAR", "JAZZ ELECTRIC GUITAR",
          "CLEAN ELECTRIC GUITAR", "MUTED ELECTRIC GUITAR",
          "OVERDRIVEN GUITAR", "DISTORTION GUITAR", "GUITAR HARMONICS",
          "ACOUSTIC BASS", "FINGERED ELECTRIC BASS",
          "PICKED ELECTRIC BASS", "FRETLESS BASS", "SLAP BASS 1",
          "SLAP BASS 2", "SYNTH BASS 1", "SYNTH BASS 2", "VIOLIN",
          "VIOLA", "CELLO", "CONTRABASS", "TREMOLO STRINGS", "PIZZICATO STRINGS",
          "ORCHESTRAL HARP", "TIMPANI", "STRING ENSEMBLE 1",
          "STRING ENSEMBLE 2", "SYNTH STRINGS 1", "SYNTH STRINGS 2",
          "CHOIR AAHS", "VOICE OOHS", "SYNTH VOICE", "ORCHESTRA HIT",
          "TRUMPET", "TROMBONE", "TUBA", "MUTED TRUMPET", "FRENCH HORN",
          "BRASS SECTION", "SYNTH BRASS 1", "SYNTH BRASS 2",
          "SOPRANO SAX", "ALTO SAX", "TENOR SAX", "BARITONE SAX", "OBOE",
          "ENGLISH HORN", "BASSOON", "CLARINET", "PICCOLO", "FLUTE", "RECORDER",
          "PAN FLUTE", "BLOWN BOTTLE", "SHAKUHACHI", "WHISTLE", "OCARINA",
          "SQUARE WAVE", "SAWTOOTH WAVE", "CALLIOPE", "CHIFF", "CHARANG",
          "VOICE", "FIFTHS", "BASS AND LEAD", "NEW AGE", "WARM", "POLYSYNTH",
          "CHOIR", "BOWED", "METAL", "HALO", "SWEEP", "RAIN", "SOUNDTRACK",
          "CRYSTAL", "ATMOSPHERE", "BRIGHTNESS", "GOBLINS", "ECHOES", "SCI-FI",
          "SITAR", "BANJO", "SHAMISEN", "KOTO", "KALIMBA", "BAG PIPE", "FIDDLE",
          "SHANAI", "TINKLE BELL", "AGOGO", "STEEL DRUMS", "WOODBLOCK",
          "TAIKO DRUM", "MELODIC TOM", "SYNTH DRUM", "REVERSE CYMBAL",
          "GUITAR FRET NOISE", "BREATH NOISE", "SEASHORE", "BIRD TWEET",
          "TELEPHONE RING", "HELICOPTER", "APPLAUSE", "GUNSHOT"
      }
  );

  /**
   * The number of the MIDI percussion channel. *
   */
  private static final int PERCUSSION_CHANNEL = 9;

  private static javax.sound.midi.Synthesizer synth;
  private static javax.sound.midi.MidiChannel[] channels;

  /**
   * Next channel to allocate. *
   */
  private static int nextChannel = 0;

  /**
   * Registers extension primitives.
   */
  public void load(org.nlogo.api.PrimitiveManager primManager) {
    primManager.addPrimitive("drums", new ListDrums());
    primManager.addPrimitive("instruments", new ListInstruments());
    primManager.addPrimitive("loop-sound", new LoopSound());
    primManager.addPrimitive("play-drum", new PlayDrum());
    primManager.addPrimitive("play-note", new PlayNote());
    primManager.addPrimitive("play-note-later", new PlayNoteLater());
    primManager.addPrimitive("play-sound", new PlaySound());
    primManager.addPrimitive("play-sound-and-wait", new PlaySoundAndWait());
    primManager.addPrimitive("play-sound-later", new PlaySoundLater());
    primManager.addPrimitive("start-note", new StartNote());
    primManager.addPrimitive("stop-note", new StopNote());
    primManager.addPrimitive("stop-instrument", new StopInstrument());
    primManager.addPrimitive("stop-music", new StopMusic());
    primManager.addPrimitive("stop-sound", new StopSound());


    // undocumented primitive for debugging
    primManager.addPrimitive("__synth-dump", new Dump());
  }

  /**
   * Initializes this extension.
   */
  public void runOnce(org.nlogo.api.ExtensionManager em)
      throws org.nlogo.api.ExtensionException {
    try {

      // Open a synthesizer
      synth = javax.sound.midi.MidiSystem.getSynthesizer();
      synth.open();

      // Get array of synth channels
      channels = synth.getChannels();
      // initializing channels to 0 to fix bug #1027
      // channels have program=0 to begin with, but this additional initialization
      // seems to make them work properly for instrument 0 (acoustic grand piano)
      // when they arent initialized like this, then when inst 0 is used
      // the channel plays the wrong instrument.
      // maybe someday we can figure out why, but for now this is sufficient. -JC 7/2/10
      for (javax.sound.midi.MidiChannel ch : channels) {
        ch.programChange(0);
      }

      javax.sound.midi.Soundbank soundbank = synth.getDefaultSoundbank();

      if (soundbank == null) {
        try {
          soundbank = javax.sound.midi.MidiSystem.getSoundbank(em.getFile("sound/soundbank-min.gm").getInputStream());
        } catch (java.io.IOException e) {
          throw new org.nlogo.api.ExtensionException("Failed to load soundbank: " + e.toString());
        } catch (javax.sound.midi.InvalidMidiDataException e) {
          throw new org.nlogo.api.ExtensionException("Failed to load soundbank: " + e.toString());
        }
      }

      boolean loaded = synth.loadAllInstruments(soundbank);
    } catch (javax.sound.midi.MidiUnavailableException ex) {
      throw new org.nlogo.api.ExtensionException("MIDI is not available");
    }
  }

  public void unload(ExtensionManager em) {
    if (synth != null) {
      synth.close();
    }
  }

  /**
   * Starts playing a note.
   *
   * @param instrument the MIDI patch number of the instrument
   * @param note       the MIDI note number, from 0 to 127 (60 = Middle C)
   * @param velocity   the speed with which the key was depressed
   */
  static void startNote(int instrument, int note, int velocity) {
    javax.sound.midi.MidiChannel channel = ensureChannel(instrument);
    channel.noteOn(note, velocity);
  }

  /**
   * Stops playing a note.
   *
   * @param instrument the MIDI patch number of the instrument
   * @param note       the MIDI note number, from 0 to 127 (60 = Middle C)
   */
  static void stopNote(int instrument, int note) {
    javax.sound.midi.MidiChannel channel = getChannel(instrument);
    if (channel != null) {
      channel.noteOff(note);
    }
  }

  /**
   * Stops all notes of an instrument.
   *
   * @param instrument the MIDI patch number of the instrument
   */
  static void stopNotes(int instrument) {
    javax.sound.midi.MidiChannel channel = getChannel(instrument);
    if (channel != null) {
      channel.setMute(true);
      channel.setMute(false);
    }
  }

  /**
   * Stops all notes.
   */
  static void stopNotes() {
    // the api says stop messages are recevied by all channels
    channels[0].allNotesOff();
  }

  /**
   * Plays a note for a specified duration.
   *
   * @param instrument the MIDI patch number of the instrument
   * @param note       the MIDI note number, from 0 to 127 (60 = Middle C)
   * @param velocity   the speed with which the key was depressed
   * @param duration   time in milliseconds before the note is stopped
   */
  static void playNote(int instrument, int note, int velocity, int duration) {
    javax.sound.midi.MidiChannel channel = ensureChannel(instrument);
    channel.noteOn(note, velocity);

    // start the stop thread
    if (duration > -1) {
      (new StopNoteThread(channel, note, duration)).start();
    }
  }


  static void playNoteLater(int instrument, int note, int velocity, int duration, int delay) {
    javax.sound.midi.MidiChannel channel = ensureChannel(instrument);
    new PlayNoteThread(channel, note, velocity, duration, delay)
        .start();
  }

  /**
   * Hits a drum.
   *
   * @param drum     the key number of the drum.
   * @param velocity the speed at which the drum was hit, from 0 to 128
   */
  static void playDrum(int drum, int velocity) {
    channels[PERCUSSION_CHANNEL].noteOn(drum, velocity);
  }


  /**
   * Starts a sample after a specified duration
   */

  private static class PlaySoundThread extends Thread {
    private javax.sound.midi.MidiChannel channel;
    private URL soundurl;
    private int delay;

    PlaySoundThread(URL soundurl) {
      super("PlaySoundThread");
      this.soundurl = soundurl;
      this.delay = 0;
    }

    PlaySoundThread(URL soundurl, int delay) {
      super("PlaySoundThread");
      this.soundurl = soundurl;
      this.delay = delay;
    }

    public void run() {
      try {
        java.applet.AudioClip clip =
            java.applet.Applet.newAudioClip(soundurl);
        Thread.sleep(delay);
        clip.play();
      } catch (InterruptedException e) {
        org.nlogo.util.Exceptions.ignore(e);
      }

    }
  }


  static void playSound(URL url)
      throws org.nlogo.api.ExtensionException {
    new PlaySoundThread(url).start();
  }


  static void playSoundLater(URL url, int delay)
      throws org.nlogo.api.ExtensionException {
    new PlaySoundThread(url, delay).start();
  }


  static void playSoundAndWait(URL url)
      throws org.nlogo.api.ExtensionException {
    java.applet.AudioClip clip =
        java.applet.Applet.newAudioClip(url);
    clip.play();
  }

  static java.applet.AudioClip currentClip = null;

  static void loopSound(URL url)
      throws org.nlogo.api.ExtensionException {
    currentClip =
        java.applet.Applet.newAudioClip(url);
    currentClip.loop();
  }

  static void stopSound()
      throws org.nlogo.api.ExtensionException {
    if (currentClip != null) {
      currentClip.stop();
      currentClip = null;
    }
  }


  /**
   * Finds the MIDI patch number of an instrument by name.
   *
   * @return index for the instrument
   * @throws org.nlogo.api.ExtensionException
   *          if the instrument does not exist
   */
  static int getInstrument(String name)
      throws org.nlogo.api.ExtensionException {
    name = name.toUpperCase().intern();

    int instrument = INSTRUMENT_NAMES.indexOf(name);

    if (instrument != -1) {
      return instrument;
    } else {
      throw new org.nlogo.api.ExtensionException
          ("No such instrument: " + name);
    }
  }

  /**
   * Finds the MIDI note number of a drum sound by name.
   *
   * @throws org.nlogo.api.ExtensionException
   *          if the instrument does not exist
   */
  static int getDrum(String name)
      throws org.nlogo.api.ExtensionException {
    name = name.toUpperCase().intern();
    int drum = DRUM_NAMES.indexOf(name);

    if (drum != -1) {
      return drum + 35;
    } else {
      throw new org.nlogo.api.ExtensionException
          ("No such drum: " + name);
    }
  }

  /**
   * Debugging output shows channel allocations.
   */
  static String dump() {
    StringBuilder s = new StringBuilder();

    for (int j = 0; j < channels.length; j++) {
      String name;
      int instrument = channels[j].getProgram();
      name = (instrument > -1)
          ? ("" + instrument + ". " + INSTRUMENT_NAMES.get(instrument))
          : "N/A";

      if (j == PERCUSSION_CHANNEL) {
        name = name + " <PERCUSSION>";
      }
      s.append("" + j + "\t" + name + "\n");
    }

    return s.toString();
  }

  /**
   * Returns the channel playing this instrument,
   * -1 if no channel is playing it.
   */
  private static javax.sound.midi.MidiChannel getChannel(int instrument) {
    for (int j = 0; j < channels.length; j++) {
      if (j != PERCUSSION_CHANNEL && channels[j].getProgram() == instrument) {
        return channels[j];
      }
    }
    return null;
  }

  /**
   * Returns a channel playing this instrument.
   * If no channel was playing it, allocates a new one.
   */
  private static javax.sound.midi.MidiChannel ensureChannel(int instrument) {
    javax.sound.midi.MidiChannel channel = getChannel(instrument);

    if (channel != null) {
      return channel;
    }

    channel = channels[nextChannel];
    channel.allNotesOff();
    channel.programChange(instrument);

    // figure out the next channel to allocate
    nextChannel++;
    if (nextChannel == PERCUSSION_CHANNEL) nextChannel++;
    if (!(nextChannel < channels.length)) nextChannel = 0;

    return channel;
  }


  /**
   * Starts a note after a specified duration
   */

  private static class PlayNoteThread extends Thread {
    private javax.sound.midi.MidiChannel channel;
    private int note, velocity, duration, delay;

    PlayNoteThread(javax.sound.midi.MidiChannel channel, int note, int velocity, int duration, int delay) {
      super("PlayNoteThread");
      this.channel = channel;
      this.note = note;
      this.velocity = velocity;
      this.duration = duration;
      this.delay = delay;
    }

    public void run() {
      try {
        Thread.sleep(delay);
      } catch (InterruptedException e) {
        org.nlogo.util.Exceptions.ignore(e);
      }
      channel.noteOn(note, velocity);

      // start the stop thread
      if (duration > -1) {
        (new StopNoteThread(channel, note, duration)).start();
      }
    }
  }


  /**
   * Stops a note after a specified duration
   */
  private static class StopNoteThread extends Thread {
    private javax.sound.midi.MidiChannel channel;
    private int note, duration;

    StopNoteThread(javax.sound.midi.MidiChannel channel, int note, int duration) {
      super("StopNoteThread");
      this.channel = channel;
      this.note = note;
      this.duration = duration;
    }

    public void run() {
      try {
        Thread.sleep(duration);
      } catch (InterruptedException e) {
        org.nlogo.util.Exceptions.ignore(e);
      }
      channel.noteOff(note);
    }
  }

}
