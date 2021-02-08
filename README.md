# Covid19

This project is from the [grox.io](https://grox.io/language/julia/course#book) _Julia Course_.

This version of the project has been reworked to use a different set of libraries:
* DataFrames.jl for for representation and manipulation of tabular data
* Chain.jl for support of piping a value through a series of transformation expressions
* Gadfly for plotting
* Pluto as an interactive notebook

### Installation

Clone the project and open your Julia REPL then type the following in the prompt:

`julia> ]`

The closing square bracket switches to the package manager interface. Once in it type:

`(Covid19) pkg> instantiate`

This will install the packages in the same state that is given by the manifest specified in the `Manifest.toml` file.

### Running the notebook

After instatiating the project, type the following in the Julia REPL:

`julia> using Pluto`

and then launch the Pluto server with:

`julia> Pluto.run()`

Then open the `notebook.jl` file in the UI.
