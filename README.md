## About

DotEnv4Delphi is a library to use **.env** files in Delphi/Lazarus. You can also get Environment Variables in a very easy and fast way.

Original version is here: https://github.com/rafael-figueiredo-alves/DotEnv4Delphi

Changes by **Olray Dragon**

## Latest version - New features

Olray's version of DotEnv4Delphi's is **2.0.0**

## Changes to the original version of DotEnv4Delphi

* Removed Singleton support for DotEnv4Delphi and replaced it with factory methods mainly because a singleton 
  removes the ability to load more than one .env file
* Moved loading of env variables to IEnvReader class
* Moved handling of connection string classes to IConnectionString
* Removed a bunch of directory related functions because we already have them in TPath (use System.IOUtils)
* Added ability to override environment variables instead of raising an exception when a key appears twice. Last one wins
* Added ability to "chain" several env files. It's common practice that people have a file .env and another file
  .env.local to override values
* I sensed a distinct lack of tests so I wrote some to learn how to use the library. You will find all examples
  you need to use the library there. It's important to know that these tests only test the fraction of DotEnv4Delphi
  I need. Feel free to add more tests and I will fix any bugs your tests find
* Dropped support for Free Pascal mainly because I don't use it and cannot test it

So far, for my use case DotEnv4Delphi does all I need. Big thank you to the original author Rafael Figueiredo Alves
