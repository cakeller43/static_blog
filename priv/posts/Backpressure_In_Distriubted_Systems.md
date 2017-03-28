---

title: Backpressure in Distributed Systems
date: 2017-03-27
intro: When to use synchronous calls in your system.
img: /images/elixir-icon.png
author: Corey Keller

---

## The Problem

Asynchronous messaging in a distributed system is great! It allows for clients to move on with their lives without waiting on a response from the service. It can also enable sending messages when the service is unavailible.
However, async messaging has it's downsides as well. Unpredictable traffic or heavy load could cause this service to become overwhelmed and start providing unacceptable processing times.

Let's assume in the following diagram that there are 4 clients and each client sends 2 messages per second to `FooService`. While FooService can process up to 4 messages per second.

![overflow](/images/cm-blog/diag_1.png)

Clearly this will become a problem if the traffic continues at this rate. Processing times on newly sent messages will grow quickly while the queue will consume more and more memory.
There are a few solutions to this problem, one of which being to add an additional `FooService` to read from the queue, or you could utilize synchronicity.

## Synchronous Backpressure

Replacing the call with a synchronous one enables `FooService` to put pressure back on the clients in order to regulate it's traffic. Each client will be blocked while waiting for their
message to be processed, preventing them from sending any other messages. Sounds bad right? However, this means that the work queue can not have any more messages in it than the number of clients utilizing the service.
In this case, 4.

![backpressure](/images/cm-blog/diag_2.png)

Each client will now have to wait at most 1 second for it's request to finish processing. This limits the work `Foo` will need to do while also maintaining an consistent response time for each client.

There are a few things to keep in mind with this approach. 
1. This could provide an unpleasent user experience if the "client" is part of your front end.
2. The clients could be less performant when not using the "fire and forget" async messages.

Keep synchronous processing in mind if you can afford to push the time back to your clients and consistent time in message processing necessary.

## Load Shedding

Synchronicity is not the only way to handle out of control queues. Perhaps an even simpler solution is to have a limit on your queues and drop messages that are added over the limit.
Obviously you must be ok with losing a certain percentage of messages during high load, but this will allow clients to keep the "fire and forget" mentaility and protect your service from
being overwhelmed.

![load shedding](/images/cm-blog/diag_3.png)

The message loss can be mitigated by storing the dropped messages elsewhere or retrying with an exponential backoff strategy. Load shedding is a great way to maintain responsiveness on clients and control load as long as some message loss is acceptable.

// Discuss pull based services with buffers

## Pull Based Services

Instead of pushing work to the FooService, why don't we have it request work from the clients when it is ready? The basic idea of this is to push the message storing/queueing onto the clients
while the work queue for FooService stays at an acceptable level. A simple way to do this is to publish an event, e.g. `GatherFoo`, from `FooService` when it's work is low. `GatherFoo` is then consumed by the clients, which can offload some of their outbound queue onto the work queue.

![request work](/images/cm-blog/diag_4.png)

`FooService` requests work by publishing `GatherFoo`.

![receive work](/images/cm-blog/diag_5.png)

Clients send messages from their outbound queue to `FooService`.

The main benefit of this strategy is to spread the responsibility of storage across the system. 