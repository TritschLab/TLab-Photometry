function data = processBeh(data,params)
%Process Behavior
%
%   [data] = processBeh(data,params)
%
%   Description: This function is designed to convert rotary encoder information into velocity
%   traces and quickly find onsets. The parameters for the analysis are found in the params
%   structure, which is created from a user-created scripted based on the
%   processParam.m file.
%
%   Input:
%   - data - A data structure specific to the Tritsch Lab. Created using
%   the convertH5_FP script
%   - params - A structure created from a variant of the processParams
%   script
%
%   Output:
%   - data - Updated data structure containing processed data
%
%   Author: Pratik Mistry 2019

%Pull parameters from the params structure
circum = 2*pi*params.beh.radius; velThres = params.beh.velThres;
winSize = params.beh.winSize;
finalOnset = params.beh.finalOnset;
nAcq = length(data.acq);
sigEdge = params.FP.sigEdge;
dsRate = params.dsRate;
dsType = params.dsType;

%The following for-loop will run the behavior analysis on each sweep in the
%acquisition
for n = 1:nAcq
    wheel = data.acq(n).wheel;
    rawFs = data.acq(n).Fs;
    Fs = rawFs/dsRate; data.final(n).Fs = Fs;
    if sigEdge ~= 0
        wheel = data.acq(n).wheel;
        wheel = wheel((sigEdge*rawFs)+1:end-(sigEdge*rawFs));
    end
    wheel = unwrapBeh(wheel);
    if size(wheel,1) == 1
        wheel = wheel';
    end
    lpFilt = designfilt('lowpassiir','SampleRate',rawFs,'FilterOrder',10,'HalfPowerFrequency',10);
    wheel = filtfilt(lpFilt,wheel);
    wheel = downsampleTLab(wheel,dsRate,dsType);
    wheel = wheel*circum;
    data.final(n).wheel = wheel;
    vel = getVel(wheel,Fs,winSize);
    minRest = params.beh.minRestTime * Fs; minRun = params.beh.minRunTime * Fs;
    [onsets,offsets] = getOnsetOffset(abs(vel),velThres,minRest,minRun,finalOnset);
    data.final(n).vel = vel;
    if ~isfield(data.final(n),'time')
        timeVec = [1:length(vel)];
        data.final(n).time = timeVec'/Fs;
    end        
    data.final(n).beh.onsets = onsets;
    data.final(n).beh.offsets = offsets;
end
