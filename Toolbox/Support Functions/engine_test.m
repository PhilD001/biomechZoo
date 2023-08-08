fld = 'D:\Lab\Thesis\chapters'

% Start timer
tic
% Record the current memory usage
memory_before = whos;
% fl = engine('path',fld, 'extension', 'pptx', 'search path', 'results')
fl = engine_improved('path',fld, 'extension', 'pptx', 'search path', 'results')
% Stop timer
elapsed_time = toc;
% Record the memory usage after function execution
memory_after = whos;
disp(['Elapsed time: ', num2str(elapsed_time), ' seconds']);
% Calculate and display the difference in memory usage
memory_consumed = sum([memory_after.bytes]) - sum([memory_before.bytes]);
disp(['Memory consumed: ', num2str(memory_consumed / (1024^2)), ' MB']);