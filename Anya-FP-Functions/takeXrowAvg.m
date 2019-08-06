function [newVector] = takeXrowAvg(originalVector, numRow)

% Created By: Anya Krok
% Created On: 05 March 2019
% Description: average every X rows of data
%   reshape matrix (M, N) into matrix (x, M*N/x), take mean of matrix, 
%   which gives row vector, then reshape row vector into matrix (M/3, x)
%
% [newVector] = takeXrowAvg(originalVector, numRow)
%

x = originalVector;
xx = mean(reshape(x,numRow,[]),1); 
newVector = reshape(xx,[size(x,1)/numRow, size(x,2)]);

end
