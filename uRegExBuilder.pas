unit uRegExBuilder;

interface

uses SysUtils, Classes;

type
  TDigit = 0..9;
  TLetter = type char;

  TCharSet = record
  strict private
    FInclusions : string;
    FExclusions : string;
  public
    property Inclusions : string read FInclusions;
    property Exclusions : string read FExclusions;
  public
    class operator Add(const inCharSet1, inCharSet2 : TCharSet): TCharSet;
    class operator Subtract(const inCharSet1, inCharSet2 : TCharSet): TCharSet;
  public
    procedure Clear; inline;
  public
    class function AnyDigit: TCharSet; static;
    class function NonDigit: TCharSet; static;
    class function Digit(inMin, inMax : TDigit): TCharSet; static;
    class function AnyLetter: TCharSet; static;
    class function Letter(inMin, inMax : TLetter): TCharSet; overload; static;
    class function Letter(inLetter : TLetter): TCharSet; overload; static;
    class function AnyWordChar : TCharSet; static;
    class function NonWordChar : TCharSet; static;
    class function AnyWhiteSpace : TCharSet; static;
    class function NonWhiteSpace : TCharSet; static;
    class function Space: TCharSet; static;
    class function FullStop: TCharSet; static;
    class function Dot: TCharSet; static;
    class function Comma: TCharSet; static;
    class function SemiColon: TCharSet; static;
    class function Apostrophe: TCharSet; static;
    class function SingleQuote: TCharSet; static;
    class function Hyphen: TCharSet; static;
    class function Underscore : TCharSet; static;
    class function Tilde : TCharSet; static;
    class function Plus : TCharSet; static;
    class function Minus : TCharSet; static;
    class function CarriageReturn : TCharSet; static;
    class function ClosingRoundBracket : TCharSet; static;
    class function ClosingSquareBracket : TCharSet; static;
  end;

  TRegExMode = (remFreeSpacing);
  TRegExModes = set of TRegExMode;

  TRegExBuilder = record
  strict private
    FRegEx : string;
  public
    property RegEx : string read FRegEx write FRegEx;
    procedure AssertEquals(const inRegEx : string);
  public
    class operator Add(const inExpression1, inExpression2 : TRegExBuilder): TRegExBuilder;
  strict private
    function EscapeCharacters(const inText: string) : string;
  public
    function Literal(const inText : string) : TRegExBuilder;
    function CharSet(const inCharSet : TCharSet) : TRegExBuilder;
  public
    function CaptureGroup(const inExpression : TRegExBuilder) : TRegExBuilder; overload;
    function CaptureGroup(const inName : string; const inExpression : TRegExBuilder) : TRegExBuilder; overload;
    function Group(const inExpression : TRegExBuilder) : TRegExBuilder;
    function Alternately: TRegExBuilder;
  public
    function RepeatAtLeast(inQuantity : integer; const inCharSet : TCharSet) : TRegExBuilder; overload;
    function RepeatAtLeast(inQuantity : integer; const inExpression : TRegExBuilder) : TRegExBuilder; overload;
    function RepeatFor(inQuantity : integer; const inExpression : TRegExBuilder) : TRegExBuilder;
    function RepeatBetween(inMin, inMax : integer; const inExpression : TRegExBuilder) : TRegExBuilder;
  public
    function WhitespaceAtLeast(inMin : integer) : TRegExBuilder;
    function OptionalWhitespace : TRegExBuilder;
    function Whitespace : TRegExBuilder;
  public
    function WordBoundary : TRegExBuilder;
    function Word(const inExpression : TRegExBuilder) : TRegExBuilder; overload;
    function Word(const inLiteral : string) : TRegExBuilder; overload;
    function AtEndOfString : TRegExBuilder;
  public
    function AnyChar : TRegExBuilder;
    function AnyWordChar : TRegExBuilder;
    function AnyNonWordChar : TRegExBuilder;
    function AnyCharFrom(const inCharSet : TCharSet) : TRegExBuilder; overload;
    function AnyCharFrom(const inCharSets : array of TCharSet): TRegExBuilder; overload;
    function AnyCharExcept(const inCharSet : TCharSet) : TRegExBuilder; overload;
    function AnyCharExcept(const inCharSets : array of TCharSet) : TRegExBuilder; overload;
  public
    constructor Build(inMode : TRegExModes);
  end;

