function rdata = clip_data(data, boundaries)

rdata = data;

if (size(boundaries, 2) ~= 2)
   error('Error using clip_data function') ;
end

if (data < boundaries(1))
   rdata = boundaries(1);
   return;
end

if (data > boundaries(2))
   rdata = boundaries(2);
   return;
end