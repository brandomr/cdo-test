# Running
To run: 
```
docker compose up -d
```

# Troubleshooting
Run:
```
docker exec -it cdo-test-container /bin/bash
```

Then in the container, enter the python commandline executable by running `python3` and run the following code:
```
import regridding_code.regridding_2 as regrid
import pandas
df = pandas.read_csv("from_gridded.csv")
regrid.regridding_interface(df, ["latitude", "longitude"], "date", 2.0, {"water": "mean", "people": "sum"})
```

This code is also present in ```run.py```. The code presented here will run CDO and silently error out. Once you see `Before regridding multi` appear in the stdout, wait for about 10 seconds and then kill the process. This will dump CDO's stdout showing an error that should resemble:

```
# DEBUG - start =============================================================
CALL  :/usr/local/bin/cdo -O -s -f nc -remapavg tmp_data.nc tmp_result.nc
STDOUT:
STDERR:
cdo    remapavg  : Enter grid description file or name > 
# DEBUG - end ===============================================================
RETURNCODE:-2
did not find a match in any of xarray's currently installed IO backends ['netcdf4']. Consider explicitly selecting one of the installed engines via the ``engine`` parameter, or installing additional IO dependencies, see:
http://xarray.pydata.org/en/stable/getting-started-guide/installing.html
http://xarray.pydata.org/en/stable/user-guide/io.html

```

I believe that CDO is unable to open the input netcdf produced by this code because it is trying to use xarray to do so and that xarray is failing to find the netCDF4 library, even though running `xarray.open_dataset(<Any netcdf here>)` works.

You can also troubleshoot with a bigger dataset by using the following code (Note that you will need to source the `MERRA2_...` file from the datasets google drive):

```
import regridding_code.regridding_2 as regrid
import xarray as xr
data = xr.open_dataset("MERRA2_400.inst3_3d_asm_Np.20220101.nc4", decode_coords="all")
df = data.to_dataframe().reset_index()
df.columns.value_counts()
regrid.regridding_interface(df, ["lat", "lon"], "time", 2.0, {"SLP": "mean", "T": "mean", "U":"max", "V": "min"})
```

# Additional problems
There is an additional problem where I am not taking the time field into account because if the time field is included in the dataset dimensions CDO rejects the dataset as being generic. The only way I have found to get CDO to accept the dataset as a geographic dataset is to run it on the bigger dataset and modify the code [here](https://github.com/Sorrento110/cdo-test/blob/d9aa3ead9fd1bd894b41b390e7e6a9aa16d7e02e/regridding_code/regridding_2.py#L31) and [here](https://github.com/Sorrento110/cdo-test/blob/d9aa3ead9fd1bd894b41b390e7e6a9aa16d7e02e/regridding_code/regridding_2.py#L38) to include both the time_column variable and the `"lev"` dimension in the `MERRA2` dataset. Including the `lev` elevation field allows CDO to treat the dataset as geographic when the time field is included in the dataset dimensions.
