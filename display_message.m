function display_message(activate, handles, message)

if activate == true
   set(handles.text_message, 'visible', 'on');
else
   set(handles.text_message, 'visible', 'off'); 
end

set(handles.text_message, 'string', message);
drawnow;

end