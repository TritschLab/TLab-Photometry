function [fName] = chk_N_Analysis(data)
%Check Number of Analysis
%
%   [fName] = chk_N_Analysis(data)
%
%   Description: This function is a helper to the analyzeFP script. It
%   parses a data structure to see how many final_x array of structures
%   there are and outputs the next available final_x field name that the
%   user can create.
%
%   Input:
%   - data - Data structure in the format specified by convertH5_FP and
%   analyzeFP scripts
%
%   Output:
%   - fName - Next available field name that can be used to input analyzed
%   data
%
%
%   Author: Pratik Mistry, 2019
%
    n = 0;
    while(1)
        if n == 0
            if isfield(data,'final')
                n = n+1;
            else
                fName = 'final';
                break
            end
        else
            if (isfield(data,sprintf('final_%d',n)))
                n = n+1;
            else
                fName = sprintf('final_%d',n);
                break;
            end
        end
    end
end