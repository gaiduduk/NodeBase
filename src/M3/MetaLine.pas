unit MetaLine;

{
  Line: TLine;
begin
  Line := TLine.Create('name$I5');
  ShowMessage(Line.ControlsValues[0]);
  Exit;
  }

interface

uses
  SysUtils, MetaUtils;

type

  //Set of illegal characters
  //Set of filename reserved characters

  TLine = class
  public
    Name: string;
    Path: array of string;
    ParentLocal: string;
    Source: string;
    Names: array of String;       //to ControlNames
    Values: array of String;       //property Controls[Index: Integer]: string read Get write Put;
    FType: TLine;
    Local: array of TLine;
    Params: array of TLine;
    Value: TLine;
    FElse: TLine;
    constructor CreateName(SourceNode, NameNode, IdNode, ControlsNode: String);
    constructor Script(var LURI: String; FirstRun: Boolean = False);
    constructor Create(LURI: string);
    destructor Destroy;
  end;


implementation


destructor TLine.Destroy;
var i: Integer;
begin           
  if FType <> nil then
    FType.Destroy;
  for i:=0 to High(Params) do
    if Params[i] <> nil then
      Params[i].Destroy;
  if Value <> nil then
    Value.Destroy;
  if FElse <> nil then
    FElse.Destroy;
  for i:=0 to High(Local) do
    if Local[i] <> nil then
      Local[i].Destroy;
  inherited Destroy;
end;

constructor TLine.CreateName(SourceNode, NameNode, IdNode, ControlsNode: String);
begin
  inherited Create;
  if IdNode = '' then Exit;
  if SourceNode <> '' then
    Source := SourceNode;
  if NameNode <> '' then
    Name := Name + NameNode;
  Name := Name + IdNode;
  if ControlsNode <> '' then
    Name := Name + '$' + ControlsNode;
end;

constructor TLine.Create(LURI: string);
begin
  Script(LURI, True);
end;
                                                         //��������� �� Notepad
constructor TLine.Script(var LURI: String; FirstRun: Boolean = False);   //����� ������� ��� ����
var                                                              //����� ������� ��� ������������
  s, LS: string;
  Index, i, dx: Integer;
