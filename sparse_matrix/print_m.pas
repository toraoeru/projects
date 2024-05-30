program iamatmyfuckinlimit;

{$mode objfpc}
Uses Index, Utils_, sysutils;

const maxlen = 10;

procedure mode1(a: tr_ptr);
begin
    if a <> nil then begin
        write('Node ', a^.node_number, '; Key: (', a^.row, ', ', a^.column, '); Value: ', a^.element:maxlen:1);
        write(' | L: ');
        if a^.left <> nil then
            write(a^.left^.node_number)
        else
            write('NULL');
        write(', R: ');
        if a^.right <> nil then
            write(a^.right^.node_number)
        else
            write('NULL');
        writeln;
        if a^.left <> nil then
            mode1(a^.left);
        if a^.right <> nil then
            mode1(a^.right)
    end
end;

procedure pr_node(a: tr_ptr);
begin
    if a <> nil then begin
        write('Node ', a^.node_number, '; Key: (', a^.row, ', ', a^.column, '); Value: ', a^.element:maxlen:1);
        write(' | L: ');
        if a^.left <> nil then
            write(a^.left^.node_number)
        else
            write('NULL');
        write(', R: ');
        if a^.right <> nil then
            write(a^.right^.node_number)
        else
            write('NULL');
        writeln;
    end;
end;


function height(p: tr_ptr): integer;
var l, r: integer;
begin
    if p <> nil then begin
        l := height(p^.left);
        r := height(p^.right);
    if l > r then 
        height := l + 1
    else 
        height := r + 1
    end
    else
        height := 0;
end;

procedure mode3(a: tr_ptr);
var h: longint; i: integer;

procedure printl(a: tr_ptr; level: integer);
begin
    if a <> nil then begin
        if level = 1 then begin
            write('Node ', a^.node_number, '; Key: ', a^.row, ', ', a^.column, '; Value:', a^.element:maxlen:1);
            write(' Kids: L: ');
            if a^.left <> nil then
                write(a^.left^.node_number)
            else
                write('NULL');
            write(', R: ');
            if a^.right <> nil then
                write(a^.right^.node_number)
            else
                write('NULL');
            writeln;
        end;
        printl(a^.left, level - 1);
        printl(a^.right, level - 1)
    end
end;

begin
    if a <> nil then begin
        h := height(a);
        for i := h + 1 downto 0 do
            printl(a, i - 1);
        end 
    else exit;
end;

{$L ./pmode.obj}
procedure mode_ass(var a :tr_ptr; h: integer); stdcall; external name 'pr_tree';

var 
    mtr_tr: tr_ptr; matrix, ind_f: text;
begin
    if paramCount() <> 2 then 
        writeln('wrong number of arguments')
    else begin
        {$I-} assign(matrix, paramStr(1));
        reset(matrix); {$I+}
        mtr_tr := nil;
        create_index(matrix, ind_f, mtr_tr, false);
        if paramStr(1) = '1' then
            mode1(mtr_tr)
        else if paramStr(1) = '3' then
            mode3(mtr_tr)
        else mode_ass(mtr_tr, height(mtr_tr));
    end;

end.
