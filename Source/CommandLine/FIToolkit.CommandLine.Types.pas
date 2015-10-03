unit FIToolkit.CommandLine.Types;

interface

type

  TCLIOptionString = type String;

  TCLIOptionStringHelper = record helper for TCLIOptionString
    public
      const
        CHR_SPACE = ' ';  // do not localize!
        CHR_QUOTE = '"';  // do not localize!
  end;

implementation

end.
