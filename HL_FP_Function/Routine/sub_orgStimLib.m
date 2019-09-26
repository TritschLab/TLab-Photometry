% function StimLib = sub_orgStimLib(tmpStimLib)
% Organize WS Stimulus Library
%
%   StimLib = sub_orgStimLib(tmpStimLib);
%
%   Description: This function organizes the data structure of the stimulus
%   library created from the crawl_h5_tree into a format that is easier to
%   parse and to locate the corresponding stimulis to maps, and maps to
%   sequences.
%
% Haixin Liu 2019-09
% taken directly from Pratik's loading data function
%% 
function StimLib = sub_orgStimLib(tmpStimLib)

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
            nMapSeq = numel(fieldnames(tmpSeq.IndexOfEachMapInLibrary));
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
