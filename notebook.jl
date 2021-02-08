### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 93585fec-69bc-11eb-36c8-370494bcaecb
begin
	using Covid19, DataFrames
	using Chain: @chain
	using Gadfly
	using PlutoUI
end

# ╔═╡ 20d23642-69bb-11eb-0b3f-77f02b3b89fe
md"# _COVID-19 Cases and Death_

## Data Setup
Our data comes from [Our World in Data](https://ourworldindata.org/coronavirus-source-data). We use two feeds, the population feed and the all-four-metrics feed.

### Packages

* Covid19.jl loads, scrubs and joins the Covid19 case and population data into one dataframe
* DataFrames for representation of tabular data
* Chain for support of piping a value through a series of transformation expressions
* Gadfly for plotting
"

# ╔═╡ e48ed04e-69bc-11eb-0ce3-61724f785c5d
md" ## Data

This is an example data frame that shows the use of our toolset.

* We start with the data for cases
* Then we choose the columns we want
* Then we filter by the country with the first cases so we'll see data
* Finally we pipe to a dataframe so we'll keep the data that way.
"

# ╔═╡ 088856aa-69bd-11eb-3fcf-83a565739164
@chain data() begin
	select(:location, :population, :date, :new_cases,
           :new_deaths, :total_cases, :total_deaths)
	filter(:location => ==("China"), _)
end

# ╔═╡ 42d06cbc-69bd-11eb-031c-ad555c053079
md" ### Show all the data for the USA"

# ╔═╡ 53282aaa-69bd-11eb-1a90-c9b28875663e
df = data();

# ╔═╡ 5d8fbb96-69bd-11eb-3071-95daa0ca39ac
usa_cases = @chain df begin
    select(:location, :population, :new_cases)
    filter(:location => ==("United States"), _)
end

# ╔═╡ 7296bcda-69bd-11eb-1275-39461d8bfa59
md" ### Weight Statistics by Population

This normalization approach (first step in the pipeline) is only correct if the `min` is 0, which isn't the case here. But this is just to show a more complex pipeline with transformations."



# ╔═╡ 2b405aa8-69bf-11eb-3af6-b9716e9e3ce4
weighted_cases = @chain df begin
    transform(:population => (x -> x / maximum(skipmissing(x))) => :normed_pop)
    transform([:normed_pop, :total_cases] => ByRow(*) => :weighted_cases)
    select(:location, :total_cases, :population, :normed_pop, :weighted_cases)
    filter(:total_cases => !(==(0.0)), _)
end

# ╔═╡ 348e130a-69bf-11eb-1bf5-c5b35920853e
@chain weighted_cases begin
    groupby([:location, :population])
    combine(:weighted_cases => last)
    sort(:population, rev=true)
	first(10)
end

# ╔═╡ 502ee878-69bf-11eb-29d9-cb13a9573a51
md" ## Split-Apply-Combine

This technique lets us break up data, aggregate some measurements, and then roll up the pieces so we can extract insights.

The next technique is to use one of the many plotting engines Julia supports. We’ll run a few plots so we can bring out trends that may be harder to see by just examining raw data."

# ╔═╡ 8a355e3a-69bf-11eb-194a-a5e010d4f4e8
cases = data();

# ╔═╡ 5546f8c6-69c1-11eb-2523-050602204e4a
@bind metric Select(["new_deaths", "total_deaths", "new_cases", "total_cases"])

# ╔═╡ 99cf7556-69bf-11eb-203b-9b2c63a6eea4
@chain cases begin
    groupby(:location)
    combine(metric => maximum => :deaths)
    sort(:deaths, rev=true)
    filter(:location => !(==("World")), _)
    first(10)
end

# ╔═╡ a1af9e86-69bf-11eb-0dcb-c703729bd68e
md" ### Hot Spots

Based on our analysis we can say that the following countries are hot spots for COVID-19

Note that we will be using the same `metric` variable from above to choose which metric (new deaths, total deaths, new cases, total cases) will be rendered."

# ╔═╡ 5de2a39e-69c2-11eb-0dc6-ad75e929029a
hot = ["United States", "India", "Brazil", "France", "Mexico"];

# ╔═╡ 691d6ab2-69c2-11eb-0aa6-a7841224d56d
hot_cases = @chain cases begin
    select(:location, :population, :date, :new_cases,
           :new_deaths, :total_cases, :total_deaths)
    filter(:location => in(hot), _)
end;

# ╔═╡ 70c93a2c-69c2-11eb-326b-09e4cca351ac
@chain hot_cases begin
    plot(_, x=:date, 
         y=metric,
         color=:location,
         Geom.line)
end

# ╔═╡ Cell order:
# ╟─20d23642-69bb-11eb-0b3f-77f02b3b89fe
# ╠═93585fec-69bc-11eb-36c8-370494bcaecb
# ╟─e48ed04e-69bc-11eb-0ce3-61724f785c5d
# ╠═088856aa-69bd-11eb-3fcf-83a565739164
# ╟─42d06cbc-69bd-11eb-031c-ad555c053079
# ╠═53282aaa-69bd-11eb-1a90-c9b28875663e
# ╠═5d8fbb96-69bd-11eb-3071-95daa0ca39ac
# ╟─7296bcda-69bd-11eb-1275-39461d8bfa59
# ╠═2b405aa8-69bf-11eb-3af6-b9716e9e3ce4
# ╠═348e130a-69bf-11eb-1bf5-c5b35920853e
# ╟─502ee878-69bf-11eb-29d9-cb13a9573a51
# ╠═8a355e3a-69bf-11eb-194a-a5e010d4f4e8
# ╠═5546f8c6-69c1-11eb-2523-050602204e4a
# ╠═99cf7556-69bf-11eb-203b-9b2c63a6eea4
# ╟─a1af9e86-69bf-11eb-0dcb-c703729bd68e
# ╠═5de2a39e-69c2-11eb-0dc6-ad75e929029a
# ╠═691d6ab2-69c2-11eb-0aa6-a7841224d56d
# ╠═70c93a2c-69c2-11eb-326b-09e4cca351ac
