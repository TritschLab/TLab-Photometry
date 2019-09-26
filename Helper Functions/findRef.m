function [ref] = findRef(modFreq,refSig,Fs)
%Find reference signal
%
%   [ref] = findRef(modFreq,refSig,Fs)
%
%   Description: This function goes through all the reference signals in
%   the refSig cell and tries to find the signal that corresponds to the
%   input modulation frequency using an FFT with a +/-5Hz window
%
%   Input:
%   - modFreq - Modulation frequency specified by the user
%   - refSig - Cell array containing reference signals
%   - Fs - Sampling frequency of the traces
%
%   Output:
%   - ref - Reference signal that has the same frequency as modFreq
%
%   Author: Pratik Mistry 2019

for n = 1:length(refSig)
    tmpRef = refSig{n}; %Pull the signal
    [refMag,refFreq] = calcFFT(tmpRef-mean(tmpRef),Fs); %Calculate the frequency and find the x and y axis
    maxRefFreq = refFreq(find(refMag == max(refMag))); %Find the frequncy that the max power occurs
    %This if-statement checks to see if maxRefFreq matches the inputted
    %modulation frequency
    if modFreq >= (maxRefFreq-5) && modFreq <= (maxRefFreq+5)
        ref = tmpRef;
    end
end

end