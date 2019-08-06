%% convertH5_FP
%
%   Description: This function will convert as many H5 files into MAT files
%   that follow an organization pattern agreed upon by fellow lab members
%   of the Tritsch Lab. 
%
%   This function requires h5 data files to be in the following format:
%   - AN_ExpDate_Cond_0001.h5
%
%       - AN --> Animal Name
%       - ExpDate --> Experiment Date
%       - Cond --> Conditional (Optional)
%       - 001 --> Experiment index from wavesurfer 
%
%   This script uses an intermediate function called
%   extractH5_WS, which parses the H5 tree. Parts of that function were
%   repurposed from Adam Taylors innate functions to extract data from H5
%   trees. The createFPStruct function will take a data structure created
%   from the extractH5_WS into a data structure with the following format:
%
%   data --> Main data structure
%   - mouseName
%   - expDate
%   - acq(n) -> An array of structures. An acquisition is either multiple
%   sweeps or multiple experiments on the same day
%       - FP --> Matrix of photometry recordings
%       - encoder --> Data from wheel rotary encoder
%       - nFPchan --> Number of FP channesl
%       - FPNames --> Names of the FP channels
%       - Fs --> Sampling Frequency
%       - refSig --> Matrix of Reference signals if performing photometry modulation
%       - refSigNames --> Name of reference signals 
%       - control --> Red or Isosbestic Control Signals
%
%   Author: Pratik Mistry, 2019

clear all

[h5Files,fPath] = uigetfile('*.h5','MultiSelect','On');
if (~iscell(h5Files))
    h5Files = {h5Files};
end
if (h5Files{1}==0)
    msgbox('No File Selected');
else
    newPath = uigetdir(fPath,'Select Path for New File');
    if (newPath==0)
        newPath = fPath;
    end

    nFiles = length(h5Files);
    initExpDate = [];

    for n = 1:nFiles
        tic
        h5Name = h5Files{n};
        [AN,other] = strtok(h5Name,'_');
        [expDate,~] = strtok(other,'_');
        dataWS = extractH5_WS(fullfile(fPath,h5Files{n}));
        data = createFPStruct(dataWS,AN,expDate);
        save(fullfile(newPath,strtok(h5Files{n},'.')),'data');
        AN = []; expDate = []; other = []; h5Name = [];
        data = []; dataWS = [];
        toc
    end
end
clear all


