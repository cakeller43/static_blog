---

title: Erlang/Elixir Concurrency - Processes
date: 2017-01-21
intro: Overview of Elixir processes and how they enable parallelization and concurrency.
img: /images/elixir-icon.png
author: Corey Keller

---
## The Big Picture

Processes are the basic building blocks of parallelization and concurrency on the Erlang VM. Simply put, a process is code that is running in isolation. 
An important distinction that must be made is that a Elixir process is not related to OS processes. Elixir processes are much smaller, sometimes as small as a few kilobytes,
and can be created/destroyed with minimal overhead. It is not uncommon to have thousands of processes running simultaneously. 
The following diagram shows the relation between the OS, VM, and processes.  

![big picture](/images/Elixir_Processes_Part1/1_big_picture.png)

As you can see whole VM is hosted in a single OS process. The schedulers in BEAM manage the workload of processes.
There is one scheduler per thread on the cpu which allows BEAM to optimize code execution for the hardware. Each one of these
schedulers has a work queue of processes. These processes get executed for a limited amount of time and then the scheduler moves onto the next 
process putting the current process at the end of the queue. This continues until the process is finished executing, it is then removed from the queue.
This is the general strategy for how BEAM will manage code execution in your application, now let's take a look at processes specifically.

## The Process

So far, you may be thinking that processes sound a lot like functions or methods, however processes have some unique traits.
    
    Processes do not share memory.

This is perhaps the most important trait of processes. This allows code to be executed across many cores or machines
without worrying about side effects or mutation of data. This means that if a process needs to send data to another process the data must be *deep copied* to the other processes memory. 

    Processes run in isolation.

As you saw in the first diagram each process is self-contained and executed individually. This is possible because of the independent memory. Because processes are isolated, if an error occurs during execution, such as a network timeout, the disrupted process
can simply be restarted and tried again by it's supervisor with no ill side effects.

    Processes communicate with message passing.

Processes are identified by a `pid` or *process id*. You can think of this kind of like an ip address. Other processes will send messages to this `pid` in order to communicate.
These ids are unique across VMs which means if you had two BEAMs running on different machines you could send a message regardless of where the process actually was located.
This also encourages a "fire and forget" mentality where the sending process can assume success and let the receiving process handle failures.

You can visualize that a process looks something like this.

![process](/images/Elixir_Processes_Part1/2_process.png)

## Wrap up

We discussed the basics of elixir processes and how they are used to parallelize the execution of code on a machine.
This is just one type of process however. What if you wanted a process to hold state? For example, a process that reads text from a file and needs 
to keep track of what has been read. Once a process can hold state, it begins to look less like a method and more like an object from object oriented languages.
We will discuss how we can accomplish this next time.