# Fy cornering tire simulation
Simulate the cornering force values of the tires based on pacejak tire coefficients. Coefficients are found via optimizing the coefficients based on tire test data using least squared optimization.

Two tires are used by the club: LC0 and R20 Hoosier tires, and are simulated here.

# Architecture
![Current architecture diagram](current.drawio.svg)

Note: changing the run file (input for generator.m) changes what data to look at, and depending on the run what tire to look at

If the run file is changed or tire being simulated is changed, change the other file/folder names in the matlab scripts so it matches and doesn't overwrite other data.

lateral_force_grapher.m: graphs lateral force vs slip angle

data_grapher.m: graph the data

generator.m: parse data and filter by nominal load

organize.m: filters the data more by binding certain values

combiner.m: combine all the filtered data to a few files for input into optimizer

R20_optimizer.m: using least squared optimization, optimize the RMSE (Root Mean Squared Error value) for a R20 tire

LC0_optimizer.m: using least squared optimization, optimize the RMSE (Root Mean Squared Error value) for a LC0 tire

pacejka.m: function that determines the lateral force value using tire coefficients

# Work to be done
Convert to Simulink. Refer to MATLAB_practices.docx for best ways to do this.