function NewRegEx : TRegExBuilder; inline;

function Literal(const inText : string) : TRegExBuilder;
function CharSet(const inCharSet : TCharSet) : TRegExBuilder;
function CaptureGroup(const inExpression : TRegExBuilder) : TRegExBuilder; overload;
function CaptureGroup(const inName : string; const inExpression : TRegExBuilder) : TRegExBuilder; overload;
function Group(const inExpression : TRegExBuilder) : TRegExBuilder;
function Alternately: TRegExBuilder;
function RepeatAtLeast(inQuantity : integer; const inExpression : TRegExBuilder) : TRegExBuilder;
function RepeatFor(inQuantity : integer; const inExpression : TRegExBuilder) : TRegExBuilder;
function RepeatBetween(inMin, inMax : integer; const inExpression : TRegExBuilder) : TRegExBuilder;
function WhitespaceAtLeast(inMin : integer) : TRegExBuilder;
function WordBoundary : TRegExBuilder;
function Word(const inExpression : TRegExBuilder) : TRegExBuilder; overload;
function Word(const inLiteral : string) : TRegExBuilder; overload;
function AtEndOfString : TRegExBuilder;
function AnyChar : TRegExBuilder;
function AnyWordChar : TRegExBuilder;
function AnyNonWordChar : TRegExBuilder;
function AnyCharFrom(const inCharSet : TCharSet) : TRegExBuilder; overload;
function AnyCharFrom(const inCharSets : array of TCharSet): TRegExBuilder; overload;
function AnyCharExcept(const inCharSet : TCharSet) : TRegExBuilder; overload;
function AnyCharExcept(const inCharSets : array of TCharSet) : TRegExBuilder; overload;

implementation

{ TCharSet }

procedure TCharSet.Clear;
begin
  FInclusions := '';
  FExclusions := '';
end;

class operator TCharSet.Add(const inCharSet1, inCharSet2: TCharSet): TCharSet;
begin
  Result.Clear;
  Result.FInclusions := inCharSet1.FInclusions + inCharSet2.FInclusions;
  Result.FExclusions := inCharSet1.FExclusions + inCharSet2.FExclusions;
end;

class operator TCharSet.Subtract(const inCharSet1, inCharSet2: TCharSet): TCharSet;
begin
  {$REGION 'Assert'}Assert(inCharSet2.Exclusions = '');{$ENDREGION}
  Result.Clear;
  Result.FInclusions := inCharSet1.FInclusions;
  { exclude the inclusions of the second character set }
  Result.FExclusions := inCharSet1.FExclusions + inCharSet2.Inclusions;
end;

class function TCharSet.AnyDigit: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := '\d';
end;

class function TCharSet.NonDigit: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := '\D';
end;

class function TCharSet.AnyLetter: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := 'A-Za-z';
end;

class function TCharSet.Apostrophe: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := '''';
end;

class function TCharSet.SingleQuote : TCharSet;
begin
  Result.Clear;
  Result.FInclusions := '''';
end;

class function TCharSet.FullStop: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := '.';
end;

class function TCharSet.Dot: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := '.';
end;

class function TCharSet.Comma: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := ',';
end;

class function TCharSet.ClosingRoundBracket: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := ')';
end;

class function TCharSet.ClosingSquareBracket: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := ']';
end;

class function TCharSet.Digit(inMin, inMax: TDigit): TCharSet;
begin
  Result.Clear;
  Result.FInclusions := Format('%d-%d', [inMin, inMax]);
end;

class function TCharSet.Hyphen: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := '-';
end;

