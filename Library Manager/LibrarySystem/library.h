#pragma once
#include <iostream>
#include <string>
#include <list>
using namespace std;

class Book;
class Student;
class Teacher;
class User;
class Reader;
class Librarian;
class Copy;

// Binary TreeNode class definition
template <class Type>
struct TreeNode {
	Type value;

	TreeNode<Type>* left;
	TreeNode<Type>* right;

	TreeNode() : left(nullptr), right(nullptr) {}
	TreeNode(Type x) : value(x), left(nullptr), right(nullptr) {}
	TreeNode(Type x, TreeNode<Type>* left, TreeNode<Type>* right) : value(x), left(left), right(right) {}
};

// Reserver linked list class definition
struct ReserverNode
{
	string name;
	ReserverNode* next;

	ReserverNode() : next(nullptr) {}
	ReserverNode(string x) : name(x), next(nullptr) {}
	~ReserverNode() {}
};


/*********************************************** User Classes and Functions ***********************************************/
class User
{
	protected:
		string username;
		string password;
		int role;
	public:
		/* Template Variables */
		string main_key = username;

		/* Accessors */
		string getUsername();
		string getPassword();
		int getRole();

		/* Mutators */
		void setUsername(string user);
		void setPassword(string pass);
		void setRole(int r);
		void changePassword(string pass);

		/* Print Functions */
		virtual void myInformation();

		/* Operators */
		bool operator < (User& right);
		bool operator > (User& right);
};

class Librarian : public User
{
	public:
		/* Constructors */
		Librarian();
		Librarian(string user, string pass);

		/* Print Functions */
		void myInformation();

		/* Librarian Functions */
		void addBooks(TreeNode<Book>* root, TreeNode<Copy>*c_root, int& last_id);
		void deleteBooks(TreeNode<Copy>* root, TreeNode<Book>* b_root);
		void searchUsers(TreeNode<User>* u_root, TreeNode<Student>* s_root, TreeNode<Teacher>* t_root, TreeNode<Librarian>* l_root, TreeNode<Book>* b_root, TreeNode<Copy>* c_root);
		void addUsers(TreeNode<User>* u_root, TreeNode<Student>* s_root, TreeNode<Teacher>* t_root, TreeNode<Librarian>* l_root);
		void deleteUsers(TreeNode<User>* u_root, TreeNode<Student>* s_root, TreeNode<Teacher>* t_root, TreeNode<Librarian>* l_root, TreeNode<Book>* b_root);
};


class Reader : public User
{
	protected:
		list<int> borrow_list;				//contains ID of each copy
		list<long long int> reserved_list;	//contains ISBN of each Book class
	public:
		/* Accessors */
		virtual int getMaxCopiesAllowed();
		virtual int getMaxBorrowPeriod();
		int getBorrowListID(int index);
		int getBorrowListSize();
		int getReservedListISBN(int index);
		int getReservedListSize();

		/* Mutators */
		void addToBorrowList(int id);
		void removeFromBorrowList(int id);
		void addToReservedList(long long int isbn);
		void removeFromReservedList(long long int isbn);

		/* Print Functions */
		void myBorrowList(TreeNode<Book>* bookTree, TreeNode<Copy>* copyTree);
		void myInformation();

		/* Reader Functions */
		void searchBook(TreeNode<Book>* bookTree, TreeNode<Copy>* copyTree, int date);
		void borrowBook(TreeNode<Copy>* copyTree, int id, int date);
		void returnBook(TreeNode<Book>* bookTree, TreeNode<Copy>* copyTree, int id, int date);
		void renewBook(TreeNode<Book>* bookTree, TreeNode<Copy>* copyTree, int id, int date);
		void reserveBook(TreeNode<Book>* bookTree, long long int isbn);
		void cancelReservation(TreeNode<Book>* bookTree, long long int isbn);
};

class Student : public Reader
{
	public:
		/* Constructors */
		Student();
		Student(string user, string pass);

