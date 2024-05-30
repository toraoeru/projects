#include <string>
#include <cstring>
#include <vector>
#include "Parser.h"

using namespace std;

struct Expression {
    Expression(string token) : token(token) {}
	Expression(string token, Expression a) : token(token), args{ a } {}
	Expression(string token, Expression a, Expression b) : token(token), args{ a, b } {}

	string token;
	vector<Expression> args;
};


int get_priority(const string& binary_op);

Expression Parser::parse_binary_expression(int min_priority);

Expression Parser::parse();

double eval(const Expression& e);

double get_val(const char* input);
