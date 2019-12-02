function data = extractH5_WS(h5file)
%Extract WaveSurfer Data from H5 File
%
%   data = extractH5_WS(h5file);
%
%   Description: This function parses the H5 file generated after an
%   acquisition using the wavesurfer software. The function uses a
%   combination of original code as well as code found in the innate
%   wavesurfer function ws.loadDataFile for opening and storing data files
%   from wavesurfer. The function pulls all of the information from the
%   header, organizes the Stimulus Library into a "hopefully" user-friendly
%   method of parsing the organization, and it also pulls all the traces
%   into a single matrix.
%
%   Input:
%   - h5file - H5 data file generated from a WS acquisition
%
%   Output:
%   - data - Data structure that can be used in experiments
%
%
%   Author: Pratik Mistry, 2019
%

data = struct; %Specify the variable data to be a structure.
h5Struct = h5info(h5file); %Load a generic h5 structure using the h5info function
h5Header = h5Struct.Groups(1); %Isolate the header portion of the structure into a variable
tmpStimLib = crawl_h5_tree('/header/StimulusLibrary/',h5file); %Use the innate wavesurfer function
% crawl_h5_tree to create a structure of the stimulus. This structure
% will be modified to be more "readable"
data = sub_extractHeader(data,h5Header,h5file); %Calls a function to extract header variables
data.StimulusLibrary = sub_orgStimLib(tmpStimLib); %Call a function to reorganize the stimulus library
%into a new format
clear tmpStimLib; %Clear the temporary stimulus library to free up space
data = sub_extractScans(data,h5Struct,h5file); %Pull the traces into a field within the struct

end

function data = sub_extractHeader(data,h5Header,h5file)
% Extract Header Information from WaveSurfer H5 -- sub function to the main
% function
%
%   data = sub_extractHeader(data,h5Header,h5file)
%
%   Description: This function reads all the header parameters and
%   stores them into a field titled 'header' within the structure
%
%   Input:
%   - data - Data structure that does not contain the header
%   - h5Header - A structure containing the header tree pulled using the
%   h5info function
%   - h5file - File name / file path
%
%   Output:
%   - data - Edited data structure that now contains a field callled header
%
%
%   Author: Pratik Mistry, 2019
rootVal = strcat(h5Header.Name,'/');
nDatasets = size(h5Header.Datasets,1);
for n = 1:nDatasets
    dataSetName = h5Header.Datasets(n).Name;
    data.header.(dataSetName) = h5read(h5file,strcat(rootVal,dataSetName));
end
end

function StimLib = sub_orgStimLib(tmpStimLib)
%Organize WS Stimulus Library
%
%   StimLib = sub_orgStimLib(tmpStimLib);
%
%   Description: This function organizes the data structure of the stimulus
%   library created from the crawl_h5_tree into a format that is easier to
%   parse and to locate the corresponding stimulis to maps, and maps to
%   sequences.
%
%
%
if (tmpStimLib.NStimuli == 0)
    %disp('This experiment contains no stimuli');
    StimLib.Stimuli = 0;
else
    for n = 1:tmpStimLib.NStimuli
        elem = sprintf('element%d',n);
        tmpStim = tmpStimLib.Stimuli.(elem);
        StimLib.Stimuli(n).Name = tmpStim.Name;
        StimLib.Stimuli(n).Parameters = tmpStim.Delegate;
    end
end
if (tmpStimLib.NMaps == 0)
    %disp('This experiment contains no Maps');
    StimLib.Maps = 0;
else
    for n = 1:tmpStimLib.NMaps
        elem = sprintf('element%d',n);
        tmpMaps = tmpStimLib.Maps.(elem);
        nStimuliMap = size(tmpMaps.ChannelName,1);
        StimLib.Maps(n).Name = tmpMaps.Name;
        StimLib.Maps(n).Parameters = cell(nStimuliMap+1,2);
        StimLib.Maps(n).Parameters{1,1} = 'Channel Name';
        StimLib.Maps(n).Parameters{1,2} = 'Stimulus Name';
        for m = 2:(nStimuliMap+1)
            try
                StimLib.Maps(n).Parameters{m,1} = tmpMaps.ChannelName{m-1,1};
            catch
                StimLib.Maps(n).Parameters{m,1} = tmpMaps.ChannelName;
            end
            elem_2 = sprintf('element%d',m-1);
            stimInd = tmpMaps.IndexOfEachStimulusInLibrary.(elem_2);
            if stimInd == 0
                StimLib.Maps(n).Parameters{m,2} = 'Unknown Stimulus';
            else
                StimLib.Maps(n).Parameters{m,2} = StimLib.Stimuli(stimInd).Name;
            end
        end
    end
