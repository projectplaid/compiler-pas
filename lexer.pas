unit lexer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TTokenType = (EOF, Identifier, Keyword, Period, Unknown);

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

    function GetChar(var Ch: char): boolean;
    function PeekChar(var Ch: char): boolean;
  end;

implementation

constructor TLexer.Create(SourceStream: TStream);
begin
  Stream := SourceStream;
end;

destructor TLexer.Destroy;
begin
end;

function TLexer.GetChar(var Ch: char): boolean;
var
  Buffer: array[0..0] of char = (#0);
  ReadCount: longint;
begin
  ReadCount := Stream.Read(Buffer, 1);
  if ReadCount > 0 then
  begin
    Ch := Buffer[0];
    Result := True;
  end
  else
  begin
    Result := False;
  end;
end;

function TLexer.PeekChar(var Ch: char): boolean;
var
  Buffer: array[0..0] of char = (#0);
  ReadCount: longint;
  Pos: int64;
begin
  ReadCount := Stream.Read(Buffer, 1);
  if ReadCount > 0 then
  begin
    Ch := Buffer[0];
    Result := True;

    // rewind the stream when we had a successful read
    Pos := Stream.Position;
    Dec(Pos);
    Stream.Position := Pos;
  end
  else
  begin
    Result := False;
  end;
end;

procedure TLexer.SkipWhitespace;
var
  Ch: char = #0;
begin
  while PeekChar(Ch) do
  begin
    case Ch of
      #0, #9, #10, #13, #32: GetChar(Ch);
      else
      begin
        exit;
      end;
    end;
  end;
end;

function TLexer.NextToken: TToken;
var
  Ch: char = #0;
begin
  SkipWhitespace;

  if Not PeekChar(Ch) then
  begin
    Result.TokenType := EOF;
    Result.Value := 'EOF';
    exit;
  end;

  case Ch of
    '0'..'9': Result := HandleNumber;
    'A'..'Z', 'a'..'z': Result := HandleAlpha;
    '''': Result := HandleStringLiteral;
    '"': Result := HandleComment;
    '.': begin
      GetChar(Ch);
      Result.TokenType := Period;
      Result.Value := '.';
    end
    else
    begin
      Result.TokenType := Unknown;
      Result.Value := 'Unknown token';
    end;
  end;
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
var
  Ch: char = #0;
  Value: String = '';
begin
  while PeekChar(Ch) do
  begin
    case Ch of
      #0, #9, #10, #13, #32: break;
      '.': break;
      else
      begin
        GetChar(Ch);
        Value := Value + Ch;
      end;
    end;
  end;

  if Value[Length(Value)-1] = ':' Then
  begin
    Result.TokenType := Keyword;
  end else
  begin
    Result.TokenType := Identifier;
  end;
  Result.Value := Value;
end;

end.
