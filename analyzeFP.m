%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ANALYZE FIBER PHOTOMETRY - TRITSCH LAB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Description: This code processes photometry experiments. First, the user
% will select as many photometry experiments they want to analyze. Then the
% code will ask the user to upload a single parameter file to use. Finally,
% a window will pop-up asking the user which analyzes to perform. These
% options are also multi-select using "CTRL" + Click or "SHIFT" + Arrows
%
%
% Author: Pratik Mistry, 2019

%% Run Analysis

clear all;
[FPfiles,FPpath] = uigetfile('*.mat','Select FP Files to Analyze','MultiSelect','On');
if isempty(FPfiles)
    errordlg('No Photometry File Selected!');
else
    [paramFile,paramPath] = uigetfile('*.m','Select FP Parameters File','MultiSelect','On');
    if isempty(paramFile)
        errordlg('No Parameter File Selected!');
    else
        run(fullfile(paramPath,paramFile));
        if (~iscell(FPfiles))
            FPfiles = {FPfiles};
        end
        nFiles = length(FPfiles);
        [analysisOpt,ind] = listdlg('PromptString',{'Select All Analyzes to Perform',...
            'For Multiple Methods: Hold Ctrl and Select'},'ListString',{'Photometry',...
            'Velocity','Onset/Offset','Cross-Correlations','Optogenetics'});
        if ind == 0
            msgbox('Analysis Aborted');
        else
            for x = 1:nFiles
                load(fullfile(FPpath,FPfiles{x}));
                tmpData = data;
                if (isfield(tmpData,'final'))
                    tmpData.final = [];
                end
                tmpData.final.params = params;
                for y = 1:length(analysisOpt)
                    choice = analysisOpt(y);
                    switch choice
                        case 1
                            modStatus = menu('Are you demodulating a signal?','Yes','No');
                            if modStatus == 1
                                isoStatus = menu(['Does this experiment: ',FPfiles{y},...
                                    ' contain an Isosbestic Control?'],'Yes','No');
                                if isoStatus == 1
                                    tmpData = processIso(tmpData,params);
                                else
                                    tmpData = processDual(tmpData,params);
                                end
                            elseif modStatus == 2
                                tmpData = processFP(tmpData,params);
                            else
                                errordlg('No Valid Photometry Option Selected');
                            end
                        case 2
                            tmpData = processBeh(tmpData,params);
                        case 3
                            try
                                tmpData = processOnsetOffset(tmpData,params);
                            catch
                                errordlg(['Error Processing Onset/Offset for file: ',FPfiles{x}]);
                            end
                            try
                                tmpData = processRestOnsetOffset(tmpData,params);
                            catch
                                errordlg(['Error Processing Rest Onset/Offset for file: ',FPfiles{x}]);
                            end
                        case 4
                            try
                                tmpData = processCC(tmpData,params);
                            catch
                                errordlg(['Error Processing Cross Correlation for file: ',FPfiles{x}]);
                            end
                        case 5
                            load(fullfile(FPpath,FPfiles{n}));
                            try
                                tmpData = processOpto(tmpData,params);
                            catch
                                errordlg(['Error Processing Optogenetic Pulses for file: ',FPfiles{x}]);
                            end
                    end
                end
                fName = chk_N_Analysis(data);
                data.(fName) = tmpData.final;
                save(fullfile(FPpath,FPfiles{x}),'data');
            end
            clear all
        end
    end
end
