module Covid19

using CSV, DataFrames, HTTP, DataConvenience
using Chain: @chain

export data, data_without_world

url_loc = "https://covid.ourworldindata.org/data/ecdc/locations.csv"
url_full = "https://covid.ourworldindata.org/data/ecdc/full_data.csv"

function data()
    loc = HTTP.get(url_loc).body |> CSV.File |> DataFrame
    raw_cases = HTTP.get(url_full).body |> CSV.File |> DataFrame

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
    @chain data() begin
        select(:date, :location, :new_cases, :new_deaths)
    end
end


function data_without_world()
    @chain data() begin
        filter(:location => !(==("World")), _)
    end
end


end # module
