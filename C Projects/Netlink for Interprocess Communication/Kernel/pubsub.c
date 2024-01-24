// Author: Dylan Li
// This is the code for the linux kernel to allow interprocess communication

#include <linux/module.h>
#include <net/sock.h>
#include <linux/netlink.h>
#include <linux/skbuff.h>

#define NETLINK_USER 31
#define PUB_MARKER 'p'		// *** a char of 'p' or 's' will be used to define type of process
#define SUB_MARKER 's'

struct sock *nl_sk = NULL;	// This will point to a netlink socket created in initial kernel function

// Kernel lined list node declaration HERE
struct mystruct {
     int data ;				// ******** data = pid
     struct list_head mylist ;
} ;

// HEAD OF LINKED LIST HERE
LIST_HEAD(klist);		// klist shall be the name of the head



// USED TO FREE MEMORY UPON EXIT
void free_kernel_linked_list(struct list_head *head) {
    struct mystruct *ptr, *next;

    // Traverse the list and free memory
    list_for_each_entry_safe(ptr, next, head, mylist) {
        list_del(&ptr->mylist);
        kfree(ptr);
    }
}




static void hello_nl_recv_msg(struct sk_buff *skb)		// **** I suspect a socket buffer is what publisher sends to kernel
{
    struct nlmsghdr *nlh;		// pointer to netlist message header
	struct sk_buff *skb_out;	// socket buffer pointer for ouput to sub
	int msg_size;				// will be used later for function arguments
	char *total_payload;			// contain message + marker
	char *msg;					// will be used to store actual message
	int res;					// this is used to check for error
	int pid_p;					// gotta save this cause netlink header gets renewed


	nlh = (struct nlmsghdr *)skb->data;
	total_payload = nlmsg_data(nlh);
	pid_p = nlh->nlmsg_pid;

	// Detemine whether something is subscribing or publishing
	if (*total_payload == PUB_MARKER) {		// Publisher has sent something
    	
		msg = total_payload + 1;	// *** this should have the message from the header from publisher
		msg_size = strlen(msg);
		
		printk(KERN_INFO "Netlink received msg: %s\n", msg);   // (ignore) see what was sent
	} 
	else {		// Subscriber wants to subscribe
		// WE NEED TO EXTEND THE LINKED LIST

		// Create it
		struct mystruct *new_node = kmalloc(sizeof(struct mystruct), GFP_KERNEL);
		if (!new_node) {
			printk(KERN_ERR "Failed to allocate memory for new node\n");
		return;
		}
		new_node->data = nlh->nlmsg_pid;
		INIT_LIST_HEAD( & new_node->mylist ) ;

		// Then add it
		list_add ( &new_node->mylist , &klist ) ;

		printk(KERN_INFO "Process %d has been added.\n", new_node->data);

		// Debug the whole list
		struct mystruct  *datastructureptr = NULL ; 
		list_for_each_entry ( datastructureptr , & klist, mylist ) 
			{ 
				printk ("Found pid  =  %d\n" , datastructureptr->data ); 
			}
		

		return;		// don't send anything
	}




	// Send message to every process except the sender
	struct mystruct  *datastructureptr = NULL ;
	list_for_each_entry ( datastructureptr , &klist, mylist ) 	// use this macro
	{
		/*************************/
		skb_out = nlmsg_new(msg_size, 0);		// *****make a new socket buffer for each sub
		if (!skb_out) {				// (ignore) just check for error
			printk(KERN_ERR "Failed to allocate new skb\n");
	    	return;
		}

		nlh = nlmsg_put(skb_out, 0, 0, NLMSG_DONE, msg_size, 0);  // **** add new netlink message
		NETLINK_CB(skb_out).dst_group = 0; /* (keep) not in mcast group */
		strncpy(nlmsg_data(nlh), msg, msg_size);		// copy msg data to new netlink
		/**************************/


		if (datastructureptr != NULL && datastructureptr->data != pid_p) {
			res = nlmsg_unicast(nl_sk, skb_out, datastructureptr->data);		// pid argument is the subscriber
			if (res < 0) { printk(KERN_INFO "Error while sending back to subscriber %d\n", datastructureptr->data); }
		} else if (datastructureptr->data == pid_p) {
			printk(KERN_INFO "Message from %d has been sent\n", pid_p);
		}
	

	}

}

static int __init hello_init(void)	// happens upon kernel getting installed (initialization) ignore
{

    printk("Entering: %s\n", __FUNCTION__); // (ignore) just print function name
    struct netlink_kernel_cfg cfg = {		// function being passed
        .input = hello_nl_recv_msg,
    };

    nl_sk = netlink_kernel_create(&init_net, NETLINK_USER, &cfg);  // to here
    if (!nl_sk) {										// (ignore) just check for error
        printk(KERN_ALERT "Error creating socket.\n");
        return -10;
    }

    return 0;
}

static void __exit hello_exit(void)		// we need to free memory
{
	// Free memory
	free_kernel_linked_list(&klist);


	printk("All memory allocated has been freed.\n");
    printk(KERN_INFO "exiting hello module\n");
    netlink_kernel_release(nl_sk);
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
