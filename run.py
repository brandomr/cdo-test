import regridding_code.regridding_2 as regrid
import pandas


if "name" == "__main__":
    df = pandas.read_csv("from_gridded.csv")
    print("Running regridding")
    dataframe = regrid.regridding_interface(df, ["latitude", "longitude"], "date", 2.0, {"water": "mean", "people": "sum"})

    print(dataframe)