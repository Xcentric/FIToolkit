unit FIToolkit.CommandLine.Types;

interface

type

  TCLIOptionString = type String;

  TCLIOptionStringHelper = record helper for TCLIOptionString
    public
      const
        CHR_SPACE = Char(' ');  // do not localize!
        CHR_QUOTE = Char('"');  // do not localize!
  end;

implementation

end.
