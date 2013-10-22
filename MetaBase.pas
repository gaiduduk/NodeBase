unit MetaBase;

interface

uses
  SysUtils{AllocMem, Now}, Classes{TStrings}, MetaLine, Windows{SetTimer},
  MetaUtils, Dialogs;

type
  TimerProc = procedure (wnd: HWND; uMsg, idEvent: UINT; dwTime: DWORD) of object; stdcall;

  PNode = ^TNode;

  ANode = array of PNode;

  TNode = record
    Path  : String;            //test mode
    LocalName: String;

    Name  : String;
    ParentName: PNode;
    Index : ANode;
    ParentIndex: PNode;
    Local : ANode;
    ParentLocal: PNode;
    Value : PNode;
    ParentField: PNode;
    Fields: ANode;
    Source: PNode;
    FType : PNode;
    FTrue : PNode;
    FElse : PNode;
    Params: ANode;
    Next  : PNode;
    Prev  : PNode;

    Attr  : Integer;
    Count : Integer;            //controls
    Handle: Integer;
    SaveTime : Double;
    RefCount : Integer;


  end;

  PBlock = ^TBlock;   //replace to interval

  TBlock = record
    FBegin: Double;
    FEnd  : Double;
    Nodes : ANode;
    Next  : PBlock;
  end;

  TMeta = class
  public
    NodeCount: Integer; //statistic
    ID: String;
    Root: PNode;
    Prev: PNode;
    Module: PNode;
    TimeLine: PBlock;
    TimerInterval: Double;
    constructor Create;
    function NextID: String;
    function AddSubNode(var Arr: ANode): PNode;
    function AddIndex(Node: PNode; Name: Char): PNode;
    function NewIndex(Name: String): PNode;
    function AddLocal(Node: PNode): PNode; overload;
    function AddLocal(Node: PNode; Local: PNode): PNode; overload;
    function AddValue(Node: PNode; Value: String): PNode;
    function AddField(Node: PNode; Field: PNode): PNode;
    function AddParam(Node: PNode; Param: PNode; Index: Integer): PNode;
    function GetIndex(Node: PNode): String;
    function SetValue(Node: PNode; Value: String): PNode;
    function GetValue(Node: PNode): PNode;
    function GetParam(Node: PNode): PNode;
    function GetData(Node: PNode): PNode;
    function GetType(Node: PNode): PNode;
    function GetSource(Node: PNode): PNode;
    procedure NewModule(Node: PNode);
    procedure CallFunc(Node: PNode);
    function FindNode(Index: PNode): PNode;
    function NewNode(Line: String): PNode; overload;
    function NewNode(Line: TLine): PNode; overload;
    procedure Run(Node: PNode);
    procedure NextNode(Node: PNode);
    procedure OnTimer(wnd: HWND; uMsg, idEvent: UINT; dwTime: DWORD) stdcall;
    procedure AddEvent(Node: PNode);
    procedure SaveNode(Node: PNode);
    function Get(Line: String): PNode;
  end;

const
  naIndex = $0;
  naWord = $1;
  naLink = $2;
  naData = $3;
  naFile = $4;          //naStdFunc = $51; naFastCallFunc = $52;
  naFunc = $5;
  naNumber = $6;
  naPointer = $7;

  msec = 86400000;
  RootPath = 'data';

var
  Base: TMeta;

implementation

constructor TMeta.Create;
var Method: TMethod;
begin
  CreateDir(RootPath);

  TimerInterval := 100;
  TimerProc(Method) := Self.OnTimer;
  Windows.SetTimer(0, 0, Round(TimerInterval), Method.Code);
  TimerInterval := TimerInterval / msec;

  Root := AllocMem(SizeOf(TNode));
  Module := NewNode(NextID);
end;

function TMeta.NextID: String;
var i: Integer;
begin
  i := 1;
  while True do
    if i > Length(ID) then
    begin
      ID := ID + #1;
      Break;
    end
    else
    begin
      ID[i] := Chr(Ord(ID[i]) + 1);
      if ID[i] <> #0 then
        Break;
      Inc(I);
    end;
  Result := '@' + ID;
end;

