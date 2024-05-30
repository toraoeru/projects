program ihatemylife;

{$mode objfpc}
Uses 
    sysutils;

const 
    SP_FLAG = 'sparse_matrix';
    DEN_FLAG = 'dence_matrix';

type
    tr_ptr= ^tree_node;

    tree_node = record
        node_number: longword;
        row, column: longword;
        element: double;
        left, right: ^ tree_node;
    end;

    states = (form_exp, form_ent, size_exp, row_ent, coln_ent, sp_cont, den_cont);
    readin_nums_st = (new_line_exp, num_exp, int_part, frac_part, eoln_exp);

var 
    matrix, indx: text; tr_matrix: tr_ptr;



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

procedure edit_index();
begin
end;

function compare_indx(x1, y1, x2, y2: integer): boolean;
begin
    if x2 > x1 then compare_indx := true
    else if x1 > x2 then compare_indx := false
    else begin
        if y2 > y1 then compare_indx := true
        else compare_indx := false;
    end;
end;

procedure add(var tree: tr_ptr; node_num, row, col: longword; el: double);
begin
    if tree = nil then begin 
        //writeln('0###');
	    new(tree);
        //writeln('1###');
        tree^.node_number := node_num;
        //writeln('2###');
        tree^.row := row;
        //writeln('3###');
        tree^.column := col;
        //writeln('4###');
        tree^.element := el;
        //writeln('5###');
        tree^.left := nil;
        //writeln('6###');
        tree^.right := nil;
	end
    else if compare_indx(row, col, tree^.row, tree^.column) then 
        add(tree^.left, node_num, row, col, el)
	else add(tree^.right, node_num, row, col, el);
end;

