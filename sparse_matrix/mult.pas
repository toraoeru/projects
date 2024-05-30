program letmedie;

{$mode objfpc}
Uses Utils_, sysutils;
//структура данных для csr
const
    SELF_RESPECT = 0.00001;
type
    arri = array of integer;
    arrd = array of double;

    mtr_crs = record
        pointr: arri;
        cols: arri;
        values: arrd;
    end;

    arr3dob =  array[1..3] of double;

    crs_help = array of arr3dob;

    readin_nums_st = (new_line_exp, num_exp, int_part, frac_part, eoln_exp);

function get_count(m: crs_help; n: integer):integer;
var res, i: integer;
begin
    res := 0;
    for i := 0 to length(m) - 1 do begin
        if abs(m[i,1] - n) < SELF_RESPECT then
            inc(res);
    end;
    get_count := res;
end;

function to_crs(m: crs_help; r:integer): mtr_crs;
var res: mtr_crs; i: integer;
begin
    setlength(res.pointr, r);
    setlength(res.cols, length(m));
    setlength(res.values, length(m));
    for i := 0 to length(m) - 1 do begin
        res.cols[i] := trunc(m[i, 2]);
        res.values[i] := m[i, 3];
    end;
    res.pointr[0] := 0;
    for i := 1 to r - 1 do 
        res.pointr[i] := res.pointr[i -1] + get_count(m, i);
    to_crs := res;
end;

function mult_vec(c1, c2: arri; v1,v2: arrd): double;
var i1, i2: integer; summ: double;
begin
    summ := 0; i1 := 0; i2 := 0;
    while (i1 < length(c1)) and (i2 < length(c2)) do begin
        if (c1[i1] = c2[i2]) and (v1[i1]*v2[i2] > StrToFloat(paramStr(1))) then begin
            summ := summ + v1[i1]*v2[i2];
            inc(i1); inc(i2);
        end
        else begin
            if c1[i1] > c2[i2] then inc(i2)
            else inc(i1);
        end;
    end;
    mult_vec := summ;
end;

procedure get_size(var f: text; var x: integer; var y: integer);
var str: string; i: integer;
begin
    str := '';
    while (not eof(f)) and (pos('_matrix', str) = 0) do
        readln(f, str);
    i := 1;
    while (i <= length(str)) and ((str[i] > '9') or (str[i] < '0')) do 
        inc(i);
    x := strtoint(str[i]);
    inc(i);
    while (i <= length(str)) and (str[i] <= '9') and (str[i] >= '0') do begin
        x := x*10 + strtoint(str[i]);
        inc(i);
    end;
    while (i <= length(str)) and ((str[i] > '9') or (str[i] < '0')) do 
        inc(i);
    y := strtoint(str[i]);
    inc(i);
    while (i <= length(str)) and (str[i] <= '9') and (str[i] >= '0') do begin
        y := y*10 + strtoint(str[i]);
    end;
end;
//непр на мнов
//касат плоско
//диф второго порядка в точке

procedure sort(var crs: crs_help);
var i, j: integer; k: double;
begin
    for i := 0 to length(crs) - 1 do begin
        for j := 0 to length(crs) - i - 2 do begin
            if crs[j, 1] > crs[j + 1, 1] then begin
                k := crs[j, 1];
                crs[j, 1] := crs[j + 1, 1];
                crs[j + 1, 1]:=k;

                k := crs[j, 2];
                crs[j, 2] := crs[j + 1, 2];
                crs[j + 1, 2]:=k;

                k := crs[j, 3];
                crs[j, 3] := crs[j + 1, 3];
                crs[j + 1, 3]:=k;
            end
            else if (crs[j, 1] = crs[j + 1, 1]) and (crs[j,2] > crs[j + 1, 2]) then begin
                k := crs[j,2];
                crs[j, 2] := crs[j + 1, 2];
                crs[j + 1, 2]:= k;

                k := crs[j,3];
                crs[j,3] := crs[j + 1,3];
                crs[j + 1, 3]:=k;
            end
        end;
    end;
end;


function eq_ar(a1,a2: arr3dob): boolean;
var j, conc: integer;
begin
    conc := 0;
    for j := 1 to length(a1) do begin
        if a1[j] = a2[j] then inc(conc);
    end;
    if conc = length(a1) then eq_ar := true
    else eq_ar := false;
end;

