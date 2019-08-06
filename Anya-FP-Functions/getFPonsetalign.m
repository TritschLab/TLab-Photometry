function [time, dfOn, dfOnAll, behOn, behOnAll, varargout] = getFPonsetalign (varargin)

% Created by: Anya Krok
% Created on: 05 March 2019
% Edited on: 18 June 2019, incorporated new T-lab data structure format
% Description: 
%       extract fluorescence and behavior traces aligned to onset, averaged
%       over multiple acquisitions for each mouse recording day 
%
% [time, dfOn, dfOnAll, behOn, behOnAll, varargout] = getOnsetAvg (varargin)
% [time, dfOn, dfOnAll, behOn, behOnAll, varargout] = getOnsetAvg (varargin)
% [time, ~, ~, ~, ~, dfOff, dfOffAll, behOff, behOffAll] = getOnsetAvg (varargin)
%
% INPUT
%   option A: 'data' - open data structure already loaded into workspace
%   option B: 'dataFiles','dataPath','nFiles'
%           
% OUTPUT
%   'time':     vector with time values, in seconds
%   'dfOn':     matrix, row are dfOnAll averaged over multiple acquisitons
%       dimensions (M,N) where M = length(mouse)*length(date)*length(acq),
%   'dfOnAll':  all extracted onset-aligned fluorescent trace
%   'behOn':    same as above, but for onset-aligned behavior
%   'behOnAll' 
%   varargout:  variable output argument
%       offset data (9): [time, ~, ~, ~, ~, dfOff, dfOffAll, behOff, behOffAll]
%       same as above, but offset-aligned

if nargin == 1
    data = varargin{1}; nFiles = 1;
elseif nargin == 3
    dataFiles = varargin{1}; dataPath = varargin{2}; nFiles = varargin{3};
end

for n = 1:nFiles
    if nargin == 3; load(fullfile(dataPath,dataFiles{n})); end
    
    for acqNum = 1:length(data.acq)   
tic
        %set working roi to current acquisition we are iterating through
        roi = data.final(acqNum).beh; 

        %fluorescence and behavior traces aligned to onset for each
        %movement bout, concatenated over all bouts in one acquisiton
        if exist('dfOn') == 0
            dfOnAll  = roi.DF.dfOnsets;    dfOffAll = roi.DF.dfOffsets;  
            behOnAll = roi.behOnsets;  behOffAll = roi.behOffsets; 
        else 
            dfOnAll  = [dfOnAll;  roi.DF.dfOnsets];   dfOffAll = [dfOffAll;  roi.DF.dfOffsets];   
            behOnAll = [behOnAll; roi.behOnsets]; behOffAll = [behOffAll; roi.behOffsets];
        end

        %average aligned traces over each acquisition, then concatenate
        %matrixes to form matrix with average DF and behavior traces
        %over all acquisitions on each mouse recording day
        if exist('dfOnavg') == 0
            dfOn     = mean(roi.DF.dfOnsets,1);   
            dfOff    = mean(roi.DF.dfOffsets,1);
            behOn    = mean(roi.behOnsets,1);
            behOff   = mean(roi.behOffsets,1);
        else
            dfOn     = [dfOn;     mean(roi.DF.dfOnsets,1)]; 
            dfOff    = [dfOff;    mean(roi.DF.dfOffsets,1)];
            behOn    = [behOn;    mean(roi.behOnsets,1)];
            behOff   = [behOff;   mean(roi.behOffsets,1)];
        end   
toc
    end
end

dfOnAll = real(dfOnAll); dfOffAll = real(dfOffAll); %remove non-real values

if nargout == 9 %offset data
    varargout{1} = dfOff;    
    varargout{2} = dfOffAll;
    varargout{3} = behOff;   
    varargout{4} = behOffAll;
end

time = roi.timeDF;

end