procedure create_index();
var 
    format, state: states; row_n, coln_n, i, row, col, step, str_num: integer;
    c: char; is_error, is_root: boolean; form_name: string;
    num_readin_st: readin_nums_st; val, fr_p: double; 
    procedure break_line();
    begin
        //write('1111111');
        str_num := str_num + 1;
        {if not is_root then begin
            new(tr_matrix);
            tr_matrix^.node_number := 1;
            tr_matrix^.row := row;
            tr_matrix^.column := col;
            tr_matrix^.element := val;
            tr_matrix^.left := nil;
            tr_matrix^.right := nil;
            is_root := true;
        end
        else }
        //write(tr_matrix = nil);
        add(tr_matrix, str_num, row, col, val);
        //write('fgjldkfglkd');
        writeln(indx, #9, str_num, ' [label="', row, '  ', col, val:10:5, '"];');
        step := 0; row := 0; col := 0; val := 0;
        num_readin_st := new_line_exp; fr_p := 0;
        //обнулить все
        readln(matrix);
    end;

begin
    tr_matrix := nil;
    state := form_exp;
    is_error := false;
    i := 2; val := 0;
    while (not eof(matrix)) and (not is_error) do begin
        case state of
            form_exp:
                begin
                    if not eoln(matrix) then begin
                        read(matrix, c);
                        if (c = '#') or eoln(matrix) then readln(matrix)
                        else if c = SP_FLAG[1] then begin 
                            state := form_ent;
                            form_name := SP_FLAG;
                        end
                        else if c = DEN_FLAG[1] then begin
                            state := form_ent;
                            form_name := DEN_FLAG;
                        end
                        else is_error := true;
                    end
                    else readln(matrix);
                end;
            form_ent:
                begin
                    if i <= length(form_name) then begin
                        if eoln(matrix) then is_error := true
                        else begin
                            read(matrix, c);
                            if c <> form_name[i] then is_error := true;
                        end;
                        i := i + 1;
                    end
                    else state := size_exp;
                end;
            size_exp:
                begin
                    if not eoln(matrix) then begin
                        read(matrix, c);
                        if not in_str(c, ' 1234567890') then is_error := true
                        else if in_str(c, '1234567890') then begin
                            if row_n = 0 then begin
                                row_n := strtoint(c);
                                state := row_ent;
                            end
                            else begin 
                                coln_n := strtoint(c);
                                state := coln_ent;
                            end;
                        end;
                    end
                    else is_error := true;
                end;
            row_ent:
                begin
                    if not eoln(matrix) then begin
                        read(matrix, c);
                        if c = ' ' then state := size_exp
                        else if in_str(c, '1234567890') then row_n := row_n*10 + strtoint(c)
                        else is_error := true;
                    end
                    else is_error := true;
                end;
            coln_ent:
                begin
                    if not eoln(matrix) then begin
                        read(matrix, c);
                        if in_str(c, '1234567890') then coln_n := coln_n*10 + strtoint(c)
                        else begin
                            readln(matrix);
                            if form_name = DEN_FLAG then state := den_cont
                            else state := sp_cont;
                        end;
                    end
                    else if eoln(matrix) and (coln_n <> 0) then begin
                            readln(matrix);
                            if form_name = DEN_FLAG then state := den_cont
                            else state := sp_cont;
                    end
                    else is_error := true;
                end;
            den_cont:
                begin
                    while (not eof(matrix)) and (not is_error) do begin
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
                                    else if c <> ' ' then
                                        is_error := true;  
                                end;
                            int_part:
                                begin
                                    //writeln(row, col, val, str_num);
                                    if not eoln(matrix) then begin
                                        read(matrix, c);
                                        //write('!!!',c,'!!!!', step);
                                        if in_str(c, '1234567890') then 
                                            val := val + strtoint(c)
                                        else if c = '.' then num_readin_st := frac_part
                                        else if c = ' ' then break_line()
                                        else is_error := true;
                                    end
                                    else if step = 3 then break_line()
                                    else is_error := true;
                                end;
                            frac_part: 
                                begin
                                    writeln(row, col, val, str_num);
                                    if not eoln(matrix) then begin
                                        read(matrix, c);
                                        if in_str(c, '1234567890') then 
                                            fr_p := fr_p + strtoint(c)
                                        else if (c = '#') or (c = ' ') then begin
                                            val := val + fr_p/ exp(ln(10) * (trunc(ln(fr_p)/ln(10)) + 1));
                                            break_line();
                                        end                                                
                                        else is_error := true;
                                    end
                                    else begin
                                        val := val + fr_p/ exp(ln(10) * (trunc(ln(fr_p)/ln(10)) + 1));
                                        break_line();
                                    end;
                                end;
                        end;
                    end;
                end;
            sp_cont:
                begin
                    while (not eof(matrix)) and (not is_error) do begin
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
                                    else if c <> ' ' then begin is_error := true;  end;
                                end;
                            int_part:
                                begin
                                    //writeln(row, col, val, str_num);
                                    if not eoln(matrix) then begin
                                        read(matrix, c);
                                        //write('!!!',c,'!!!!', step);
                                        if in_str(c, '1234567890') then begin
                                            if step = 1 then row := row + strtoint(c)
                                            else if step = 2 then col := col + strtoint(c)
                                            else val := val + strtoint(c);
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
                                    writeln(row, col, val, str_num);
                                    if not eoln(matrix) then begin
                                        read(matrix, c);
                                        if in_str(c, '1234567890') then 
                                            fr_p := fr_p + strtoint(c)
                                        else if (c = '#') or (c = ' ') then begin
                                            val := val + fr_p/ exp(ln(10) * (trunc(ln(fr_p)/ln(10)) + 1));
                                            break_line();
                                        end                                                
                                        else is_error := true;
                                    end
                                    else begin
                                        val := val + fr_p/ exp(ln(10) * (trunc(ln(fr_p)/ln(10)) + 1));
                                        break_line();
                                    end;
                                end;
                        end;
                    end;
                end;
        end;
    end;
    writeln(is_error);
end;

procedure pr_edges(tree: tr_ptr);
begin
    if tree <> nil then begin 
        pr_edges(tree^.left); 
        if tree^.left <> nil then 
            write(indx, #9, tree^.node_number, '  ->  ', tree^.left^.node_number, '  [label="L"];');
        if tree^.right <> nil then 
            writeln(indx, #9,  tree^.node_number, '  ->  ', tree^.right^.node_number, '  [label="R"];');
        pr_edges(tree^.right) ;
    end;
end;


begin
    if paramCount() = 0 then 
        writeln('specify the file with the matrix')
    else begin
        assign(matrix, paramStr(1));
        {$I-} reset(matrix); {$I+}

        if IOresult = 0 then begin
            assign(indx, slice(paramStr(1), 1 ,length(paramStr(1)) - 4) + 'dot');
            rewrite(indx);
            writeln(indx, 'digraph', #13#10, '{');
            create_index();
            writeln(indx,#13#10, #9, '//edges', #10#13);
            pr_edges(tr_matrix);
            write(indx, #13#10, '}');
            //{$I-} reset(indx); {$I+}
            //if IOresult = 0 then edit_index()
            //else create_index();
            close(indx);
            close(matrix);
        end
        else 
            writeln('there is no such file');
    end;

end.