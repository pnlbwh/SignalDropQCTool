function varargin = remapPartialParamNames(fullNames, varargin)
%remapPartialParamNames  Replace partial P-V pair names with full names.
%
%    OUTCELL = remapPartialParamNames(FULLNAMES, INCELL) replaces
%    partial matches of the strings in the input cell array INCELL
%    with the corresponding matches in the FULLNAMES cell array of
%    strings.  Basically, look for case insensitive partial matches
%    of strings in INCELL with the longer version of those strings
%    in FULLNAMES.
%
%    Typical usage example:
%
%       % Replace partial name matches with the canonical form.
%       varargin = remapPartialParamNames({'DisplayOptimization', 'PyramidLevels'}, ...
%                                         varargin{:});

%   Copyright 2011 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2011/11/09 16:49:13 $


% Look for parameter names in the input fields.
for p = 1:numel(varargin)
  
  if (isa(varargin{p}, 'char'))

    % Look for input param name in the list of known names.
    idx = my_strmatch(varargin{p}, fullNames);
    
    % Replace unambiguous param name matches with the canonical full name.
    if (numel(idx) == 1)
      varargin{p} = fullNames{idx};
    end
    
  end
  
end

end



function idx = my_strmatch(str, cellOfStrings)
% A function that looks and acts like STRMATCH, but isn't STRMATCH.

idx = find(strncmpi(str, cellOfStrings, numel(str)));

end
