function checkForSameSizeAndClass(X, Y, ~)
%checkForSameSizeAndClass used by immultiply,imdivide,imabsdiff
%   private function to check that X and Y have the same size and class.
    
% Copyright 2007-2011 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2011/07/19 23:55:00 $
    
if ~strcmp(class(X),class(Y))
    error(message('images:checkForSameSizeAndClass:mismatchedClass'))
end

if ~isequal(size(X),size(Y))
    error(message('images:checkForSameSizeAndClass:mismatchedSize'))
end
