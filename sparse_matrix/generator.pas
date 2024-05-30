program killme;

{$mode objfpc}

uses sysutils, math;

const 
    WRONG_CHAR_FNAME = ['\', '/', ':', '*', '?', '"', '>', '<', '|', '+', '=', '[', ']', ';'];
    MAX_VAL = 1000000;
    SPACE_ST = '        ';

type 
    item = array of array[1..2] of integer;
    tmode = 1..6;

var 
    row_n, coln_n, mode: integer; 
    sparsity: double;
    file_name: string;
    format, do_print: 0..1;
    tfile: text;

function adm_fname(fname: string): boolean;
var i: integer;
begin
    for i := 1 to length(fname) do begin
        if fname[i] in WRONG_CHAR_FNAME then
            exit(false);
    end;
    exit(true);
end;

function check_arg(): boolean;
var {routes: text;} code: word;
begin
    if (paramCount() < 6) or (paramCount() > 7) then begin
        writeln('wrong number of parameters');
        exit(false);
    end
    else if (strtoint(paramStr(1)) <= 0) or (strtoint(paramStr(2)) <= 0) then begin
        writeln('wrong size of matrix');
        exit(false);
    end
    else if (strtofloat(paramStr(3)) <= 0) or (strtofloat(paramStr(3)) > 1) then begin
        writeln('wrong sparsity');
        exit(false);
    end
    else if (strtoint(paramStr(4)) < 1) or (strtoint(paramStr(4)) > 3) then begin
        writeln('mode can be only 1, 2 or 3');
        exit(false);
    end
    else if not adm_fname(paramStr(5)) then begin
        writeln('wrong file name');
        exit(false);
    end
    else if (strtoint(paramStr(6)) < 0) or (strtoint(paramStr(6)) > 1) then begin
        writeln('0 - sparse matrix, 1 - full matrix');
        exit(false);
    end
    else if (paramCount() = 7) and ((strtoint(paramStr(7)) < 0) or (strtoint(paramStr(7)) > 1)) then begin
        writeln('0 - not print matrix, 1 - print matrix');
        exit(false);
    end;
    val(paramStr(1), row_n, code);
    val(paramStr(2), coln_n, code);
    val(paramStr(3), sparsity, code);
   { val(paramStr(3), mode, code);
    val(paramStr(5), format, code);
    if paramCount() = 7 then val(paramStr(6), do_print, code);}
    check_arg := true;
end;

function in_arr(i, j, len: integer; arr: item): boolean;
var k: integer;
begin
    for k := 0 to len - 1 do begin
        if (arr[k, 1] = i) and (arr[k, 2] = j) then
            exit(true);
    end;
    in_arr := false;
end;

procedure generate_m(mode: tmode);
var 
    num_1, i, j, ri, rj: integer; 
    used_item: item;
begin
    num_1 := round(sparsity * row_n * coln_n);
    if ((mode = 3) or (mode = 6)) and (num_1 > min(row_n, coln_n)) then num_1 := min(row_n, coln_n);
    if num_1 = 0 then num_1 := 1;
    setLength(used_item, num_1);
    randomize();
    for i := 0 to num_1 - 1 do begin
        repeat
            ri := random(row_n) + 1;
            if (mode = 3) or (mode = 6) then rj := ri
            else rj := random(coln_n) + 1;
        until not in_arr(ri, rj, i, used_item);
        used_item[i, 1] := ri;
        used_item[i, 2] := rj;
        if mode = 2 then writeln(tfile, ri, SPACE_ST, rj, SPACE_ST, (random(MAX_VAL) - MAX_VAL/2 + random()):10:5)
        else if mode < 4 then writeln(tfile, ri, SPACE_ST, rj, '    1');
    end;
    if mode > 3 then begin
        for i := 1 to row_n do begin
            for j := 1 to coln_n do begin
                if in_arr(i, j, length(used_item), used_item) then begin
                    if mode = 5 then
                        write(tfile, (random(MAX_VAL) - MAX_VAL/2 + random()):10:5)
                    else 
                        write(tfile, 1);
                end
                else 
                    write(tfile, 0.0:1:1);
                write(tfile, SPACE_ST);
            end;
            writeln(tfile);
        end;
    end;
end;

{rocedure print_m(tfile: text);
var c: char;
begin
    reset(tfile);
    while not eof() do begin
        read(tfile, c);
        if (not eoln(tfile)) and then
        while not eoln(tfile) do begin
            readln(f,s); writeln(s);
        end;
    end;
    close(f);
end;}

begin
    if check_arg then begin
        if paramStr(6) = '0' then assign(tfile, paramStr(5) + '.smtr')
        else assign(tfile, paramStr(5) + '.dmtr');
        rewrite(tfile);
        if paramStr(6) = '0' then writeln(tfile, 'sparse_matrix ', row_n, ' ', coln_n)
        else writeln(tfile, 'dence_matrix ', row_n, ' ', coln_n);
        writeln(tfile);
        generate_m(strtoint(paramStr(6)) * 3 + strtoint(paramStr(4)));   
        close(tfile);
    end
    else 
        writeln('argument pattern: row_n, coln_n : int; sparsity : double; mode: int; file_name: string; format, print?: [0...1]');
end.