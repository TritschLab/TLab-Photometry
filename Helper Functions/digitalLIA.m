function [sig,filtStruct] = digitalLIA(modSig,refSig,Fs,lpCut,filtOrder)
%Digital Lock-In Amplifier Demodulation
%
%   [sig,filtStruct] = digitalLIA(modSig,refSig,Fs,lpCut,filtOrder)
%
%   Description: This function demodulates a signal using a phase sensitive
%   detection method. The function takes two inputs: modulated signal and
%   the recorded reference signal. If the input reference signal is in
%   phase with the modulated signal (as measured by a cross-correlation),
%   the function will perform a demodulation that is phase dependent. If
%   the user does not input an in phase reference signal, the function will
%   perform a phase independent demodulation that utilizes a reference
%   signal 90-degrees out of phase with the input reference signal; then
%   the function will demodulate using a quadrature demodulation method.
%
%   Multiplying two sinusoids:
%
%   A*sin(w_1*t+phi_1) .* B*sin(w_2*t+phi_2) =
%       0.5*A*B*cos((w_1-w_2)*t+(phi_1-phi_2)) -
%       cos((w_1+w_2)*t+(phi_1+phi_2));
%
%   Input:
%   - modSig - Measured modulated signal
%   - refSig - Measured driving signal used to drive the LED
%
%   Output:
%   - sig - "Demodulated" signal
%   - filtStruct - A structure containing all the filter objects used in
%   this function --> These can be used to viusalize filter magnitude,
%   impulse, and step responses
%
%
%   Author: Pratik Mistry, 2019

%Check to see if signals are column vectors; if not, it corrects the
%signal orientation to column vectors
modSig = sub_chkSigSize(modSig); refSig = sub_chkSigSize(refSig);
%Check to see if the signals are the same length because the signal
%multiplication requires the signals to be exactly the same length
if (size(modSig,1) ~= size(refSig,1))
    disp('ERROR: Signals are not the same length. Signals need to be the same length for the code to perform phase sensitive detection');
    sig = 0;
    return;
else
    %Bandpass filter your modulated signal to ensure that only the
    %frequency of modulation exists --> This allows for a cleaner
    %phase-detection
    %bpFilt = sub_createFilter(modSig,'bandpassiir');
    %modSig = filtfilt(bpFilt,modSig);
    %Normalize Reference Signal and ensure the amplitude goes from +2
    %to -2V --> This step ensures that you are maintaining the original
    %ampltiude from the modulated photometry signal
    refSig = refSig-min(refSig); refSig = refSig/max(refSig); refSig = (refSig-0.5)*4;
    %Check to see if user inputted an in-phase reference signal
    %Perform a cross-correlation. If maximum correlation exists at 0,
    %then the signals are in phase.
    [x,lag] = xcov(modSig,refSig,'coeff');
    phaseDiff = lag(find(x==max(x)));
    %Clear variables to free space
    clear x lag;
    lpFilt = designfilt('lowpassiir','FilterOrder',filtOrder,'HalfPowerFrequency',lpCut,'SampleRate',Fs,'DesignMethod','butter');
    if phaseDiff == 0 %Signals are in-phase perform standard PSD
        PSD = modSig.*refSig;
        sig = filtfilt(lpFilt,PSD);
    else %Signals are not in-phase compute a quadrature using reference signal shift 90 degrees
        refSig_90 = gradient(refSig);
        PSD_1 = modSig.*refSig;
        PSD_1 = filtfilt(lpFilt,PSD_1);
        PSD_2 = modSig.*refSig_90;
        PSD_2 = filtfilt(lpFilt,PSD_2);
        sig = hypot(PSD_1,PSD_2);
    end
    filtStruct = lpFilt;
end

end

function adjSig = sub_chkSigSize(orgSig)
%Check Signal Size/Orientation
%
%   [adjSig] = sub_chkSigSize(orgSig);
%
%   Description: This sub-function ensures the orientation of the signals
%   are both column vectors. This function is necessary because if the
%   vectors are not the same orientation for the phase sensitive detection,
%   it will throw an error.
%
%   Input:
%   - orgSig - Original Signal
%
%   Output:
%   - adjSig - Adjusted Signal
%
%

%This function uses the size function to ensure that size(sig,2) = 1
%The second index in size is the number of columns
if size(orgSig,2) ~= 1
    adjSig = orgSig';
else
    adjSig = orgSig;
end
end

%This function is no longer necessary for the analysis, but is being kept
%for record. I used it to visualize and change filter parameters for this
%analysis method.

%{
function filterObj = sub_createFilter(sig,filtType)
%Create Filter Object
%
%   filterObj = sub_createFilter(sig,filtType);
%
%   Description: This sub-function is **temporary** But it is designed to
%   allow the user to create a filter and visualize the effect before
%   implementation of the filter. This function is designed for us to get a
%   better sense of filter properties for this type of analysis.
%   Additionally, the function outputs the filter object necessary for
%   filtering.
%
%   Input:
%   - filtType - Type of filter to use. (ex. 'lowpassiir' or 'bandpassiir'
%   or 'highpassiir'
%
%   Output:
%   - filterObj - The final filter object to use for filtering
    filterObj = designfilt(filtType);
    
    %THe following while loop will plot the filtered signal as well as the
    %filter visualization (to visualize filter magnitude response, impulse
    %response, and step response). If adequate the user can accept the
    %filter, if not, the user can adjust the parameters.
    while(1)
        fig = figure; plot(filtfilt(filterObj,sig));
        fvtool(filterObj);
        choice = menu('Do you want to change filter parameters?','Yes','No');
        if choice == 1
            close(fig);
            filterObj = designfilt(filtType);
        elseif choice == 2
            close(fig);
            break;
        else
            disp('Not a valid selection: Filter will be set to most recent settings');
            close(fig);
            break;
        end
    end
end
%}