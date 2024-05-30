#include "header.h"

int main(){
    srand(time(NULL));
    setlocale(LC_ALL,"Russian");
    int variant;
    do {
        print_menu();
        variant = get_variant();
        switch (variant){
            case 1:
            {
                cout << "Введите подынтегральную функцию" << endl;
                string func = get_func();
                cout << "Введите левую границу интегрирования" << endl;
                float left_b = get_num();
                cout << "Введите правую границу интегрирования" << endl;
                float right_b = get_num();
                try{
                    monte_karlo_method(func, left_b, right_b, 0.001, 1000);
                    method_of_rectangles(func, left_b, right_b, 0.001);
                    simpson_method(func, left_b, right_b, 0.001);
                } catch (runtime_error) {
                    cout << ERROR << endl;
                }
            }
                break;
            case 2:
                cout << "Доступны функции sin, cos, log, abs, asin, atan, возведение в степень" << endl <<
                "Для дробных чисел используйте точку" << endl << "Переменная - х" << endl <<
                "Для больших отрезков интегрирования программа работает медленно" << endl;
                break;
        }
        cout << "----------------------" << endl;
    } while (variant != 3);
    return 0;
}