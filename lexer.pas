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
  Pos: Int64;
begin
  ReadCount := Stream.Read(Buffer, 1);
  while ReadCount > 0 do
  begin
    case Ord(Buffer[0]) of
      $0, $9, $0A, $0D: ;
      else
      begin
        Pos := Stream.Position;
        dec(Pos);
        Stream.Position := Pos;
        exit;
      end;
    end;
    ReadCount := Stream.Read(Buffer, 1);
  end;
end;

function TLexer.NextToken: TToken;
begin
  SkipWhitespace;

  Result.TokenType := EOF;
  Result.Value := 'EOF';
end;

end.
