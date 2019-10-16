function [data] = createFPStruct(wsData,animalName,expDate)
%%Create Data Structure from WaveSurfer to MAT function
%
%   [data] = createDataStruct(wsData,animalName,expDate)
%
%   Description: This file takes a data structure generated from the
%   extractH5_WS function and it organizes the acquired traces into a lab
%   specific format by asking the user specify which type of recording the
%   trace is: (Photometry, Reference, Wheel, Opto Pulse)
%
%   Input:
%   - wsData - Data structure generated from extractH5_WS
%   - animalName - Name of animal/exp to add to data structure
%   - expDate - Date that the experiment took place
%
%   Output:
%   - data - New data structure that is cleaner to parse
%
%
%   Author: Pratik Mistry 2019

data = initDS; %Intialize data structure
data.mouse = animalName; data.date = expDate; %Add mouse name and experiment date to structure
nSweeps = length(wsData.sweeps);
Ls = wsData.header.ExpectedSweepScanCount;
%The following for-loop will go through all the sweeps and organize the
%data within each sweep depending on the trace name
traceNames = wsData.sweeps(1).traceNames;
nTraces = length(traceNames);
traceType = zeros(nTraces,1);
for x = 1:nTraces
    tName = traceNames{x};
    tName(find(tName==' ')) = [];
    traceNames{x} = tName;
    %Following line asks the user to select the type for the trace
    choice = menu(['Select an option for trace: ',tName],'Photometry','Reference',...
        'Wheel Encoder','Opto Pulses');
    traceType(x) = choice;
end
for sweepNum = 1:nSweeps
    data.acq(sweepNum).Fs = wsData.header.AcquisitionSampleRate; %Pull Sampling Rate
    data.acq(sweepNum).startTime = wsData.header.ClockAtRunStart; %Pull time at start
    FPind = 1; RefInd = 1; %Need to initialize index for FP and Ref sigs because there may be multiple
    for n = 1:nTraces
        %Following line asks the user to select the type for the trace
        choice = traceType(n);
        %The switch statement will organize the traces into specific fields
        %in the new data structure depending on user input
        switch choice
            case 1
                data.acq(sweepNum).FP{FPind,1} = wsData.sweeps(sweepNum).acqData(:,n);
                data.acq(sweepNum).FPnames{FPind,1} = tName;
                FPind = FPind+1;
            case 2
                data.acq(sweepNum).refSig{RefInd,1} = wsData.sweeps(sweepNum).acqData(:,n);
                data.acq(sweepNum).refSigNames{RefInd,1} = tName;
                RefInd = RefInd+1;
            case 3
                data.acq(sweepNum).wheel = wsData.sweeps(sweepNum).acqData(:,n);
            case 4
                data.acq(sweepNum).opto{1} = wsData.sweeps(sweepNum).acqData(:,n);
        end
    end
    data.acq(sweepNum).nFPchan = length(data.acq(sweepNum).FP);
    timeVec = [1:Ls]/data.acq(sweepNum).Fs;
    data.acq(sweepNum).time = timeVec';
end
end

function data = initDS()
data = struct('mouse',[],'date',[],'acq',struct());
data.acq = struct('FPnames','','nFPchan',[],'FP',[]);
end