class function TCharSet.Tilde: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := '~';
end;

class function TCharSet.Plus: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := '+';
end;

class function TCharSet.Minus: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := '-';
end;

class function TCharSet.Letter(inLetter: TLetter): TCharSet;
begin
  Result.Clear;
  Result.FInclusions := inLetter;
end;

class function TCharSet.Letter(inMin, inMax: TLetter): TCharSet;
begin
  Result.Clear;
  Result.FInclusions := inMin + '-' + inMax;
end;

class function TCharSet.SemiColon: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := ';';
end;

class function TCharSet.Space: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := ' ';
end;

class function TCharSet.Underscore: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := '_';
end;

class function TCharSet.AnyWhiteSpace: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := '\s';
end;

class function TCharSet.NonWhiteSpace: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := '\S';
end;

class function TCharSet.AnyWordChar: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := '\w';
end;

class function TCharSet.NonWordChar: TCharSet;
begin
  Result.Clear;
  Result.FInclusions := '\W';
end;

class function TCharSet.CarriageReturn: TCharSet;
begin
  Result.Clear;
  result.FInclusions := '\r';
end;

{ TRegExBuilder }

constructor TRegExBuilder.Build(inMode: TRegExModes);
begin
  FRegEx := '';
end;

class operator TRegExBuilder.Add(const inExpression1, inExpression2: TRegExBuilder): TRegExBuilder;
begin
  Result.FRegEx := inExpression1.RegEx + inExpression2.RegEx;
end;

procedure TRegExBuilder.AssertEquals(const inRegEx: string);
begin
  Assert((inRegEx = FRegEx), Format('Expression %s does not match TRegExBuilder expression %s', [inRegEx, FRegEx]));
end;

function TRegExBuilder.Alternately: TRegExBuilder;
begin
  FRegEx := FRegEx + '|';
  Result := Self;
end;

function TRegExBuilder.AnyChar: TRegExBuilder;
begin
  FRegEx := FRegEx + '.';
  Result := Self;
end;

function TRegExBuilder.AnyWordChar: TRegExBuilder;
begin
  FRegEx := FRegEx + '\w';
  Result := Self;
end;

function TRegExBuilder.AnyNonWordChar: TRegExBuilder;
begin
  FRegEx := FRegEx + '\W';
  Result := Self;
end;

function TRegExBuilder.CaptureGroup(const inExpression: TRegExBuilder): TRegExBuilder;
begin
  FRegEx := FRegEx + '(' + inExpression.RegEx + ')';
  Result := Self;
end;

function TRegExBuilder.CaptureGroup(const inName: string; const inExpression: TRegExBuilder): TRegExBuilder;
begin
  FRegEx := FRegEx + '(?<' + inName + '>' + inExpression.RegEx + ')';
  Result := Self;
end;

function TRegExBuilder.CharSet(const inCharSet: TCharSet): TRegExBuilder;
begin
  {$REGION 'Assert'}Assert(inCharSet.Exclusions = '');{$ENDREGION}
  FRegEx := FRegEx + inCharSet.Inclusions;
  Result := Self;
end;

