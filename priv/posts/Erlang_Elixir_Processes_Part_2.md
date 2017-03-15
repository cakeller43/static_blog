---

title: Erlang/Elixir Concurrency - Processes Part 2
date: 2017-02-28
intro: Overview of Elixir server processes and how to maintain state within a process.
img: /images/elixir-icon.png
author: Corey Keller

---
In part 1 we talked about Erlang processes at a high level general and how they can be used to enable parallelization and concurrency in your system. It is often necessary to keep track 
of state in an application(for example, a "shopping cart"). However, this becomes a bit of a challenge since processes are disposed as soon as the execution of the code is complete. 
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