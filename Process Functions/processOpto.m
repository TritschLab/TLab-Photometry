function [tempOpto] = processOpto (signal, params)

%Created By: Anya Krok
%Created On: 18 June 2019
%Description: T-Lab specific code for processing optogenetic stimulation
%signal into genreal T-Lab data structure
%
% [tempOpto] = processOpto (signal, params)
%
% INPUT
%   'signal'    - extracted file from wavesurfer (h5tomat) or openephys (openADC)
%   'params'    - T-Lab optogenetic stimulation parameters
%
% OUTPUT
%   'tempOpto'  - data structure consisting of onsets, offsets (in *sec*) of
%   optogenetic stimulation

optoThres = params.opto.threshold;
optoFs = params.Fs;

if isfield(params.opto,'dsRate')
    dsRate = params.opto.dsRate;
    optoFs = params.Fs/dsRate;
    signal = downsampleBins (signal, dsRate); %downsample opto signal 
    %not necessary to downsample signal if onset, offset indices converted to seconds
end

[pulseOnset, pulseOffset] = getPulseOnsetOffset (signal, optoThres);
pulseOnset  = pulseOnset/optoFs;  %pulse onset in seconds
pulseOffset = pulseOffset/optoFs; %pulse offset in seconds

if isfield(params.opto,'stimtype')
    switch params.opto.stimtype
        case 'excitation'
            %excitatory optostim protocol: 5Hz, 5sec = 25 pulses per pattern repeat
            pulseOnset = pulseOnset(:,1:25:end) + 1; %extract every 25th value starting from 1st
            pulseOffset = pulseOffset(:,25:25:end); %extract every 25th value starting from 25th
    end
end

tempOpto = struct; %initialize structure
tempOpto.onsets  = pulseOnset;
tempOpto.offsets = pulseOffset;
tempOpto.params  = params.opto;
tempOpto.params.Fs = optoFs;
        
end
