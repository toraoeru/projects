program bulletinmyhead;

{$mode objfpc}
Uses Index, RegExpr, Utils_, sysutils;

const PATTERN_EL = '\s*[+-]?([0-9]*[.])?[0-9]+'; //?????????

function replace_occur(str, pattern, rep_str: string; num: integer): string;
var i, j: integer; res: string; c: char;
begin
    j := 1; res := ''; i := 1; c := 'b';
    //re := TRegExpr.Create(pattern); substr := '';
    //(str[i] = ' ') or in_str(c, '1234567890') or 
    while ((j <> num)) and (i <= length(str)) do begin
        //writeln(str[i], '! ', in_str(str[i], '1234567890'), ' -', c = ' ', '- ', j);
        if in_str(str[i], '1234567890') and (c = ' ') then begin
            inc(j);
            if j <> num then res := res + str[i];
        end
        else res := res + str[i];
        c := str[i];
        inc(i);
    end;
    //write(j, slice(str, 1, i));
    res := res + rep_str + SPACE_ST;
    //re := TRegExpr.Create('\s[+-]?([0-9]*[.])?[0-9]+\s');
    while (not (in_str(str[i], '1234567890') and (c = ' '))) and (i <= length(str)) do begin
        c := str[i];
        inc(i);
    end;
    res := res + slice(str, i, length(str));
    replace_occur := res;//////////
end;


var 
    ttemp, mtr_tr: tr_ptr; r_n, c_n, des_num, i, j, node_num, qqq: integer; val_n: doubLe;
    matrix,f, fi, ind_f: text; str, pattern_str, lab_pat, str_lab: string; 
    re: TRegExpr; flag: boolean;

