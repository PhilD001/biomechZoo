function t = ListCheckBox(fig, pos, items)
    % S'assure que la figure est en avant et active
    figure(fig);
    
    % Prépare les données pour la uitable
    databox = cell(numel(items), 2);
    databox(:, 1) = {false};  % Toutes les cases à cocher non cochées par défaut
    databox(:, 2) = items;   % Les noms des items
    
    % Crée une uitable avec une barre de défilement verticale
    t = uitable(fig, 'Data', databox, 'ColumnName', {'','Name'}, 'ColumnEditable', [true false], ...
                'RowName', [], 'Position', pos, 'ColumnWidth', {25, 120}, 'Units', 'normalized');
    

     % Stocke databox dans UserData pour un accès ultérieur
    set(fig, 'UserData', databox);

end
