library MMath;

uses
  SysUtils, Classes, Dialogs;


function add(a, b: Integer): Integer; stdcall;
begin
  Result := a + b;
end;

function fadd(a, b: Double): Double; stdcall;
begin
  Result := a + b;
end;

function inc(a: Integer): Integer; stdcall;
begin
  Result := a + 1;
end;

function finc(a: Double): Double; stdcall;
begin
  Result := a + 1;
end;

function sub(a, b: Integer): Integer; stdcall;
begin
  Result := a - b;
end;

function fsub(a, b: Double): Double; stdcall;
begin
  Result := a - b;
end;

function mul(a, b: Integer): Integer; stdcall;
begin
  Result := a * b;
end;

function fmul(a, b: Double): Double; stdcall;
begin
  Result := a * b;
end;

function _div(a, b: Integer): Integer; stdcall;
begin
  Result := Round(a / b);
end;

function fdiv(a, b: Double): Double; stdcall;
begin
  Result := a / b;
end;

function sqr(a: Integer): Integer; stdcall;
begin
  Result := System.Sqr(a);
end;

function fsqr(a: Double): Double; stdcall;
begin
  Result := System.Sqr(a);
end;

function sqrt(a: Integer): Double; stdcall;
begin
  Result := System.Sqrt(a);
end;

function fsqrt(a: Double): Double; stdcall;
begin
  Result := System.Sqrt(a);
end;

function jmp: Integer; stdcall;
begin
  Result := 1;
end;

function jg(a, b: Integer): Integer; stdcall;
begin
  if a > b
  then Result := 1
  else Result := 0;
end;

function fjg(a, b: Double): Integer; stdcall;
begin
  if a > b
  then Result := 1
  else Result := 0;
end;

function jl(a, b: Integer): Integer; stdcall;
begin
  if a < b
  then Result := 1
  else Result := 0;
end;

function fjl(a, b: Double): Integer; stdcall;
begin
  if a < b
  then Result := 1
  else Result := 0;
end;

function je(a, b: Integer): Integer; stdcall;
begin
  if a = b
  then Result := 1
  else Result := 0;
end;

function fje(a, b: Double): Integer; stdcall;
begin
  if a = b
  then Result := 1
  else Result := 0;
end;

function stoi(s: PChar): Integer; stdcall;
begin
  Result := StrToInt(s);
end;

function stof(s: PChar): Double; stdcall;
begin
  Result := StrToFloat(s);
end;

function itos(a: Integer): PChar; stdcall;
begin
  Result := PChar(IntToStr(a));
end;

function ftos(a: Double): PChar; stdcall;
begin
  Result := PChar(FloatToStr(a));
end;

function round(a: Double): Integer; stdcall;
begin
  Result := System.Round(a);
end;

function abs(a: Integer): Integer; stdcall;
begin
  Result := System.Abs(a);
end;

function fabs(a: Double): Double; stdcall;
begin
  Result := System.Abs(a);
end;


exports
  add,
  fadd,
  inc,
  finc,
  sub,
  fsub,
  mul,
  fmul,
  _div,
  fdiv,
  sqr,
  fsqr,
  sqrt,
  fsqrt,
  jmp,
  jg,
  fjg,
  jl,
  fjl,
  je,
  fje,
  stoi,
  stof,
  itos,
  ftos,
  round,
  abs,
  fabs;

begin

end.
 