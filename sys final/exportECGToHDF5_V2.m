function exportECGToHDF5_V2(matFilePath, outputFolderPath, outputFileName)

    % --------- Estado de prueba ---------- %
    
    % Cargar el archivo .mat
    data = load(matFilePath);
    
    % Suponemos que la señal ECG está en una variable llamada 'val'
    if isfield(data, 'val')
        ecgData = data.val;
    else
        error('El archivo .mat no contiene una variable llamada ''val''.');
    end
    
    % Pedir al usuario que ingrese información médica del paciente
    prompt = {'Nombre:', 'Edad:', 'Género:', 'ID del Paciente:'};
    dlgTitle = 'Información del Paciente';
    numLines = 1;
    defaultAns = {'', '', '', ''};
    answer = inputdlg(prompt, dlgTitle, numLines, defaultAns);
    
    if isempty(answer)
        error('No se ingresó información del paciente.');
    end
    
    % Crear una estructura con la información del paciente
    patientInfo = struct('Nombre', answer{1}, 'Edad', str2double(answer{2}), ...
                         'Género', answer{3}, 'ID', answer{4});
    
    % Crear el nombre del archivo de salida
    outputPath = fullfile(outputFolderPath, [outputFileName, '.h5']);
    
    % Guardar los datos en un archivo HDF5
    saveToHDF5(outputPath, ecgData, patientInfo);
end

function saveToHDF5(outputPath, ecgData, patientInfo)
    % Crear o abrir el archivo HDF5
    if exist(outputPath, 'file')
        delete(outputPath); % Borrar el archivo si ya existe
    end
    
    % Guardar la señal ECG
    h5create(outputPath, '/ECG', size(ecgData), 'Datatype', 'double');
    h5write(outputPath, '/ECG', ecgData);
    
    % Guardar la información del paciente
    patientFields = fieldnames(patientInfo);
    for i = 1:numel(patientFields)
        fieldName = patientFields{i};
        fieldValue = patientInfo.(fieldName);
        if isnumeric(fieldValue)
            h5create(outputPath, ['/', fieldName], 1, 'Datatype', 'double');
        else
            h5create(outputPath, ['/', fieldName], 1, 'Datatype', 'string');
        end
        h5write(outputPath, ['/', fieldName], fieldValue);
    end
end
