module Covid19

using CSV, DataFrames, Query, HTTP

export data, data_without_world

url_loc = "https://covid.ourworldindata.org/data/ecdc/locations.csv"
url_full = "https://covid.ourworldindata.org/data/ecdc/full_data.csv"

function data()
    loc = CSV.File(HTTP.get(url_loc).body) |> DataFrame
    raw_cases = CSV.File(HTTP.get(url_full).body) |> DataFrame

    cases = coalesce.(raw_cases, 0.0)

    world = DataFrame(
        :countriesAndTerritories => "World",
        :location => "World",
        :continent => "World", 
        :population_year => 2020, 
        :population => (loc.population |> skipmissing |> sum)
        )

    pop = vcat(loc, world)
    innerjoin(cases, pop, on=:location)
end


function data_primary_columns()
    data() |>
    @select(:date, :location, :new_cases, :new_deaths)
end


function data_without_world()
    data() |> @filter(_.location != "World")
end


end # module
