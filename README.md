# rboards
Create simple status boards for project management. Just a toy package to dynamically create some `reactable` project management boards and mess around with customization.

## Install
To install `rboards` use `remotes` or `devtools`:

```{r}
remotes::install_github("gdagstn/rboards")
```

## Usage

Using `rboards` is very easy. You just need to build a data frame with pre-set column names and values. 
Every row is an *entry* and it contains a specific action item.

The boards have mandatory fields:
 - **Project**: the project the field is referring to
 - **Item**: the task or item within the project
 - **Priority**: one of High, Medium or Low
 - **Status**: one of Done, Doing or To do
 - **Assignee**: who's responsible for the task

|Project|Item|Priority|Status|Assignee|
|---|---|---|---|---|
| Salad | Buy tomatoes | High | Done | Me | 
| Salad | Chop tomatoes | Medium | Doing | Me |
| Salad | Eat salad | Low | Done | Me | 

You can start a new board with `addEntry()` setting `board = NULL`:

```{r}
newboard = addEntry(board = NULL, project = "Pasta", item = "Buy pasta", priority = "High", status = "Done", assignee = "me")
```

The `newboard` object can be further modified by calling `addEntry()` again, this time setting `board = newboard`:

```{r}
newboard = addEntry(board = newboard, project = "Pasta", item = "Boil water", priority = "Medium", status = "Doing", assignee = "me")
```

You can also add several entries at a time:

```{r}
newboard = addEntry(board = newboard, 
                    project = c("Pasta", "Pasta", "Pasta"),
                    item = c("Chop onions", "Make sauce", "Grate cheese"),
                    priority = c("Medium", "Medium", "Low"),
                    status = c("Doing", "To do", "To do"),
                    assignee = c("me", "me", "Cat"))
```

To render the board just call `renderBoard()`:

```{r}
renderBoard(newboard)
```

<img width="934" alt="rboards" src="https://github.com/gdagstn/rboards/assets/21171362/2e129903-6575-4ec8-b6b0-dfaa22a1188e">

You can also remove some entries by using indices and/or any other matching character (or character vector) in specific columns using `removeEntry()`: 

```{r}
newboard = removeEntry(newboard, priority = "Medium")
```

And that's it, really.

## Acknowledgments:
This tiny package was made possible by the `reactable` package (Greg Lin) and the `htmltools` package (RStudio team), and obviously the R Project for Statistical Computing.

<img width="1159" alt="rboards2" src="https://github.com/gdagstn/rboards/assets/21171362/b274d6a0-3415-44ee-b5f1-a6eaa6fb62b8">

The board is fully searchable, orderable and filterable. You can save it as an HTML page, or inlcude it in a Quarto/Rmarkdown block. 
