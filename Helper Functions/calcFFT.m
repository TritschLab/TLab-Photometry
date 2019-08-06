function [varargout] = calcFFT(y,fs,varargin)
%calcFFT - Calculate the Fourier Power Spectrums
%   Created By: Pratik Mistry
%   Created On: 31 January 2019
%   Edited On: 5 June 2019
%   
%   calcFFT - Plots fourier magnitude and phase values
%   calcFFT(y,fs) - Plots the data
%   [fftamp] = calcFFT(y,fs)
%   [fftampfftfreq] = calcFFT(y,fs)
%   [fftamp,fftfreq,fftphase] = calcFFT(y,fs)
%
%   Description: This function will calculate the Fourier spectrum of a
%   signal and return the phase and magnitude spectrums. The function can
%   also plot the variables if necessary
%
%   Input:
%   - y - Input signal
%   - fs - Sampling frequency
%   - 'log' - Optional input to get log transformed data
%
%   Output: (ALL OPTIONAL)
%   - fftamp - Vector of amplitudes for positive frequencies
%   - fftphase - Phase associated with positive frequencies
%   - fftfreq - Vector of positive freqencies -- Xaxis
%
%

    Y=fft(y);
    L=length(Y);
    Y_pos=Y(1:(L/2));
    fftfreq=(0:(L/2)-1)*fs/L;
    fftamp=abs(Y_pos);
    Y_pos(abs(Y_pos)<1e-6) = 0;
    fftphase=unwrap(angle(Y_pos));
    x_title = 'Frequency(Hz)';
    y_title = 'Power';
    if nargin > 2
        if (strcmp(varargin{1},'log') || strcmp(varargin{1},'Log'))
            fftfreq = log10(fftfreq);
            fftamp = log10(fftamp);
            x_title = 'log(Frequency(Hz))';
            y_title = 'log(Power)';
        else
            msgbox('Invalid Input: Will not log scale FFT plots');
        end
    end
    
    if nargout == 0
        plotTitle = inputdlg('Enter the Name of Plot','Plot Name');
        figure; plot(fftfreq,fftamp); xlabel(x_title); ylabel(y_title); title(strcat(plotTitle,' - FFT Mag Plot'));
        figure; plot(fftfreq,fftphase/pi); xlabel(x_title); ylabel(y_title); title(strcat(plotTitle,'-FFT Phase Plot'));
    elseif(nargout==1)
        varargout{1} = fftamp;
    elseif (nargout==2)
        varargout{1} = fftamp;
        varargout{2} = fftfreq;
    elseif (nargout==3)
        varargout{1} = fftamp;
        varargout{2} = fftfreq;
        varargout{3} = fftphase;
    end
end