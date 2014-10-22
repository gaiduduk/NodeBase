unit Console;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  Kernel, Generator, Utils;

type
  TGG = class(TForm)
    SeqBox: TListBox;
    TaskBox: TListBox;
    Splitter: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure ShowNode(Node: TNode);
  end;

var
  GG: TGG;
  Generator: TGenerator;

implementation

{$R *.dfm}

procedure TGG.FormCreate(Sender: TObject);
begin
  Generator := TGenerator.Create;
  Generator.Execute('/dll/math32.node$activate');
  ShowNode(Generator.GenerateNode);

  {Generator.Task := Generator.Execute('task?round?x&2;&je?x&3,14;');
  Generator.CreateApplication;
  ShowNode(Generator.Task); }
end;

procedure TGG.ShowNode(Node: TNode);
var
  Body: String;
  Str, Res: String;
  i: Integer;

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

  procedure Add(Str: String);
  begin
    SeqBox.Items.Add(Str);
  end;

begin
  with Generator do
  begin
    SeqBox.Clear;
    Add('unit ' + GetIndex(FUnit) + ';');
    Add('');
    Add('interface');
    Add('');
    Add('uses');
    for i:=0 to High(FUnit.Local) do
    begin
      Str := GetIndex(FUnit.Local[i]) + ShowParams(FUnit.Local[i]);
      Str := '  ' + Str + ';';
      Add(Str);
    end;
    Res := '';
    if Node.Value <> nil then
    begin
      if GetValue(Node).FType = naData then
        Res := ': Result = ' + EncodeStr(GetValue(Node).Data)
      else
        Res := ': Result = ' + GetIndex(GetValue(Node));
    end;
    Add('');
    Add('implementation');
    Add('');
    Add('//...');
    Add('');
    Add('function ' + GetIndex(Node.ParentName) + GetIndex(Node) + ShowParams(Node) + Res + ';');

    Add('var');
    for i:=0 to High(Node.Local) do
    begin
      Str := GetIndex(Node.Local[i]) + ShowParams(Node.Local[i]);
      Str := '  ' + Str + ';';
      Add(Str);
    end;

    Add('begin');
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
          Str := Str + ' then ' + GetIndex(GetSource(Node.ValueType));
        if Node.FElse <> nil then
          Str := Str + ' else ' + GetIndex(GetSource(Node.FElse));
      end;

      Str := '  ' + Str + ';';
      Add(Str);
      Node := Node.Next;
    end;
    Add('end;');
    Add('');
    Add('//...');
    Add('');
    Add('end.');
  end;
end;


end.