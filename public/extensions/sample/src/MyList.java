import org.nlogo.api.*;

public class MyList extends DefaultReporter {
  public Syntax getSyntax() {
    return Syntax.reporterSyntax
        (new int[]{Syntax.WildcardType() | Syntax.RepeatableType()}, Syntax.ListType(), 2);
  }

  public Object report(Argument args[], Context context)
      throws ExtensionException, LogoException {
    LogoListBuilder list = new LogoListBuilder();
    for (int i = 0; i < args.length; i++) {
      list.add(args[i].get());
    }
    return list.toLogoList();
  }
}
