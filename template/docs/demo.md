# Demo
This demo should get you started with programming using Entangled. This file is best viewed side by side with the rendered output in your browser. The code snippets in here are all Python, but could be any language. Feel free to remove the `docs/demo.md` file after you're up and running. Any files that are generated from here should also be removed automatically.

## Basics
### References
Entangled works with references. Each code block either outputs to a file (`file=` attribute), or creates a reference (`#` identifier). Identifiers can be used inside code blocks to substitute for their content. Here are two code blocks. One writes to the file `demo/hello.py`,

``` {.python file=demo/hello.py}
print("You say goodbye,")
<<hello>>
```

and the other substitutes any `<<hello>>` reference:

``` {.python #hello}
print("And I say hello.")
```

Try editing the file in `demo/hello.py` and see the changes here.

## Howto
### Create figures
You can create figures using the Brei workflow system that's embedded in Entangled. Note here that some of the attributes to the code block are given as commented lines.

``` {.python .task}
#| description: Plot Delaunay triangulation
#| creates: docs/fig/delaunay.svg
#| collect: figures
from pathlib import Path
from matplotlib import pyplot as plt
from matplotlib.tri import Triangulation
import numpy as np

x, y = np.random.normal(size=(2, 100))
t = Triangulation(x, y)

fig, ax = plt.subplots()
ax.triplot(t)
ax.axis("equal")
ax.set_xlim([-1, 1])
ax.set_ylim([-1, 1])

Path("docs/fig").mkdir(exist_ok=True)
fig.savefig("docs/fig/delaunay.svg")
```

![Delaunay triangulation](fig/delaunay.svg)

To run all tasks in the `figures` collection, run

```bash
entangled brei figures
```

You can tweak and modify how a workflow is run in the `[brei]` section of `entangled.toml`.

### Dependencies
To give one more example: you can specify intermediate data as follows. First we generate some data. We have a recursive random process with scaling to create self-similar point sets.

``` {.python #self-similar-point-set}
def draw_points(origin, n, r):
    return origin + np.random.normal(scale=r, size=(n, 2))

def recur_sp(origin, n, r, scale, depth):
    if depth == 0:
        yield origin
    else:
        for p in draw_points(origin, n, r):
            yield from recur_sp(p, n, r * scale, scale, depth - 1)
```

Now we show what such a point set might look like:

``` {.python .task}
#| description: Generate data
#| creates: data/self-similar.npy
#| collect: data
import numpy as np
from pathlib import Path

<<self-similar-point-set>>

data = np.fromiter(recur_sp([0, 0], 3, 1.0, 0.5, 6), dtype="2f")
Path("data").mkdir(exist_ok=True)
np.save("data/self-similar.npy", data)
```

Then we plot in another task.

``` {.python .task}
#| description: Plot data
#| creates: docs/fig/self-similar.svg
#| requires: data/self-similar.npy
#| collect: figures
from pathlib import Path
import numpy as np
from matplotlib import pyplot as plt

data = np.load("data/self-similar.npy")
fig, ax = plt.subplots()
ax.plot(*data.T, '.')
ax.axis("equal")

Path("docs/fig").mkdir(exist_ok=True)
fig.savefig("docs/fig/self-similar.svg")
```

![](fig/self-similar.svg)

### Shebang lines
Some scripts require that the first line starts with `#!` to indicate the executable.

``` {.python file=demo/answer mode=755}
#!/usr/bin/python
print(42)
```

## Effective Literate Programming
Literate programming is a bit of an acquired skill. Some patterns work really well, others less so.

### Document tests first
Often when introducing a new concept you'd write down a few examples of how some function or class should work. You can collect those into unit tests, then the implementation becomes just an afterthought.

Example: The factorial function should return $n * f(n-1)$.

``` {.python #factorial-spec}
assert factorial(n) == factorial(n - 1) * n
```

Then elsewhere you can write (possibly folded):

``` {.python file=demo/test.py}
from hypothesis import given, ints

<<math-functions>>

@given(n = ints)
def test_factorial(n):
    <<factorial-spec>>
```

### Don't repeat names
It is tempting to repeat names. Usually the name of a code block should describe *what* the code does, then the content can show *how* that is achieved. If you define a factorial function the name of the function is already enough of a description. So **don't do**:

``` {.python #factorial}
def factorial(n):
    return factorial(n-1) * n if n > 0 else 1
```

Then somewhere else you'd do,

``` {.python #math}
<<factorial>>
<<fib>>
# etc ...
# listing many other math functions
```

**Rather**, create the module with a single reference to `<<math-functions>>`, then you can keep appending on that identifier:

``` {.python #math-functions}
def factorial(n):
    return factorial(n-1) * n if n > 0 else 1
```

And add another

``` {.python #math-functions}
def fib(n):
    return fib(n-1) + fib(n-2) if n > 1 else 1
```

### Programming with classes
The same holds for Object Oriented Programming. When you define a class, add a reference to fill in that class' methods.

``` {.python #some-class}
class Some:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    <<some-methods>>
```

Then it is very easy to extend the methods of that class when you need it. Let's add addition:

``` {.python #some-methods}
def __add__(self, other):
    return Some(self.x + other.x, self.y + other.y)
```

### Mixing with illiterate code
You don't have to make your entire program literate if you don't feel like it. Files tangled by Entangled can live hapily side by side normal files. You could use the [PyMDownX module `snippets`](https://facelessuser.github.io/pymdown-extensions/extensions/snippets/) to include files verbatim for reference.

## References

- [Tutorials](https://entangled.github.io/tutorials)
- [Brei documentation](https://entangled.github.io/brei)

