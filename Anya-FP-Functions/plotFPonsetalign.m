% Created By: Anya Krok
% Created On: 19 June 2019
% Edited On: 20 June 2019 by Pratik
% Description: plotting onset-aligned photometry and behavior signal

%% Extracting variables for plotting from data structures
choice = menu('Data already opened in workspace?', 'Yes', 'No')
switch choice
    case 1
        %extract data - onset-aligned photometry and behavior signal
        [time, dfOn, dfOnAll, behOn, ~] = getFPonsetalign(data);
    case 2
        [dataFiles, dataPath] = uigetfile('*.mat','Select Data to Analyze','MultiSelect','On'); % Select data file to be parsed
        if (~iscell(dataFiles))
            dataFiles = {dataFiles};
        end
        nData = length(dataFiles);

        %extract data - onset-aligned photometry and behavior signal
        [time, dfOn, dfOnAll, behOn, ~] = getFPonsetalign(dataFiles, dataPath, nData);
end

%% Adjust onset-aligned signal to average over days
[choice] = menu('adjust onset-aligned signal?', 'yes', 'no')
switch choice
    case 1
        usrInput = inputdlg({'Enter # days to average over (default 1)'},'# Days',1);
        while isempty(str2num(usrInput{1}))
            warndlg('Input must be numerical'); pause(1)
            prompt = {'Enter # Days to Average Over'} ;
            promptTitle = '# Days';
            usrInput = inputdlg(prompt,promptTitle,1);
        end
        
        %adjust onset-aligned signal to average over days
        dfOn  = takeXrowAvg(dfOn, str2num(usrInput{1}));
        behOn = takeXrowAvg(behOn, str2num(usrInput{1}));  
end

%% Plotting onset-aligned signal
%top subplot: mean/SEM of input plot_dfOn and mean/SEM of input plot_behOn
%bottom subplot: all onset-aligned photometry traces
usrInput = inputdlg({'Enter Figure Name (e.g. SW99_190619)'},'plotName',1);
plotName = cellstr(usrInput{1});
            
[fig] = plothelperFPonsetalign (plotName, time, dfOnAll, dfOn, behOn);
