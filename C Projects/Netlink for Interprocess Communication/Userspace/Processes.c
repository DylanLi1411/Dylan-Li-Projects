// Author: Dylan Li
// This program uses netlink to allow processes to communicate with one another

#include <linux/netlink.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
#include <pthread.h>

#define NETLINK_USER 31

#define MAX_PAYLOAD 1024 /* maximum payload size*/
pthread_t tid[2];                 // thread ids


// Function for Publish
void *Publish(void *vargp) {
    struct sockaddr_nl src_addr, dest_addr;
    struct nlmsghdr *nlh = NULL;
    struct iovec iov;
    int sock_fd;
    struct msghdr msg;
    char user_msg[MAX_PAYLOAD];


    sock_fd = socket(PF_NETLINK, SOCK_RAW, NETLINK_USER);
    if (sock_fd < 0)
        return -1;

    memset(&src_addr, 0, sizeof(src_addr));
    src_addr.nl_family = AF_NETLINK;
    src_addr.nl_pid = getpid(); /* self pid */

    bind(sock_fd, (struct sockaddr *)&src_addr, sizeof(src_addr));

    memset(&dest_addr, 0, sizeof(dest_addr));
    dest_addr.nl_family = AF_NETLINK;
    dest_addr.nl_pid = 0; /* For Linux Kernel */
    dest_addr.nl_groups = 0; /* unicast */

    nlh = (struct nlmsghdr *)malloc(NLMSG_SPACE(MAX_PAYLOAD));
    memset(nlh, 0, NLMSG_SPACE(MAX_PAYLOAD));
    nlh->nlmsg_len = NLMSG_SPACE(MAX_PAYLOAD);
    nlh->nlmsg_pid = getpid();
    nlh->nlmsg_flags = 0;

    iov.iov_base = (void *)nlh;
    iov.iov_len = nlh->nlmsg_len;
    msg.msg_name = (void *)&dest_addr;
    msg.msg_namelen = sizeof(dest_addr);
    msg.msg_iov = &iov;
    msg.msg_iovlen = 1;



    // Will take user input forever
    while(1)
    {
        char payload[MAX_PAYLOAD + 1] = "p";

        fgets(user_msg, MAX_PAYLOAD, stdin);
        strcat(payload, user_msg);      // combine marker with message
        
        strcpy(NLMSG_DATA(nlh), payload);
        sendmsg(sock_fd, &msg, 0);          // send to kernel
        printf("Message sent!\n");
    }


    close(sock_fd);

    return NULL;
}


// Function for threads
void *Subscribe(void *vargp) {

    struct sockaddr_nl src_addr, dest_addr;
    struct nlmsghdr *nlh = NULL;
    struct iovec iov;
    int sock_fd;
    struct msghdr msg;
    char user_msg[MAX_PAYLOAD];

    sock_fd = socket(PF_NETLINK, SOCK_RAW, NETLINK_USER);
    if (sock_fd < 0)
        return -1;

    memset(&src_addr, 0, sizeof(src_addr));
    src_addr.nl_family = AF_NETLINK;
    src_addr.nl_pid = getpid(); /* self pid */

    bind(sock_fd, (struct sockaddr *)&src_addr, sizeof(src_addr));

    memset(&dest_addr, 0, sizeof(dest_addr));
    dest_addr.nl_family = AF_NETLINK;
    dest_addr.nl_pid = 0; /* For Linux Kernel */
    dest_addr.nl_groups = 0; /* unicast */

    nlh = (struct nlmsghdr *)malloc(NLMSG_SPACE(MAX_PAYLOAD));
    memset(nlh, 0, NLMSG_SPACE(MAX_PAYLOAD));
    nlh->nlmsg_len = NLMSG_SPACE(MAX_PAYLOAD);
    nlh->nlmsg_pid = getpid();
    nlh->nlmsg_flags = 0;

    strcpy(NLMSG_DATA(nlh), "s");

    iov.iov_base = (void *)nlh;
    iov.iov_len = nlh->nlmsg_len;
    msg.msg_name = (void *)&dest_addr;
    msg.msg_namelen = sizeof(dest_addr);
    msg.msg_iov = &iov;
    msg.msg_iovlen = 1;

    // Notify the kernel to add the process to the kernel linked list
    printf("Adding process %d to the kernel list.\n", getpid());
    sendmsg(sock_fd, &msg, 0);

    
    while(1)
    {
        // Clear the data before printing new message
        memset(NLMSG_DATA(nlh), 0, MAX_PAYLOAD);

        // Get message from kernel
        recvmsg(sock_fd, &msg, 0);

        printf("Received message payload: %s\n", (char*)NLMSG_DATA(nlh));
    }


    close(sock_fd);

    return NULL;
}




int main()
{

    // Just type anything into the terminal and press Enter to send data
    printf("A process has been created.\nType anything into the terminal and press ENTER to send data.\nIncoming data will automatically be shown in the terminal\n");


    // Create the threads
    pthread_create(&tid[0], NULL, Publish, (void *)&tid[0]);
    pthread_create(&tid[1], NULL, Subscribe, (void *)&tid[1]);
    
    // Close threads
    pthread_join(tid[0], NULL);
    pthread_join(tid[1], NULL);



    return 0;
}
