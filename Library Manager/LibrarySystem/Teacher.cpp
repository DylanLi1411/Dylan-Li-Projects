#include "library.h"
#include <iostream> 
using namespace std;


/* Constructors */
Teacher::Teacher()
    {
        username = "";
        password = "";
        role = 1;
        main_key = username;
    }
Teacher::Teacher(string user, string pass)
    {
        username = user;
        password = pass;
        role = 1;
        main_key = username;
    }


/* Accessors */
int Teacher::getMaxCopiesAllowed() { return 10; }
int Teacher::getMaxBorrowPeriod() { return 50; }