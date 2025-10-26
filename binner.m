clc, clearvars, clear all

inFile = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation/R20_with_FY.csv';

[folder, name, ext] = fileparts(inFile);

outputFile = fullfile(folder, [name '_binned.csv']);
table = readtable(inFile);

