clear all;
[FPfiles,FPpath] = uigetfile('*.mat','Select FP Files to Analyze','MultiSelect','On');
if FPfiles == 0
    errordlg('No Photometry File Selected!');
else
    [paramFile,paramPath] = uigetfile('*.m','Select FP Parameters File','MultiSelect','On');
    if paramFile == 0
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
                data.params = params;
                for y = 1:length(analysisOpt)
                    choice = analysisOpt(y);
                    switch choice
                        case 1
                            modStatus = menu('Are you demodulating a signal?','Yes','No');
                            if modStatus == 1
                                isoStatus = menu(['Does this experiment: ',FPfiles{y},...
                                    ' contain an Isosbestic Control?'],'Yes','No');
                                if isoStatus == 1
                                    data = processIso(data,params);
                                else
                                    data = processDual(data,params);
                                end
                            elseif modStatus == 2
                                data = processFP(data,params);
                            else
                                errordlg('No Valid Photometry Option Selected');
                            end
                        case 2
                            data = processBeh(data,params);
                        case 3
                            try
                                data = processOnsetOffset(data,params);
                            catch
                                errordlg(['Error Processing Onset/Offset for file: ',FPfiles{x}]);
                            end
                            try
                                data = processRestOnsetOffset(data,params);
                            catch
                                errordlg(['Error Processing Rest Onset/Offset for file: ',FPfiles{x}]);
                            end
                        case 4
                            try
                                data = processCC(data,params);
                            catch
                                errordlg(['Error Processing Cross Correlation for file: ',FPfiles{x}]);
                            end
                        case 5
                            load(fullfile(FPpath,FPfiles{n}));
                            try
                                data = processOpto(data,params);
                            catch
                                errordlg(['Error Processing Optogenetic Pulses for file: ',FPfiles{x}]);
                            end
                    end
                end
                save(fullfile(FPpath,FPfiles{x}),'data');
            end
            clear all
        end
    end
end
