unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  Kernel, Generator, Utils;

type
  TGG = class(TForm)
    SeqBox: TListBox;
    Timer: TTimer;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ShowNode(Node: TNode);
    procedure TimerTimer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  end;

var
  GG: TGG;
  Generator: TGenerator;

implementation

{$R *.dfm}

procedure TGG.FormCreate(Sender: TObject);
begin


  Generator := TGenerator.Create;
  Generator.Execute('/dll/math.node$activate');

  ShowNode(Generator.GenerateNode);
end;


procedure TGG.ShowNode(Node: TNode);
var
  Body: String;
  Str, Res: String;
  i: Integer;
   Status: THeapStatus;
  function ShowParams(Node: TNode): String;
  var Str: String;
  i: Integer;
  begin
    if Node.Params = nil then begin Result := ''; Exit; end;
    Str := Str + '(';
    for i:=0 to High(Node.Params) do
      Str := Str + Generator.GetIndex(Node.Params[i]) + ', ';
    Delete(Str, Length(Str) - 1, 2);
    Str := Str + ')';
    Result := Str;
  end;

 procedure AddFmt(const Fmt: string; Args: array of const);
  begin
    SeqBox.Items.Add(Format(Fmt, Args));
  end;
var MemoryStatus: TMemoryStatus;
begin
 MemoryStatus.dwLength := SizeOf(MemoryStatus);
  with Generator do
  begin
    SeqBox.Clear;
  Status := GetHeapStatus;
  GlobalMemoryStatus(MemoryStatus);

