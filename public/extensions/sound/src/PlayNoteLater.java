package org.nlogo.extensions.sound;

/**
 * NetLogo command plays a note for a specified duration.
 */
public class PlayNoteLater
    implements org.nlogo.api.Command {
  public String getAgentClassString() {
    return "OTP";
  }

  public org.nlogo.api.Syntax getSyntax() {
    int[] right =
        {
            org.nlogo.api.Syntax.NumberType(),  // delay
            org.nlogo.api.Syntax.StringType(),  // instrument
            org.nlogo.api.Syntax.NumberType(),  // note
            org.nlogo.api.Syntax.NumberType(),  // velocity
            org.nlogo.api.Syntax.NumberType()   // duration
        };
    return org.nlogo.api.Syntax.commandSyntax(right);
  }

  public boolean getSwitchesBoolean() {
    return false;
  }

  public org.nlogo.api.Command newInstance(String name) {
    return new PlayNoteLater();
  }


  public void perform(org.nlogo.api.Argument args[], org.nlogo.api.Context context)
      throws org.nlogo.api.ExtensionException, org.nlogo.api.LogoException {
    // convert delay from seconds to milliseconds
    int delay = Math.round((float) args[0].getDoubleValue() * (float) 1000.0);
    int instrument = SoundExtension.getInstrument(args[1].getString());
    int note = args[2].getIntValue();
    int velocity = args[3].getIntValue();
    // convert duration from seconds to milliseconds
    int duration = Math.round((float) args[4].getDoubleValue() * (float) 1000.0);


    SoundExtension.playNoteLater(instrument, note, velocity, duration, delay);
  }
}
