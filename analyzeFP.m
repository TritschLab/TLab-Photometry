%% Analyze FP
%
%Description: 
%This script analyzes photometry data and optionally wheel
%data if the photometry experiment is performed on a wheel using a rotary
%encoder. The analysis pipeline runs using settings specified in a
%parameters file, and it runs on data files converted into a format
%specified by the convertH5_FP script. This code allows you to run multiple
%parameter files on multiple photometry experiments. Each analysis pipeline
%will be stored in an array of structures called final_x.
%
%
% STILL TO ADD:
%   - Cross-Correlation Settings
%   - Frequency Analysis
%
% Author: Pratik Mistry 2019
%
%

%% Clear Workspace and Select Files for Analysis
%Clear workspace
clear all


%Select Parameter files
[paramFiles,paramPath] = uigetfile('*.m','Select FP Parameters File','MultiSelect','On');
if (~iscell(paramFiles))
    paramFiles = {paramFiles};
end
nParams = length(paramFiles);


%Select FP Files to analyze
[FPfiles,FPpath] = uigetfile('*.mat','Select FP Files to Analyze','MultiSelect','On');
if (~iscell(FPfiles))
    FPfiles = {FPfiles};
end
nFiles = length(FPfiles);


%% Process FP Experiments
%The following for loop runs all the parameter files on all the FP files
%selected by the user. The data gets analyzed in a temporary data structure
%called tmpData and the final result is added to the array of structures
%called final_x in the desired/non-temporary data structure
for x = 1:nParams
    run(fullfile(paramPath,paramFiles{x}));
    for n = 1:nFiles
        load(fullfile(FPpath,FPfiles{n}));
        tmpData = data;
        if (isfield(data,'final'))
            tmpData.final = []; %Clear the final field in tmpDat
        end
        %If demodStatus = 1, the pipeline will run the function to
        %demodulate photometry experiments. Else it will run the standard
        %photometry pipeline
        if params.FP.demodStatus == 1
            tmpData = processMod(tmpData,params);
        else
            tmpData = processFP(tmpData,params);
        end
        %This if-statement is checking to see if the user recording encoder
        %data, and if so, the code will use settings specified in the
        %parameters files to obtain movement info (velocity, onsets,
        %offsets, etc.)
        if params.wheelStatus == 1
            try
                tmpData = processBeh(tmpData,params);
            catch
                msgbox('ERROR: Could not extract velocity or onset/offset indicies');
            end
            try
                tmpData = processOnsetOffset(tmpData,params);
            catch
                msgbox('ERROR: Could not process movement onset and offset data');   
            end
            try
                tmpData = processRestOnsetOffset(tmpData,params);
            catch
                msgbox('ERROR: Could not process rest onset and offset data');   
            end
        end
        if params.optoStatus == 1
            try
                tmpData.opto = processOpto(tmpData.acq.pulse,params);
            catch
                msgbox('ERROR: Could not process optogentic analysis'); 
            end
        end
        for y = 1:length(tmpData.final)
            tmpData.final(y).params = params;
        end
        fName = chk_N_Analysis(data);
        data.(fName) = tmpData.final;
        clear tmpData
        save(fullfile(FPpath,strtok(FPfiles{n},'.')),'data')
    end
    clear params
end

clear all;
