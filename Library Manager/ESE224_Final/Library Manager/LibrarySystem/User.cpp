#include "library.h"
#include <iostream> 
#include <string>
using namespace std;


/* Accessors */
string User::getUsername() {return username;}
string User::getPassword() {return password;}
int User::getRole() { return role; }


/* Mutators */
void User::setUsername(string user) {username = user;}
void User::setPassword(string pass) {password = pass;}
void User::setRole(int r) { role = r; }
void User::changePassword(string pass) { password = pass; }


/* Print Functions */
void User::myInformation() { ; }    // See Librarian and Reader function


/* Operators */
bool User::operator > (User& right)
{
    bool status;

    if (username > right.getUsername())
        status = true;
    else
        status = false;

    return status;
}

bool User::operator < (User& right)
{
    bool status;

    if (username < right.getUsername())
        status = true;
    else
        status = false;

    return status;
}