function TRegExBuilder.EscapeCharacters(const inText: string) : string;

  function IsEscapableChar(inChar : char) : boolean; inline;
  const
    ESCAPABLE_CHARS : array[0..9] of char = ('[', ']', '(', ')', '\', '.', '+', '*', '{', '}');
  var
    i : integer;
  begin
    for i := Low(ESCAPABLE_CHARS) to High(ESCAPABLE_CHARS) do begin
      if ESCAPABLE_CHARS[i] = inChar then
        Exit(True);
    end;
    Result := False;
  end;

const
  ESCAPE_CHAR = '\';
var
  c : Char;
  i, escapeNeededAt : integer;
begin
  for c in inText do begin
    if IsEscapableChar(c) then
      Result := Result + ESCAPE_CHAR;
    Result := Result + c;
  end; // for
end;

function TRegExBuilder.AtEndOfString: TRegExBuilder;
begin
  FRegEx := FRegEx + '$';
  Result := Self;
end;

function TRegExBuilder.Group(const inExpression: TRegExBuilder): TRegExBuilder;
begin
  FRegEx := FRegEx + '(?:' + inExpression.RegEx + ')';
  Result := Self;
end;

function TRegExBuilder.Literal(const inText: string): TRegExBuilder;
var
  escapedText : string;
begin
  escapedText := EscapeCharacters(inText);
  FRegEx := FRegEx + escapedText;
  Result := Self;
end;

function TRegExBuilder.AnyCharExcept(const inCharSet : TCharSet) : TRegExBuilder;
begin
  {$REGION 'Assert'}Assert(inCharSet.Exclusions = '');{$ENDREGION}
  FRegEx := FRegEx + '[^' + inCharSet.Inclusions + ']';
  Result := Self;
end;

function TRegExBuilder.AnyCharExcept(const inCharSets: array of TCharSet): TRegExBuilder;
var
  charSet, combinedCharSet : TCharSet;
begin
  combinedCharSet.Clear;
  for charSet in inCharSets do begin
    {$REGION 'Assert'}Assert(charSet.Exclusions = '');{$ENDREGION}
    combinedCharSet := combinedCharSet + charSet;
  end; // for
  FRegEx := FRegEx + '[^' + combinedCharSet.Inclusions + ']';
  Result := Self;
end;

function TRegExBuilder.AnyCharFrom(const inCharSet: TCharSet): TRegExBuilder;
begin
  FRegEx := FRegEx + '[' + inCharSet.Inclusions;
  if inCharSet.Exclusions <> '' then
    FRegEx := FRegEx + '-[' + inCharSet.Exclusions + ']';
  FRegEx := FRegEx + ']';
  Result := Self;
end;

function TRegExBuilder.AnyCharFrom(const inCharSets : array of TCharSet): TRegExBuilder;
var
  charSet, combinedCharSet : TCharSet;
begin
  combinedCharSet.Clear;
  for charSet in inCharSets do
    combinedCharSet := combinedCharSet + charSet;
  Result := AnyCharFrom(combinedCharSet);
end;

function TRegExBuilder.RepeatAtLeast(inQuantity: integer; const inExpression: TRegExBuilder): TRegExBuilder;
var
  multiplicitySpecifier : string;
begin
  case inQuantity of
    0: multiplicitySpecifier := '*';
    1: multiplicitySpecifier := '+';
  else
    multiplicitySpecifier := '{' + IntToStr(inQuantity) + ',}';
  end; // case
  FRegEx := FRegEx + inExpression.RegEx + multiplicitySpecifier;
  Result := Self;
end;

function TRegExBuilder.RepeatAtLeast(inQuantity: integer; const inCharSet : TCharSet): TRegExBuilder;
begin
  Result := RepeatAtLeast(inQuantity, NewRegEx.CharSet(inCharSet));
end;

function TRegExBuilder.RepeatBetween(inMin, inMax: integer; const inExpression: TRegExBuilder): TRegExBuilder;
begin
  FRegEx := FRegEx + inExpression.RegEx + '{' + IntToStr(inMin) + ',' + IntToStr(inMax) + '}';
  Result := Self;
end;

function TRegExBuilder.RepeatFor(inQuantity: integer; const inExpression: TRegExBuilder): TRegExBuilder;
begin
  FRegEx := FRegEx + inExpression.RegEx + '{' + IntToStr(inQuantity) + '}';
  Result := Self;
end;

function TRegExBuilder.WhitespaceAtLeast(inMin: integer): TRegExBuilder;
begin
  Result := RepeatAtLeast(inMin, NewRegEx.CharSet(TCharSet.AnyWhiteSpace));
end;

function TRegExBuilder.OptionalWhitespace: TRegExBuilder;
begin
  Result := WhitespaceAtLeast(0);
end;

function TRegExBuilder.Whitespace: TRegExBuilder;
begin
  Result := WhitespaceAtLeast(1);
end;

function TRegExBuilder.Word(const inExpression: TRegExBuilder): TRegExBuilder;
begin
  FRegEx := FRegEx + '\b' + inExpression.RegEx + '\b';
  Result := Self;
end;

function TRegExBuilder.Word(const inLiteral : string) : TRegExBuilder;
begin
  FRegEx := FRegEx + '\b' + EscapeCharacters(inLiteral) + '\b';
  Result := Self;
end;

function TRegExBuilder.WordBoundary: TRegExBuilder;
begin
  FRegEx := FRegEx + '\b';
  Result := Self;
end;

function NewRegEx : TRegExBuilder;
begin
  Result := TRegExBuilder.Build([]);
end;

function AnyChar : TRegExBuilder;
begin
  Result := NewRegEx.AnyChar;
end;

function AnyWordChar : TRegExBuilder;
begin
  Result := NewRegEx.AnyWordChar;
end;

function AnyNonWordChar : TRegExBuilder;
begin
  Result := NewRegEx.AnyNonWordChar;
end;

function AnyCharFrom(const inCharSet : TCharSet) : TRegExBuilder;
begin
  Result := NewRegEx.AnyCharFrom(inCharSet);
end;

function AnyCharFrom(const inCharSets : array of TCharSet) : TRegExBuilder;
begin
  Result := NewRegEx.AnyCharFrom(inCharSets);
end;

function AnyCharExcept(const inCharSet : TCharSet) : TRegExBuilder;
begin
  Result := NewRegEx.AnyCharExcept(inCharSet);
end;

function AnyCharExcept(const inCharSets : array of TCharSet) : TRegExBuilder;
begin
  Result := NewRegEx.AnyCharExcept(inCharSets);
end;

function Literal(const inText : string) : TRegExBuilder;
begin
  Result := NewRegEx.Literal(inText);
end;

function CharSet(const inCharSet : TCharSet) : TRegExBuilder;
begin
  Result := NewRegEx.CharSet(inCharSet);
end;

function CaptureGroup(const inExpression : TRegExBuilder) : TRegExBuilder;
begin
  Result := NewRegEx.CaptureGroup(inExpression);
end;

function CaptureGroup(const inName : string; const inExpression : TRegExBuilder) : TRegExBuilder;
begin
  Result := NewRegEx.CaptureGroup(inName, inExpression);
end;

function Group(const inExpression : TRegExBuilder) : TRegExBuilder;
begin
  Result := NewRegEx.Group(inExpression);
end;

function Alternately: TRegExBuilder;
begin
  Result := NewRegEx.Alternately;
end;

function RepeatAtLeast(inQuantity : integer; const inExpression : TRegExBuilder) : TRegExBuilder;
begin
  Result := NewRegEx.RepeatAtLeast(inQuantity, inExpression);
end;

function RepeatFor(inQuantity : integer; const inExpression : TRegExBuilder) : TRegExBuilder;
begin
  Result := NewRegEx.RepeatFor(inQuantity, inExpression);
end;

function RepeatBetween(inMin, inMax : integer; const inExpression : TRegExBuilder) : TRegExBuilder;
begin
  Result := NewRegEx.RepeatBetween(inMin, inMax, inExpression);
end;

function WhitespaceAtLeast(inMin : integer) : TRegExBuilder;
begin
  Result := NewRegEx.WhitespaceAtLeast(inMin);
end;

function WordBoundary : TRegExBuilder;
begin
  Result := NewRegEx.WordBoundary;
end;

function Word(const inExpression : TRegExBuilder) : TRegExBuilder;
begin
  Result := NewRegEx.Word(inExpression);
end;

function Word(const inLiteral : string) : TRegExBuilder;
begin
  Result := NewRegEx.Word(inLiteral);
end;

function AtEndOfString : TRegExBuilder;
begin
  Result := NewRegEx.AtEndOfString;
end;

end.
