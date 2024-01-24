#pragma once
#include "library.h"
#include <iostream>
#include <stdlib.h>
#include <fstream>
#include <queue>
#include <time.h>
using namespace std;

// Declared Functions
void readFiles();
void addCopyListMain(TreeNode<Book>* bookTree, TreeNode<Copy>* copyTree);



//Global variables
fstream bookFile;
fstream copyFile;
fstream userFile;
int role;
bool loggedout = false;
TreeNode<User>* currentUser = NULL; //Points to the current user
TreeNode<Student>* currentStudent = NULL; //Points to the current user
TreeNode<Teacher>* currentTeacher = NULL; //Points to the current user
TreeNode<Librarian>* currentLibrarian = NULL; //Points to the current user
int last_id = 1;                 // used to assign unique IDs
time_t start = time(0);          // to compare time


// Binary Trees
TreeNode<Book>* rootBook = new TreeNode<Book>();
TreeNode<Copy>* rootCopy = new TreeNode<Copy>();
TreeNode<Student>* rootStudent = new TreeNode<Student>();
TreeNode<Teacher>* rootTeacher = new TreeNode<Teacher>();
TreeNode<Librarian>* rootLibrarian = new TreeNode<Librarian>();
TreeNode<User>* rootUser = new TreeNode<User>();


// Returns the current day (5 seconds is 1 passing day) starting from day 1
int dateCounter()
{
	return ((int)difftime(time(0), start) / 5) + 1;
}



void readFiles()
{
	bookFile.open("book.txt");
	if (bookFile.fail())
	{
		cerr << "Error opening 'book.txt'" << endl;
		return;
	}

	copyFile.open("copy.txt");
	if (copyFile.fail())
	{
		cerr << "Error opening 'copy.txt'" << endl;
		return;
	}

	userFile.open("student.txt");
	if (userFile.fail())
	{
		cerr << "Error opening 'student.txt'" << endl;
		return;
	}

	long long int isbn;
	string title, author, category;
	while (!bookFile.eof())
	{
		bookFile >> isbn >> title >> author >> category;
		Book tempBook(isbn, title, author, category);
		if (title != "")
			addElement(tempBook, rootBook);
	}
	
	int num;
	string username, password;
	while (!userFile.eof())
	{
		userFile >> num >> username >> password;
		Student tempStudent(username, password);
		Teacher tempTeacher(username, password);
		Librarian tempLibrarian(username, password);

		if (username != "")
		{
			if (num == 0)
			{
				addElement(tempStudent, rootStudent);
				addElementUsers(tempStudent, rootUser);
			}
			if (num == 1)
			{
				addElement(tempTeacher, rootTeacher);
				addElementUsers(tempTeacher, rootUser);
			}
			if (num == 2)
			{
				addElement(tempLibrarian, rootLibrarian);
				addElementUsers(tempLibrarian, rootUser);
			}
		}
	}
	
	int id;
	while (!copyFile.eof())
	{
		copyFile >> isbn >> id;
		Copy tempCopy(isbn, id);
		if (isbn != NULL)
		{
			addElement(tempCopy, rootCopy);
			last_id++;
		}
	}

	rootBook = removeElement(0, rootBook); //idk why but the head of the trees are always NULL so I gotta remove it. Its spaghetti code but it works.
	rootCopy = removeElement(0, rootCopy);
	rootStudent = removeElement("", rootStudent);
	rootTeacher = removeElement("", rootTeacher);
	rootLibrarian = removeElement("", rootLibrarian);
	rootUser = removeElement("", rootUser);

	addCopyListMain(rootBook, rootCopy);
}

// After the binary trees are created, the Book classes start with empty copyLists
// This function fixes this by adding the correct IDs to each instance of Book class
// Preorder traversal is used for this function
void addCopyListMain(TreeNode<Book>* bookTree, TreeNode<Copy>* copyTree)
{
	// Find Book class related to the Copy at node by ISBN
	TreeNode<Book>* temp = search(bookTree, (copyTree->value).getISBN());

	// Add ID to that Book class's copyList
	(temp->value).addCopy((copyTree->value).getID());

	// Check left
	if (copyTree->left != NULL)
	{
		addCopyListMain(bookTree, copyTree->left);
	}

	// Check right
	if (copyTree->right != NULL)
	{
		addCopyListMain(bookTree, copyTree->right);
	}
}

template <typename Type>
bool user_authentication()
{
	string user, pass;
	cout << "Welcome!" << endl;
	cout << "\nEnter username: ";
	cin >> user;

	cout << "Enter Password: ";
	cin >> pass;

	currentUser = search(rootUser, user);
	currentStudent = search(rootStudent, user);
	currentTeacher = search(rootTeacher, user);
	currentLibrarian = search(rootLibrarian, user);

	if (currentUser != NULL && currentUser->value.getPassword() == pass)
	{
		loggedout = false;
		role = currentUser->value.getRole();
		cout << "Signed in as " << user << endl;
		return true;
	}
	else if (currentUser != NULL && currentUser->value.getPassword() != pass)
	{
		loggedout = true;
		cout << "Incorrect password for this user" << endl;
		return false;
	}
	else if (currentUser == NULL)
	{
		loggedout = true;
		cout << "There is no user by this username" << endl;
		return false;
	}
}


