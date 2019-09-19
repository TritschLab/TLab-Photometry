%% Analyze Fiber Photometry and Behavioral Data

%Description: This function performs Fiber Photometry Analysis,
%Wheel Position-to-Velocity conversions, Adjustment of Movement Bouts, Processing of
%Optogenetic pulses, and cross-correlations of velocity and photometry
%
%
%
%Author: Pratik Mistry, 2019

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
        while(1)
            choice = menu('Select an Analysis Option','Photometry','Velocity','Onset/Offset','Optogenetics','Cross-Correlation');
            switch choice
                case 0
                    msgbox('Analysis Ended');
                    break;                    
                case 1
                    for n = 1:nFiles
                        load(fullfile(FPpath,FPfiles{n}));
                        modStatus = menu('Are you demodulating a signal?','Yes','No');
                        if modStatus == 1
                          data = processMod(data,params);
                        else
                          data = processFP(data,params);
                        end
                        if ~isfield(data,'params')
                            data.params = params;
                        end
                        save(fullfile(FPpath,FPfiles{n}),'data');
                    end
                case 2
                    for n = 1:nFiles
                        load(fullfile(FPpath,FPfiles{n}));
                        data = processBeh(data,params);
                    end
                    data.params = params;
                    save(fullfile(FPpath,FPfiles{n}),'data');
                case 3
                    for n = 1:nFiles
                        load(fullfile(FPpath,FPfiles{n}));
                        try
                            data = processOnsetOffset(data,params);
                        catch
                            errordlg(['Error Processing Onset/Offset\n','Change Parameters for file: ',FPfiles{n}]);
                        end
                        try
                            data = processRestOnsetOffset(data,params);
                        catch
                            errordlg(['Error Processing Rest Onset/Offset\n','Change Parameters for file: ',FPfiles{n}]);
                        end
                    end
                    if ~isfield(data,'params')
                        data.params = params;
                    end
                    save(fullfile(FPpath,FPfiles{n}),'data');
                case 4
                    for n = 1:nFiles
                        load(fullfile(FPpath,FPfiles{n}));
                        try
                            data = processOpto(data,params);
                        catch
                            errordlg(['Error Processing Optogenetic Pulses','Change Parameters for file: ',FPfiles{n}]);
                        end
                    end
                    if ~isfield(data,'params')
                        data.params = params;
                    end
                    save(fullfile(FPpath,FPfiles{n}),'data');
                case 5
                    for n = 1:nFiles
                        load(fullfile(FPpath,FPfiles{n}));
                        try
                            data = processCC(data,params);
                        catch
                            errordlg(['Error Processing Cross Correlation','Change Parameters for file: ',FPfiles{n}]);
                        end
                    end
                    if ~isfield(data,'params')
                        data.params = params;
                    end
                    save(fullfile(FPpath,FPfiles{n}),'data');
            end
        end
    end
end