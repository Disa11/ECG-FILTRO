function matToCsv(matFilePath, outputFolder, outputFileName)
    % Cargar el archivo .mat
    data = load(matFilePath);
    
    % Obtener los nombres de las variables en el archivo .mat
    variableNames = fieldnames(data);
    
    % Crear un archivo CSV para cada variable
    for i = 1:length(variableNames)
        varName = variableNames{i};
        varData = data.(varName);
        
        % Verificar si los datos son una matriz, tabla, o estructura
        if isnumeric(varData) || islogical(varData)
            % Convertir la matriz a tabla
            varTable = array2table(varData);
        elseif isstruct(varData)
            % Convertir la estructura a tabla
            varTable = struct2table(varData);
        else
            error('El tipo de dato %s no es soportado.', class(varData));
        end
        
        % Definir la ruta del archivo de salida
        outputPath = fullfile(outputFolder, [outputFileName, '.csv']);
        
        % Escribir la tabla en el archivo CSV
        writetable(varTable, outputPath);
    end
    
    fprintf('Archivos convertidos y guardados en la carpeta: %s\n', outputFolder);
end