function el_exist(m: crs_help; a: arr3dob): boolean;
var res:boolean; i: integer;
begin
    res := false;
    for i := 0 to length(m) - 1 do begin
        if eq_ar(m[i], a) then res:= true;
    end;
    el_exist := res;
end;

function slicei(ar: arri; a,b:integer): arri;
var res: arri; i: integer;
begin
    setlength(res, length(ar));
    for i := a to b do
        res[i-a] := ar[i];
    slicei := res;
end;

function sliced(ar: arrd; a,b:integer): arrd;
var res: arrd; i: integer;
begin
    setlength(res, length(ar));
    for i := a to b do
        res[i-a] := ar[i];
    sliced := res;
end;

function mult(m1, m2: mtr_crs; x,y: integer): mtr_crs;
var i1, i2, i,j, count: integer; res: crs_help; prev: double;
c1, c2: arri; v1, v2: arrd;
begin
    setlength(res, x*y); i1 := 0; count := 0;
    for i := 1 to x do begin
        c1 := slicei(m1.cols, i1, i1+m1.pointr[i]-m1.pointr[i-1] - 1);
        v1 := sliced(m1.values, i1, i1+m1.pointr[i]-m1.pointr[i-1] - 1);
        i2 := 0;
        for j := 1 to y do begin
            c2 := slicei(m2.cols, i2, i2+m2.pointr[j]-m2.pointr[j-1] - 1);
            v2 := sliced(m2.values, i2, i2+m2.pointr[j]-m2.pointr[j-1] - 1);
            prev := mult_vec(c1, c2, v1, v2);
            if prev > StrToFloat(paramStr(1)) then begin
                res[count, 1] := i;
                res[count, 2] := j;
                res[count, 3] := prev;
                inc(count);
            end;
            i2 := i2+m2.pointr[j]-m2.pointr[j-1];
        end;
        i1 := i1+m1.pointr[i]-m1.pointr[i-1];
    end;

    setlength(res, count);

    {for i := 0 to length(res) - 1 do begin
        for j:=1 to 3 do
            write(res[i,j]:1,' ');
        writeln();
    end;}
    mult := to_crs(res, x+1);
    
end;

function build_crs(var matrix: text; is_tr, is_smtr: boolean; row_n, coln_n: integer): mtr_crs;
var num_readin_st: readin_nums_st;
    i, j, row, col, step, str_num, cur_col, sign, count: integer;
    c: char; is_error, is_root: boolean; form_name: string;
    val, fr_p: double; killme: crs_help;

    procedure break_line();//for smtr
    begin
        str_num := str_num + 1; 
        if abs(val) > StrToFloat(paramStr(1)) then begin
            if is_tr then begin 
                killme[count, 2] := row;
                killme[count, 1] := col;
            end
            else begin 
                killme[count, 1] := row;
                killme[count, 2] := col;
            end;
            killme[count, 3] := val*sign;
            //writeln(killme[count, 1], ' ', killme[count, 2], ' ', killme[count, 3]);
            inc(count);
        end;
        /////////////////////////////////////////
        //add(tr_matrix, str_num, row, col, val);
        //if print_file then writeln(indx, #9, str_num, ' [label="', row, '  ', col,'\n', sign*val:10:5, '"];');
        step := 0; row := 0; col := 0; val := 0; sign := 1;
        num_readin_st := new_line_exp; fr_p := 0;
        readln(matrix); //res: mtr_crs; //inc(count);
    end;

    procedure next_num();
    begin
        if abs(val) > StrToFloat(paramStr(1)) then begin
            killme[count, 1]  := str_num;
            killme[count, 2]  := cur_col;
            killme[count, 3]  := val*sign;
             inc(count);
        end;
        //writeln(killme[count, 1], ' ', killme[count, 2], ' ', killme[count, 3]);
        cur_col := cur_col + 1;
        //res.value[(str_num - 1)*row_n + cur_col - 1] := val*sign;
        val := 0;  fr_p := 0; sign := 1; fr_p := 0; 
        if coln_n <> cur_col then num_readin_st := num_exp;
    end;

    procedure bl_den();
    begin
        str_num := str_num + 1; cur_col := 0;
        num_readin_st := new_line_exp; 
        readln(matrix);
    end;
