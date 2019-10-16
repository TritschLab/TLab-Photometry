function vel = getVel(distTravel,Fs,winSize)
% Get Velocity
%
%   vel = getVel(rawData,radius,Fs,winSize);
%
%   Description: This function performs the simple manipulations to obtain
%   velocity information from raw rotary encoder data.
%
%   Input:
%   - rawData - Data from the rotary encoder
%   - radius - Radius of the wheel
%   - Fs - Sample Rate of Acquisition
%   - winSize - Window size in seconds for smoothing the unwrapped encoder
%   data to remove in the trace that prevent us from obtaining an
%   appropriate velocity trace
%
%   Output:
%   - vel - Velocity trace
%

if winSize ~= 0
    distTravel = movmean(distTravel,ceil(Fs*winSize*0.5));
end
vel = [diff(distTravel),(distTravel(end)-distTravel(end-1))] * Fs;
vel = medfilt1(vel,ceil(Fs*winSize));
end