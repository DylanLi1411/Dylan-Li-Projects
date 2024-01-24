#include "library.h"
#include <iostream>
using namespace std;


/* Constructors */
Copy::Copy()
    {
        ISBN = 0;
	    ID = 0;
	    reader_name = "";
	    reserver_name = "";
	    reserve_date = 0;
        start_date = 0;
        expire_date = 0;
        main_key = ID;
    }
Copy::Copy(long long int isbn, int id)
    {
        ISBN = isbn;
	    ID = id;
	    reader_name = "";
	    reserver_name = "";
	    reserve_date = 0;
	    start_date = 0;
	    expire_date = 0;
		main_key = ID;
    }


/* Accessors */
long long int Copy::getISBN() { return ISBN; }
int Copy::getID() { return ID; }
string Copy::getReaderName() { return reader_name; }
string Copy::getReserverName() { return reserver_name; }
int Copy::getReserveDate() { return reserve_date; }
int Copy::getStartDate() { return start_date; }
int Copy::getExpireDate() { return expire_date; }


/* Mutators */
void Copy::setReaderName(string name) { reader_name = name; }
void Copy::setReserverName(string name) { reserver_name = name; }
void Copy::setReserveDate(int date) { reserve_date = date; }
void Copy::setStartDate(int date) { start_date = date; }
void Copy::setExpireDate(int date) { expire_date = date; }


/* Copy Functions */
void Copy::deleteReservation()
    {
        reserver_name = "";
        reserve_date = 0;
    }
void Copy::returnCopy()
    {
        reader_name = "";
        start_date = 0;
        expire_date = 0;
    }


// Overloaded operators
bool Copy::operator > (Copy& right)
{
    bool status;

    if (ID > right.getID())
        status = true;
    else
        status = false;

    return status;
}

bool Copy::operator < (Copy& right)
{
    bool status;

    if (ID < right.getID())
        status = true;
    else
        status = false;

    return status;
}