		/* Accessors */
		int getMaxCopiesAllowed();
		int getMaxBorrowPeriod();
};

class Teacher : public Reader
{
	public:
		/* Constructors */
		Teacher();
		Teacher(string user, string pass);

		/* Accessors */
		int getMaxCopiesAllowed();
		int getMaxBorrowPeriod();
};



/*********************************************** Book Classes and Functions ***********************************************/
class Book
{
	private:
		long long int ISBN;
		string author, title, category;
		list<int> copyList;				//contains ID of each copy(used to relate Book class back to Copy)
		ReserverNode* reserverHead;		//pointer to head of linked list
		int favor_count;
	public:
		/* Template Variables */
		long long int main_key = ISBN;

		/* Constructors */
		Book();
		Book(long long int isbn, string tt, string auth, string cat);

		/* Accessors */
		long long int getISBN();
		string getAuthor();
		string getTitle();
		string getCategory();
		int getCopyListID(int index);
		int getCopyListSize();
		string getReserver(int index);
		int getReserverListSize();
		int getFavorCount();

		/* Mutators */
		void setISBN(long long int isbn);
		void setAuthor(string auth);
		void setTitle(string tt);
		void setCategory(string cat);
		void addCopy(int id);
		void removeCopy(int id);
		void addReserver(string name);
		void removeReserver(int index);
		void incFavorCount();

		/* Operators */
		void operator <<(ostream& output);
		void operator >>(istream& input);
		void operator =(Book& book);
		bool operator < (Book& right);
		bool operator > (Book& right);
};

class Copy
{
	private:
		long long int ISBN;			//use to relate copy back to its Book class
		int ID;
		string reader_name;
		int start_date;
		int expire_date;
		string reserver_name;		//name of the first person in queue to reserve this copy
		int reserve_date;			//start time when copy is available for first reserver
	public:
		/* Template Variables */
		int main_key = ID;

		/* Constructors */
		Copy();
		Copy(long long int isbn, int id);

		/* Accessors */
		long long int getISBN();
		int getID();
		string getReaderName();
		string getReserverName();
		int getReserveDate();
		int getStartDate();
		int getExpireDate();

		/* Mutators */
		void setReaderName(string name);
		void setReserverName(string name);
		void setReserveDate(int date);
		void setStartDate(int date);
		void setExpireDate(int date);

		/* Copy Functions */
		void deleteReservation();
		void returnCopy();

		/* Operators */
		void operator >> (ostream& output);
		bool operator < (Copy& right);
		bool operator > (Copy& right);
};

/*
template <class T, typename Type>
class DataHolder
{
	public:
		Type main_key = T.main_key;
};
*/

/*********************************************** Binary Tree Functions ***********************************************/

template <typename Type>
TreeNode<Type>* addElement(Type val, TreeNode<Type>* root) {

	TreeNode<Type>* newNode = new TreeNode<Type>(val);
	/* If the tree is empty, return a new node */
	if (root == NULL)
	{
		return newNode;
	}


	//It is sorted in ascending order
	if (val < root->value)
		root->left = addElement(val, root->left);	
	else
		root->right = addElement(val, root->right);


	return root;

}

template <typename Type, typename Type2>
TreeNode<Type>* addElementUsers(Type2 val, TreeNode<Type>* root) {

	TreeNode<Type>* newNode = new TreeNode<Type>(val);
	/* If the tree is empty, return a new node */
	if (root == NULL)
	{
		return newNode;
	}


	//It is sorted in ascending order
	if (val < root->value)
		root->left = addElementUsers(val, root->left);
	else
		root->right = addElementUsers(val, root->right);


	return root;

}

template <typename Type>
void printValueAtNode(TreeNode<Type>* root)
{
	if (root == NULL)
		return;

	//inorder traversal
	printValueAtNode(root->left);
	cout << root->value.main_key << " ";
	printValueAtNode(root->right);
}

