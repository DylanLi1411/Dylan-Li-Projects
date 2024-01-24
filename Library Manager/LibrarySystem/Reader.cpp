#include "library.h"
#include <vector>
#include <string>
#include <iostream>
using namespace std;

/* Search book functions (declared) */
void sortBooks(vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray, int date);
void sortTitle(vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray, int low, int high);
void sortAuthor(vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray, int low, int high);
void sortISBN(vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray, int low, int high);
void sortID(vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray, int low, int high);
void printSortedBooks(vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray, int date);
template <typename Type>
void quickSort(vector<Type>& array, int low, int high, vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray);
template <typename Type>
int partition(vector<Type>& array, int low, int high, vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray);
void copyBookToVectors(Book book, TreeNode<Copy>* copyTree, vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray);
void preorderTraversalTitle(TreeNode<Book>* bookTree, TreeNode<Copy>* copyTree, string title_compare, vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray);
void preorderTraversalCategory(TreeNode<Book>* bookTree, TreeNode<Copy>* copyTree, string category_compare, vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray);


/* Accessors */
int Reader::getMaxCopiesAllowed() { return 0; }		// See Teacher and Student function
int Reader::getMaxBorrowPeriod() { return 0; }		// See Teacher and Student function
int Reader::getBorrowListID(int index)
{
    auto ptr = borrow_list.begin();

    for (int i = 0; i < index; i++)
    {
        ++ptr;
    }

    return *ptr;
}
int Reader::getBorrowListSize() { return borrow_list.size(); }
int Reader::getReservedListISBN(int index)
{
    auto ptr = reserved_list.begin();

    for (int i = 0; i < index; i++)
    {
        ++ptr;
    }

    return *ptr;
}
int Reader::getReservedListSize() { return reserved_list.size(); }


/* Mutators */
void Reader::addToBorrowList(int id) { borrow_list.push_back(id); }
void Reader::removeFromBorrowList(int id) { borrow_list.remove(id); }
void Reader::addToReservedList(long long int isbn) { reserved_list.push_back(isbn); }
void Reader::removeFromReservedList(long long int isbn) { reserved_list.remove(isbn); }


/* Print Functions */
void Reader::myBorrowList(TreeNode<Book>* bookTree, TreeNode<Copy>* copyTree)
{
    TreeNode<Copy>* temp;
    TreeNode<Book>* temp2;

    // Go through Reader's borrowed list
    for (int i = 0; i < getBorrowListSize(); i++)
    {
        // Find matching ID in copyTree
        temp = search(copyTree, getBorrowListID(i));

        // Find matching ISBN in bookTree
        temp2 = search(bookTree, (temp->value).getISBN());

        // Print contents relating to that Copy
        cout << "ID: " << (temp->value).getID() << "    ";
		cout << "ISBN: " << (temp2->value).getISBN() << "   ";
        cout << "Title: " << (temp2->value).getTitle() << "    ";
        cout << "Author: " << (temp2->value).getAuthor() << "   ";
        cout << "Category: " << (temp2->value).getCategory() << "   " << endl;
    }
}
void Reader::myInformation()
{
    cout << "Username: " << getUsername() << endl;
    cout << "Password: " << getPassword() << endl;
    if (getRole() == 0)
    {
        cout << "Reader is a Student." << endl;
    }
    else
    {
        cout << "Reader is a Teacher" << endl;
    }
}


