/**
 * Authors: initkfs
 */
module os.core.sys.calc;

private
{
	alias KStack = os.core.util.algo.kstack;
	alias ConversionUtil = os.core.util.conversion_util;

	__gshared const char delimiter = ' ';

	__gshared struct Operators
	{
		static const char addition = '+';
		static const char subtraction = '-';
		static const char multiplication = '*';
		static const char division = '/';
		static const char divisionRemainder = '%';
		static const char exponentiation = '^';
		static const char leftParenthesis = '(';
		static const char rightParenthesis = ')';
	}
}

private bool isDelimiter(const char c) @safe pure nothrow
{
	return c == delimiter;
}

private bool isOperator(const char c) @safe pure nothrow
{
	foreach (operator; __traits(allMembers, Operators))
	{
		const auto operatorValue = __traits(getMember, Operators, operator);
		if (c == operatorValue)
		{
			return true;
		}
	}

	return false;
}

private int operatorPriority(char operator) @safe pure nothrow
{
	if (operator == Operators.addition || operator == Operators.subtraction)
	{
		return 1;
	}
	else if (operator == Operators.multiplication || operator == Operators.divisionRemainder
			|| operator == Operators.division || operator == Operators.exponentiation)
	{
		return 2;
	}

	return 0;
}

private void calculateOperation(KStack.KStackSmall!long* digitsStack,
		KStack.KStackSmall!char* operatorStack)
{
	if (digitsStack.isEmpty)
	{
		return;
	}

	const char operator = operatorStack.pop;

	//first right
	long rightDigit = digitsStack.pop;
	long leftDigit = digitsStack.pop;

	switch (operator)
	{
	case Operators.addition:
		digitsStack.push(leftDigit + rightDigit);
		break;
	case Operators.subtraction:
		digitsStack.push(leftDigit - rightDigit);
		break;
	case Operators.multiplication:
		digitsStack.push(leftDigit * rightDigit);
		break;
	case Operators.division:
		digitsStack.push(leftDigit / rightDigit);
		break;
	case Operators.divisionRemainder:
		digitsStack.push(leftDigit % rightDigit);
		break;
	case Operators.exponentiation:
		digitsStack.push(leftDigit ^^ rightDigit);
		break;
	default:
		return;
	}
}

//TODO strip ' '
long calc(string s)
{

	KStack.KStackSmall!long digitsStack = KStack.KStackSmall!long();
	KStack.KStackSmall!char operatorsStack = KStack.KStackSmall!char();

	for (size_t i = 0; i < s.length; ++i)
	{
		const char expressionChar = s[i];

		if (isDelimiter(expressionChar))
		{
			continue;
		}

		if (expressionChar == Operators.leftParenthesis)
		{
			operatorsStack.push(Operators.leftParenthesis);
		}
		else if (expressionChar == Operators.rightParenthesis)
		{
			while (operatorsStack.peek != Operators.leftParenthesis)
			{
				calculateOperation(&digitsStack, &operatorsStack);
			}
			operatorsStack.pop;
		}
		else if (isOperator(expressionChar))
		{
			const char currentOperator = expressionChar;
			while (!operatorsStack.isEmpty
					&& operatorPriority(operatorsStack.peek) >= operatorPriority(expressionChar))
			{
				calculateOperation(&digitsStack, &operatorsStack);
			}
			operatorsStack.push(currentOperator);
		}
		else
		{
			const int digit = ConversionUtil.charToInt(expressionChar);
			digitsStack.push(digit);
		}
	}

	while (!operatorsStack.isEmpty)
	{
		calculateOperation(&digitsStack, &operatorsStack);
	}

	return digitsStack.pop;
}

unittest
{
	import os.core.util.assertions_util;

	kassert(isDelimiter(' '));
	kassert(isOperator('+'));
	kassert(isOperator('*'));
	kassert(isOperator('%'));

	KStack.KStackSmall!long digits = KStack.KStackSmall!long();
	KStack.KStackSmall!char operators = KStack.KStackSmall!char();

	digits.push(2);
	digits.push(3);
	operators.push('+');
	calculateOperation(&digits, &operators);

	kassert(digits.peek == 5);

	kassert(calc("3 + 5") == 8);
	kassert(calc("5 - 2") == 3);
	kassert(calc("6 * 2") == 12);
	kassert(calc("6 / 2") == 3);

	kassert(calc("6 - 2 * 2") == 2);
	kassert(calc("6 - (1 + 2)") == 3);
	kassert(calc("9 - (1 + 2) * 2") == 3);
}
