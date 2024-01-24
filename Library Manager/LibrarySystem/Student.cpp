#include "library.h"
#include <iostream> 
using namespace std;


/* Constructors */
Student::Student()
	{
		username = "";
		password = "";
		role = 0;
		main_key = username;
	}
Student::Student(string user, string pass)
	{
		username = user;
		password = pass;
		role = 0;
		main_key = username;
	}


/* Accessors */
int Student::getMaxCopiesAllowed() { return 5; }
int Student::getMaxBorrowPeriod() { return 30; }