function TMeta.AddSubNode(var Arr: ANode): PNode;
begin
  SetLength(Arr, High(Arr) + 2);
  Result := AllocMem(SizeOf(TNode));
  Arr[High(Arr)] := Result;
end;

function TMeta.AddIndex(Node: PNode; Name: Char): PNode;
begin
  Result := AddSubNode(Node.Index);
  Result.Attr := naIndex;
  Result.Name := Name;
  Result.ParentIndex := Node;
  Result := Node.Index[High(Node.Index)];

  Node := Result;
  while Node <> nil do
  begin
    Result.Path := Node.Name + Result.Path;
    Node := Node.ParentIndex;
  end;
end;

function TMeta.AddLocal(Node: PNode; Local: PNode): PNode;
begin
  AddSubNode(Node.Local);
  if Node.Attr = naIndex
  then Local.ParentName  := Node
  else Local.ParentLocal := Node;
  Node.Local[High(Node.Local)] := Local;
  Result := Local;

  while Node <> nil do
  begin
    Result.LocalName := Node.Name + Result.LocalName;
    Node := Node.ParentIndex;
  end;
end;

function TMeta.AddLocal(Node: PNode): PNode;
begin
  Result := AddLocal(Node, NewIndex(NextID));
end;

function TMeta.AddValue(Node: PNode; Value: String): PNode;
begin
  Result := AllocMem(SizeOf(TNode));
  Result.Name := Value;
  Result.Attr := naData;
  Node.Value := Result;
end;

function TMeta.AddField(Node: PNode; Field: PNode): PNode;
var i: Integer;
begin
  Result := nil;
  Field.Source := nil;
  if Node.Source <> nil then
    Node := Node.Source;
  if (Node.Value <> nil) and (Node.Value.Attr = naPointer) and (Node.Value.Source <> nil)then
    Node := Node.Value.Source;
  for i:=0 to High(Node.Fields) do
    if Node.Fields[i].ParentName = Field.ParentName then
    begin
      Result := Node.Fields[i];
      Exit;
    end;
  AddSubNode(Node.Fields);
  Field.ParentField := Node;
  Field.Value := nil;
  Node.Fields[High(Node.Fields)] := Field;
  Result := Field;
end;

function TMeta.AddParam(Node: PNode; Param: PNode; Index: Integer): PNode;
var i: Integer;
begin
  Result := nil;
  if Param.FType <> nil then
  begin
    Param.Source := nil;
    for i:=0 to High(Node.Params) do
      if Node.Params[i].ParentName = Param.ParentName then
      begin
        Result := Node.Params[i];
        Exit;
      end;
    AddSubNode(Node.Params);
    Node.Params[High(Node.Params)] := Param;
    Result := Param;
  end
  else
  begin
    if Index = High(Node.Params) + 1 then
    begin
      AddSubNode(Node.Params);
      Node.Params[Index] := Param;
      Result := Node.Params[Index];
    end
    else
    if Index <= High(Node.Params) then
    begin
      Result := Node.Params[Index];
      if Result <> Param then
        Result.Value := Param;
    end;
  end;
end;

function TMeta.GetIndex(Node: PNode): String;
begin
  if Node <> nil then
    while Node.ParentIndex <> nil do
    begin
      Result := Node.Name + Result;
      Node := Node.ParentIndex;
    end;
end;

function TMeta.SetValue(Node: PNode; Value: String): PNode;
begin
  Result := AddValue(Node, Value);
  if Node.Source <> nil then
    Node.Source.Value := Result;
end;

function TMeta.GetValue(Node: PNode): PNode;
begin
  Result := nil;
  while Node <> nil do
  begin
    if (Node.Attr <> naPointer) and (Node.Source <> nil) then
      Node := Node.Source
    else
    begin
      Result := Node;
      if Result.Attr = naPointer then Exit;
      Node := Node.Value;
    end;
  end;
end;

function TMeta.GetParam(Node: PNode): PNode;
begin
  Result := nil;
  while Node <> nil do
  begin
    Result := Node;
    if Result.Attr = naPointer then Exit;
    Node := Node.Value;
  end;
end;

