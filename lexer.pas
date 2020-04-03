unit lexer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TTokenType = (EOF, Identifier);

  PToken = ^TToken;

  TToken = record
    TokenType: TTokenType;
    Value: ansistring;
  end;

  TLexer = class
  private
    Stream: TStream;
  public
    constructor Create(SourceStream: TStream);
    destructor Destroy; override;
    function NextToken: TToken;
  private
    procedure SkipWhitespace;

    function HandleComment: TToken;
    function HandleStringLiteral: TToken;
    function HandleNumber: TToken;
    function HandleAlpha: TToken;
  end;

implementation

constructor TLexer.Create(SourceStream: TStream);
begin
  Stream := SourceStream;
end;

destructor TLexer.Destroy;
begin
end;

procedure TLexer.SkipWhitespace;
var
  Buffer: array[0..1] of char;
  ReadCount: longint;
  Pos: int64;
begin
  ReadCount := Stream.Read(Buffer, 1);
  while ReadCount > 0 do
  begin
    case Ord(Buffer[0]) of
      $0, $9, $0A, $0D, $20: ;
      else
      begin
        Pos := Stream.Position;
        Dec(Pos);
        Stream.Position := Pos;
        exit;
      end;
    end;
    ReadCount := Stream.Read(Buffer, 1);
  end;
end;

function TLexer.NextToken: TToken;
var
  Buffer: array[0..1] of char;
  ReadCount: longint;
  Pos: int64;
begin
  SkipWhitespace;

  ReadCount := Stream.Read(Buffer, 1);
  if ReadCount < 1 then
  begin
    Result.TokenType := EOF;
    Result.Value := 'EOF';
    exit;
  end;

  case Buffer[0] of
    '0'..'9': Result := HandleNumber;
    'A'..'Z', 'a'..'z': Result := HandleAlpha;
    '''': Result := HandleStringLiteral;
    '"': Result := HandleComment;
    else
    begin
      Pos := Stream.Position;
      Dec(Pos);
      Stream.Position := Pos;
      exit;
    end;
  end;

  Result.TokenType := EOF;
  Result.Value := 'EOF';
end;

function TLexer.HandleComment: TToken;
begin
  Result.TokenType := EOF;
  Result.Value := 'EOF';
end;

function TLexer.HandleStringLiteral: TToken;
begin
  Result.TokenType := EOF;
  Result.Value := 'EOF';
end;

function TLexer.HandleNumber: TToken;
begin
  Result.TokenType := EOF;
  Result.Value := 'EOF';
end;

function TLexer.HandleAlpha: TToken;
begin
  Result.TokenType := EOF;
  Result.Value := 'EOF';
end;

end.
