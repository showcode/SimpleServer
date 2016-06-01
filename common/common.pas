//
// https://github.com/showcode
//

unit common;

interface

uses
  Classes;

type
  PNetHeader = ^TNetHeader;
  TNetHeader = record
    CtrlCode: Integer;
    MsgSize: Integer;
    DataSize: Integer;
    Data: record end;
  end;

  TNetMessage = class
  private
    FCtrlCode: Integer;
    FData: string;
    function GetDataSize: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function PackTo(var Buff: string): Integer;
    function Extract(var Buff: string): Boolean; overload;
    function Extract(const AStream: TStream): Boolean; overload;

    property CtrlCode: Integer read FCtrlCode write FCtrlCode;
    property DataSize: Integer read GetDataSize;
    property Data: string read FData write FData;
  end;

implementation

uses
  Windows, SysUtils;

{ TNetMessage }

constructor TNetMessage.Create;
begin
  inherited;
end;

destructor TNetMessage.Destroy;
begin
  inherited;
end;

function TNetMessage.GetDataSize: Integer;
begin
  Result := Length(FData);
end;

function TNetMessage.PackTo(var Buff: string): Integer;
var
  Header: PNetHeader;
begin
  Result := SizeOf(TNetHeader) + DataSize;
  SetLength(Buff, Length(Buff) + Result);
  Header := @Buff[Length(Buff) - Result + 1];
  Header.CtrlCode := CtrlCode;
  Header.MsgSize := Result;
  Header.DataSize := Length(FData);
  if DataSize > 0 then
    Move(Pointer(Data)^, Header.Data, Header.DataSize);
end;

function TNetMessage.Extract(var Buff: string): Boolean;
var
  Header: PNetHeader;
begin
  Result := (Length(Buff) >= SizeOf(TNetHeader));
  if not Result then
    Exit;

  Header := Pointer(Buff);
  Result := (Length(Buff) >= Header.MsgSize);
  if not Result then
    Exit;

  FCtrlCode := Header.CtrlCode;
  SetLength(FData, Header.DataSize);
  Move(Header.Data, Pointer(FData)^, Header.DataSize);

  Delete(Buff, 1, Header.MsgSize)
end;

function TNetMessage.Extract(const AStream: TStream): Boolean;
var
  Header: TNetHeader;
  N: Integer;
begin
  Result := (AStream.Size-AStream.Position >= SizeOf(TNetHeader));
  if not Result then
    Exit;

  N := AStream.Position;
  AStream.ReadBuffer(Header, SizeOf(TNetHeader));
  Result := (AStream.Size-N >= Header.MsgSize-SizeOf(TNetHeader));
  if not Result then begin
    AStream.Seek(N, soFromBeginning); // return position
    Exit;
  end;

  FCtrlCode := Header.CtrlCode;
  AStream.ReadBuffer(FData, Header.DataSize);
  AStream.Seek(N + Header.MsgSize, soFromBeginning);
end;

end.