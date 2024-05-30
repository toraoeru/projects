#include "header.h"

float n_stof(string s){
    double res = 0;
    int d_pos = s.find(".");
    bool is_neg = (s[0] == '-');
    int sign = is_neg*(-2) + 1;
    if (d_pos != -1){
        string wh_s = s.substr(is_neg, d_pos - is_neg);
        int x, y;
        sscanf(&wh_s[0], "%d", &y);
        sscanf(&s[d_pos+1], "%d", &x);
        res += sign*(x/float((pow(10, s.length() - d_pos - 1))) + y);
    }
    else{
        for (int i = is_neg; i < s.length(); ++i){
            int x;
            sscanf(&s[i], "%d", &x);
            res += float(x);
        }
        res *= sign;
    }
    return res;
}

string get_func(){
    string func;
    cout << ">";
    getline(cin, func);
    return func;
}

string change_arg(string func, float arg){
    for (int i = 0; i < func.length(); ++i){
        if (func[i] == 'x')
            func.replace(i, 1, to_string(arg));
    }
    for (int i = 0; i < func.length(); ++i){
        if (func[i] == ',')
            func.replace(i, 1, ".");
    }
    return func;
}

float integrate_rec(string func, float min_lim, float max_lim, int n){
    float integral = 0.0;
    float step = (max_lim - min_lim) / n;
    for (float x = min_lim; x < max_lim-step; x += step)
        integral += step * get_val(change_arg(func, x + step / 2).c_str());
    return integral;
}

void method_of_rectangles(string func, float min_lim, float max_lim, float delta){
    float start = clock();
    float d = 1;
    int n = 1;
    while (abs(d) > delta){
        d = (integrate_rec(func, min_lim, max_lim, n * 2) - integrate_rec(func, min_lim, max_lim, n)) / 3;//
        n *= 2;
    }
    float a = abs(integrate_rec(func, min_lim, max_lim, n));
    float b = abs(integrate_rec(func, min_lim, max_lim, n)) + d;
    float end = clock();
    cout << "Метод прямоугольников: " << (a + b) / 2 << "+-" << abs(d) / 2 << 
    ", время выполнения " <<  (end - start) / CLOCKS_PER_SEC << endl;
}

float integrate_sim(string func, float min_lim, float max_lim, int n){
    float integral = 0.0;
    float step = (max_lim - min_lim) / n;
    for (float x = min_lim + step / 2; x < max_lim - step / 2; x += step){
        integral += step / 6 * (get_val(change_arg(func, x - step / 2).c_str()) +
         4 * get_val(change_arg(func, x).c_str()) + get_val(change_arg(func, x + step / 2).c_str()));
    }
    return integral;
}

void simpson_method(string func, float min_lim, float max_lim, float delta){
    float start = clock();
    float d = 1;
    int n = 1;
    while (abs(d) > delta){
        d = (integrate_sim(func, min_lim, max_lim, n * 2) - integrate_sim(func, min_lim, max_lim, n)) / 15;//
        n *= 2;
        if (n > pow(2, 15)) break;
    }
    float a = abs(integrate_sim(func, min_lim, max_lim, n));
    float b = abs(integrate_sim(func, min_lim, max_lim, n)) + d;
    float end = clock();
    cout << "Метод Симпсона: " << (a + b) / 2 << "+-" << abs(d) / 2 << 
     ", время выполнения " <<  (end - start) / CLOCKS_PER_SEC << endl;
}

float find_ex(string func, float min_lim, float max_lim, float step, bool flag){
    float maxx = -99999999999.0;
    float minn = 9999999999.0;
    for (float i = min_lim; i <= max_lim; i += step){
        if (get_val(change_arg(func, i).c_str()) > maxx)
            maxx = get_val(change_arg(func, i).c_str());
        if (get_val(change_arg(func, i).c_str()) < minn)
            minn = get_val(change_arg(func, i).c_str());
    }
    if (flag) return maxx;
    return minn;
}

void monte_karlo_method(string func, float min_lim, float max_lim, float step_func, int n){
    float start = clock();
    if (max_lim - min_lim < 0){
        float end = clock();
        cout << "Метод Монте-Карло: " << " 0, время выполнения " << (end - start) / CLOCKS_PER_SEC << endl;
        return;
    }
    int in_d = 0;
    const int deep = 1000;
    float min_val = find_ex(func, min_lim, max_lim, step_func, false);
    float max_val = find_ex(func, min_lim, max_lim, step_func, true);
    if (max_val - min_val > 0.001){
        for (int i = 0; i < n; ++i){
            float x = min_lim + (max_lim - min_lim) / RAND_MAX * float(rand());
            float y;
            if (min_val < 0) y = min_val + (max_val - min_val) / RAND_MAX * float(rand());
            else y = max_val / RAND_MAX * float(rand());
            if ((y >=  0) && (y <= get_val(change_arg(func, x).c_str())))
                in_d += 1;
            else if ((y <  0) && (y >= get_val(change_arg(func, x).c_str())))
                in_d -= 1;
        } 
        float end = clock();
        if (min_val < 0){
            cout << "Метод Монте-Карло: " << in_d / float(n) * (max_val - min_val) * (max_lim - min_lim) << 
            ", время выполнения " <<  (end - start) / CLOCKS_PER_SEC << endl;                              
        } else {
            cout << "Метод Монте-Карло: " << in_d / float(n) * max_val * (max_lim - min_lim) << 
            ", время выполнения " <<  (end - start) / CLOCKS_PER_SEC << endl;
        }
        return;
    }
    cout << "Метод Монте-Карло: " << (max_val + min_val) / 2 * (max_lim - min_lim) << endl;
}

float get_num(){
    bool is_digit = true;
    string s;
    int error_num = 0;
    do {
        ++error_num;
        if (error_num > 1) cout << "Неправильный ввод. Попытайтесь снова" << endl;
        is_digit = true;
        cout << ">";
        getline(cin, s);
        int point_num = 0;
        for (int i = 0; i < s.length(); ++i){
            if (s[i] == '-'){
                if (i != 0) is_digit *= 0;
            }
            else{
                if (s[i] == '.'){
                    ++point_num;
                    is_digit *= (point_num == 1);
                }
                else is_digit *= isdigit(s[i]);
            }
        }
    } while (!is_digit);
    return n_stof(s);
}

void print_menu(){
    cout << "Что будем делать?(Введите пункт меню)" << endl;
    cout << "1. Ввести функцию и вычислить интеграл" << endl;
    cout << "2. Справочная информация и правила пользования" << endl;
    cout << "3. Выход" << endl;
}

int get_variant(){
    string s;
    cout << ">";
    getline(cin, s);
    while ((s != "1") && (s != "2") && (s != "3")){
        cout << "Неправильный ввод. Попытайтесь снова" << endl << ">";
        getline(cin, s);
    }
    return stoi(s);
}