/* 
Author: Dylan Li
ID: 114228567
Title: Simple Shell in C
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <fcntl.h>


struct node
{
    char* data;
	struct node* next;
};


void parse(char *line, char **argv)
{
    while (*line != '\0') {             /* if not the end of line ....... */
    
        while (*line == ' ' || *line == '\t' || *line == '\n')
        {
            *line++ = '\0';             /* replace white spaces with 0    */
        }
        
        if (*line == '"' && *line != '\0')				/* check for string		          */
        {
        	*argv++ = line;          	/* save the argument position     */
        	
        	line++;
        	while (*line != '"')
        	{
        		line++;
			}
		} else {
			if (*line != '\0')
			{
				*argv++ = line;
			}
		}
        
        while (*line != '\0' && *line != ' ' &&
            *line != '\t' && *line != '\n')
        {
            line++;                     /* skip the argument until ...    */
        }
    }
    
    *argv = '\0';
}


struct node* CreateLinkedList(char** argv)
{
	struct node* current = malloc(sizeof(struct node));
	struct node* root = current;
	
	// Create first node
	if (*argv != '\0')
	{
		current->data = *argv++;
		current->next = NULL;
    }
    else
    {
        fputs("No input detected\n", stdout);
        return root;
    }

	while (*argv != '\0')
	{
		// Create new node
		struct node* new_node = malloc(sizeof(struct node));

		// Argument put inside new node
		new_node->data = *argv++;
		new_node->next = NULL;

		// Point current to new node
		current->next = new_node;
		current = current->next;
	}
	

	return root;
}


void PrintCommands(struct node* root)
{
    struct node* save_root = root;
    char *cmds[64];
    int i = 0;

    // Get the commands and put into an array of strings
    cmds[i] = root->data;
    root = root->next;
    while (root != '\0')
    {
        if (strcmp(root->data, "|") == 0)
        {
            root = root->next;
            i++;
            cmds[i] = root->data;
        }

        root = root->next;
    }
    i++;
    cmds[i] = '\0';

    // Print commands
    fputs("Commands:", stdout);
    i = 0;
    while (cmds[i] != '\0')
    {
    	fputs(" ", stdout);
    	fputs(cmds[i], stdout);
        i++;
    }
    printf("\n");
    
    
    // Now, print the commands with their respective inputs
    i = 0;
    root = save_root;
    while (root != '\0')
    {
    	if (strcmp(root->data, "|") == 0)		// skip the pipe symbol
		{
			fputs("\n", stdout);
		} else if (root->data == cmds[i]) {
			fputs(root->data, stdout);
			fputs(":", stdout);
    		i++;
		} else {
			fputs(" ", stdout);
			fputs(root->data, stdout);
		}
    	
		
		root = root->next;
	}
	
	fputs("\n\n", stdout);
}


void execute(char **argv)
{


    struct node* root = CreateLinkedList(argv);
    pid_t pid, pid2;
    int fd, fd2;		// file descriptor
	int status;
	
    // Print the commands 
    PrintCommands(root);


	// Get arguments and handle command types
	char *cmds[64];		// the command and argument list
	int i = 0;
	while (root != '\0')
	{	
		if (strcmp(root->data, "|") == 0) {
			cmds[i] = '\0';		// Save the command argument before pipe
			++i;
			int j = i;			// point to after pipe
			int pfd[2];			// keep track of pipe

			
			pipe(pfd);		// pipe
			
			
			pid = fork();		// fork
			if (pid < 0)		// fork unsuccessful
			{
				fputs("Unsuccessful fork.", stdout);
				return;
			}
			else if (pid > 0)		// Parent
			{
				pid2 = fork();		// second fork

				if (pid2 < 0) {
					fputs("Unsuccessful fork.", stdout);
					return;
				}
				else if (pid2 > 0) {
					waitpid(pid2, &status, 0);
				}
				else {
					dup2(pfd[0], fileno(stdin));


					// Get the rest of the arguments
					while (root != '\0')
					{
						cmds[i] = root->data;
						root = root->next;
						i++;
					}
					cmds[i] = '\0';

					execvp(cmds[j], cmds + j);

					exit(-1);
				}


				waitpid(pid, &status, 0);
			}
			else {				// Child
				dup2(pfd[1], fileno(stdout));

				execvp(cmds[0], cmds);

				exit(-1);
			}

			close(pfd[0]);
			close(pfd[1]);

			return;
		}
		else if (strcmp(root->data, ">") == 0) {
			cmds[i] = '\0';

			// Find the file name
			root = root->next;
			if (root == '\0') { fputs("No file specified.\n", stderr); return; }
			
			// Open output file
			fd = open(root->data, O_WRONLY | O_CREAT | O_APPEND);
			if (fd == -1) { fputs("Error opening output file.\n", stderr); return; }
			
			// Duplicate the file
			fd2 = dup(1);
			dup2(fd, fileno(stdout));
			close(fd);


			pid = fork();
			if (pid < 0)		// fork unsuccessful
			{
				fputs("Unsuccessful fork.", stdout);
				return;
			}
			else if (pid > 0)		// Parent
			{
				waitpid(pid, &status, 0);
			}
			else {				// Child
				execvp(cmds[0], cmds);

				exit(-1);
			}

			dup2(fd2, fileno(stdout));
			close(fd2);

			return;
		}
		else if (strcmp(root->data, "<") == 0) {
			cmds[i] = '\0';

			// Find the file name
			root = root->next;
			if (root == '\0') { fputs("No file specified.\n", stderr); return; }
			
			// Open input file
			fd = open(root->data, O_RDONLY | O_EXCL);
			if (fd == -1) { fputs("Error opening input file.\n", stderr); return; }
			
			// Duplicate the file
			fd2 = dup(0);
			dup2(fd, 0);
			close(fd);


			pid = fork();
			if (pid < 0)		// fork unsuccessful
			{
				fputs("Unsuccessful fork.", stdout);
				return;
			}
			else if (pid > 0)		// Parent
			{
				waitpid(pid, &status, 0);
			}
			else {				// Child
				execvp(cmds[0], cmds);

				exit(-1);
			}

			dup2(fd2, fileno(stdin));
			close(fd2);

			return;
		}
		else if (strcmp(root->data, "&") == 0) {
			cmds[i] = '\0';

			pid = fork();
			if (pid < 0)		// fork unsuccessful
			{
				fputs("Unsuccessful fork.", stdout);
				return;
			}
			else if (pid == 0)	// Parent does not wait
			{
				execvp(cmds[0], cmds);
				
				exit(-1);
			}

			return;
		}
		else {
			cmds[i] = root->data;
			i++;
		}
		
		root = root->next;
	}
	
	// End of list (no special char)
	cmds[i] = '\0';
	pid = fork();
	if (pid < 0)		// fork unsuccessful
	{
		fputs("Unsuccessful fork.", stdout);
		return;
	}
	else if (pid > 0)		// Parent
	{
		waitpid(pid, &status, 0);
	}
	else {				// Child
		execvp(cmds[0], cmds);
		
		exit(-1);
	}

}





void main(void)
{
     char  line[1024];                          /* the input line                 */
     char  *argv[64];                           /* the command line argument      */

     while (1) {                                /* repeat until done ....         */
          fputs("Shell -> ",stdout);            /*   display a prompt             */
          fgets(line, 1024, stdin);             /*   read in the command line     */
          fputs("\n", stdout);
          parse(line, argv);                    /*   parse the line               */
          if (strcmp(argv[0], "exit") == 0) {   /*   check exit                   */
              exit(0);                          
          }
          execute(argv);                        /* otherwise, execute the command */
     }
}
