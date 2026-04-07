# Tic Tac Toe

We are going to create a game of tic-tac-toe playable through two interfaces, command line and through a web application. The project is coded using the Gleam Programming language. This is a language I've not used before soe its going be to a new challenge. 

## Project Structure

The project has three main components: 

### 1. Core
this is the main CLI and includes a tic-tac-toe solver and various types that will be shared. 


### 2. server

this is the web application backend coded in [Wisp](https://github.com/gleam-wisp/wisp)

### 3. client

This is an SPA application coded in Gleam's [Lustre Framework](https://github.com/lustre-labs/lustre). 

We are following the guide full-stack application building found in the Lustre documentation. 

https://hexdocs.pm/lustre/guide/06-full-stack-applications.html


I've added the documentation at LUSTRE_FULL_STACK_GUIDE.md to reference 

## Tic Tac Toe Implementation 

Look i did some googling around and I found out that 15 is the magic number for tic-tac-toe, if you number each square magically then every winning combination adds up to 15. You can do some fancy iteration on every three number combination that has been played and just check for 15 so lets use that. 



Proposed Phase 1:
Within Core: 
- create a record type for each square assign each square an x, y coordinate where 0,0 is the top left square
- assign each square a "value" where each winning combo of 3 adds to fifteen. 
- create a solver function 

Proposed Phase 2:
within core
- create a CLI interface to the core functions