begin
    sign := 1; 
    num_readin_st := new_line_exp;
    str_num := 0;
    is_error := false; val := 0; fr_p := 0;
    i := 2; val := 0; cur_col := 0; step := 0;
    row := 0; col := 0;
    setlength(killme, row_n*coln_n);
    //setlength(killme, row_n*coln_n);
    if not is_smtr then begin
        {for i := 1 to coln_n do begin
            setlength(killme[i - 1][1], coln_n);
            setlength(killme[i - 1][2], coln_n);
        end;}
        //writeln( eof(matrix), is_error, 'wtf ure here');
        while (not eof(matrix)) and (not is_error) and (str_num <= row_n) do begin
            writeln('im here');
            case num_readin_st of 
                new_line_exp:
                    begin
                        if eoln(matrix) then readln(matrix)
                        else num_readin_st := num_exp;
                    end;
                num_exp:
                    begin
                        read(matrix, c);
                        if in_str(c, '1234567890') then begin
                            num_readin_st := int_part;
                            val := strtoint(c);
                        end
                        else if c = '-' then begin
                            sign := -1;
                            num_readin_st := int_part;
                        end
                        else if c <> ' ' then
                            is_error := true;  
                    end;
                int_part:
                    begin
                        if not eoln(matrix) then begin
                            if cur_col = (coln_n) then bl_den()
                            else begin
                                read(matrix, c);
                                if in_str(c, '1234567890') then 
                                    val := val*10 + strtoint(c)
                                else if c = '.' then num_readin_st := frac_part
                                else if (c = ' ') then next_num()
                                else is_error := true;
                            end;
                        end
                        else if cur_col = coln_n  then bl_den()
                        else is_error := true;
                    end;
                frac_part: 
                    begin
                        if not eoln(matrix) then begin
                            if cur_col = (coln_n ) then bl_den()
                            else begin
                                read(matrix, c);
                                if in_str(c, '1234567890') then 
                                    fr_p := fr_p*10 + strtoint(c)
                                else if c = ' ' then begin
                                    if fr_p > SELF_RESPECT then
                                        val := val + fr_p/ exp(ln(10) * (trunc(ln(fr_p)/ln(10)) + 1));
                                    next_num();
                                end                                                
                                else is_error := true;
                            end;
                        end
                        else if cur_col = (coln_n  - 1) then begin 
                            if fr_p > SELF_RESPECT then begin
                                //writeln('2fjksdfsd');
                                val := val + fr_p/ exp(ln(10) * (trunc(ln(fr_p)/ln(10)) + 1));
                            end;
                            next_num();
                            bl_den();
                        end
                        else if cur_col = (coln_n ) then bl_den()
                        else is_error := true;
                    end;
            end;
        end;
        //setlength(killme,count);
        {res.pointr[0] := 0;
        for i:= 1 to length(res.pointr) - 1 do 
            res.pointr[i] := coln_n;
        for i:= 0 to length(res.cols) - 1 do 
            res.pointr[i] := i mod row_n + 1;}
    end
    else begin
        count := 0;
        setlength(killme, row_n*coln_n);
        //writeln( (not eof(matrix)) and (not is_error) );
        while (not eof(matrix)) and (not is_error)do begin
            //writeln(row,' ', col,' ', val:10:1,' ', str_num, ' ', num_readin_st, '   ', step);
            case num_readin_st of 
                new_line_exp:
                    begin
                        if eoln(matrix) then readln(matrix)
                        else num_readin_st := num_exp;
                    end;
                num_exp:
                    begin
                        read(matrix, c);
                        if in_str(c, '1234567890') then begin
                            num_readin_st := int_part;
                            step := step + 1;
                            if row = 0 then row := strtoint(c)
                            else if col = 0 then col := strtoint(c)
                            else val := strtoint(c);
                        end
                        else if c = '-' then begin
                            sign := -1;
                            num_readin_st := int_part;
                        end
                        else if c <> ' ' then begin is_error := true;  end;
                    end;
                int_part:
                    begin
                        //writeln(row, col, val, str_num);
                        if not eoln(matrix) then begin
                            read(matrix, c);
                            //write('!!!',c,'!!!!', step);
                            if in_str(c, '1234567890') then begin
                                if step = 1 then row := row*10 + strtoint(c)
                                else if step = 2 then col := col*10 + strtoint(c)
                                else val := val*10 + strtoint(c);
                            end
                            else if (c = '.') and (step = 3) then num_readin_st := frac_part
                            else if (c = ' ') and (step = 3) then break_line()
                            else if c = ' ' then num_readin_st := num_exp
                            else is_error := true;
                        end
                        else if step = 3 then break_line()
                        else is_error := true;
                    end;
                frac_part: 
                    begin
                        //writeln(row, col, val, str_num);
                        if not eoln(matrix) then begin
                            read(matrix, c);
                            if in_str(c, '1234567890') then 
                                fr_p := fr_p + strtoint(c)
                            else if (c = '#') or (c = ' ') then begin
                                if fr_p > SELF_RESPECT then
                                begin
                                    //writeln('3fjksdfsd');
                                    val := val + fr_p/ exp(ln(10) * (trunc(ln(fr_p)/ln(10)) + 1));
                                end;
                                break_line();
                            end                                                
                            else is_error := true;
                        end
                        else begin
                            if fr_p > SELF_RESPECT then
                            begin
                                //writeln('4fjksdfsd');
                                val := val + fr_p/ exp(ln(10) * (trunc(ln(fr_p)/ln(10)) + 1));
                            end;
                            break_line();
                        end;
                    end;
            end;
        end;


    end;
    setlength(killme, count);
   { 
    write(count,'           ');
    for i := 0 to length(killme) -1 do begin
        for j:=1 to 3 do
            write(killme[i,j]:1,' ');
        writeln();
    end;}

    sort(killme);
    build_crs := to_crs(killme, row_n + 1);
    {writeln('AFTER');
    for i := 0 to length(killme) -1 do begin
        for j:=1 to 3 do
            write(killme[i,j]:1,'  ');
        writeln();
    end;}
    //build_crs := res;
