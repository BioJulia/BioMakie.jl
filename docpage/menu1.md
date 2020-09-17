@def title = "Basic Usage"
@def hascode = true
@def rss = "Visual Biology with Julia"

# Basic Usage

After the package is imported, you can try it out by loading up a structure
from the Protein Data Bank like so:
```julia
julia> lysozyme1 = viewstruc("2VB1")

```

The first time you load a visualization, it might take a minute. Subsequent load times will be shorter.