function TMeta.GetData(Node: PNode): PNode;
begin
  Result := nil;
  while Node <> nil do
  begin
    if (Node.Attr <> naPointer) and (Node.Source <> nil) then
      Node := Node.Source
    else
    begin
      if Node.Attr = naData then
        Result := Node;
      Node := Node.Value;
    end;
  end;
end;

function TMeta.GetSource(Node: PNode): PNode;
begin
  Result := Node;
  if Node = nil then Exit;
  while Result.Source <> nil do
  begin
    Result := Result.Source;
    if (Result.Value <> nil) and (Result.Value.Attr = naPointer) then
    begin
      Result := Result.Value;
      Exit;
    end;
  end;
end;

function TMeta.GetType(Node: PNode): PNode;
begin
  Result := nil;
  if Node = nil then Exit;
  if Node.Source <> nil
  then Result := GetType(Node.Source)
  else Result := GetData(Node.FType);
end;

function TMeta.NewIndex(Name: String): PNode;
var i, j, Index: Integer;
begin
  Result := Root;
  for i:=1 to Length(Name) do
  begin
    Index := -1;
    for j:=0 to High(Result.Index) do
      if  Result.Index[j].Name = Name[i] then
      begin
        Index := j;
        Break;
      end;
    if Index = -1
    then Result := AddIndex(Result, Name[i])
    else Result := Result.Index[Index];
  end;
  if Result <> Root
  then Inc(Result.Count)
  else Result := nil;
end;

procedure TMeta.NewModule(Node: PNode);
var
  i: Integer;
  Func, PrevModule: PNode;
  List: TStrings;
  FileName, FileExt: String;
begin
  FileName := Copy(GetIndex(Node.ParentName), 2, MaxInt);
  if not FileExists(FileName) then Exit;
  List := TStringList.Create;
  FileExt := LowerCase(ExtractFileExt(FileName));
  if FileExt = '.dll' then
  begin
    Node.Handle := GetImageFunctionList(FileName, List);
    for i:=0 to List.Count-1 do
    begin
      Func := NewNode(List.Strings[i]);
      Func.Attr := naFunc;
      Func.Prev := Node;
      Func.Handle := GetProcAddress(Node.Handle, List.Strings[i]);
      AddLocal(Node, Func);
    end;
    //if FileExists(FileName + '.meta') then
  end
  else
  if FileExt = '.meta' then
  begin
    PrevModule := Module;
    Module := Node;
    List.LoadFromFile(FileName);
    for i:=0 to List.Count-1 do
      Get(List.Strings[i]);
    Module := PrevModule;
  end;
  List.Free;
end;

procedure TMeta.CallFunc(Node: PNode);
var
  Value: PNode;
  Params: String;
  Stack: array of Integer;
  Func, FourByte, i, BVal: Integer;
  DBVal: Double;
  IfFloat: Integer;
begin
  DBVal := DBVal + 1;
  Func := Node.Handle;
  if (Func = 0) then Exit;
  for i:=0 to High(Node.Params) do
  begin
    Value := GetData(Node.Params[i]);
    if Value <> nil
    then Params := Params + Value.Name
    else Exit;
  end;
  while Params <> '' do              //fastcall
  begin
    SetLength(Stack, High(Stack) + 2);
    Stack[High(Stack)] := StrToInt4(Copy(Params, 1, 4));
    Delete(Params, 1, 4);
  end;
  for i:=High(Stack) downto 0 do
  begin
    FourByte := Stack[i];
    asm push FourByte end;
  end;
  asm
    CALL Func
    JC @1
    MOV BVal, EAX                //get int value
    MOV IfFloat, 0
    JMP @2
    @1:
    FSTP QWORD PTR [DBVal]       //get float value
    MOV IfFloat, 1
    @2:
  end;
  if IfFloat = 0
  then SetValue(Node, IntToStr4(BVal))
  else SetValue(Node, FloatToStr8(DBVal));
end;

function FindInNode(Node: PNode; Index: PNode): PNode;
var
  i: Integer;
  Local: PNode;
