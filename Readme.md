# Running the Tool

Please install Julia from this webpage: [(https://julialang.org/downloads/)](https://julialang.org/downloads/).

## Installation

Clone the repository and install the dependencies:

First cd into the project directory then run:

```bash
$> julia --project -i -e 'using Pkg; Pkg.instantiate()'
```

Then run the app

```bash
$> julia --project
```

```julia
julia> using GenieFramework
julia> Genie.loadapp() # load app
julia> up(async=true) # start server
```

## Usage

Open your browser and navigate to http://localhost:8000/