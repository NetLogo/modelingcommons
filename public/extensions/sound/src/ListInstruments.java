package org.nlogo.extensions.sound;

import org.nlogo.api.LogoList;

/**
 * NetLogo command returns the names of all the available instruments.
 */
public class ListInstruments
    implements org.nlogo.api.Reporter {
  public String getAgentClassString() {
    return "OTP";
  }

  public org.nlogo.api.Syntax getSyntax() {
    return org.nlogo.api.Syntax.reporterSyntax(org.nlogo.api.Syntax.ListType());
  }

  public boolean getSwitchesBoolean() {
    return false;
  }

  public org.nlogo.api.Reporter newInstance(String name) {
    return new ListInstruments();
  }

  public Object report(org.nlogo.api.Argument args[], org.nlogo.api.Context context)
      throws org.nlogo.api.ExtensionException, org.nlogo.api.LogoException {
    return LogoList.fromJava(SoundExtension.INSTRUMENT_NAMES);
  }
}
