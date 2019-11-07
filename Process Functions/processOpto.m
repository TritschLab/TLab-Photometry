function [data] = processOpto (data, params)
%Created By: Anya Krok
%Created On: 18 June 2019
%Description: T-Lab specific code for processing optogenetic stimulation
%signal into general T-Lab data structure
%Updated On: 31 October 2019 - added new filter+downsampling
%
% [data] = processOpto (data, params)
%
% INPUT
%   'data'    - T-Lab data file with data.acq.Fs and data.acq.opto
%   'params'  - T-Lab optogenetic stimulation parameters
%
% OUTPUT
%   'data'  - data structure containing new data.opto sub-structure
%

opto = struct; %initialize structure

%pull variables from params:
thres = params.opto.threshold;      %threshold for pulse onset/offset
cutoff = params.opto.cutoff;        %filter cutoff freq
order = params.opto.order;          %filter order
filtType = params.opto.filtType;    %filter type
dsRate = params.opto.dsRate;        %downsampling rate
dsType = params.opto.dsType;

for n = 1:length(data.acq)
    %extract pulse onset and offset times from original signal 
    optoFs = data.acq(n).Fs;
    signal = data.acq(n).opto{1};
    [pulseOnset, pulseOffset] = getPulseOnsetOffset (signal, thres);
    
    %downsample signal to match Fs of other signals (e.g. FP, beh)
    [optoNew,~] = filterFP(signal,optoFs,cutoff,order,filtType);
    optoFsNew = optoFs/dsRate;
    optoNew = downsample_TLab(optoNew,dsRate,dsType);
    

    %vestigial code to extract only first and last stimuli of pulse train
    %if isfield(params.opto,'stimtype')
    %    switch params.opto.stimtype
    %        case 'excitation'
    %            %excitatory optostim protocol: 5Hz, 5sec = 25 pulses per pattern repeat
    %            pulseOnset = pulseOnset(:,1:25:end) + 1; %extract every 25th value starting from 1st
    %            pulseOffset = pulseOffset(:,25:25:end); %extract every 25th value starting from 25th
    %    end
    %end

    opto(n).on  = pulseOnset; %pulse onset in samples, matching original optoFs
    opto(n).off = pulseOffset;
    opto(n).Fs = optoFs;
    opto(n).params = params.opto;
    opto(n).vec = optoNew; %downsampled (and filtered) vector 
    opto(n).vecFs = optoFsNew; %Fs of downsampled/filtered vector
end      

data.opto = opto; %add to data structure
end