# Sea Live World

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000/game`](http://localhost:4000) from your browser.

On the world is a table of size 15x10 (height x width) with cells equal in size to each other, the size of the table set by variables in the code so that you can quickly change the size.

Each cell of the world can:
- be free
- occupied by one instance of an creature of any kind

The world has to have "Restart" command, after perform this command the world should be reloaded to its initial state (more details about the initial state explained below)
Also the world has to have "Next step" command. There is one clock cycle of the world simulation should be performed.
Within one step, each instance of creature makes one move (if possible).
Creatures do one step in its turn, in the order of going around the world.

# Rules for live in the world

## For all creatures
- Arbitrary places are 8 cells nearby
- All creatures can move one cell within a neighborhood (that is, up, down, right, left, and diagonally)
- There are two types of creatures: penguins and orcas (killer whales)

## Penguins

### Moves
- At each turn, trying to swim
- For movement selects a random direction
- If penguin finds an empty cell nearby, penguin has to move there
- If penguin cannot find empty cell, penguin skips the turn

### Generation
- If 3 moves live, then on the third step tries to produce a child
- Reproduction occurs by creating a new penguin on an arbitrary free place in the ~neighborhood~ near the penguin
- If there are no free places nearby, then penguin skips generation and repeats the process another after 3 moves

## Orcas

### Moves
- Trying to swim at every turn
- At each turn, checks all directions and if a penguin is found, it moves to its place and eats it
- If there are no penguins nearby, then it moves in the same way as a penguin
- There are no other orcas

### Generation
- If 8 moves live, then on the 8th step tries to produce a child
- The generation process is the same as that of penguins

### Death
- If orca doesn't eat any penguin within 3 turns, orca dies (disappears from the world, leaving the cell empty)

## Initial State of the world
There is the world should be filled with penguins by 50% and orcas by 5%
