clc;close all; clear all;
%% Load data from Excel sheet
[num,txt,raw] = xlsread('data.xlsx');
txt = txt(:,2:end); % remove first column
raw = raw(:,2:end); % remove first column
%% Datasheet parameters
% Datasheet organizational parameters
% indicate which row contains the following information
% Textual data
% open the txt data and see where each parameter appears
sampleNameRow = 1;
testTypeRow = 12;
% Numerial data
% open the num data and see where each parameter appears
sampleCSWidthRow = [12,13];
sampleCSThicknessRow = [14,15];
sampleODRow = [16,17];
numStart = 19;
timeCol = 1;
sizeCol = 2;
displCol = 3;
forceCol = 4;
%% Organize data
numOfDataSets = length(raw(1,:))/4;
data_cell = cell(numOfDataSets,1);
% every five columns represents one set of data
for s = 1:numOfDataSets
    sampleName = [txt{sampleNameRow,4*s-3},'-',txt{testTypeRow,4*s-3}];
    width = [num(sampleCSWidthRow(1),4*s-3),num(sampleCSWidthRow(2),4*s-3)];
    thickness = [num(sampleCSThicknessRow(1),4*s-3),num(sampleCSThicknessRow(2),4*s-3)];
    OD = [num(sampleODRow(1),4*s-3),num(sampleODRow(2),4*s-3)];
    time = num(numStart:end,4*s-(4-timeCol));
    size = num(numStart:end,4*s-(4-sizeCol));
    displ = num(numStart:end,4*s-(4-displCol));
    force = num(numStart:end,4*s-(4-forceCol));
    % create the entry in the data structure
    data_cell{s} = struct('name',sampleName,'width',width,'OD',OD,...
    'thickness',thickness,'time',time(~isnan(time)),'size',size(~isnan(size))...
    ,'displ',displ(~isnan(displ)),'force',force(~isnan(force)));
end
%% Keep only the data cell array
clearvars -except data_cell