begin
  Result := nil;
  if Node.ParentName = Index then
    Result := Node;
  if (Result = nil) then
    for i:=0 to High(Node.Params) do
      if Node.Params[i].ParentName = Index then
        Result := Node.Params[i];
  if (Result = nil) and (Node.Value <> nil) and (Node.Value.ParentName = Index) then
    Result := Node.Value;
  if (Result = nil) and (Node.FTrue <> nil) and (Node.FTrue.ParentName = Index) then
    Result := Node.FTrue;
  if (Result = nil) and (Node.FElse <> nil) and (Node.FElse <> Pointer(1))
      and (Node.FElse.ParentName = Index) then
    Result := Node;
  if Result = nil then
    for i:=0 to High(Node.Local) do
    begin
      Local := Node.Local[i];
      while Local.ParentField <> nil do
        Local := Local.ParentField;
      if Local.Attr = naFile then
      begin
        Result := FindInNode(Local, Index);
        if Result <> nil then Exit;
      end;
      if Local.ParentName = Index then
      begin
        Result := Local;
        Exit;
      end;
    end;
end;

function TMeta.FindNode(Index: PNode): PNode;
var Node, Find: PNode;
begin
  Result := nil;
  if Prev = nil
  then Node := Module
  else Node := Prev;
  while Node <> nil do
  begin
    Find := FindInNode(Node, Index);
    if Find <> nil then
    begin
      Result := Find;
      if Find.Source = nil then Exit;
    end;
    Node := Node.Prev;
  end;
end;

function  TMeta.NewNode(Line: String): PNode;
begin Result := NewNode(TLine.Create(Line)); end;

function TMeta.NewNode(Line: TLine): PNode;
var
  i: Integer;
  Node: PNode;
  IsPointer: Boolean;
begin
  IsPointer := False;
  if (Length(Line.Name) <> 0) and (Line.Name[1] = '*') then
  begin
    Delete(Line.Name, 1, 1);
    IsPointer := True;
  end;
  Result := NewIndex(Line.Name);
  if Result = nil then Exit;
  if Line.Name[1] <> '@' then
    Result := AddLocal(Result);
  case Line.Name[1] of
    '!' : Result.Attr := naData;
    '@' : Result.Attr := naLink;
    '/' : Result.Attr := naFile;
    '0'..'9', '-': Result.Attr := naNumber;
    else  Result.Attr := naWord;
  end;
  if Result.Attr = naWord then
  begin
    if Line.FType = nil then
      Result.Source := FindNode(Result.ParentName);
    for i:=1 to High(Line.Path) do
      Result := AddField(Result, NewNode(Line.Path[i]));
    if Line.Source <> '' then
    begin
      NextNode(NewNode(Line.Source));
      Result := GetSource(Result);
      Result.Source := Prev;
    end;
    if (Result.Source = nil) and (Line.Value <> nil) and (Prev <> nil) and (Prev <> Module) then
    begin
      NextNode(NewNode(Line.Name));
      Result.Source := Prev;
    end;
  end;
  for i:=0 to High(Line.Params) do
    AddParam(Result, NewNode(Line.Params[i]), i);
  if Result.Attr = naData then
  begin
    AddValue(Result, DecodeName(Copy(Line.Name, 2, MaxInt)));
    Result.Value.Attr := naData;
  end;
  if (Result.Attr = naNumber) and (Result.ParentField = nil) then
    if Pos(',', Line.Name) = 0
    then Result.Value := NewNode('!' + EncodeName(  IntToStr4(  StrToInt(Line.Name))))
    else Result.Value := NewNode('!' + EncodeName(FloatToStr8(StrToFloat(Line.Name))));
  if Line.FElse <> nil then
  begin
    Result.FElse := NewNode(Line.FElse);
    if Result.FElse = nil then
      Result.FElse := Pointer(1);
    Result.FTrue := NewNode(Line.Value);
  end
  else
  if Line.Value <> nil then
  begin
    Result.Value := NewNode(Line.Value);
    Node := GetSource(Result);
    Node.Value := GetValue(Result.Value);
  end;
  if Line.FType <> nil then
    Result.FType := NewNode(Line.FType);
  for i:=0 to High(Line.Local) do
    AddLocal(Result, NewNode(Line.Local[i]));
  if IsPointer = True then
  begin
    Node := GetData(Result);
    if Node <> nil then
      AddValue(Result, IntToStr4(Integer(PChar(Node.Name))));
    Result.Attr := naPointer;
  end;

  if Result.Source <> nil then
    Inc(Result.Source.RefCount);
  AddEvent(Result);
  Inc(NodeCount);
