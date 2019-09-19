function [data] = processOpto (data, params)

%Created By: Anya Krok
%Created On: 18 June 2019
%Description: T-Lab specific code for processing optogenetic stimulation
%signal into genreal T-Lab data structure
%
% [data] = processOpto2 (data, params)
%
% INPUT
%   'data'    - T-Lab data file with data.acq.Fs and data.acq.opto
%   'params'  - T-Lab optogenetic stimulation parameters
%       params.opto.threshold: threshold for pulse onset, offset
%       params.opto.stimtype: 'excitation' or 'inhibition', variable number
%       of pulses per train
%
% OUTPUT
%   'data'  - data structure containing pulse onsets, offsets (in samples)
%

optoThres = params.opto.threshold;
data.opto = struct; %initialize structure

for n = 1:length(data.acq)
    optoFs = data.acq(n).Fs;
    signal = data.acq(n).opto{1};
    
    if isfield(params.opto,'dsRate')
        dsRate = params.opto.dsRate;
        optoFs = optoFs/dsRate;
        signal = downsampleBins (signal, dsRate); %downsample opto signal 
        %not necessary to downsample signal if onset, offset indices converted to seconds
    end

    [pulseOnset, pulseOffset] = getPulseOnsetOffset (signal, optoThres);
    %pulseOnset  = pulseOnset/optoFs;  %pulse onset in seconds
    %pulseOffset = pulseOffset/optoFs; %pulse offset in seconds

    if isfield(params.opto,'stimtype')
        switch params.opto.stimtype
            case 'excitation'
                %excitatory optostim protocol: 5Hz, 5sec = 25 pulses per pattern repeat
                pulseOnset = pulseOnset(:,1:25:end) + 1; %extract every 25th value starting from 1st
                pulseOffset = pulseOffset(:,25:25:end); %extract every 25th value starting from 25th
        end
    end

data.opto(n).on  = pulseOnset;
data.opto(n).off = pulseOffset;
data.opto(n).params = params.opto;
data.opto(n).Fs = optoFs;

end       
end
