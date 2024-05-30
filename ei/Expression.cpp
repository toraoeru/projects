#include "Expression.h"
#include "Parser.h"
#include "header.h"

using namespace std;

string Parser::parse_token() {
	while (isspace(*input)) ++input;
	if (isdigit(*input)) {
		string number;
		while (isdigit(*input) || *input == '.') number.push_back(*input++);
		return number;
	}
	static const string tokens[] = {"+", "-", "^", "*", "/", "abs", "sin", "cos", "log", "asin", "atan",  "(", ")"};
	for (auto& t : tokens) {
		if (strncmp(input, t.c_str(), t.size()) == 0) {
			input += t.size();
			return t;
		}
	}
	return "";
}

Expression Parser::parse_simple_expression() {
	auto token = parse_token();
	if (token.empty()){
        ERROR = "Неправильный ввод";
        throw runtime_error(ERROR);
    }
	if (token == "(") {
		auto result = parse();
		if (parse_token() != ")"){
            ERROR = "Ожидалась')'";
            throw runtime_error(ERROR);
        }
		return result;
	}
	if (isdigit(token[0]))
		return Expression(token);

	return Expression(token, parse_simple_expression());
}

int get_priority(const string& binary_op) {
	if (binary_op == "+") return 1;
	if (binary_op == "-") return 1;
	if (binary_op == "*") return 2;
	if (binary_op == "/") return 2;
	if (binary_op == "^") return 3;
	return 0;
}

Expression Parser::parse_binary_expression(int min_priority) {
	auto left_expr = parse_simple_expression();
	for (;;) {
		auto op = parse_token();
		auto priority = get_priority(op);
		if (priority <= min_priority) {
			input -= op.size();
			return left_expr;
		}
		auto right_expr = parse_binary_expression(priority);
		left_expr = Expression(op, left_expr, right_expr);
	}
}

Expression Parser::parse() {
	return parse_binary_expression(0);
}


double eval(const Expression& e) {
	switch (e.args.size()) {
	case 2: {
		auto a = eval(e.args[0]);
		auto b = eval(e.args[1]);
		if (e.token == "+") return a + b;
		if (e.token == "-") return a - b;
		if (e.token == "*") return a * b;
		if (e.token == "/") {
            if (!b){
                ERROR = "Деление на ноль'";
                throw runtime_error(ERROR);
            }
            return a / b;
        }
		if (e.token == "^") return pow(a, b);
        ERROR = "Неизвестный бинарный оператор";
		throw runtime_error(ERROR);
	}

	case 1: {
		auto a = eval(e.args[0]);
		if (e.token == "+") return +a;
		if (e.token == "-") return -a;
		if (e.token == "abs") return abs(a);
		if (e.token == "sin") return sin(a);
		if (e.token == "cos") return cos(a);
        if (e.token == "log"){
            if (a <= 0){
                ERROR = "Функция не оцпределена на части этого промежутка";
		        throw runtime_error(ERROR);
            }
            return log(a);
        }
        if (e.token == "asin"){
            if ((a < -1) || (a > 1)){
                ERROR = "Функция не оцпределена на части этого промежутка";
		        throw runtime_error(ERROR);
            }
            return asin(a);
        }
        if (e.token == "atan") return atan(a);
		ERROR = "Неизвестный унарный оператор";
		throw runtime_error(ERROR);
	}
	case 0:
		return n_stof(e.token);
	}
	ERROR = "Неизвестный тип выражения";
	throw runtime_error(ERROR);
}

double get_val(const char* input){
    Parser p(input);
    auto result = eval(p.parse());
    return result;
}