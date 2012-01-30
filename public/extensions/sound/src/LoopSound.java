package org.nlogo.extensions.sound;

import java.net.URL;

/**
 * NetLogo command loops a sound file
 */
public class LoopSound
    implements org.nlogo.api.Command {
  public String getAgentClassString() {
    return "OTP";
  }

  public org.nlogo.api.Syntax getSyntax() {
    int[] right =
        {
            org.nlogo.api.Syntax.StringType(),
        };
    return org.nlogo.api.Syntax.commandSyntax(right);
  }

  public boolean getSwitchesBoolean() {
    return false;
  }

  public org.nlogo.api.Command newInstance(String name) {
    return new LoopSound();
  }


  public void perform(org.nlogo.api.Argument args[], org.nlogo.api.Context context)
      throws org.nlogo.api.ExtensionException, org.nlogo.api.LogoException {
    try {
      String soundpath = args[0].getString();
      URL soundurl;
      soundpath = context.attachCurrentDirectory(soundpath);
      try {
        soundurl = new URL(context.attachCurrentDirectory(soundpath));
      } catch (java.net.MalformedURLException ex) {
        soundurl = new URL("file", "", soundpath);
      }
      SoundExtension.loopSound(soundurl);
    } catch (java.net.MalformedURLException ex) {
      throw new org.nlogo.api.ExtensionException
          ("Unable to open sound sample: " + ex.getMessage());
    }
  }
}