begin
  if length(LURI) = 0 then Exit;                               //����� ���� �����
  Name := '';

  Index := NextIndex(0, [' '], LURI);
  if Index <> MaxInt then
  begin
    LS := Copy(LURI, Index + 1, MaxInt);                     //������ Local
    Delete(LURI, Index, MaxInt);
  end;

  while Length(LS) > 0 do
  begin
    Index := NextIndex(0, [' '], LS);
    s := Copy(LS, 1, Index-1);
    SetLength(Local, High(Local)+2);                                //Local
    Local[High(Local)] := TLine.Script(s);
    Delete(LS, 1, Index);
  end;

  Index := NextIndex(0, ['?', ':', '=', '&', ';', '#', '|'], LURI);     //� ������� �����������


  if Index > 1 then
  begin
    Name := Copy(LURI, 1, Index - 1);    //Name
    Source := Copy(Name, 1, Pos('^', Name) - 1);                      //Source
    Delete(Name, 1, Pos('^', Name));
    if Length(Name) > 0 then
    begin
      ParentLocal := Copy(Name, 1, Pos('@', Name) - 1);               //ParentLocal
      Delete(Name, 1, Pos('@', Name)-1);
    end;
    Delete(LURI, 1, Index-1);
    if NextIndex(0, ['\', '/'], Name) <> MaxInt then               //��������� �� �������
    begin
      for i:=0 to Length(Name) do
        if Name[i] = '\' then
          Name[i] := '/';
      if not (Name[1] in ['\', '/']) then
        Name := '/' + Name;
      SetLength(Path, 1);
      Path[0] := Name;                                              //Path
    end;
    if Name[1] <> '!' then
    begin
      if Pos('$', Name) <> 0 then                                  //�������� � UpperCase
      begin
        S := UpperCase(Copy(Name, Pos('$', Name) + 1, MaxInt));
        Delete(Name, Pos('$', Name), MaxInt);
        while S <> '' do
        begin
          SetLength(Names, High(Names) + 2);                     //Names
          SetLength(Values, High(Values) + 2);                   //Values
          Names[High(Names)] := S[1];
          Delete(S, 1, 1);
          for i:=1 to Length(S) do
            if not (S[i] in ['0'..'9', ',', '.']) then
              Break;
          Values[High(Values)] := Copy(S, 1, i-1);
          Delete(S, 1, i-1);
        end;
      end;
    end
    else
    begin                                                          //?
      SetLength(Path, 1);
      Path[0] := Name;
    end;

    if Length(LURI) = 0 then Exit;                                //?
  end;
                                                  //�������� �� �� ������������ �������
  if LURI[1] = '|' then                             //��������� else � ������� �������
  begin
    Exit;
  end;

  if LURI[1] = ':' then                           //FType
  begin
    Delete(LURI, 1, 1);
    Index := NextIndex(0, ['?', ':', '=', '&', ';', '#'], LURI);

    if Index = MaxInt then                     //���� ����������� ��������
    begin
      FType := TLine.Script(LURI);
      Delete(LURI, 1, Length(LURI));
    end
    else
    if LURI[Index] = '=' then                  
    begin
      s := Copy(LURI, 1, Index-1);
      FType := TLine.Script(s);
      Delete(LURI, 1, Index);
      Value := TLine.Script(LURI);          //��������� ��������
    end
    else
    begin
      if Length(LURI) > 0 then                 //������ �������
        FType := TLine.Script(LURI);
    end;
    Exit;
  end;

  if LURI[1] = '=' then
  begin
    Delete(LURI, 1, 1);
    {Index := NextIndex(0, ['&', '#'], LURI);
    s := Copy(LURI, 1, Index-1);
    Delete(LURI, 1, Index-1);}
    Value := TLine.Script(LURI);
    Exit;
  end;

  if LURI[1] = ';' then
  begin
    Delete(LURI, 1, 1);
    Exit;
  end;


  if LURI[1] = '?' then
  begin
    Delete(LURI, 1, 1);
    repeat
      Index := NextIndex(0, ['?', ':', '=', '&', ';', '#'], LURI);

      if (Index = MaxInt) or (LURI[Index] = ';') then
      begin
        s := Copy(LURI, 1, Index-1);
        Delete(LURI, 1, Index);
        if Length(s) > 0 then
        begin
          SetLength(Params, High(Params)+2);
          Params[High(Params)] := TLine.Script(s);
        end
        else
          Break;
        Exit;
      end;

      if LURI[Index] in [':', '='] then
      begin
        SetLength(Params, High(Params)+2);
        Params[High(Params)] := TLine.Script(LURI);
        Continue;
      end;

      if LURI[Index] = '&' then
      begin
        s := Copy(LURI, 1, Index-1);
        Delete(LURI, 1, Index);
        if Length(s) > 0 then
        begin
          SetLength(Params, High(Params)+2);
          Params[High(Params)] := TLine.Script(s);
        end;
        Continue;
      end;

      if LURI[Index] = '#' then
      begin
        s := Copy(LURI, 1, Index-1);
        Delete(LURI, 1, Index-1);
        if Length(s) > 0 then
        begin
          SetLength(Params, High(Params)+2);
          Params[High(Params)] := TLine.Script(s);
        end;
        Break;
      end;

      if LURI[Index] = '?' then
      begin
        SetLength(Params, High(Params)+2);
        Params[High(Params)] := TLine.Script(LURI);
      end;

    until False;
  end;

  if (Length(LURI) > 0) and (LURI[1] = '#') and (FirstRun = True) then
  begin
    Delete(LURI, 1, 1);
    Value := TLine.Script(LURI);
  end;

  if (Length(LURI) > 0) and (LURI[1] = '|') then
  begin
    Delete(LURI, 1, 1);
    FElse := TLine.Script(LURI);
  end;

end;

















procedure FastParseMetaBaseLink(var Str: String);
// ��������������� ��� � ������ ���� ������ @
// ���� ��� ���� �� ������������ � ID
//������ ������ parent^name@id$controls?params#value|else
var
  i, Str_Length, Index_Parent, Index_ID, Index_Controls, Index_Params, Index_Value, Index_Felse: Integer;
  Parent, Name, ID, Controls, Params, Value, Felse: String;
  Chr: Char;
begin


  Index_Parent   := 0;
  //Index_ID       := 0;
  Index_Controls := 0;
  Index_Params   := 0;
  Index_Value    := 0;
  Index_Felse    := 0;

  //���������� �������� ������ ��������
  for i:=1 to Length(Str) do
  begin
    Chr := Str[i];
    if Chr = '@' then
      Index_ID := i
    else
      if Chr = '^' then     //������������������ ���� �� ����������� �������������
        Index_Parent := i
      else
        if Chr = '$' then
          Index_Controls := i
        else
          if Chr = '?' then
            Index_Params := i
          else
            if Chr = '#' then
              Index_Value := i
            else
              if Chr = '|' then
              begin
                Index_Felse := i;
                Break;
              end;
  end;


  //���������� ������� ������ � ����������
  //���������� ��� ��������� �������� �� ��������� �������������� ��������
  // ������ � ������  parent^name@
  if Index_Parent <> 0 then
  begin
    Parent := Copy(Str, 1, Index_Parent - 1);
    Name := Copy(Str, Index_Parent - 1, Index_ID - Index_Parent - 1);
  end
  else
  begin
    Name := Copy(Str, 1, Index_ID - 1);
  end;

  // ������ � �����  @id$controls?params#value|else
  //����� ����������� � ������ else ����� �������� ���������� ��� �� ���������� �������� ���

  if Index_Felse <> 0 then
  begin
    Felse := Copy(Str, Index_Felse + 1, MaxInt);
    if Index_Value <> 0 then
    begin
      Value := Copy(Str, Index_Value + 1, Index_Felse - Index_Value - 1);
      if Index_Params <> 0 then
      begin
        Params := Copy(Str, Index_Params + 1, Index_Value - Index_Params - 1);
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
          ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
        end;
      end
      else
      begin
        Params := '';
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, Index_Value - Index_Controls - 1);
          ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          ID := Copy(Str, Index_ID + 1, Index_Value - Index_ID - 1);
        end;
      end;
    end
    else
    begin
      Value := '';
      if Index_Params <> 0 then
      begin
        Params := Copy(Str, Index_Params + 1, Index_Felse - Index_Params - 1);
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
          ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
        end;
      end
      else
      begin
        Params := '';
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, Index_Felse - Index_Controls - 1);
          ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          ID := Copy(Str, Index_ID + 1, Index_Felse - Index_ID - 1);
        end;
      end;
    end;
  end
  else
  begin
    Felse := '';
    if Index_Value <> 0 then
    begin
      Value := Copy(Str, Index_Value + 1, MaxInt - Index_Value - 1);
      if Index_Params <> 0 then
      begin
        Params := Copy(Str, Index_Params + 1, Index_Value - Index_Params - 1);
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
          ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
        end;
      end
      else
      begin
        Params := '';
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, Index_Value - Index_Controls - 1);
          ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          ID := Copy(Str, Index_ID + 1, Index_Value - Index_ID - 1);
        end;
      end;
    end
    else
    begin
      Value := '';
      if Index_Params <> 0 then
      begin
        Params := Copy(Str, Index_Params + 1, MaxInt - Index_Params - 1);
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, Index_Params - Index_Controls - 1);
          ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          ID := Copy(Str, Index_ID + 1, Index_Params - Index_ID - 1);
        end;
      end
      else
      begin
        Params := '';
        if Index_Controls <> 0 then
        begin
          Controls := Copy(Str, Index_Controls + 1, MaxInt - Index_Controls - 1);
          ID := Copy(Str, Index_ID + 1, Index_Controls - Index_ID - 1);
        end
        else
        begin
          Controls := '';
          ID := Copy(Str, Index_ID + 1, MaxInt - Index_ID - 1);
        end;
      end;
    end;
  end;
end;

end.

