---

title: Backpressure in Distributed Systems
date: 2017-03-27
intro: When to use synchronous calls in your system.
img: /images/elixir-icon.png
author: Corey Keller

---
## Backpressure in Message Based Systems.

Asynchronous messaging in a distributed system is great! It allows for clients to move on with their lives without waiting on a response from the service. It canalso enable sending messages when the service is unavailible.
However, async messaging has it's downsides as well. Unpredictable traffic or spikes in traffic could cause this service to become overwhelmed and start providing unacceptable processing times.

Let's assume in the following diagram that there are 4 clients and each client sends 2 messages per second to `FooService`. While FooService can process up to 4 messages per second.

![overflow](/images/cm-blog/diag_1.png)

Clearly this will become a problem if the traffic continues at this rate. Processing times on newly sent messages will grow quickly while the queue will consume more and more memory.
There are a few solutions to this problem, one of which being to add additional an `FooService` to read from the queue, or you could utilize synchronicity.

Replacing the call with a synchronous one enables `FooService` to put pressure back on the clients in order to regulate it's traffic. Each client will be blocked while waiting for their
message to be processed, preventing them from sending any other messages. Sounds bad right? However, this means that the work queue can not have any more messages in it than the number of clients utilizing the service.
In this case, 4.

![backpressure](/images/cm-blog/diag_2.png)

Each client will now have to wait at most 1 second for it's request to finish processing. This limits the work `Foo` will need to do while also maintaining an acceptable response time for each client.

There are a few things to keep in mind with this approach. 
1. This could provide an unpleasent user experience if the "client" is part of your front end.
2. The clients could be less performant when not using the "fire and forget" async messages.

This is of course not the only solution to implement backpressure in your system, another simple example is to let new messages drop off the queue at a certain limit (assuming message loss is acceptable).
Keep synchronous processing in mind if you can afford to push the time back to your clients and consistent time in message processing necessary.
