---

title: Erlang/Elixir Concurrency - Processes Part 2
date: 2017-02-28
intro: Overview of Elixir server processes and how to maintain state within a process.
img: /images/elixir-icon.png
author: Corey Keller

---
In part 1 we talked about Erlang processes at a high level and how they can be used to enable parallelization and concurrency in your system. It is often necessary to keep track 
of state in an application (for example, a "shopping cart"). However, this becomes a bit of a challenge since processes are disposed as soon as the execution of the code is complete. 
We will look at Elixir/Erlang's solution to this challenge.

## The Big Picture

Processes are garbage collected when execution is complete. Usually this is a great thing, it enables predictible load and keeps memory usage as low as possible on servers. However, 
when we want to keep state in a process that means we need to keep constant code execution. The solution? An infinite loop! In order to store state in a loop it needs to accept it's state
as a parameter and call itself recursivly passing in the same state.

```
defp loop(state) do
    
    loop(state)
end
```

## Tail Recursion

Something that should be mentioned when talking about this loop is `tail-call optimization`. A tail call occurs when the last action a function takes is to call another function. During a
tail call elixir does not perform a stack push. Instead, elixir simply "jumps" to the top of the loop. This does not allocate any more stack space and does not consume additional
memory. This means that tail-recursive functions can effectively run indefinitely without crashing the system. 


## Communicating With Our Process

So far we have a process that executes code that looks something like this.

```
def start_link(initialState) do
    loop(initialState)
end

defp loop(state) do
    
    loop(state)
end
```

When we start the process with `start_link/1` we initialize it's state and then it is kept in memory as the process continues to loop. However, this is not very useful since we cannot access
 or modify this state. If you remember from part 1, processes communicate via message passing and that is what we will leverage to interact with our state.  

 In elixir processes receive messages using the `receive` construct. `recieve` uses pattern matching to find messages in the process's mailbox and process them.

 ```
 receive do
    {:foo, message} -> IO.puts(message)
    {:message_signature, message} -> message
 end
 ```

If a message in the mailbox does not match any of these patterns, then it will stay in the mailbox and the `recieve` call will skip it.
 We can add this into our loop and use elixir's `send` function to interact with the state.

```
# pid = MyProcess.start_link(1)  # start the process
# send(pid, {:add, 5})           # send message to the process id of the new process.
# send(pid, {:print, []})        # send another message
# #=> 6                          # IO output from the process receiving our messages.
def start_link(initialState) do
    loop(initialState)
end

defp loop(state) do
    receive do
        {:print, message} -> IO.puts(state)
        {:add, message} -> state + message
    end
    loop(state)
end
```

Processes can even respond to messages that were passed to it. If the sender passes along their pid with the message, then we can simply send a response to the caller.

 ```
 # send(pid, {self(), "foo"}) # self() gets the current processes pid.
 receive do
    {caller, message} -> send(caller, message)) #echo message
 end
 ```

## GenServer

It may come as a relief to you that elixir has an abstraction for this stateful process we created, it is called a `GenServer`, or generic server. Elixir's GenServer behaviour
defines a set of functions that you can extend to customize the logic of your process, while hiding the recieve message loop behind it's abstraction. This is very similar to an
interface in object oriented programming. I recommend reading the [GenServer](https://hexdocs.pm/elixir/GenServer.html) documentation to get a basic idea of how to use it.

Two of the callbacks that you define are `handle_call\2` and `handle_cast\2`. These are the main functions that are called when a message is read from the mailbox. A `Call` is synchronous
execution while `Cast` is asynchronous execution. In the next post we will investigate when it makes sense to use a cast versus a call.