/* Reader Functions */
void Reader::searchBook(TreeNode<Book>* bookTree, TreeNode<Copy>* copyTree, int date) //(Dylan)
{
    // Initialize local variables
    int i;
    int choice;
    long long int isbn_compare;
    string title_compare;
    string category_compare;
    TreeNode<Book>* temp;
    TreeNode<Copy>* temp2;
    // These vectors will be used for sorting (similar to midterm project)
    vector<int> expireArray;
    vector<string> titleArray;
    vector<string> authorArray;
    vector<long long int> isbnArray;
    vector<int> idArray;
    vector<string> categoryArray;

    // Print out list of search options
    cout << "1: ISBN" << endl;
    cout << "2: Title" << endl;
    cout << "3: Category" << endl;
    cout << "(Enter number) Search by: ";
    cin >> choice;

    // Ask for the search key and match all books with that key
    switch (choice) {
    case 1:
        cout << "Enter ISBN: ";
        cin >> isbn_compare;

        // Find the Book class that matches the ISBN
        temp = search(bookTree, isbn_compare);

        // Find each copy of the Book class
        for (i = 0; i < (temp->value).getCopyListSize(); i++)
        {
            temp2 = search(copyTree, (temp->value).getCopyListID(i));

            // Put all information into the vectors
            expireArray.push_back((temp2->value).getExpireDate());
            titleArray.push_back((temp->value).getTitle());
            authorArray.push_back((temp->value).getAuthor());
            categoryArray.push_back((temp->value).getCategory());
            isbnArray.push_back((temp->value).getISBN());
            idArray.push_back((temp2->value).getID());
        }

        break;
    case 2:
        cout << "Enter Title: ";
        cin >> title_compare;

        // Find all Book classes that match the title key and put into vectors
        preorderTraversalTitle(bookTree, copyTree, title_compare, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);

        break;
    case 3:
        cout << "Enter Category: ";
        cin >> category_compare;

        // Find all Book classes that match the category key and put into vectors
        preorderTraversalCategory(bookTree, copyTree, category_compare, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);

        break;
    default:
        cout << "Invalid Choice." << endl;
        return;
    }


    // Display sorted array
    sortBooks(isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray, date);
    cout << endl << "Books found: " << endl;
    printSortedBooks(isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray, date);
}

void Reader::borrowBook(TreeNode<Copy>* copyTree, int id, int date) //(Dylan)
{
    // Initialize local variables
    int i;
    TreeNode<Copy>* temp;


    /* Check to see if reader can't borrow copies */
    // Check if the reader has any overdue copies
    for (i = 0; i < getBorrowListSize(); i++)
    {
        // Find matching copy from borrow list
        temp = search(copyTree, getBorrowListID(i));

        // Check if that copy is overdue, end function if true
        if ((temp->value).getExpireDate() < date)
        {
            cout << "You have overdue books." << endl;
            cout << "Copy ID: " << (temp->value).getID() << " is overdue." << endl;
            return;
        }
    }

    // Check if the reader is borrowing more than they are allowed
    if (getBorrowListSize() >= getMaxCopiesAllowed())
    {
        // If reader is trying to borrow more than allowed, end function
        cout << "Already holding max number of copies allowed." << endl;
        return;
    }

    // Find the specified copy
    temp = search(copyTree, id);

    // Check if copy even exists
    if (temp == NULL)
    {
        cout << "That ID does not exist." << endl;
        return;
    }

    // Check if someone else is borrowing that copy
    if (temp->value.getReaderName() != "")
    {
        // If copy is already with someone else, end function
        cout << "Someone else has that book copy." << endl;
        return;
    }

    // Check if someone is reserving that copy
    if (temp->value.getReserverName() != "")
    {
        // Check if copy was reserved by reader
        if (temp->value.getReserverName() == getUsername())
        {
            removeFromReservedList(temp->value.getISBN());
        }
        else    // If reader was not the one who reserved the copy, check if reservation is overdue
        {
            // If reader was not the one who reserved the copy, check if reservation is overdue
            if ((temp->value.getReserveDate() + 5) < date)
            {
                // Cancel reservation
                temp->value.deleteReservation();
            }
            else	// Otherwise, end function
            {
                cout << "Someone else is reserving that book copy." << endl;
                return;
            }
        }
    }


    /* All checks have passed. Reader can now borrow book. */
    (temp->value).setReaderName(getUsername());
    (temp->value).setStartDate(date);
    (temp->value).setExpireDate(date + getMaxBorrowPeriod());
    addToBorrowList(id);
    cout << "Borrowing book successful." << endl;
}

