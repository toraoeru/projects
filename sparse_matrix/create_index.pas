program ihatemylife;

{$mode objfpc}
Uses 
    sysutils, Index, Utils_;

var 
    matrix, indx: text; tr_matrix: tr_ptr;


begin
    if paramCount() = 0 then 
        writeln('specify the file with the matrix')
    else begin
        assign(matrix, paramStr(1));
        {$I-} reset(matrix); {$I+}
    
        if IOresult = 0 then begin
            tr_matrix := nil;
            assign(indx, slice(paramStr(1), 1 ,length(paramStr(1)) - 4) + 'dot');
            rewrite(indx);
            writeln(indx, 'digraph', #13#10, '{');
            create_index(matrix, indx, tr_matrix, true);
            writeln(indx,#13#10, #9, '//edges', #10#13);
            pr_edges(tr_matrix, indx);
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