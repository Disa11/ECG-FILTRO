function fileInfo = loadMatFileProperties(filePath)
    % Obtener información del archivo
    fileStruct = dir(filePath);
    fileInfo.name = fileStruct.name;
    fileInfo.size = fileStruct.bytes; % Tamaño en bytes
    fileInfo.date = fileStruct.date;
    
    % Cargar las variables del archivo .mat
    data = load(filePath);
    variables = whos('-file', filePath);
    
    % Extraer variables y duraciones si es relevante
    fileInfo.variables = {variables.name};
    for i = 1:length(variables)
        varName = variables(i).name;
        varData = data.(varName);
        
        % Suponiendo que la duración se refiere a una señal de tiempo
        if isnumeric(varData) && isvector(varData)
            Fs = 500; % Suponiendo una frecuencia de muestreo fija de 250 Hz
            fileInfo.duration.(varName) = length(varData) / Fs;
        end
    end
end
