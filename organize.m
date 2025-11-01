clc, clearvars, clear all

dataFolder = '/Users/Blanchards1/Documents/FormulaSim/new-cornering-simulation';

csvFiles = dir(fullfile(dataFolder, "R20_FZ_*.csv"));

for i = 1:numel(csvFiles)