void Reader::returnBook(TreeNode<Book>* bookTree, TreeNode<Copy>* copyTree, int id, int date) //(Dylan)
{
    // Initialize local variables
    int i;
    TreeNode<Copy>* temp = search(copyTree, id);		// Find the specified copy


    // Check if the ID/copy even exists
    if (temp == NULL)
    {
        cout << "That ID does not exist." << endl;
        return;
    }

    // Check borrowed list is not empty
    if (getBorrowListSize() == 0)
    {
        cout << "You have no books to return." << endl;
        return;
    }

    // Find the Book class related to this copy
    TreeNode<Book>* temp2 = search(bookTree, (temp->value).getISBN());

    // Search through Reader's borrowed list
    for (i = 0; i < getBorrowListSize(); i++)
    {
        // Find the matching ID
        if (id == getBorrowListID(i))
        {
            // Remove from list
            removeFromBorrowList(id);

            // Make book copy available again
            (temp->value).returnCopy();

            // If there is a reserver
            if ((temp2->value).getReserverListSize() != 0)
            {
                // This book copy becomes reserved
                (temp->value).setReserveDate(date);
                (temp->value).setReserverName((temp2->value).getReserver(0));

                // Move linked list onto next reserver
                (temp2->value).removeReserver(0);
            }

            // Successfully returned book
            cout << "Successfully returned Book ID: " << id << endl;

            // Ask if reader liked the book
            char response;
            cout << "Did you like this book(Y/N)? ";
            cin >> response;

            if (response == 'Y')
            {
                (temp2->value).incFavorCount();
            }
            return;
        }
    }

    // If ID is not even in borrowed list, end function
    if (i == getBorrowListSize())
    {
        cout << "ID: " << id << " does not exist in your borrowed list." << endl;
        return;
    }
}

void Reader::renewBook(TreeNode<Book>* bookTree, TreeNode<Copy>* copyTree, int id, int date) //(Dylan)
{
    // Initialize local variables
    int i;
    TreeNode<Copy>* temp = search(copyTree, id);		// Find the specified copy
    TreeNode<Book>* temp2 = search(bookTree, temp->value.getISBN());	// Find related Book class


    // Check if the ID/copy even exists
    if (temp == NULL)
    {
        cout << "That ID does not exist." << endl;
        return;
    }

    // Check borrowed list is not empty
    if (getBorrowListSize() == 0)
    {
        cout << "You have no books to renew." << endl;
        return;
    }

    // Check that no one else has reserved a copy from the Book
    if ((temp2->value).getReserverListSize() != 0)
    {
        cout << "Someone else is reserving that book copy." << endl;
        return;
    }

    // Search through Reader's borrowed list
    for (i = 0; i < getBorrowListSize(); i++)
    {
        // Find the matching ID
        if (id == getBorrowListID(i))
        {
            // Renew book
            (temp->value).setStartDate(date);
            (temp->value).setExpireDate(date + getMaxBorrowPeriod());

            // Successfully renewed book
            cout << "Successfully renewed Book ID: " << id << endl;
            return;
        }
    }

    // If ID is not even in borrowed list, end function
    if (i == getBorrowListSize())
    {
        cout << "ID: " << id << " does not exist in your borrowed list." << endl;
        return;
    }
}

void Reader::reserveBook(TreeNode<Book>* bookTree, long long int isbn) //(Dylan)
{
    // Initialize local variables
    int i;
    TreeNode<Book>* temp = search(bookTree, isbn);		// Find the specified book class

    // Check if ISBN even exists
    if (temp == NULL)
    {
        cout << "That ISBN does not exist." << endl;
        return;
    }

    // Check if reader already reserved the book
    for (i = 0; i < getReservedListSize(); i++)
    {
        // Find the matching ISBN, end function if true
        if (isbn == getReservedListISBN(i))
        {
            cout << "You already reserved that book." << endl;
            return;
        }
    }

    // Otherwise, add reader to book's reserver list
    (temp->value).addReserver(getUsername());

    // Add book's isbn to reader's reserved list
    addToReservedList(isbn);

    // Successfully reserved book
    cout << "You sucessfully reserved Book ISBN: " << isbn << endl;
}

void Reader::cancelReservation(TreeNode<Book>* bookTree, long long int isbn) //(Dylan)
{
    // Initialize local variables
    int i;
    TreeNode<Book>* temp = search(bookTree, isbn);		// Find the specified book class

    // Check if ISBN even exists
    if (temp == NULL)
    {
        cout << "That ISBN does not exist." << endl;
        return;
    }

    // Look through Book class for reader's reservation
    for (i = 0; i < (temp->value).getReserverListSize(); i++)
    {
        // Find matching reservation
        if ((temp->value).getReserver(i) == getUsername())
        {
            // Remove from Book's linked list
            (temp->value).removeReserver(i);

            // Remove from reader's reserved list
            removeFromReservedList(isbn);

            // Success
            cout << "Successfully canceled reservation at Book ISBN: " << isbn << endl;
            return;
        }
    }

    // If can't find reservation, then it didn't exist in the first place
    cout << "You don't have a reservation at Book ISBN: " << isbn << endl;
}



