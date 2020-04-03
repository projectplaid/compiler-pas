program compiler;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX}
  cthreads, {$ENDIF}
  Classes,
  SysUtils,
  CustApp,
  { you can add units after this }
  lexer;

type
  { TCompiler }
  TCompiler = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ TCompiler }

procedure TCompiler.DoRun;
var
  ErrorMsg: string;
  SourceFile: string;
  SourceStream: TFileStream;
  Lex: TLexer;
  Tok: TToken;
begin
  // quick check parameters
  ErrorMsg := CheckOptions('hs:', 'help source:');
  if ErrorMsg <> '' then
  begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then
  begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }
  if HasOption('s', 'source:') then
  begin
    SourceFile := GetOptionValue('s', 'source:');
    SourceStream := TFileStream.Create(SourceFile, fmOpenRead);
    Lex := TLexer.Create(SourceStream);
    WriteLn('Starting lex of ', SourceFile);
    repeat
      Tok := Lex.NextToken;
      WriteLn('Token Type: ', Tok.TokenType, ' Value: ', Tok.Value);
    until ((Tok.TokenType = EOF) or (Tok.TokenType = Unknown));
    Lex.Free;
    SourceStream.Free;
  end;

  // stop program loop
  Terminate;
end;

constructor TCompiler.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException := True;
end;

destructor TCompiler.Destroy;
begin
  inherited Destroy;
end;

procedure TCompiler.WriteHelp;
begin
  { add your help code here }
  WriteLn('Usage: ', ExeName, ' -h');
end;

var
  Application: TCompiler;
begin
  Application := TCompiler.Create(nil);
  Application.Title := 'Compiler';
  Application.Run;
  Application.Free;
end.
