---

title: Minimal Api with Elixir, Cowboy and Plug 
date: 2016-09-26
intro: How to make a simple api that responds to requests with only cowboy and plug as dependencies. 
img: /images/elixir-icon.png
author: Corey Keller

---
I started working with the [Phoenix](http://www.phoenixframework.org/) framework recently, and I have really enjoyed it. 
Phoenix made it simple to set up a functioning website with routing almost instantly. This made me wonder how it worked behind the scenes 
and what was **actually** necessary to respond to an http request.

If you don't already have Elixir installed go ahead and install it. It should be all you need!   
<http://elixir-lang.org/install.html>
## Let's get started!

We will start by making a new project with Mix. Mix the build tool for Elixir, it contains many useful commands 
for creating, building, and testing your project. Open a command prompt or terminal and run this command to make a new project.

```
mix new min_api --sup
```

*Note:* --sup initializes a basic supervisor tree. I will go over what this does and why we need it later.

You should see output similar to this.

![mix new](/images/Minimal_Api_Cowboy_Plug/1_mix_new.PNG)

Mix creates the project with a skeleton structure and a working test! 

![mix test](/images/Minimal_Api_Cowboy_Plug/2_mix_test.PNG)
```
min_api  
|   .gitignore
|   mix.exs
|   README.md
|
+---config
|       config.exs
|
+---lib
|       min_api.ex
|
\---test
        min_api_test.exs
        test_helper.exs
```
I will give a brief description of the files that are generated by mix. 
You can find a more detailed description [here](http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html). 
It is worth noting that files with a .exs extension are not compiled during a build of the project unlike .ex files. Most test and config files are scripts (.exs).  

`_build` - Build artifacts go here.  

`mix.exs` - This is where you specify dependencies and start 3rd party applications such as cowboy. You can specify dependencies from [Hex](https://hex.pm/) (package manager for the Erlang ecosystem) and github.  

`.gitignore` - Default gitignore for Elixir projects.  

`README.md` - Readme markdown file for github repos.  

`config.exs` - This is a config file that can be used to configure your applications in the project. Environment specific config files can also be imported through this one.  

`lib` - Your elixir files and modules.  

`min_api.ex` - This is where your application is started and where workers and supervisors are set up.  

`min_api_test.exs` - Basic test file with an example test written. Tests are written in ExUnit by default.  

`test_helper.exs` - File that initializes ExUnit to run tests.  

## Adding packages

After we have our project setup, the next step is to add our dependencies. 
We need to add [Cowboy](https://github.com/ninenines/cowboy) and [Plug](https://github.com/elixir-lang/plug).
Cowboy is a web server written in Erlang which provides routing and dispatching of requests. While Plug is both 
"A specification for composable modules between web applications" and a set of prebuilt connection adapters that we can use with Cowboy.  

Go ahead and open up `mix.exs`. Let's add the two packages to the `deps` list at the bottom of the file.

![add deps](/images/Minimal_Api_Cowboy_Plug/3_deps.PNG)

After you add these go back to your console and pull the packages down using mix.

```
mix deps.get
```

![deps get](/images/Minimal_Api_Cowboy_Plug/4_deps_get.PNG)

Also in `mix.exs` we need to specify which other applications are dependencies and should be started when we start the Api.
 We need to add Cowboy and Plug to this list.  

![deps get](/images/Minimal_Api_Cowboy_Plug/5_deps_apps.PNG)  

## Creating the router

Now that we have our dependencies we can start writing our router.
 Create a new folder in lib called `min_api` and inside it add a new elixir file called `Router.ex`.
  In here we are going to define a new module named `MinApi.Router`. We need to do two things in our router.

  * Setup the prebuilt Plug Router
  * Define a route

![router](/images/Minimal_Api_Cowboy_Plug/6_router.PNG)

  We setup the Plug.Router by including the router via the `use` ketword and defining the plugs `:match` and `:dispatch`. 
  The `:match` plug uses pattern matching to find a defined route based on an incoming request, then forwards the request to `:dispatch` who sends it to the matched route.
  After we setup the Plug.Router we can use Plug's macros for defining routes. We can define a "home" router with "/".
    
  ```
  Note: A Plug is a function that accepts a connection with a set of options and returns a new connection
  ```

Our router is looking good! However if we were to try and make a http request to our server it would fail. 
We have not specified how or when our router should be started.

## Starting the router

Here is where the `--sup` option becomes important. We need to tell the supervisor how to start our router.
 A Supervisor is a process that watches child processes and knows how to rescue them if they crash. 
 You can read more about supervisors, supervision trees, and OTP [here](http://elixir-lang.org/getting-started/mix-otp/supervisor-and-application.html).
Go ahead and open up `min_api.ex`. In here you will see some generated code regarding supervision. We want to add our new router as a worker in the children list.

![router](/images/Minimal_Api_Cowboy_Plug/7_sup.PNG)

The plug function `child_spec` returns a worker to be supervised. `child_spec` accepts a scheme, a plug, and options as parameters.

```
child_spec(scheme, plug, opts, options \\ [])
```

## Run it!

Now that we have started our router, it is time to try it out! Go back to your console and run the following command. 
It runs compiles and runs your project in an iex(the Elixir REPL) instance.

```
iex -S mix
```

![router](/images/Minimal_Api_Cowboy_Plug/8_iex.PNG)

Once you see this it is time to send an http request. You can use something like `cURL` or [Postman](https://www.getpostman.com/).
Cowboy runs on port 4000 by default. Send a `GET` request to `http://localhost:4000/` and you should receive a response!

![router](/images/Minimal_Api_Cowboy_Plug/9_request.PNG)

However, what happens if we send a request to a different route?

![router](/images/Minimal_Api_Cowboy_Plug/10_500.PNG)

We get an internal server error, not good.
 Furthermore, if you look at your console you will see that an exception was raised.

![router](/images/Minimal_Api_Cowboy_Plug/11_error.PNG)

This is one of the reasons that Plug suggests that you define a catch-all route in your routers. 
Go ahead and add this below your other defined route.

![router](/images/Minimal_Api_Cowboy_Plug/12_catchall.PNG)

If you try the request again you should get a much better result (remember to restart your server).

![router](/images/Minimal_Api_Cowboy_Plug/13_404.PNG)

## Conclusion

And there you have it! A simple web server that returns `200` or `404` from a web request. Perhaps not the most useful piece of software, but at least we learned a thing or two. I put the source code for the project [here](https://github.com/cakeller43/min_api).