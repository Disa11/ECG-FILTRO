function exportMatToExcel(matFileName, excelFileName)
    % Cargar el archivo .mat
    data = load(matFileName);
    
    % Obtener los nombres de las variables del archivo .mat
    varNames = fieldnames(data);
    
    % Inicializar un contenedor para las tablas
    tables = cell(size(varNames));
    
    % Convertir cada variable en una tabla (si es posible)
    for i = 1:numel(varNames)
        varData = data.(varNames{i});
        if ismatrix(varData) && isnumeric(varData)
            % Si la variable es una matriz numérica, convertirla en una tabla
            tables{i} = array2table(varData);
            % Añadir un nombre a las columnas si la tabla tiene una sola columna
            if size(varData, 2) == 1
                tables{i}.Properties.VariableNames = {varNames{i}};
            end
        else
            % Si la variable no es una matriz numérica, convertirla en una tabla con un solo elemento
            tables{i} = table(varData);
        end
        % Añadir el nombre de la variable como nombre de la tabla
        tables{i}.Properties.Description = varNames{i};
    end
    
    % Escribir cada tabla en una hoja separada del archivo de Excel
    for i = 1:numel(tables)
        writetable(tables{i}, excelFileName, 'Sheet', varNames{i});
    end
    
    fprintf('Datos exportados a %s\n', excelFileName);
end