template <typename Type>
void printTree(TreeNode<Type>* root)
{
	if (typeid(Type) == typeid(Book))
		cout << "Books tree: ";

	if (typeid(Type) == typeid(Copy))
		cout << "Copies tree: ";

	if (typeid(Type) == typeid(Student))
		cout << "Student tree: ";

	if (typeid(Type) == typeid(Teacher))
		cout << "Teacher tree: ";

	if (typeid(Type) == typeid(Librarian))
		cout << "Librarian tree: ";

	if (typeid(Type) == typeid(User))
		cout << "Users tree: ";

	printValueAtNode(root);

	cout << endl;
}

template <typename Type>
TreeNode<Type>* minValueNode(TreeNode<Type>* node)
{
	TreeNode<Type>* current = node;

	while (current && current->left != NULL)
		current = current->left;

	return current;
}


template <class classType, typename Type>
TreeNode<classType>* removeElement(Type key, TreeNode<classType>* root)
{

	// base case
	if (root == NULL)
		return root;

	// If the key to be deleted is
	// smaller than the root's
	// key, then it lies in left subtree
	if (key < (root->value).main_key)
		root->left = removeElement(key, root->left);

	// If the key to be deleted is
	// greater than the root's
	// key, then it lies in right subtree
	else if (key > (root->value).main_key)
		root->right = removeElement(key, root->right);

	// if key is same as root's key, then This is the node
	// to be deleted
	else {
		// node has no child
		if (root->left == NULL and root->right == NULL)
			return NULL;

		// node with only one child or no child
		else if (root->left == NULL) {
			TreeNode<classType>* temp = root->right;
			delete root;
			return temp;
		}
		else if (root->right == NULL) {
			TreeNode<classType>* temp = root->left;
			delete root;
			return temp;
		}

		// node with two children: Get the inorder successor
		// (smallest in the right subtree)
		TreeNode<classType>* temp = minValueNode(root->right);

		// Copy the inorder successor's content to this node
		root->value = temp->value;

		// Delete the inorder successor
		root->right = removeElement((temp->value).main_key, root->right);
	}

	return root;
}

template <typename Type>
TreeNode<Type>* removeElementUsers(string key, TreeNode<Type>* root)
{

	// base case
	if (root == NULL)
		return root;

	// If the key to be deleted is
	// smaller than the root's
	// key, then it lies in left subtree
	if (key < (root->value).main_key)
		root->left = removeElement(key, root->left);

	// If the key to be deleted is
	// greater than the root's
	// key, then it lies in right subtree
	else if (key > (root->value).main_key)
		root->right = removeElement(key, root->right);

	// if key is same as root's key, then This is the node
	// to be deleted
	else {
		// node has no child
		if (root->left == NULL and root->right == NULL)
			return NULL;

		// node with only one child or no child
		else if (root->left == NULL) {
			TreeNode<Type>* temp = root->right;
			delete root;
			return temp;
		}
		else if (root->right == NULL) {
			TreeNode<Type>* temp = root->left;
			delete root;
			return temp;
		}

		// node with two children: Get the inorder successor
		// (smallest in the right subtree)
		TreeNode<Type>* temp = minValueNode(root->right);

		// Copy the inorder successor's content to this node
		root->value = temp->value;

		// Delete the inorder successor
		root->right = removeElementUsers((temp->value).main_key, root->right);
	}

	return root;
}

// Function to search through any binary tree
// Assuming operator overloads
// Returns a node pointer to the matching node; Returns NULL if no such node exists
template <class classType, typename searchType>
TreeNode<classType>* search(TreeNode<classType>* head, searchType search_key)
{
	// Base case
	if ((head->value).main_key == search_key)
		return head;

	if (search_key < (head->value).main_key && head->left != NULL)
		return search(head->left, search_key);

	else if (search_key > (head->value).main_key && head->right != NULL)
		return search(head->right, search_key);




	//DataHolder<classType, searchType> tempClass;
	//tempClass.main_key = (head->value).main_key;




	return NULL;
}