{

TotalAddrSpace	�������� ������������, ��������� ����� ��������� � ������. �������� ����� ���� ����� �����, �� ���� ����, ��� ������������� ����� ������, ����������� ���������� ����� ����������.
TotalUncommitted	����������, ������� ������ �� TotalAddrSpace �� ��������� � swap-�����.
TotalCommitted	����������, ������� ������ �� TotalAddrSpace ��������� � swap-�����. ��������������, TotalCommited + TotalUncommited = TotalAddrSpace
TotalAllocated	������� ����� ������ ������ ���� ����������� �������� ����� ����������
TotalFree	������� ������ (� ������) �������� ��� ��������� ����� ����������. ���� ��������� ��������� ��� ��������, � ����������� ������ ��� ����� ����������, �� ��������� �������� �������� ������������ ��� ������ ���������� � �������������� ���������� �������� TotalAddrSpace
FreeSmall	���������, �� �������������� ������ (� ������), ����������� � "���������" ������.
FreeBig	���������, �� �������������� ������ (� ������), ����������� � "�������" ������. ������� ����� ����� ������������� �� ����������� ������������������� "���������".
Unused	������ (� ������) ������� �� ������������ (�� ���������) ����� ����������. Unused + FreeSmall + FreeBig = TotalFree.
Overhead	������� ������ (� ������) ���������� ��������� ����, ����� ����������� ��� �����, ����������� ���������� ����� ����������.
HeapErrorCode	���������� ������ ����


  DWORD dwLength; 	// ������ ���������
	DWORD dwMemoryLoad;	// ������� ������������� ������
	DWORD dwTotalPhys;	// ���������� ������, ����
	DWORD dwAvailPhys;	// ��������� ���������� ������, ����
	DWORD dwTotalPageFile;	// ������ ����� ��������, ����
	DWORD dwAvailPageFile;	// ��������� ���� � ����� ��������
	DWORD dwTotalVirtual;	// ����������� ������, ������������ ���������
	DWORD dwAvailVirtual;   // ��������� ����������� ������


  TotalAddrSpace / dwTotalPhys > 30

  }
  AddFmt('TotalAddrSpace = %d', [Status.TotalAddrSpace]);
  AddFmt('TotalUncommitted = %d', [Status.TotalUncommitted]);
  AddFmt('TotalCommitted = %d', [Status.TotalCommitted]);
  AddFmt('TotalAllocated = %d', [Status.TotalAllocated]);
  AddFmt('TotalFree =%d', [Status.TotalFree]);
  AddFmt('FreeSmall =%d', [Status.FreeSmall]);
  AddFmt('FreeBig = %d', [Status.FreeBig]);
  AddFmt('Unused = %d', [Status.Unused]);
  AddFmt('Overhead = %d', [Status.Overhead]);
  AddFmt('dwMemoryLoad = %d', [MemoryStatus.dwMemoryLoad]);
  AddFmt('dwTotalPhys = %d', [MemoryStatus.dwTotalPhys]);
  AddFmt('dwAvailPhys = %d', [MemoryStatus.dwAvailPhys]);
  AddFmt('dwTotalPhys - dwAvailPhys = %d', [(MemoryStatus.dwTotalPhys)-(MemoryStatus.dwAvailPhys)]);

    SeqBox.Items.Add('uses');
    for i:=0 to High(FUnit.Local) do
    begin
      Str := GetIndex(FUnit.Local[i]) + ShowParams(FUnit.Local[i]);
      Str := '  ' + Str + ';';
      SeqBox.Items.Add(Str);
    end;
    Res := '';
    if Node.Value <> nil then
    begin
      if GetValue(Node).Attr = naData then
        Res := ': Result = ' + EncodeStr(GetValue(Node).Data)
      else
        Res := ': Result = ' + GetIndex(GetValue(Node));
    end;

    SeqBox.Items.Add('function ' + GetIndex(Node.ParentName) + GetIndex(Node) + ShowParams(Node) + Res + ';');

    SeqBox.Items.Add('var');
    for i:=0 to High(Node.Local) do
    begin
      Str := GetIndex(Node.Local[i]) + ShowParams(Node.Local[i]);
      Str := '  ' + Str + ';';
      SeqBox.Items.Add(Str);
    end;

    SeqBox.Items.Add('begin');
    Node := Node.Next;
    while Node <> nil do
    begin
      Body := Generator.GetNodeBody(Node);
      if Pos(#10, Body) <> 0 then
        Delete(Body, Pos(#10, Body), MaxInt);
      Str := GetIndex(Node);
      if Node.Source <> nil then
        Str := GetIndex(GetSource(Node));
      if Node.Value <> nil then
      begin
        Str := Str + ' := ' + GetIndex(GetSource(Node.Value));
        if Node.Value <> nil then
          if Node.Value.Source <> nil then
            Str := Str + ShowParams(GetSource(Node.Value));
      end;

      if (Node.FTrue <> nil) or (Node.FElse <> nil) then
      begin
        Str := 'if ' + Str;
        if Node.FTrue <> nil then
          Str := Str + ' then ' + GetIndex(GetSource(Node.FType));
        if Node.FElse <> nil then
          Str := Str + ' else ' + GetIndex(GetSource(Node.FElse));
      end;

      Str := '  ' + Str + ';';
      SeqBox.Items.Add(Str);
      Node := Node.Next;
    end;
    SeqBox.Items.Add('end;');
  end;
end;



procedure TGG.TimerTimer(Sender: TObject);
var
  i: Integer;
  Status: THeapStatus;
  MemoryStatus: TMemoryStatus;
begin
  Timer.Enabled := False;

  Status := GetHeapStatus;
  GlobalMemoryStatus(MemoryStatus);

  if Status.TotalAddrSpace > 200 * 1024 * 1024 then  
  begin
    Generator.Clear;
    Generator.FUnit := Generator.NewNode(Generator.NextID);
    Generator.Execute('/dll/math.node$activate');
  end;

  for i:=0 to 1000 do
    Generator.GenerateNode;
  ShowNode(Generator.GenerateNode);
  Timer.Enabled := True;

end;

procedure TGG.Button1Click(Sender: TObject);
begin
  if Timer.Enabled = True then
  begin
    Timer.Enabled := False;
  end
  else
  begin
    Timer.Enabled := True;
    Generator.Clear;
    Generator.FUnit := Generator.NewNode(Generator.NextID);
    Generator.Execute('/dll/math.node$activate');
  end;
end;

end.
