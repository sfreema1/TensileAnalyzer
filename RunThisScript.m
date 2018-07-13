clc; close all; clear all;
%% Load data from Excel sheet
[num,txt,~] = xlsread('raw_tensile_data.xlsx');
%% Organize data
clc;
sample_names = txt(1,2:end);
sample_widths = num(1,:);
sample_thicknesses = num(3,:);
sample_IDs = num(5,:);
sample_data = num(8:end,:);
% Calculate how many samples there are
num_samples = length(sample_data(1,:))/5;
% Create cells that will hold output data
data_cell = cell(1,length(num_samples));
% initialize text progressbar
textprogressbar('Loading data from file:   ')
for i = 1:num_samples
    entryname = sample_names{5*i-4};
    OD = sample_IDs(5*i-4); % in mm
    width = sample_widths(5*i-4); % in mm
    thickness = sample_thicknesses(5*i-4); % in um
    % only keep non NaN values
    select = ~isnan(sample_data(:,5*i-4));
    % extract time, size, displacement, and force values for each sample
    % test
    time = sample_data(select,5*i-4);
    size = sample_data(select,5*i-4+2);
    displ = sample_data(select,5*i-4+3);
    force = sample_data(select,5*i-4+4);
    data_cell{i}= struct('name',entryname,'OD',OD,'width',width,...
        'thickness',thickness,'time',time,'size',size,'displ',displ,'force',force);
    % report progress
    textprogressbar(100*i/num_samples)
end
textprogressbar('Data finished loading');
%% Clear all unnecessary variables
clearvars -except data_cell num txt