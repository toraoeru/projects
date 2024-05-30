program calc;

{$mode objfpc}{$H+}

Uses 
    sysutils, 
    {$IFDEF UNIX}{$IFDEF UseCThreads}
    cthreads,ё  
    {$ENDIF}{$ENDIF}
    Classes, 
    math;    

const
    FNAME = 'input.txt'; 
    ALPH = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*';

function slice_str(str: string; sti, endi: integer): string;
var res: string; i: integer;
begin
    res := '';
    for i := sti to endi do begin
        res := res + str[i];
    end;
    exit(res);
end;

function to10_notation(numer: string; base: integer): real;
var tnumer: real; i, sign: integer;
begin
    sign := 1;
    if numer[1] = '-' then begin
        sign := -1; 
        delete(numer, 1, 1);
    end;
    tnumer := 0;
    for i := 1 to length(numer) do begin
        tnumer := tnumer + exp(ln(base) * (length(numer) - i))*(pos(numer[i], ALPH) - 1);
    end;
    exit(sign * tnumer);
end;

function changef10_notation(num: real; base: integer): string;
var resI, resF, sign: string; n, dnumer, precision: real; i, numer: integer;
begin
    precision := 0.1; sign := '';
    if paramCount() <> 0 then 
        precision := StrToFloat(paramStr(1));

    if num < 0 then begin
        sign := '-'; 
        num := -1 * num;
    end; 
   
    resI := ''; resF := '.'; i := 0;
    numer := trunc(num); dnumer := frac(num);
    repeat
        n := dnumer * base;
        dnumer := frac(n);
        resF := resF + ALPH[trunc(n) + 1];
        {writeln('-', n:1:1, '-', dnumer:1:1,'-', resF, '-');}
        i := i + 1;
    until abs((to10_notation(slice_str(resF, 2, length(resF)), base) / (base**(i))) - frac(num)) > precision;
   
    while numer <> 0 do begin
        resI := ALPH[numer mod base + 1] + resI;
        numer := numer div base;
    end;
    if resI = '' then resI := '0';
    exit(sign + resI + resF);
end;


function parser(): real;
var i, j, sign: integer; infile: textfile; str, nsys, numer, dnumer: string; res: real;
begin
	assignfile(infile, FNAME);
    reset(infile);
    res := 0; str := '';
    while ((not eof(infile)) and (pos('finish', str) = 0)) do begin
        readln(infile, str);
        if (str <> '') and (pos('finish', str) = 0) then begin
            j := 0;
            for i := 1 to length(str) do begin
                if str[i] <> ' ' then begin
                    j := j + 1;
                    if j < i then str[j] := str[i];
                end;
            end;
            SetLength(str, j);
            delete(str, pos(';', str), length(str) - pos(';', str) + 1);

            nsys := slice_str(str, 2, pos(':', str) - 1); 
            numer := slice_str(str, pos(':', str) + 1, pos('/', str) - 1); 
            dnumer := slice_str(str, pos('/', str) + 1, length(str)); 

            case str[1] of
                '+': res := res + to10_notation(numer, StrToInt(nsys)) / to10_notation(dnumer, StrToInt(nsys));
                '-': res := res - to10_notation(numer, StrToInt(nsys)) / to10_notation(dnumer, StrToInt(nsys));
                '*': res := res * to10_notation(numer, StrToInt(nsys)) / to10_notation(dnumer, StrToInt(nsys));
                '/': res := res / to10_notation(numer, StrToInt(nsys)) / to10_notation(dnumer, StrToInt(nsys));
            end;
        end;
    end;
    close(infile);
    exit(res);
end;


var 
    result: real; i: integer;
    {num_bases: array of integer;}

begin
    result := parser();
    {setLength(num_bases, paramCount());}
	for i := 2 to paramCount() do begin
        {num_bases[i] := StrToInt(paramStr(i));}
        writeln(paramStr(i), ' ', changef10_notation(result, StrToInt(paramStr(i))));
	end;
end.