function t = ListCheckBox(fig, pos, items)
    % Makes sure the figure is always "in front" and active
    figure(fig);
    
    % Prepare data for uitable
    databox = cell(numel(items), 2);
    databox(:, 1) = {false};  % all boxes to tick, unticked by default
    databox(:, 2) = items;   % name of all items
    
    % Creates a uitable with a vertical bar
    t = uitable(fig, 'Data', databox, 'ColumnName', {'','Name'}, 'ColumnEditable', [true false], ...
                'RowName', [], 'Position', pos, 'ColumnWidth', {25, 120}, 'Units', 'normalized');
    

     % Store databox in UserData to keep accessible for user
    set(fig, 'UserData', databox);

end