/* Search book functions */
// Parameters: the ISBN, author, title, id, expiration datem and category of every book copy that has matched the search conditions
// Returns: sorts all arrays so that each element can be printed out in elemental ascending order
// Note: all arrays should have the same length/size
void sortBooks(vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray, int date)
{
    int i, j;

    // Put books in order by expire date in ascending order
    // A book with no borrower would have an expiration date of 0 or NULL (Note: There is no such thing as day 0, program starts at day 1)
    // Sorted by quicksort
    quickSort(expireArray, 0, expireArray.size() - 1, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);


    // Special case when expire dates are equal
    for (i = 1; i < expireArray.size(); i++)
    {
        j = i - 1;

        if (expireArray[i] == expireArray[i - 1])
        {
            while (expireArray[i] == expireArray[i - 1])
            {
                i++;

                // This is to prevent illegal memory access
                if (i >= expireArray.size())
                {
                    break;
                }
            }
            i--;

            sortTitle(isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray, j, i);
        }
    }
}


// Sort by title
void sortTitle(vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray, int low, int high)
{
    int lowest = low;
    int pos;
    int i;

    // Sort by quicksort
    quickSort(titleArray, low, high, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);


    // Special case when titles are equal
    pos = 0;
    for (i = low + 1; i < high + 1; i++)
    {
        pos = i - 1;

        if (titleArray[i] == titleArray[i - 1])
        {
            while (titleArray[i] == titleArray[i - 1])
            {
                i++;

                // This is to prevent illegal memory access
                if (i >= high + 1)
                {
                    break;
                }
            }
            i--;

            sortAuthor(isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray, pos, i);
        }
    }
}

// Sort by author
void sortAuthor(vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray, int low, int high)
{
    int lowest = low;
    int pos;
    int i;

    // Sort by quicksort
    quickSort(authorArray, low, high, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);


    // Special case when authors are equal
    pos = 0;
    for (i = low + 1; i < high + 1; i++)
    {
        pos = i - 1;

        if (authorArray[i] == authorArray[i - 1])
        {
            while (authorArray[i] == authorArray[i - 1])
            {
                i++;

                // This is to prevent illegal memory access
                if (i >= high + 1)
                {
                    break;
                }
            }
            i--;

            sortISBN(isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray, pos, i);
        }
    }
}


// Sort by ISBN
void sortISBN(vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray, int low, int high)
{
    int lowest = low;
    int pos;
    int i;

    // Sort by quicksort
    quickSort(isbnArray, low, high, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);


    // Special case when ISBNs are equal
    pos = 0;
    for (i = low + 1; i < high + 1; i++)
    {
        pos = i - 1;

        if (isbnArray[i] == isbnArray[i - 1])
        {
            while (isbnArray[i] == isbnArray[i - 1])
            {
                i++;

                // This is to prevent illegal memory access
                if (i >= high + 1)
                {
                    break;
                }
            }
            i--;

            sortID(isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray, pos, i);
        }
    }
}


// Sort by ID
void sortID(vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray, int low, int high)
{
    // Sort by quicksort
    quickSort(idArray, low, high, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);
}


// To be used right after the sortBooks function for easier printing
void printSortedBooks(vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray, int date)
{
    for (int i = 0; i < isbnArray.size(); i++)
    {
        if (expireArray[i] == 0)
        {
            cout << "Expire: " << "N/A" << "  ";
        }
        else
        {
            cout << "Expire: " << expireArray[i] - date << "  ";
        }
        cout << "Title: " << titleArray[i] << "  ";
        cout << "Author: " << authorArray[i] << "  ";
        cout << "ISBN: " << isbnArray[i] << "  ";
        cout << "ID: " << idArray[i] << "  ";
        cout << "Category: " << categoryArray[i] << endl;
    }
}



