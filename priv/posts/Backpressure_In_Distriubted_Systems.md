---

title: Backpressure in Distributed Systems
date: 2017-03-27
intro: When to use synchronous calls in your system.
img: /images/elixir-icon.png
author: Corey Keller

---

## The Problem

Asynchronous messaging in a distributed system is great! Among other advantages it allows for clients to move on without waiting on a response from the service as well as send messages when the service is unavailible. However, async messaging has it's downsides as well. Unpredictable traffic or spikes in traffic could cause this service to become overwhelmed and start
providing unacceptable processing times, this is where synchronous messaging can help.

## 

Overflow a queue of a slow service
increases time before clients get their request processed