void writeToBookFile(TreeNode<Book>* b_root)
{
	if (b_root == NULL)
		return;

	//inorder traversal
	writeToBookFile(b_root->left);
	cout << b_root->value.getISBN() << " " << b_root->value.getTitle() << " " << b_root->value.getAuthor() << " " << b_root->value.getCategory() << endl;
	bookFile << b_root->value.getISBN() << " " << b_root->value.getTitle() << " " << b_root->value.getAuthor() << " " << b_root->value.getCategory() << endl;
	writeToBookFile(b_root->right);
}

void writeToCopyFile(TreeNode<Copy>* c_root)
{
	if (c_root == NULL)
		return;

	//inorder traversal
	writeToCopyFile(c_root->left);
	cout << c_root->value.getISBN() << " " << c_root->value.getID() << endl;
	copyFile << c_root->value.getISBN() << " " << c_root->value.getID() << endl;
	writeToCopyFile(c_root->right);
}

void writeToUserFile(TreeNode<User>* u_root)
{
	if (u_root == NULL)
		return;

	//inorder traversal
	writeToUserFile(u_root->left);
	cout << u_root->value.getRole() << " " << u_root->value.getUsername() << " " << u_root->value.getPassword() << endl;
	userFile << u_root->value.getRole() << " " << u_root->value.getUsername() << " " << u_root->value.getPassword() << endl;

	writeToUserFile(u_root->right);
}

void endProgram()
{
	bookFile.close();
	copyFile.close();
	userFile.close();

	bookFile.open("book.txt", ios::out);
	copyFile.open("copy.txt", ios::out);
	userFile.open("student.txt", ios::out);

	writeToBookFile(rootBook);
	writeToCopyFile(rootCopy);
	writeToUserFile(rootUser);

	bookFile.close();
	copyFile.close();
	userFile.close();
}