end
if (tmpStimLib.NSequences == 0)
    %disp('This Experiment Contains No Sequences');
    StimLib.Sequences = 0;
else
    for n = 1:tmpStimLib.NSequences
        elem = sprintf('element%d',n);
        tmpSeq = tmpStimLib.Sequences.(elem);
        try
            nMapSeq = numel(fieldnames(tmpSeq.IndexOfEachMapInLibrary));
        catch
            nMapSeq = 0;
        end
        StimLib.Sequences(n).Name = tmpSeq.Name;
        StimLib.Sequences(n).Parameters{1,1} = 'Map Name';
        StimLib.Sequences(n).Parameters{1,2} = 'Map Index';
        for m = 1:nMapSeq
            elem_2 = sprintf('element%d',m);
            mapInd = tmpSeq.IndexOfEachMapInLibrary.(elem_2);
            if mapInd == 0
                StimLib.Sequences(n).Parameters{(m+1),1} = 'Unknown Map';
                StimLib.Sequences(n).Parameters{(m+1),2} = 0;
            else
                StimLib.Sequences(n).Parameters{(m+1),1} = StimLib.Maps(mapInd).Name;
                StimLib.Sequences(n).Parameters{(m+1),2} = mapInd;
            end
        end
    end
end
end

function data = sub_extractScans(data,h5Struct,h5file)
% Extract analog scans
%
%   data = sub_extractScans(data,h5Struct,h5file)
%
%   Description: This function pulls the sweeps and scan data into a vector
%   of structures. All traces from all channels are stored into a single
%   matrix. The order of the columns = order of channel names in the
%   channel name cell that is also contained in the data structure
%
%   Input:
%   - data - Data structure that contains the header and Stimulus Library
%   - h5Struct - Structure created using the h5info function
%   - h5file - Filename / Path of the h5file
%
%   Output:
%   - data - Edited data structure that now contains a vector of structures
%   called sweeps
%
%   Author: Pratik Mistry, 2019

nSweeps = size(h5Struct.Groups,1);
channelScale=data.header.AIChannelScales;
scalingCoeff=data.header.AIScalingCoefficients;
sampleRate=data.header.AcquisitionSampleRate;
for n = 2:nSweeps
    rootVal = h5Struct.Groups(n).Name;
    rawData = h5read(h5file,strcat(rootVal,'/analogScans'));
    try
        digitalData = h5read(h5file,strcat(rootVal,'/digitalScans'));
        data.sweeps(n-1).digData = digitalData;
    catch
        [];
    end
    scaledData = scaleData_WS(rawData,channelScale,scalingCoeff);
    data.sweeps(n-1).acqData = scaledData;
    data.sweeps(n-1).time = (1:length(scaledData))'/sampleRate;
    data.sweeps(n-1).traceNames = data.header.AIChannelNames;
end
end
% -------------------------------------------------------------------------------------------------
%   Thw following functions were copied from the innate functions that
%   wavesurfer contains for creating data structures that I repurposed to
%   create our own data structure for the Tritsch Lab
% -------------------------------------------------------------------------------------------------
function s = crawl_h5_tree(pathToGroup, filename)
% Get the dataset and subgroup names in the current group
[datasetNames,subGroupNames] = get_group_info(pathToGroup, filename);

% Create an empty scalar struct
s=struct();

% Add a field for each of the subgroups
for idx = 1:length(subGroupNames)
    subGroupName=subGroupNames{idx};
    fieldName = field_name_from_hdf_name(subGroupName);
    pathToSubgroup = sprintf('%s%s/',pathToGroup,subGroupName);
    s.(fieldName) = crawl_h5_tree(pathToSubgroup, filename);