end;

function get_col(p: arri; n: integer): integer;
var i: integer;
begin
    for i := 1 to length(p) - 1 do begin
        if n <= p[i] then exit(i);
    end;
end;

var 
    m1, m2, f: text; str, files: string; 
    mr1, mr2: mtr_crs;
    x1, x2, y1, y2, i, j, c: integer;
begin
    {если найдется рахреженная - результат разреженная
    првоерить размеры
    от трех аргкментов}
    if paramCount() < 5 then
        writeln('wrong num of args')
    //генерим сирэс для первых двух перемножаем, получаем сирэс, строим срс для след перемножаем и тд...
    else begin
        assign(m1, paramStr(4));
        reset(m1); {$I+} 
        if IOresult = 0 then begin
       //function build_crs(var matrix: text; is_tr, is_smtr: boolean; row_n, coln_n: integer): mtr_crs;
            get_size(m1, x1, y1);
            mr1 := build_crs(m1, false, not(pos('smtr',  paramStr(4)) = 0), x1, y1);    
            
            //writeln('re y ok');       
        end
        else 
            writeln('file not found');
        for i := 5 to paramCount() do begin
       // writeln('well');
            //проверяем размеры трансопнируем перемножаем в кур
            {$I-} assign(m2, paramStr(i));
            reset(m2); {$I+}
            if IOresult <> 0 then begin
                writeln('file not found');
                break;
            end
            else begin
                get_size(m2, x2, y2);
                if y1 <> x2 then 
                    writeln('wrong size in ', i)
                else begin
                    mr2 := build_crs(m2, true,not(pos('smtr',  paramStr(i)) = 0), y2, x2);
                    mr1 := mult(mr1, mr2, x1, y2);
                end;
            end;
            y1 := y2;
            
        end;
        close(m1);
        close(m2);

        if paramStr(2) = 'smtr' then begin
            assign(f, paramStr(3) +'.smtr');
            rewrite(f);
            writeln(f, 'sparse_matrix ', x1, ' ', y2);
            writeln(f);
            for i := 0 to length(mr1.cols)  do 
                writeln(f, get_col(mr1.pointr, i+1),SPACE_ST, mr1.cols[i], SPACE_ST, mr1.values[i]:10:5);
        end
        else begin
            assign(f, paramStr(3) +'.dmtr');
            rewrite(f);
            writeln(f, 'dence_matrix ', x1, ' ', y2);
            writeln(f); c := 0;
            for i := 0 to x1 -1  do begin
                for j := 0 to y1 -1  do begin
                    if (i = get_col(mr1.pointr, c+1)) and (j = mr1.cols[c]) then begin
                        write(f, mr1.values[c]:10:5, ' ');
                        inc(c);
                    end
                    else
                        write(f, 0);
                end;
                writeln(f);
            end;
        end;

    end;
end.