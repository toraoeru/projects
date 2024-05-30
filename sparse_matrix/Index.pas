unit Index;
Interface
Uses Utils_, sysutils;
{$mode objfpc}
const 
    SP_FLAG = 'sparse_matrix';
    DEN_FLAG = 'dence_matrix';
    SELF_RESPECT = 0.00001;

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

procedure create_index(var matrix, indx: text; var tr_matrix: tr_ptr; print_file: boolean);
procedure pr_edges(tree: tr_ptr; var indx: text);
function compare_indx(x1, y1, x2, y2: integer): boolean;
procedure add(var tree: tr_ptr; node_num, row, col: longword; el: double);
function find(tree: tr_ptr; x, y: integer): boolean;
function return_parent(tree: tr_ptr; x, y: integer): tr_ptr;

Implementation

function find(tree: tr_ptr; x, y: integer): boolean;
begin
    if tree = nil then begin
        find := false;
        exit;
    end;
    if (x = tree^.row) and (y = tree^.column) then 
        find := true
    else
    if compare_indx(x, y, tree^.row, tree^.column) then
        find := find(tree^.left, x, y)
    else find := find(tree^.right, x, y);
end;

function return_parent(tree: tr_ptr; x, y: integer): tr_ptr;
begin
    if tree = nil then begin
        return_parent := nil;
        exit;
    end;
    writeln(tree^.row, ' ', tree^.column);
    if ((tree^.left <> nil) and (x = tree^.left^.row) and (y = tree^.left^.column)) or
     ((tree^.right <> nil) and (x = tree^.right^.row) and (y = tree^.right^.column)) then
        return_parent := tree
    else if compare_indx(x, y, tree^.row, tree^.column) then
        return_parent := return_parent(tree^.left, x, y)
    else return_parent := return_parent(tree^.right, x, y);
end;

procedure pr_edges(tree: tr_ptr; var indx: text);
begin
    if tree <> nil then begin 
        pr_edges(tree^.left, indx); 
        if tree^.left <> nil then 
            write(indx, #9, tree^.node_number, '  ->  ', tree^.left^.node_number, '  [label="L"];');
        if tree^.right <> nil then 
            writeln(indx, #9,  tree^.node_number, '  ->  ', tree^.right^.node_number, '  [label="R"]')
        else if tree^.left <> nil then writeln(indx);
        pr_edges(tree^.right, indx) ;
    end;
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
    //writeln('this shit will be added: ',  node_num, ' ', row, ' ', col, ' ', el);
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

procedure create_index(var matrix, indx: text; var tr_matrix: tr_ptr; print_file: boolean);
var 
    format, state: states; 
    row_n, coln_n, i, row, col, step, str_num, cur_col, sign: integer;
    c: char; is_error, is_root: boolean; form_name: string;
    num_readin_st: readin_nums_st; val, fr_p: double; 

    procedure break_line();
    begin
        str_num := str_num + 1; sign := 1;
        add(tr_matrix, str_num, row, col, val);
        if print_file then writeln(indx, #9, str_num, ' [label="', row, '  ', col,'\n', sign*val:10:5, '"];');
        step := 0; row := 0; col := 0; val := 0;
        num_readin_st := new_line_exp; fr_p := 0;
        readln(matrix);
    end;

    procedure next_num();
    begin
        cur_col := cur_col + 1; 
        add(tr_matrix, str_num*coln_n + cur_col, str_num + 1, cur_col, sign*val);
        if print_file then writeln(indx, #9, str_num*coln_n + cur_col, ' [label="', str_num + 1, '  ', cur_col, '\n', sign*val:10:5, '"];');
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
    num_readin_st := new_line_exp;
    state := form_exp; str_num := 0;
    is_error := false; val := 0; fr_p := 0;
    i := 2; val := 0; cur_col := 0; step := 0;
    row := 0; col := 0;
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
                    //writeln('wellllllllll', num_readin_st, (str_num <= row_n));
                    while (not eof(matrix)) and (not is_error) and (str_num <= row_n) do begin
                        //writeln(val:10:1,' ', fr_p, ' ', str_num, ' ', num_readin_st, '   ', cur_col);
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
                                    //writeln(row, col, val, str_num);
                                    if not eoln(matrix) then begin
                                        if cur_col = (coln_n) then bl_den()
                                        else begin
                                            read(matrix, c);
                                            //write('!!!',c,'!!!!', step);
                                            if in_str(c, '1234567890') then 
                                                val := val*10 + strtoint(c)
                                            else if c = '.' then num_readin_st := frac_part
                                            else if (c = ' ') then next_num()
                                            else is_error := true;
                                        end;
                                    end
                                    else if cur_col = (coln_n )  then bl_den()
                                    else is_error := true;
                                end;
                            frac_part: 
                                begin
                                    //writeln(row, col, val, str_num);
                                    if not eoln(matrix) then begin
                                        if cur_col = (coln_n ) then bl_den()
                                        else begin
                                            read(matrix, c);
                                            if in_str(c, '1234567890') then 
                                                fr_p := fr_p*10 + strtoint(c)
                                            else if c = ' ' then begin
                                                if fr_p > SELF_RESPECT then begin
                                                    //writeln('1fjksdfsd');
                                                    val := val + fr_p/ exp(ln(10) * (trunc(ln(fr_p)/ln(10)) + 1));

                                                end;
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
                end;
            sp_cont:
                begin
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
        end;
    end;
    writeln('is there an error? -', is_error);
end;
end.