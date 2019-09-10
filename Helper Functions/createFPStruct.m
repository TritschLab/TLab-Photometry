function [data] = createFPStruct(wsData,animalName,expDate)
%%Create Data Structure from WaveSurfer to MAT function
%
%   [data] = createDataStruct(wsData,animalName,expDate)
%
%   Description: This file takes a data structure generated from the
%   extractH5_WS function and turns it into a data structure that can be
%   easily manipulated from experimental purposes
%
%   Input:
%   - wsData - Data structure generated from extractH5_WS
%   - animalName - Name of animal/exp to add to data structure
%   - expDate - Date that the experiment took place
%
%   Output:
%   - data - New data structure that is cleaner to parse
%
%
%   Author: Pratik Mistry 2019

    data = initDS; %Intialize data structure
    data.mouse = animalName; data.date = expDate; %Add mouse name and experiment date to structure
    nSweeps = length(wsData.sweeps);
    %Go through all sweeps and add data from the sweeps into an array of
    %structures with the fieldname acq
    for sweepNum = 1:nSweeps
        %Pull the trace names from the wsStruct into a tmp variable. We are
        %using this variable to find data from the data structure and put
        %it into the appropriate fields into the new data structure
        tmpTraceNames = wsData.sweeps(sweepNum).traceNames;
        data.acq(sweepNum).Fs = wsData.header.AcquisitionSampleRate;
        data.acq(sweepNum).startTime = wsData.header.ClockAtRunStart;
        L = wsData.header.SweepDuration * data.acq(sweepNum).Fs;
        %The following function parces the trace names and pulls the
        %indices of where they are located
        [FPind,wheelInd,refSigInd,pulseInd,controlInd] = parseTraceNames(tmpTraceNames);
        %All the following if statements checks to see if the indices
        %variables are empty. If they are not, it will create an
        %appropriately named field with data inside of it
        if (~isempty(FPind))
            data.acq(sweepNum).nFPchan = length(FPind);
            data.acq(sweepNum).FP = cell(length(FPind),1);
            data.acq(sweepNum).FPnames = cell(length(FPind),1);
            for n = 1:data.acq(sweepNum).nFPchan
                data.acq(sweepNum).FP{n} = wsData.sweeps(sweepNum).acqData(:,FPind(n));
                tmpName = tmpTraceNames{FPind(n)};
                tmpName(find(tmpName==' ')) = [];
                data.acq(sweepNum).FPnames{n} = tmpName;
            end
        end
        if (~isempty(wheelInd))
            data.acq(sweepNum).wheel{1} = wsData.sweeps(sweepNum).acqData(:,wheelInd);
        end
        if (~isempty(refSigInd))
            data.acq(sweepNum).refSig = cell(length(refSigInd),1);
            data.acq(sweepNum).refSigNames = cell(length(refSigInd),1);
            for n = 1:length(refSigInd)
                data.acq(sweepNum).refSig{n} = wsData.sweeps(sweepNum).acqData(:,refSigInd(n));
                tmpName = tmpTraceNames{refSigInd(n)};
                tmpName(find(tmpName==' ')) = [];
                data.acq(sweepNum).refSigNames{n} = tmpName;
            end
        end
        if (~isempty(pulseInd))
            data.acq(sweepNum).opto{1} = wsData.sweeps(sweepNum).acqData(:,pulseInd);
        end
        if (~isempty(controlInd))
            data.acq(sweepNum).control = cell(length(controlInd),1);
            data.acq(sweepNum).controlNames = cell(length(controlInd),1);
            for n = 1:length(controlInd)
                data.acq(sweepNum).control{n} = wsData.sweeps(sweepNum).acqData(:,controlInd(n));
                tmpName = tmpTraceNames{controlInd(n)};
                tmpName(find(tmpName==' ')) = [];
                data.acq(sweepNum).controlNames{n} = tmpName;
            end
        end
        data.acq(sweepNum).time = wsData.sweeps(sweepNum).time;
    end
end

function [FPind,wheelInd,refSigInd,pulseInd,controlInd] = parseTraceNames(traceNames)
%Parse Trace Names
%
%   [FPind,wheelInd,refSigInd,pulseInd,controlInd] = parseTraceNames(traceNames)
%   
%
%   Description: This function parses the trace names variable and pulls
%   the indices of traces with the following names. This code will be
%   edited, so we don't need to follow such a strict naming system.
%
%
%
    FPind = []; wheelInd = []; refSigInd = []; pulseInd = []; controlInd = [];
    for n = 1:length(traceNames)
        tmpName = traceNames{n};
        if (strncmp(tmpName,'ACh',3)==1) || (strncmp(tmpName,'DA',2)==1) || (strncmp(tmpName,'DAsensor',7)==1) ...
                || (strncmp(tmpName,'DASensor',7)==1) || (strncmp(tmpName,'FP',2)==1) || (strncmp(tmpName,'GCaMP',5)==1)
            FPind = [FPind,n];
        elseif (strncmp(tmpName,'Wheel',5)==1)
            wheelInd = n;
        elseif (strncmp(tmpName,'Control',5)==1) || (strncmp(tmpName,'Red',3)==1) || (strncmp(tmpName,'Isosbestic',8)==1)
            controlInd = [controlInd,n];
        elseif (strncmp(tmpName,'Ref',3)==1) || (strncmp(tmpName,'refSig',6)==1)
            refSigInd = [refSigInd,n];
        elseif (strncmp(tmpName,'Pulse',5)==1) || (strncmp(tmpName,'rawPulse',8)==1) ...
                || (strncmp(tmpName,'Opto',4)==1)
            pulseInd = n;
        end
    end
end

function data = initDS()
    data = struct('mouse',[],'date',[],'acq',struct());
    data.acq = struct('FPnames','','nFPchan',[],'FP',[]);
end