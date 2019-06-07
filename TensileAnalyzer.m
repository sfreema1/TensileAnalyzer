clc;close all;
%% Tensile Analyzer Script
% Please run runThisScript.m first to collect all the data
% run('RunThisScript.m')
%% Set script parameters
smoothingspan = 0.01; % percentage of data to use for smoothing
%resultsfilename = 'summary.xlsx'; % name of results file to be written
%% Create array to hold results
% Calculate how many data sets will be analyzed
n = length(data_cell);
% Create cell array to store results
results = cell(n+1,9);
results(1,:) = {'Name','Width (mm)','Thickness (mm)','Elastic Modulus (Pa)',...
    'UTS (Pa)','Burst pressure (mmHg)','Compliance (%/mmHg)',...
    'SEM of measurement','Toughness (J/m^3)'};
%% Analyzing graphs
for i = 1:n
    % 1. First load variables from cell-struct array
    expname = data_cell{i}.name;
    size_mm = data_cell{i}.size;
    disp_mm = data_cell{i}.displ;
    time = data_cell{i}.time;
    force = data_cell{i}.force;
    width = data_cell{i}.width(1); % in mm
    thickness = data_cell{i}.thickness(1); % in mm
    OD = data_cell{i}.OD(1); % in mm
    % 1a. Report name of experiment
    msg = ['Experiment name: ',expname];
    disp(msg);
    
    % 1b. Perform force zeroing in case there is a bit of an offset
    % Record the results of that.
    % Assumes tensile testing had long 'zero-tail' (at least 100 points)
    zeromean = mean(force(end-100:end));
    sem = std(force(end-100:end))/sqrt(100);
    pvalue = abs(zeromean)/sem; % two-tails
    msg = ['Zero offset +/- SEM: ',num2str(zeromean),' +/- ',num2str(sem),...
        ' (p = ',num2str(pvalue),')'];
    disp(msg);
    % Subtract from force
    force = force - zeromean;

    % 2. Calculate sampling frequency
    sampling_frequency = (time(4,1)-time(3,1))^-1;
    msg = ['Sampling frequency: ',num2str(sampling_frequency),' Hz'];
    disp(msg);

    % 3. Calculate smoothed force values
    smoothforce = smooths(force,20);
    % And plot
    figure;plot(disp_mm,force,'b-',disp_mm,smoothforce,'r.-')
    %set(gcf, 'Position', get(0, 'Screensize'));
    title({[num2str(i),' out of ',num2str(n),': ','Experiment name: ',expname],...
        ['Please select where the force starts and ends on the graph.']})
    xlabel('Displacement (mm)');
    ylabel('Force (N)');
    xlim([-0.05*max(disp_mm),1.05*max(disp_mm)])
    ylim([-0.05*max(force),1.05*max(force)])
    legend('Raw data','Smoothed data');

    % 4. Get user input for graph to calculate slope region
    [xin,~] = ginput(2); close;

    % 5. Record index at which to shift displacement and cut off trailing data
    [~,cv_index] = min(abs(disp_mm-min(xin)));
    [~,cv_index2] = min(abs(disp_mm-max(xin)));

    % 6. Record the original size of stretching before any force was observed
    orig_size = size_mm(cv_index); % mm
    disp(['The true size of the sample was ',num2str(orig_size),' mm.']);

    % 7. Shift displacement data and convert to stress and strain
    disp_mm = disp_mm - disp_mm(cv_index);
    strain = disp_mm(cv_index:cv_index2)/orig_size;
    stress = smoothforce(cv_index:cv_index2)/(thickness*width/(10^3)/(10^3));

    % 8. Plot stress over strain
    figure; plot(strain,stress,'r.-')
    %set(gcf, 'Position', get(0, 'Screensize'));
    xlabel('Strain (e)');
    ylabel('Stress (Pa)');
    title({[num2str(i),' out of ',num2str(n),': ','Experiment name: ',expname],...
        ['Please select the start and end of the linear region.']});
    xlim([-0.05*max(strain),1.05*max(strain)]);
    ylim([-0.05*max(stress),1.05*max(stress)]);

    % 9. Get user input on linear region calculations
    [xin,~] = ginput(2); close;
    [~,cv_index] = min(abs(strain-min(xin)));
    [~,cv_index2] = min(abs(strain-max(xin)));
    strain_linear = strain(cv_index:cv_index2);
    stress_linear = stress(cv_index:cv_index2);

    % 10. Calculate elastic modulus of linear region (slope) using LS linear
    % regression
    coeffs = polyfit(strain_linear,stress_linear,1);
    fittedX = linspace(strain_linear(1), strain_linear(end), 1000);
    fittedY = polyval(coeffs, fittedX);
    elastic_mod = coeffs(1); % Pascals
    disp(['The elastic modulus is ',SIPrefix(elastic_mod,'Pa')]);

    % 11. Calculate the UTS
    UTS = max(stress);
    disp(['The UTS is ',SIPrefix(UTS,'Pa')]);
    
    % 12. Calculate the burst pressure
    BP = (2*UTS*(thickness/1000)/(OD+2*(thickness/1000)))/133.3; % in mmHg
    disp(['The BP is ',num2str(BP),' mmHg']);
    
    % 13. Calculate compliance
    compliance = 100*133.3*(1/elastic_mod)*(OD/(2*thickness));
    disp(['The compliance is ',num2str(compliance),' %/mmHg']);
    
    % 14. Calculate the toughness
    toughness = trapz(strain,stress);
    disp(['The toughness for the sample: ',SIPrefix(toughness,'J'),'/m^3']);
    disp(' ');

    % 15. Summarize results in figure
    figure; plot(strain,stress,'r.-',fittedX,fittedY,'b.-')
    %set(gcf, 'Position', get(0, 'Screensize'));
    xlabel('Strain (e)');
    ylabel('Stress (Pa)');
    title({['Experiment name: ',expname],...
        ['Elastic modulus: ',SIPrefix(elastic_mod,'Pa'),' | UTS: ',...
        SIPrefix(UTS,'Pa'), ' | ',num2str(width),'X',...
       num2str(thickness),' mm']});
   xlim([-0.05*max(strain),1.05*max(strain)]);
   ylim([-0.05*max(stress),1.05*max(stress)]);
   close;
   
   % 13. Record results in array
   results{i+1,1} = expname;
   results{i+1,2} = width;
   results{i+1,3} = thickness;
   results{i+1,4} = elastic_mod;
   results{i+1,5} = UTS;
   results{i+1,6} = BP;
   results{i+1,7} = compliance;
   results{i+1,8} = sem;
   results{i+1,9} = toughness;
end
%% Write Excel summary file
%xlswrite(resultsfilename,results);