end;

procedure Build(Node: PNode; ToUp: Boolean = False);
var
  i: Integer;
  Value: PNode;
  Data: String;
begin
  for i:=0 to High(Node.Fields) do
  begin
    if ToUp = False then
      Build(Node.Fields[i]);
    Value := Base.GetData(Node.Fields[i]);
    if Value <> nil then
      if Node.Attr = naPointer
      then Data := Data + IntToStr4(Integer(PChar(Value.Name)))
      else Data := Data + Value.Name;
    if i = High(Node.Fields) then
      Base.SetValue(Node, Data);
  end;
  if Node.ParentField <> nil then
    Build(Node.ParentField, True);
end;

function CompareWithZero(Node: PNode): Integer;
var i: Integer;
begin
  Result := -1;
  if Node <> nil then
  begin
    Result := 0;
    for i:=0 to Length(Node.Name) do
      Inc(Result, Ord(Node.Name[i]));
  end;
end;

procedure TMeta.Run(Node: PNode);
label NextNode;
var FuncResult, i: Integer;
begin
  NextNode:
  if Node = nil then Exit;
  if Node.Attr = naFile then
    NewModule(Node);
  for i:=0 to High(Node.Params) do
    Run(Node.Params[i]);
  if (Node.Source <> nil) and ((Node.Source.Prev = Module) or (Node.Source.Attr = naFunc)) then
  begin
    for i:=0 to High(Node.Params) do
      AddParam(GetSource(Node), GetParam(Node.Params[i]), i);
    Run(Node.Source);
    Node.Value := GetData(Node.Source);
  end;
  if Node.Attr = naFunc then
    CallFunc(Node);
  if Node.FElse <> nil then
  begin
    FuncResult := CompareWithZero(GetData(Node));
    if (FuncResult = 1) and (Node.FTrue <> nil) then
    begin
      Node := GetSource(Node.FTrue);
      Goto NextNode;
    end;
    if (FuncResult = 0) and (Node.FElse <> Pointer(1)) then
    begin
      Node := GetSource(Node.FElse);
      Goto NextNode;
    end;
  end
  else
  if (Node.Value <> nil) and (Node.Source <> nil) then
  begin
    Run(Node.Value);
    if (Node.Source.Value <> nil) and (Node.Source.Value.Attr = naPointer) then
    begin
      Node.Source.Value.Value := GetValue(Node.Value);
      SetValue(Node.Source.Value.Source.Value, PChar(Integer(StrToInt4(Node.Source.Value.Value.Name))));
    end
    else
    begin
      if Node.Source.Value.Attr = naWord then
      begin
        if Node.Source.Value <> GetValue(Node.Value) then
          Node.Source.Value.Value := GetValue(Node.Value);
      end
      else
        Node.Source.Value := GetValue(Node.Value);
    end;
  end;

  Node := Node.Next;
  Goto NextNode;
end;

procedure TMeta.NextNode(Node: PNode);
begin
  if Prev <> nil then
  begin
    if Node <> nil then
      Node.Prev := Prev;
    Prev.Next := Node;
  end
  else
    if Node <> nil then
    begin
      AddSubNode(Module.Local);
      Module.Local[High(Module.Local)] := Node;
      Node.Prev := Module;
    end;
  Prev := Node;
end;





procedure TMeta.SaveNode(Node: PNode);
var
  Line: TLine;
  List: TStringList;
  IndexNode, IndexWin: String;
  i: Integer;
  Parent, BufNode: PNode;

function SaveName(Node: PNode): String;
begin
  Result := '';
  if Node = nil then Exit;
  if (Node.Attr = naData) or (Node.Attr = naFile) or (Node.Attr = naLink)
  then Result := EncodeName(GetIndex(Node), 2)
  else Result := EncodeName(GetIndex(Node), 1);
end;