/* Quicksort*/
template <typename Type>
void quickSort(vector<Type>& array, int low, int high, vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray) {

    if (low < high) {

        // find the pivot element and move elements such that
        // elements smaller than pivot are on left of pivot
        // elements greater than pivot are on righ of pivot
        int pi = partition(array, low, high, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);

        // recursive call on the left of pivot
        quickSort(array, low, pi - 1, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);

        // recursive call on the right of pivot
        quickSort(array, pi + 1, high, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);
    }
}

// function to rearrange array (partition point = array[high])
template <typename Type>
int partition(vector<Type>& array, int low, int high, vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray) {
    long long int temp;
    string temp2;
    string temp3;
    int temp4;
    int temp5;
    string temp6;

    while (low < high)
    {
        while (array[low] > array[high])
        {
            temp = isbnArray[high];
			isbnArray[high] = isbnArray[low];

			temp2 = authorArray[high];
			authorArray[high] = authorArray[low];

            temp3 = titleArray[high];
			titleArray[high] = titleArray[low];

            temp4 = idArray[high];
			idArray[high] = idArray[low];

			temp5 = expireArray[high];
			expireArray[high] = expireArray[low];

			temp6 = categoryArray[high];
			categoryArray[high] = categoryArray[low];

            if ((high - low) > 1)
            {
				isbnArray[low] = isbnArray[high - 1];
				isbnArray[high - 1] = temp;

				authorArray[low] = authorArray[high - 1];
				authorArray[high - 1] = temp2;

				titleArray[low] = titleArray[high - 1];
				titleArray[high - 1] = temp3;

				idArray[low] = idArray[high - 1];
				idArray[high - 1] = temp4;

				expireArray[low] = expireArray[high - 1];
				expireArray[high - 1] = temp5;

				categoryArray[low] = categoryArray[high - 1];
				categoryArray[high - 1] = temp6;
            }
            else
            {
				isbnArray[low] = temp;

				authorArray[low] = temp2;

				titleArray[low] = temp3;

				idArray[low] = temp4;

				expireArray[low] = temp5;

				categoryArray[low] = temp6;
            }

            high--;
        }

        low++;
    }

    return high;
}

// Function to put everything into vectors given a Book class (unsorted)
void copyBookToVectors(Book book, TreeNode<Copy>* copyTree, vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray)
{
    for (int i = 0; i < book.getCopyListSize(); i++)
    {
        TreeNode<Copy>* temp = search(copyTree, book.getCopyListID(i));

        expireArray.push_back((temp->value).getExpireDate());
        titleArray.push_back(book.getTitle());
        authorArray.push_back(book.getAuthor());
        categoryArray.push_back(book.getCategory());
        isbnArray.push_back(book.getISBN());
        idArray.push_back((temp->value).getID());
    }
}

// Function to put everything into vectors given a Book root and title
void preorderTraversalTitle(TreeNode<Book>* bookTree, TreeNode<Copy>* copyTree, string title_compare, vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray) {
    // Check if root's Book matches with title
    if ((bookTree->value).getTitle() == title_compare)
    {
        // If found match, then copy Book to vectors
        copyBookToVectors(bookTree->value, copyTree, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);
    }

    // Check for left
    if (bookTree->left != NULL)
    {
        preorderTraversalTitle(bookTree->left, copyTree, title_compare, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);
    }

    // Check for right
    if (bookTree->right != NULL)
    {
        preorderTraversalTitle(bookTree->right, copyTree, title_compare, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);
    }
}

// Function to put everything into vectors given a Book root and category
void preorderTraversalCategory(TreeNode<Book>* bookTree, TreeNode<Copy>* copyTree, string category_compare, vector<long long int>& isbnArray, vector<string>& authorArray, vector<string>& titleArray, vector<int>& idArray, vector<int>& expireArray, vector<string>& categoryArray) {
    // Check if root's Book matches with category
    if ((bookTree->value).getCategory() == category_compare)
    {
        // If found match, then copy Book to vectors
        copyBookToVectors(bookTree->value, copyTree, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);
    }

    // Check for left
    if (bookTree->left != NULL)
    {
        preorderTraversalCategory(bookTree->left, copyTree, category_compare, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);
    }

    // Check for right
    if (bookTree->right != NULL)
    {
        preorderTraversalCategory(bookTree->right, copyTree, category_compare, isbnArray, authorArray, titleArray, idArray, expireArray, categoryArray);
    }
}