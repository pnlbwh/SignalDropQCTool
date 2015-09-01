function check_matlab_pool

% % % 
% Check if we need to start matlabpool
% % % 
s = matlabpool('size');
if (s < 1)
    
    message = sprintf('Would you like to enable multicore processing? \n\nIt seems like matlabpool is not running, you can enable multicore processing by starting it');
    title = 'Allow multicore processing?';
    choice = questdlg(message, title, 'Yes', 'No', 'Yes');
    
    if strcmpi(choice, 'Yes')
        h = msgbox('Starting matlabpool, please wait a few seconds');
        matlabpool open;
        close(h);
    end
end

end