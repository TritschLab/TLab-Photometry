function dsData = downsampleTLab(rawData,dsRate,dsType)
% Tritsch Lab Downsample Data
%
%   dsData = downsample_TLab(rawData,dsRate,dsType)
%
%   Description: This function downsamples data based on the last argument
%   being the type (bin summation, bin averaging, and traditional
%   downsampling
%
%   Input:
%   - rawData - Data to be downsampled
%   - dsRate - The amount the signal will be downsampled by
%   - dsType - Select the downsampling method
%       - 1 -> Bin Summation
%       - 2 -> Bin Averaging
%       - 3 -> Traditional Downsampling (NOT RECOMMENDED)
%
%   Output:
%   - dsData - Final downsampled data
%
%   Author: Pratik Mistry, 2019

L = length(rawData);
L_new = L/dsRate;
dsData = zeros(L_new,1);
switch dsType
    case 1
        for n = 1:L_new
            if n == L_new
                dsData(n) = sum(rawData((n-1)*dsRate+1:end));
            else
                dsData(n) = sum(rawData((n-1)*dsRate+1:n*dsRate));
            end
        end
    case 2
        for n = 1:L_new
            if n == L_new
                dsData(n) = sum(rawData((n-1)*dsRate+1:end));
            else
                dsData(n) = sum(rawData((n-1)*dsRate+1:n*dsRate));
            end
        end
    case 3
        dsData = rawData(1:dsRate:end);
end
end
