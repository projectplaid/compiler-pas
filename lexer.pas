unit lexer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles;

type
  TTokenType = (EOF, Identifier, Keyword, Period, StringLiteral,
    Selector, Comment, Unknown, Invalid, PseudoVariable, ConstantReference);

  PToken = ^TToken;

  TToken = record
    TokenType: TTokenType;
    Value: ansistring;
  end;

  TLexer = class
  private
    Stream: TStream;

    PseudoVariables: THashedStringList;
    ConstantReferences: THashedStringList;
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

  PseudoVariables := THashedStringList.Create;
  PseudoVariables.Add('self');
  PseudoVariables.Add('super');
  PseudoVariables.Add('thisContext');

  ConstantReferences := THashedStringList.Create;
  ConstantReferences.Add('nil');
  ConstantReferences.Add('false');
  ConstantReferences.Add('true');
end;

destructor TLexer.Destroy;
begin
  PseudoVariables.Free;
  ConstantReferences.Free;
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

  if not PeekChar(Ch) then
  begin
    Result.TokenType := EOF;
    Result.Value := 'EOF';
    exit;
  end;

  case Ch of
    '0'..'9': Result := HandleNumber;
    '#', 'A'..'Z', 'a'..'z': Result := HandleAlpha;
    '''': Result := HandleStringLiteral;
    '"': Result := HandleComment;
    '.':
    begin
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
var
  Ch: char = #0;
  Value: string = '';
begin
  // consume the leading "
  GetChar(Ch);
  while PeekChar(Ch) do
  begin
    case Ch of
      '"':
      begin
        Result.Value := Value;
        Result.TokenType := Comment;
        GetChar(Ch);
        exit;
      end;
      else
      begin
        GetChar(Ch);
        Value := Value + Ch;
      end;
    end;
  end;

  Result.TokenType := Invalid;
  Result.Value := Value;
end;

function TLexer.HandleStringLiteral: TToken;
var
  Ch: char = #0;
  Ch2: char = #0;
  Value: string = '';
begin
  // consume the leading '
  GetChar(Ch);
  while PeekChar(Ch) do
  begin
    case Ch of
      '''':
      begin
        GetChar(Ch);
        if ((PeekChar(Ch2)) and (Ch2 = '''')) then
        begin
          Value := Value + '''';
          GetChar(Ch);
        end
        else
          break;
      end;
      else
      begin
        GetChar(Ch);
        Value := Value + Ch;
      end;
    end;
  end;

  Result.TokenType := StringLiteral;
  Result.Value := Value;
end;

function TLexer.HandleNumber: TToken;
begin
  Result.TokenType := EOF;
  Result.Value := 'EOF';
end;

function TLexer.HandleAlpha: TToken;
var
  Ch: char = #0;
  Value: string = '';
begin
  while PeekChar(Ch) do
  begin
    case Ch of
      #0, #9, #10, #13, #32: break;
      '.': break;
      '#', ':', '_', 'A'..'Z', 'a'..'z', '0'..'9':
      begin
        GetChar(Ch);
        Value := Value + Ch;
      end;
      else
      begin
        GetChar(Ch);
        Value := Value + Ch;

        Result.TokenType := Invalid;
        Result.Value := Value;
        exit;
      end;
    end;
  end;

  if ConstantReferences.IndexOf(Value) <> -1 then
  begin
    Result.TokenType := ConstantReference;
  end
  else
  if PseudoVariables.IndexOf(Value) <> -1 then
  begin
    Result.TokenType := PseudoVariable;
  end
  else
  if Value[1] = '#' then
  begin
    Result.TokenType := Selector;
  end
  else if Value[Length(Value)] = ':' then
  begin
    Result.TokenType := Keyword;
  end
  else
  begin
    Result.TokenType := Identifier;
  end;
  Result.Value := Value;
end;

end.
