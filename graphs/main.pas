{Программа которая читает файл и создает массив из уникальных строк}

{superstring - обычная строка, только может быть любой длины}
type superstring = array of char;
var 
    {supertext - наш получившийся массив}
    supertext: array of superstring; 
    i, j, p, q, kolvo_dif_len, kolvo_dif_elem: integer; 
    sym: char; 
    t: text; 
    str: superstring;
begin
    {Нужно читать из файла, т.к. в терминале не введешь строку >255}
    assign(t, 'test.txt');
    reset(t);
    {Подготовка}
    i := 0;
    j := 1;
    kolvo_dif_len := 0;
    kolvo_dif_elem := 0;
    setlength(supertext, j);
    {Чтение из файла посимвольно}
    {Реализовано классически как и в первом праке(калькуляторе)}
    {repeat пока не конец файл, проверяем на конец строки, а потом читаем символ и делаем что хочим}
    repeat
        if not eoln(t) then
        begin
            {Собирание строки из файла}
            {Читаем один символ}
            read(t, sym);
            {Добавляем пустой элемент в строке}
            i := i + 1;
            setlength(str, i);
            {В предпоследний записываем символ}
            str[i - 1] := sym;
        end
        else
        begin
            {Если мы попали сюда, то строка кончилась и сохранена в str}
            readln(t);
            {Проходим по нашему массиву}
            {Нумерация динамического массива идет с 0 так что  до length(supertext) - 1}
            for p := 0 to length(supertext) - 1 do
            begin
                {Сначала проверим на длину для ускорения работы}
                if (length(str)) = (length(supertext[p])) then
                begin
                    {Если длина совпала, то проверим поэлементно}
                    for q := 0 to length(supertext[p]) - 1 do
                    begin
                        if str[q] <> supertext[p][q] then
                        begin
                            {Если элемент не совпал, то значит наша не равна p-ому элементу массива}
                            kolvo_dif_elem := kolvo_dif_elem + 1;
                            {Если хоть один символ не совпал, то сразу break
                             (если строки отличаются хоть одним символом, то они не равны)}
                            break;
                        end;
                    end;
                end
                else
                {Если длина не совпала, то наша строка априори не равна p-ому элементу массива}
                begin
                    {Сохраняем количество несовпавших строк}
                    kolvo_dif_len := kolvo_dif_len + 1;
                end;
            end;
            {Теперь если наша строка не совпала с каким то количеством элементов массива по длине, 
             А с каким то количеством элементов массива поэлеметно, 
             То если сумма этих количеств будет равна количеству ВСЕХ элементов массива, 
             То значит строка не совпадает ни с каким элементом массива => уникальна}
            if kolvo_dif_len + kolvo_dif_elem = length(supertext) then
            begin
                {Добавляем эту строку в массив}
                supertext[j - 1] := str;
                {Добавляем пустой элемент}
                j := j + 1;
                setlength(supertext, j);
            end;
            {Обновляем длину строки(i) и количества}
            i := 0;
            kolvo_dif_len := 0;
            kolvo_dif_elem := 0;
        end;
    until eof(t);
    {Проверка последнего элемента, т.к случается выход по eof}
    {Схема та же(просто cntr + c, cntr + v)}
    for p := 0 to length(supertext) - 1 do
    begin
        if (length(str)) = (length(supertext[p])) then
        begin
            for q := 0 to length(supertext[p]) - 1 do
            begin
                if str[q] <> supertext[p][q] then
                begin
                    kolvo_dif_elem := kolvo_dif_elem + 1;
                    break;
                end;
            end;
        end
        else
        begin
            kolvo_dif_len := kolvo_dif_len + 1;
        end;
    end;
    if kolvo_dif_len + kolvo_dif_elem = length(supertext) then
    begin
        supertext[j - 1] := str;
        j := j + 1;
        setlength(supertext, j);
    end;

    {Выводим наш массив}
    writeln('otvet: ');
    {Убираем последний элемент, заведомо пустой}
    setlength(supertext, j - 1);
    write('[');
    for p := 0 to length(supertext) - 1 do 
    begin
        for q := 0 to length(supertext[p]) - 1 do
            write(supertext[p][q]);
        {чтобы не было лишней запятой(для красоты)}
        if p <> length(supertext) - 1 then
            write(', ');
    end;
    write(']');

    
end.
{p.s.}
{Эту прогу надо будет внедрить во второй прак, такой прогой создается список всех транспортов, городов}
{Эти списки нужны для работы с алгоритмом Дейкстры и Белмана Форда, вывода пассажиру}
{Тут нет никакого контроля ошибок, нет комментариев, нет убирания пробелов, чисто скелет}
{Прогу можно ускорить(но как по мне незначительно), если изначально будете делать длину больше а потом урезать
 (setlength не 1, а сразу 100 к примеру)}
{надеюсь помог!}