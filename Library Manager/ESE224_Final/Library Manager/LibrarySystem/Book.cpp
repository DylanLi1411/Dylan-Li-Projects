#include "library.h"
#include <iostream>
using namespace std;


/* Constructors */
Book::Book()
{
	ISBN = 0;
	author = "";
	title = "";
	category = "";
	favor_count = 0;
	main_key = ISBN;
}
Book::Book(long long int isbn, string tt, string auth, string cat)
{
	ISBN = isbn;
	author = auth;
	title = tt;
	category = cat;
	favor_count = 0;
	main_key = ISBN;
}


/* Accessors */
long long int Book::getISBN() { return ISBN; }
string Book::getAuthor() { return author; }
string Book::getTitle() { return title; }
string Book::getCategory() { return category; }
int Book::getCopyListID(int index)
{
	auto ptr = copyList.begin();

	for (int i = 0; i < index; i++)
	{
		++ptr;
	}

	return *ptr;
}
int Book::getCopyListSize() { return copyList.size(); }
string Book::getReserver(int index)
{
	// Save head pointer
	ReserverNode* head = reserverHead;

	// Move head pointer to node at index
	for (int i = 0; i < index; i++)
	{
		head = head->next;
	}

	// Return name at index node
	return head->name;
}
int Book::getReserverListSize()
{
	// Save head pointer
	ReserverNode* head = reserverHead;
	int i = 0;

	while (head)
	{
		head = head->next;
		i++;
	}

	return i;
}
int Book::getFavorCount() { return favor_count; }


/* Mutators */
void Book::setISBN(long long int isbn) { ISBN = isbn; }
void Book::setAuthor(string auth) { author = auth; }
void Book::setTitle(string tt) { title = tt; }
void Book::setCategory(string cat) { category = cat; }
void Book::addCopy(int id) { copyList.push_back(id); }
void Book::removeCopy(int id) { copyList.remove(id); }
void Book::addReserver(string name)
{
	// Save head pointer
	ReserverNode* head = reserverHead;

	// Allocate memory for new node
	ReserverNode* temp = new ReserverNode(name);

	// When reserver linked list is empty
	if (head == NULL)
	{
		head = temp;
	}

	/* Otherwise, add to end of linked list */
	// Go to end of linked list
	while (head->next != NULL)
	{
		head = head->next;
	}

	// Add node
	head->next = temp;
}
void Book::removeReserver(int index)
{
	// Save head pointer
	ReserverNode* head = reserverHead;

	if (index == 0)
	{
		// Move original head pointer to second node
		reserverHead = reserverHead->next;
	}
	else
	{
		ReserverNode* head2 = reserverHead;

		// Move head pointer to node to be deleted by index
		for (int i = 0; i < index; i++)
		{
			head = head->next;
		}

		// Move second head pointer to node before the one to be deleted
		for (int i = 0; i < index - 1; i++)
		{
			head2 = head2->next;
		}

		// Reconnect the linked list to skip over the soon-to-be deleted node
		head2->next = head->next;
	}

	// Delete node
	delete head;
}
void Book::incFavorCount() { favor_count++; }







/* Overloaded operators */
bool Book::operator > (Book& right)
{
    bool status;

    if (ISBN > right.getISBN())
        status = true;
    else
        status = false;

    return status;
}

bool Book::operator < (Book& right)
{
    bool status;

    if (ISBN < right.getISBN())
        status = true;
    else
        status = false;

    return status;
}

void Book::operator = (Book& right)
{
	ISBN = right.getISBN();
}
void Book::operator << (ostream& output)
{
	output << "ISBN: " << ISBN;
}