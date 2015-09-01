function BSHELL = extract_Bshells(bval, segment_size, group)
% 
% bval => vector of bvalues
% segment size => size of the segment as a percentage of the size ( value between 0
% and 1 for 0% -> 100%).
% group => range for which all the values should be in the same group
% 

if (numel(bval) < 1)
   error('Empty input "bval"'); 
end

if (segment_size <= 0)
    error('Segment size shoud be positive and non-null'); 
end

if (length(group) ~= 2) || (group(2) < group(1))
    error('"group" should be a range ex: [50, 800] ');
end

bval( bval >= group(1) & bval <= group(2) ) = 0;
bval = sort(bval);


BSHELL(1) = bval(1);
local_counter = 2;

for i=2:length(bval)
    
    if ( bval(i) > (1+segment_size) * bval(i-1) )
        BSHELL(local_counter) = bval(i);
        local_counter = local_counter +1;
    end
    
end



end