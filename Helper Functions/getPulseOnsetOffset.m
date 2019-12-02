function [pulseOnset, pulseOffset] = getPulseOnsetOffset(signal, threshold)

%Created by: Anya Krok
%Created on: 19 March 2019
%Description: general code for determination of onset and offset of
%optogenetic stimulation based on raw signal from pulse generator
%
% [pulseOnset, pulseOffset] = getPulseOnsetOffset(signal, threshold)
%
% INPUT
%   'signal' - MATLAB vector of pulse signal
%   'threshold' - a.u. or V, depends on voltage output of pulse generator
%       %arduino(for in vivo): 4V
%       %wavesurfer(photometry): 0.15V
%
% OUTPUT
%   'pulseOnset' - vector of length = #pulses, values correspond to first time point when pulse ON
%   'pulseOffset' - vector of length = #pulses, values correspond to first time point when pulse OFF
%

pulseOnset  = zeros(1,length(signal)); %initiate vectors
pulseOffset = zeros(1,length(signal));
tempPulse   = zeros(1,length(signal));

tempPulse(find(signal > threshold)) = 1;    %temporary vector: 0 = pulseON, 1 = pulseOFF

for ii = 2:length(signal)
    if (tempPulse(ii-1) == 0) && (tempPulse(ii) == 1)       %onset when successive value is above threshold
        pulseOnset(ii) = ii;
    elseif (tempPulse(ii-1) == 1) && (tempPulse(ii) == 0)   %offset when successive value is below threshold
        pulseOffset(ii) = ii;
    end
end

pulseOnset( :, all(~pulseOnset,1) ) = []; 
pulseOffset(:, all(~pulseOffset,1)) = [];  
%remove columns where value is zero, remaining columns continue values of
%onset or offset and new vector length corresponds to # pulses

end
