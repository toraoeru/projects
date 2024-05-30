#include <iostream>
#include <string>
#include <cmath>
#include <ctime>
#include <cstdlib>
#include <stdexcept>
#include <vector>
#include <cctype>
#include <cstring>
//#include "Parser.h"

using namespace std;

extern string ERROR;

float n_stof(string s);

string get_func();

string change_arg(string func, float arg);

float integrate_rec(string func, float min_lim, float max_lim, int n);

void method_of_rectangles(string func, float min_lim, float max_lim, float delta);

float integrate_sim(string func, float min_lim, float max_lim, int n);

void simpson_method(string func, float min_lim, float max_lim, float delta);

float find_ex(string func, float min_lim, float max_lim, float step, bool flag);

void monte_karlo_method(string func, float min_lim, float max_lim, float step_func, int n);

float get_num();

void print_menu();

int get_variant();