begin
    if paramCount() <> 4 then 
        writeln('wrong number of arguments')
    else begin
        assign(f, 'temp.tr');
        {$I-} assign(matrix, paramStr(1));
        reset(matrix); {$I+}
        
        if IOresult = 0 then begin
            r_n := strtoint(paramStr(2));
            c_n := strtoint(paramStr(3));
            val_n := strtofloat(paramStr(4));
            
            i := 0;
            if slice(paramStr(1), length(paramStr(1)) - 3, length(paramStr(1))) = 'smtr' then begin
                //writeln('in smtr');
                mtr_tr := nil;
                create_index(matrix, f, mtr_tr, false); //нужно добавить флаг вывода
                //writeln('am i alive&');
                if find(mtr_tr, r_n, c_n) then begin
                    //writeln('in in found edge');
                    rewrite(f);
                    re := TRegExpr.Create('\s*' + inttostr(r_n) + '\s+' + inttostr(c_n) + '\s+');
                    reset(matrix);
                    while not eof(matrix) do begin
                        //i := i + 1;
                        //writeln('FFFFFFFFff');
                        readln(matrix, str);
                        if re.Exec(str) then  
                            writeln(f, r_n, SPACE_ST, c_n, SPACE_ST, val_n:10:5)
                        else writeln(f, str);
                    end;
                    close(matrix);
                    //writeln('am i alive&');
                    close(f); 
                    //writeln('am i alive&');
                    erase(matrix);
                    //writeln('am i alive&');
                    rename(f, paramStr(1));
                    //writeln('am i alive&');
                    matrix := f;
                    
                end
                else begin
                    //writeln('in not found');
                    append(matrix);
                    writeln(matrix, r_n, SPACE_ST, c_n, SPACE_ST, val_n:10:5);
                    close(matrix);/////
                end
            end
            else begin
                //writeln('in dmtr');
                //pattern_str := PATTERN_EL;
                //for i := 2 to c_n do
                //    pattern_str := pattern_str + PATTERN_EL;
                i := 0;
                re := TRegExpr.Create(PATTERN_EL);
                rewrite(f); flag := true;
                while not eof(matrix) do begin
                    readln(matrix, str);
                    //writeln(i,' ', r_n);
                    if re.Exec(str) and (pos('#', str) = 0) and (pos('matrix', str) = 0) then inc(i);
                    //writeln(i,' ', r_n);
                    if (i = r_n) and flag then begin//////////
                        flag := false;
                        writeln(f, replace_occur(str, PATTERN_EL, floattostr(val_n), c_n));
                        //write('kljfhlskjd');
                    end
                    else 
                        writeln(f, str);
                end;
                close(matrix);
                close(f); 
                erase(matrix);
                rename(f, paramStr(1));
                matrix := f;
            end;

            assign(fi, 'temp.tr');
            {$I-} assign(ind_f, slice(paramStr(1), 1, length(paramStr(1)) - 4) + 'dot');
            reset(ind_f); {$I+}
            
            if IOresult = 0 then begin
                //writeln('in dot find');
                //fuckkkkkkkkkkkkkkkkkkkkkkkkkkkkfhojdkedassncsvcbhjtxdgr']AQGT5SHFV.":
                if find(mtr_tr, r_n, c_n) then begin
                    //writeln('in edge find');
                    //lab_pat := '[label="' + inttostr(r_n) + '\s+' + inttostr(c_n);
                    rewrite(fi); 
                    re := TRegExpr.Create('label="' + inttostr(r_n) + '\s+' + inttostr(c_n));
                    while not eof(ind_f) do begin
                        readln(ind_f, str);
                        if re.Exec(str) then writeln(fi, slice(str, 1, pos('[', str)), 'label="', r_n, '  ', c_n, '\n    ', val_n:5:5, '"];')
                        else if pos('}', str) = 0 then writeln(fi, str);
                    end;
                    write(fi, '}');
                end
                else begin
                    //writeln('in edge not found');
                    i := 0; str_lab := '';
                    while (not eof(ind_f)) and (pos('//edges', str) = 0) do begin
                        readln(ind_f, str);
                        inc(i);
                        //writeln(str, pos('label', str));
                        if pos('label', str) <> 0 then qqq := i;
                    end;
                    reset(ind_f);
                    rewrite(fi); 
                    writeln('    ',qqq);
                    for j := 1 to qqq do begin/////////
                        readln(ind_f, str);
                        writeln(fi, str);
                        //writeln(str);
                    end;
                    node_num := sti_ign(slice(str, 1, pos('[', str) - 1)) + 1;
                    //(slice(str, 1, pos('[', str)));
                    writeln(fi, #9, node_num, ' [label="', r_n, '  ', c_n, '\n    ', val_n:5:5, '"];');
                    add(mtr_tr,  node_num, r_n, c_n, val_n);
                    ttemp := return_parent(mtr_tr, r_n, c_n);
                    if (ttemp^.left = nil) or (ttemp^.right = nil) then begin
                        //writeln('in 1 child');
                        while not eof(ind_f) do begin
                            readln(ind_f, str);
                            writeln(fi, str);
                        end;
                        if (ttemp^.left = nil) then writeln(fi,  #9, ttemp^.node_number, '  ->  ', node_num, '  [label="R"];')
                        else writeln(fi,  #9, ttemp^.node_number, '  ->  ', node_num, '  [label="L"];');
                    end
                    else begin
                        //writeln('in 2 child');
                        while not eof(ind_f) do begin
                            readln(ind_f, str);
                            if pos(inttostr(ttemp^.node_number) + '  ->  ', str) <> 0 then begin
                                write(fi, str);
                                if pos('R', str) <> 0 then writeln(fi,  #9, ttemp^.node_number, '  ->  ', node_num, '  [label="L"];')
                                else writeln(fi,  #9, ttemp^.node_number, '  ->  ', node_num, '  [label="R"];'); 
                            end
                            else writeln(fi, str);
                        end;
                    end;
                end;
                close(fi); 
                close(ind_f);
                erase(ind_f);
                rename(fi, slice(paramStr(1), 1, length(paramStr(1)) - 4) + 'dot');
                ind_f := fi;
            end
            else begin
                //writeln('dot not exist');
                reset(matrix);
                rewrite(ind_f);
                writeln(ind_f, 'digraph', #13#10, '{');
                create_index(matrix, ind_f, mtr_tr, true);
                writeln(ind_f, #13#10, #9, '//edges', #10#13);
                pr_edges(mtr_tr, ind_f);
                write(ind_f, #13#10, '}');
                close(ind_f);
                close(matrix);
            end;
        end    
        else 
            writeln('there is no such file');
    end;
end.
//добавить вывод в 1 и 3
//а что с большими строками столбцами
//знаки в шаблоне и смтр