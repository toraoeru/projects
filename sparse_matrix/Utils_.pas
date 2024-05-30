unit Utils_;
Interface
Uses sysutils;
const SPACE_ST = '        ';
function slice(str: string; a, b: integer): string;
function in_str(ch: char; str: string): boolean;
function sti_ign(str: string): integer;

Implementation

function sti_ign(str: string): integer;
var i, res: integer;
begin
    res := 0;
    for i := 1 to length(str) do begin
        if (str[i] <= '9') and (str[i] >= '0') then 
            res := res*10 + strtoint(str[i]);
    end;
    sti_ign := res;
end;

function slice(str: string; a, b: integer): string;
var res: string;
begin
    res := '';
    while a <= b do begin
        res := res + str[a];
        a := a + 1;
    end;
    slice := res;
end;

function in_str(ch: char; str: string): boolean;
var i: integer;
begin
    in_str := false;
    for i := 1 to length(str) do begin
        if ch = str[i] then in_str := true;
    end;
end;
end.