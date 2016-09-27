---

title: Minimal Api with Elixir, Cowboy and Plug 
date: 2016-09-26
intro: How to make a simple api that responds to requests with only cowboy and plug as dependencies. 

---

lorem ipsums blah intro...install elixir?  
<http://elixir-lang.org/install.html>
## Let's get started!

We will start by making a new project with Mix. Mix the build tool for Elixir, it contains many useful commands 
for creating, building, and testing your project. Open a command prompt or terminal and run this command to make a new project.

```
mix new min_api --sup
```

`Note: --sup initializes a basic supervisor tree. I will go over what this does and why we need it later.`

You should see output similar to this.

![mix new](/images/post_1/1_mix_new.PNG)

Mix creates the project with a skeleton structure and a working test! 

![mix test](/images/post_1/2_mix_test.png)

* min_api  
    * _build
    * config
        * config.exs
    * lib
        * min_api.ex
    * test
        * min_api_test.exs
        * test_helper.exs
    * mix.exs
    * README.md
    * .gitignore

`_build` - Build artifacts go here.  
`config.exs` - This is a config file that can be used to configure your applications in the project. 
                Environment specific config files can also be imported through this one.  
`lib` - Your elixir files and modules.  
`min_api.ex` - 