begin
  if (Node = nil) or (Node.RefCount <> 0) then Exit;

  List := TStringList.Create;
  Line := TLine.CreateName(SaveName(Node.Source), SaveName(Node.ParentName), SaveName(Node), '');

  List.Text := Line.GetLine;
  if Node.Next <> nil then
    List.Add(SaveName(Node.Next));
  for i:=0 to High(Node.Local) do
    List.Add(#10 + SaveName(Node.Local[i]));

  IndexNode := GetIndex(Node);
  IndexWin  := RootPath;
  for i:=1 to Length(IndexNode) do
  begin
    if IndexNode[i] in [#0..#32, '/', '\', ':', '*', '?', '@', '"', '<', '>', '|']
    then IndexWin := IndexWin + '\' + IntToHex(Ord(IndexNode[i]), 2)
    else IndexWin := IndexWin + '\' + IndexNode[i];
    CreateDir(IndexWin);
  end;

  List.SaveToFile(IndexWin + '\Node.meta');

  if Node.Source <> nil then
    Dec(Node.Source.RefCount);

  while (Node <> Base.Root) and (High(Node.Index) = -1) do
  begin
    Parent := Node.ParentIndex;

    // ParentLocal

    for i:=0 to High(Parent.Index) do
      if Parent.Index[i] = Node then
      begin
        Parent.Index[i] := Parent.Index[High(Parent.Index)];
        SetLength(Parent.Index, High(Parent.Index));
      end;
    Dispose(Node);
    Dec(Base.NodeCount);
    Node := Parent;
  end;   

  //Base.TimeLine.Next
  Line.Free;
  List.Free;
end;


procedure TMeta.AddEvent(Node: PNode);
var
  Block, NewBlock: PBlock;
begin
  Node.SaveTime := Now + TimerInterval{formula};

  Block := TimeLine;
  while True do
  begin
    if Block = nil then
    begin
      Block := AllocMem(SizeOf(TBlock));
      Block.FBegin:= Node.SaveTime;
      Block.FEnd  := Node.SaveTime + TimerInterval;
      SetLength(Block.Nodes, High(Block.Nodes) + 2);
      Block.Nodes[High(Block.Nodes)] := Node;
      if TimeLine = nil then
        TimeLine := Block;
      Break;
    end
    else
    if (Node.SaveTime >= Block.FBegin) and (Node.SaveTime <= Block.FEnd) then
    begin
      SetLength(Block.Nodes, High(Block.Nodes) + 2);
      Block.Nodes[High(Block.Nodes)] := Node;
      Break;
    end;
    if (Block.Next = nil) or (Node.SaveTime < Block.Next.FBegin) then
    begin
      NewBlock := AllocMem(SizeOf(TBlock));
      NewBlock.FBegin:= Node.SaveTime;
      NewBlock.FEnd  := Node.SaveTime + TimerInterval;
      SetLength(NewBlock.Nodes, High(NewBlock.Nodes) + 2);
      NewBlock.Nodes[High(NewBlock.Nodes)] := Node;
      Block.Next := NewBlock;
    end;
    Block := Block.Next;
  end;
end;

procedure TMeta.OnTimer(wnd: HWND; uMsg, idEvent: UINT; dwTime: DWORD) stdcall;
var
  i: Integer;
  TimeLine: PBlock;
begin
  TimeLine := Base.TimeLine;
  if (TimeLine = nil) or (TimeLine.FEnd < Now) then Exit;

  for i:=0 to High(TimeLine.Nodes) do
    if (TimeLine.Nodes[i].SaveTime >= TimeLine.FBegin) and
       (TimeLine.Nodes[i].SaveTime <= TimeLine.FEnd) then
      SaveNode(TimeLine.Nodes[i]);

  TimeLine.Nodes := nil;
  Base.TimeLine := TimeLine.Next;
  Dispose(TimeLine);
end;


function TMeta.Get(Line: String): PNode;
var Data: String;
begin
  Result := NewNode(Line);
  NextNode(Result);
  Run(Result);
  if GetData(Result) <> nil then
  begin
    Data := GetData(Result).Name;
    Parse(Result, Data);
    Build(Result);
  end;
end;

initialization
  Base := TMeta.Create;
end.