int main()
{
	int ID;
	long long int ISBN;
	string newPass;
	readFiles();
	int input;
	bool authentication;

	printTree(rootBook);
	printTree(rootCopy);
	printTree(rootStudent);
	printTree(rootTeacher);
	printTree(rootLibrarian);
	printTree(rootUser);
	cout << "\n\n\n";
	cout << "--------------------------------------------" << endl;
	cout << "-          Welcome to My Library!          -" << endl;
	cout << "--------------------------------------------" << endl;
	
	

	while (1)
	{
		authentication = user_authentication<User>();
		while (loggedout == false)
		{
			if (authentication == true)
			{
				if (role == 0)
				{
					cout << "Welcome back, Student" << endl;
					cout << "Please choose:" << endl;
					cout << "1 -- Search Book" << endl;
					cout << "2 -- Borrow Book" << endl;
					cout << "3 -- Return Book" << endl;
					cout << "4 -- Renew Book" << endl;
					cout << "5 -- Reserve Book" << endl;
					cout << "6 -- Cancel Book" << endl;
					cout << "7 -- My Information" << endl;
					cout << "8 -- Change Password" << endl;
					cout << "0 -- Log Out" << endl;
					cin >> input;
					switch (input)
					{
					case 1:
						currentStudent->value.searchBook(rootBook, rootCopy, dateCounter());
						break;
					case 2:
						cout << "Enter ID of book you want to borrow: ";
						cin >> ID;
						currentStudent->value.borrowBook(rootCopy, ID, dateCounter());
						break;
					case 3:
						cout << "Enter ID of book you want ot return: ";
						cin >> ID;
						currentStudent->value.returnBook(rootBook, rootCopy, ID, dateCounter());
						break;
					case 4:
						currentStudent->value.myBorrowList(rootBook, rootCopy);
						cout << "Enter ID of book you want to renew: ";
						cin >> ID;
						currentStudent->value.renewBook(rootBook, rootCopy, ID, dateCounter());
						break;
					case 5:
						printTree(rootBook);
						cout << "Enter ISBN of book you want to reserve: ";
						cin >> ISBN;
						currentStudent->value.reserveBook(rootBook, ID);
						break;
					case 6:
						cout << "Enter ISBN of book you want to cancel reservation: ";
						cin >> ISBN;
						currentStudent->value.cancelReservation(rootBook, ID);
						break;
					case 7:
						cout << "-----------------My information-----------------" << endl;
						currentStudent->value.myInformation();
						currentStudent->value.myBorrowList(rootBook, rootCopy);
						cout << "1 -- You can keep up to 5 book copies." << endl;
						cout << "2 -- Each copy can be kept for up to 30 days." << endl;
						break;
					case 8:
						cout << "Enter new password: ";
						cin >> newPass;
						currentUser->value.changePassword(newPass);
						currentStudent->value.changePassword(newPass);
						cout << "New password changed" << endl;
						break;
					case 0:
						cout << "Logging Out..." << endl;
						loggedout = true;
						break;
					default:
						cout << "Invalid operation." << endl;
					}
				}
				else if (role == 1)
				{
					cout << "Welcome back, Teacher" << endl;
					cout << "Please choose:" << endl;
					cout << "1 -- Search Book" << endl;
					cout << "2 -- Borrow Book" << endl;
					cout << "3 -- Return Book" << endl;
					cout << "4 -- Renew Book" << endl;
					cout << "5 -- Reserve Book" << endl;
					cout << "6 -- Cancel Book" << endl;
					cout << "7 -- My Information" << endl;
					cout << "8 -- Change Password" << endl;
					cout << "0 -- Log Out" << endl;
					cin >> input;
					switch (input)
					{
					case 1:
						currentTeacher->value.searchBook(rootBook, rootCopy, dateCounter());
						break;
					case 2:
						cout << "Enter ID of book you want to borrow: ";
						cin >> ID;
						currentTeacher->value.borrowBook(rootCopy, ID, dateCounter());
						break;
					case 3:
						cout << "Enter ID of book you want ot return: ";
						cin >> ID;
						currentTeacher->value.returnBook(rootBook, rootCopy, ID, dateCounter());
						break;
					case 4:
						currentStudent->value.myBorrowList(rootBook, rootCopy);
						cout << "Enter ID of book you want to renew: ";
						cin >> ID;
						currentTeacher->value.renewBook(rootBook, rootCopy, ID, dateCounter());
						break;
					case 5:
						printTree(rootBook);
						cout << "Enter ISBN of book you want to reserve: ";
						cin >> ISBN;
						currentTeacher->value.reserveBook(rootBook, ISBN);
						break;
					case 6:
						cout << "Enter ISBN of book you want to cancel reservation: ";
						cin >> ISBN;
						currentTeacher->value.cancelReservation(rootBook, ID);
						break;
					case 7:
						cout << "-----------------My information-----------------" << endl;
						currentTeacher->value.myInformation();
						currentTeacher->value.myBorrowList(rootBook, rootCopy);
						cout << "1 -- You can keep up to 10 book copies." << endl;
						cout << "2 -- Each copy can be kept for up to 50 days." << endl;
						break;
					case 8:
						cout << "Enter new password: ";
						cin >> newPass;
						currentUser->value.changePassword(newPass);
						currentTeacher->value.changePassword(newPass);
						cout << "New password changed" << endl;
						break;
					case 0:
						cout << "Logging Out..." << endl;
						loggedout = true;
						break;
					}
				}
				else if (role == 2)
				{
				cout << "Welcome back, Librarian" << endl;
				cout << "1 -- Add Books" << endl;
				cout << "2 -- Delete Books" << endl;
				cout << "3 -- Search Users" << endl;
				cout << "4 -- Add Users" << endl;
				cout << "5 -- Delete Users" << endl;
				cout << "6 -- My Information" << endl;
				cout << "7 -- Change Password" << endl;
				cout << "8 -- Terminate Program" << endl;
				cout << "0 -- Log Out" << endl;
				cin >> input;
				switch (input)
				{
				case 1:
					currentLibrarian->value.addBooks(rootBook, rootCopy, last_id);
					printTree(rootBook);
					printTree(rootCopy);
					break;
				case 2:
					currentLibrarian->value.deleteBooks(rootCopy, rootBook);
					printTree(rootBook);
					printTree(rootCopy);
					break;
				case 3:
					currentLibrarian->value.searchUsers(rootUser, rootStudent, rootTeacher, rootLibrarian, rootBook, rootCopy);
					break;
				case 4:
					currentLibrarian->value.addUsers(rootUser, rootStudent, rootTeacher, rootLibrarian);
					printTree(rootUser);
					break;
				case 5:
					currentLibrarian->value.deleteUsers(rootUser, rootStudent, rootTeacher, rootLibrarian, rootBook);
					printTree(rootUser);
					break;
				case 6:
					cout << "-----------------My information-----------------" << endl;
					currentLibrarian->value.myInformation();
					break;
				case 7:
					cout << "Enter new password: ";
					cin >> newPass;
					currentUser->value.changePassword(newPass);
					currentLibrarian->value.changePassword(newPass);
					cout << "New password changed" << endl;
					break;
				case 8:
					cout << "Terminating program." << endl;
					endProgram();
					return 0;
					break;
				case 0:	
					cout << "Logging Out..." << endl;
					loggedout = true;
					break;
				default:
					cout << "Invalid operation." << endl;
				}
				}
				else
				{
					cout << "Error: role is not 0, 1, or 2" << endl;
				}
			}
		}
	}
}