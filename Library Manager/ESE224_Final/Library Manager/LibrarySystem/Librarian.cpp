#include "library.h"
#include <iostream>
using namespace std;

/* Constructors */
Librarian::Librarian()
{
	username = "";
	password = "";
	role = 2;
	main_key = username;
}
Librarian::Librarian(string user, string pass)
{
	username = user;
	password = pass;
	main_key = username;
	role = 2;
}

/* Print Functions */
void Librarian::myInformation() 
{
	cout << "Username: " << getUsername() << endl;
	cout << "Password: " << getPassword() << endl;
}


void Librarian::addBooks(TreeNode<Book>* root, TreeNode<Copy>* c_root, int& last_id)
{
	long long int isbn;
	string title, author, category;
	cout << "Input ISBN, title, author, and category: ";
	cin >> isbn >> title >> author >> category;

	if (search(root, isbn) == NULL)
	{
		cout << "A book by this isbn does not exist yet. Creating new book..." << endl;
		Book b1(isbn, title, author, category);
		Copy c1(isbn, last_id);
		addElement(b1, root);

		search(root, isbn)->value.addCopy(last_id);
		addElement(c1, c_root);
	}
	else
	{
		cout << "A book by this isbn exists. Creating new copy..." << endl;
		root->value.addCopy(last_id);
	}
	last_id++;
}

void Librarian::deleteBooks(TreeNode<Copy>* root, TreeNode<Book>* b_root)
{
	printTree(root);
	int id;
	long long int isbn;
	cout << "Input an ID: ";
	cin >> id;

	TreeNode<Copy>*foundCopy = search(root, id);
	if (foundCopy == NULL)
	{
		cout << "A copy with this ID does not exist" << endl;
		return;
	}
	else
	{
		cout << "Removing copy..." << endl;

		isbn = foundCopy->value.getISBN();
		TreeNode<Book>* foundBook = search(b_root, isbn);		//Find the book with this isbn in the Books tree
		if (foundBook->value.getCopyListSize() == 1)			//If there is only 1 copy left, remove the book object
		{
			cout << "This was the last copy of this book. Removing book" << endl;
			removeElement(isbn, b_root);
		}

		removeElement(id, root);
	}
}

void Librarian::searchUsers(TreeNode<User>* u_root, TreeNode<Student>* s_root, TreeNode<Teacher>* t_root, TreeNode<Librarian>* l_root, TreeNode<Book>* b_root, TreeNode<Copy>* c_root)
{
	string username;
	cout << "Input a username: " << endl;
	cin >> username;

	TreeNode<User>* foundUser = search(u_root, username);
	if (foundUser == NULL)
		cout << "No such user exists" << endl;
	else
	{
		if (foundUser->value.getRole() == 2)
		{
			cout << "This user is a librarian" << endl;
			cout << "Username: " << foundUser->value.getUsername() << endl;
			cout << "Password: " << foundUser->value.getPassword() << endl;
		}
		else
		{
			if (foundUser->value.getRole() == 1)
			{
				TreeNode<Teacher>* foundTeacher = search(t_root, username);
				cout << "This user is a teacher" << endl;
				cout << "Username: " << foundUser->value.getUsername() << endl;
				cout << "Password: " << foundUser->value.getPassword() << endl;
				cout << "Current Copies: " << endl;
				foundTeacher->value.myBorrowList(b_root, c_root);
			}
			if (foundUser->value.getRole() == 0)
			{
				TreeNode<Student>* foundStudent= search(s_root, username);
				cout << "This user is a student" << endl;
				cout << "Username: " << foundUser->value.getUsername() << endl;
				cout << "Password: " << foundUser->value.getPassword() << endl;
				cout << "Current Copies: " << endl;
				foundStudent->value.myBorrowList(b_root, c_root);
			}

		}
	}
}

void Librarian::addUsers(TreeNode<User>* u_root, TreeNode<Student>* s_root, TreeNode<Teacher>* t_root, TreeNode<Librarian>* l_root)
{
	string user, pass;
	int role;
	cout << "Enter type: 0 for Student, 1 for Teacher, 2 for Librarian: ";
	cin >> role;
	cout << "Enter username: ";
	cin >> user;
	cout << "Enter password: ";
	cin >> pass;

	if (role == 0)
	{
		Student s1(user, pass);
		addElementUsers(s1, u_root);
		addElement(s1, s_root);
	}
	if (role == 1)
	{ 
		Teacher t1(user, pass);
		addElementUsers(t1, u_root);
		addElement(t1, t_root);
	}
	if (role == 2)
	{
		Librarian l1(user, pass);
		addElementUsers(l1, u_root);
		addElement(l1, l_root);
	}
}

void Librarian::deleteUsers(TreeNode<User>* u_root, TreeNode<Student>* s_root, TreeNode<Teacher>* t_root, TreeNode<Librarian>* l_root, TreeNode<Book>* b_root)
{
	int isbn;
	string user, pass;
	cout << "Enter username: ";
	cin >> user;
		
	TreeNode<User>* foundUser = search(u_root, user);
	if (foundUser != NULL)
	{
		if (foundUser->value.getRole() == 2)
		{
			cout << "Removing this librarian" << endl;
			removeElementUsers(foundUser->value.main_key, u_root);
		}
		else
		{
			TreeNode<Student>* foundStudent = search(s_root, user);
			TreeNode<Teacher>* foundTeacher = search(t_root, user);
			if (foundStudent != NULL)
			{
				if (foundStudent->value.getBorrowListSize() != 0)
				{
					cout << "This reader still has book copies" << endl;
					return;
				}
				else
				{
					cout << "Removing this reader" << endl;
					removeElementUsers(foundUser->value.main_key, u_root);
					removeElementUsers(foundStudent->value.main_key, s_root);
					for (int i = 0; i < foundStudent->value.getReservedListSize(); i++)
					{
						isbn = foundStudent->value.getReservedListISBN(i);
						TreeNode<Book>* foundBook = search(b_root, isbn);
						for (int j = 0; j < foundBook->value.getReserverListSize(); i++)
						{
							if (foundBook->value.getReserver(j) == foundStudent->value.getUsername())
							{
								foundBook->value.removeReserver(j);
							}
						}
					}
					return;
				}
			}
			else if (foundTeacher != NULL)
			{
				if (foundTeacher->value.getBorrowListSize() != 0)
				{
					cout << "This reader still has book copies" << endl;
					return;
				}
				else
				{
					cout << "Removing this reader" << endl;
					removeElementUsers(foundUser->value.main_key, u_root);
					removeElementUsers(foundTeacher->value.main_key, s_root);

					for (int i = 0; i < foundTeacher->value.getReservedListSize(); i++)
					{
						isbn = foundTeacher->value.getReservedListISBN(i);
						TreeNode<Book>* foundBook = search(b_root, isbn);
						for (int j = 0; j < foundBook->value.getReserverListSize(); i++)
						{
							if (foundBook->value.getReserver(j) == foundTeacher->value.getUsername())
							{
								foundBook->value.removeReserver(j);
							}
						}
					}
					return;
				}
			}
		}
	}
	else
		cout << "No such user exists" << endl;

}