end

% Add a field for each of the datasets
for idx = 1:length(datasetNames) ,
    datasetName = datasetNames{idx} ;
    pathToDataset = sprintf('%s%s',pathToGroup,datasetName);
    dataset = h5read(filename, pathToDataset);
    % Unbox scalar cellstr's
    if iscellstr(dataset) && isscalar(dataset) ,
        dataset=dataset{1};
    end
    fieldName = field_name_from_hdf_name(datasetName) ;
    s.(fieldName) = dataset;
end
end  % function

function [datasetNames, subGroupNames] = get_group_info(pathToGroup, filename)
info = h5info(filename, pathToGroup);

if isempty(info.Groups) ,
    subGroupNames = cell(1,0);
else
    subGroupAbsoluteNames = {info.Groups.Name};
    subGroupNames = ...
        cellfun(@local_hdf_name_from_path,subGroupAbsoluteNames,'UniformOutput',false);
end

if isempty(info.Datasets) ,
    datasetNames = cell(1,0);
else
    datasetNames = {info.Datasets.Name};
end
end  % function

function fieldName = field_name_from_hdf_name(hdfName)
numVal = str2double(hdfName);

if isnan(numVal)
    % This is actually a good thing, b/c it means the groupName is not
    % simply a number, which would be an illegal field name
    fieldName = hdfName;
else
    try
        validateattributes(numVal, {'numeric'}, {'integer' 'scalar'});
    catch me
        error('Unable to convert group name %s to a valid field name.', hdfName);
    end
    
    fieldName = ['n' hdfName];
end
end  % function
% ------------------------------------------------------------------------------
% local_hdf_name_from_path
% ------------------------------------------------------------------------------
function localName = local_hdf_name_from_path(rawPath)
if isempty(rawPath) ,
    localName = '';
else
    if rawPath(end)=='/' ,
        path=rawPath(1:end-1);
    else
        path=rawPath;
    end
    indicesOfSlashes=find(path=='/');
    if isempty(indicesOfSlashes) ,
        localName = path;
    else
        indexOfLastSlash=indicesOfSlashes(end);
        if indexOfLastSlash<length(path) ,
            localName = path(indexOfLastSlash+1:end);
        else
            localName = '';
        end
    end
end
end  % function

function scaledData = scaleData_WS(dataAsADCCounts, channelScales, scalingCoefficients)
%THIS FUNCTION WAS COPIED FROM THE WAVESURFER LIBRARY TO FIT THE NEEDS OF THE TRITSCH LAB
%Function to convert raw ADC data as int16s to doubles, taking to the
% per-channel scaling factors into account.
%
%   scalingCoefficients: nScans x nChannels int16 array
%   channelScales:  1 x nChannels double array, each element having
%                   (implicit) units of V/(native unit), where each
%                   channel has its own native unit.
%   scalingCoefficients: nCoefficients x nChannels  double array,
%                        contains scaling coefficients for converting
%                        ADC counts to volts at the ADC input.
%
%   scaledData: nScans x nChannels double array containing the scaled
%               data, each channel with it's own native unit.

inverseChannelScales=1./channelScales;  % if some channel scales are zero, this will lead to nans and/or infs
[nScans,nChannels] = size(dataAsADCCounts) ;
nCoefficients = size(scalingCoefficients,1) ;
scaledData=zeros(nScans,nChannels) ;
if nScans>0 && nChannels>0 && nCoefficients>0 ,  % i.e. if nonempty
    % This nested loop *should* get JIT-accelerated
    for j = 1:nChannels ,
        for i = 1:nScans ,
            datumAsADCCounts = double(dataAsADCCounts(i,j)) ;
            datumAsADCVoltage = scalingCoefficients(nCoefficients,j) ;
            for k = (nCoefficients-1):-1:1 ,
                datumAsADCVoltage = scalingCoefficients(k,j) + datumAsADCCounts*datumAsADCVoltage ;
            end
            scaledData(i,j) = inverseChannelScales(j) * datumAsADCVoltage ;
        end
    end
end
end

