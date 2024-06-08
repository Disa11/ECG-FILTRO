function exportECGToHDF5(matFilePath, outputFolderPath, outputFileName)
    % Cargar datos del archivo .mat
    data = load(matFilePath);
    
     if isfield(data, 'val')
        ecgData = data.val;
    else
        error('El archivo .mat no contiene una variable llamada ''val''.');
    end
    % Solicitar información del paciente
    patientInfo = getPatientInfo();
    
%     % Solicitar el nombre del archivo de salida
%     [fileName, pathName] = uiputfile('*.h5', 'Guardar archivo como', fullfile(outputFolder, 'ECG_PatientData.h5'));
%     if isequal(fileName, 0) || isequal(pathName, 0)
%         disp('Operación cancelada.');
%         return;
%     end
%     outputPath = fullfile(pathName, fileName);
    
    outputPath = fullfile(outputFolderPath, [outputFileName, '.h5']);

    % Guardar los datos en el archivo HDF5
    saveToHDF5(outputPath, ecgData, patientInfo);
    
    fprintf('Datos exportados y guardados en: %s\n', outputPath);
end

% function patientInfo = getPatientInfo()
%     prompt = {'Nombre:', 'Edad:', 'Género:', 'Frecuencia de Muestreo (Hz):', 'Diagnóstico:'};
%     dlgtitle = 'Información del Paciente';
%     dims = [1 35];
%     definput = {'', '', '', '250', ''};
%     answer = inputdlg(prompt, dlgtitle, dims, definput);
%     
%     % Convertir la respuesta en una estructura
%     patientInfo.Name = answer{1};
%     patientInfo.Age = str2double(answer{2});
%     patientInfo.Gender = answer{3};
%     patientInfo.Fs = str2double(answer{4});
%     patientInfo.Diagnosis = answer{5};
% end

function patientInfo = getPatientInfo()
    % Crear una figura para la ventana de entrada de datos
    fig = uifigure('Name', 'Datos del Paciente', 'Position', [100, 100, 400, 300]);
    
    % Crear etiquetas y campos de entrada para cada dato
    uilabel(fig, 'Position', [20, 250, 100, 22], 'Text', 'Nombre:');
    nameField = uieditfield(fig, 'text', 'Position', [140, 250, 200, 22]);
    
    uilabel(fig, 'Position', [20, 210, 100, 22], 'Text', 'Edad:');
    ageField = uieditfield(fig, 'numeric', 'Position', [140, 210, 200, 22]);
    
    uilabel(fig, 'Position', [20, 170, 100, 22], 'Text', 'Género:');
    genderField = uieditfield(fig, 'text', 'Position', [140, 170, 200, 22]);
    
    uilabel(fig, 'Position', [20, 130, 100, 22], 'Text', 'Frecuencia de Muestreo (Hz):');
    fsField = uieditfield(fig, 'numeric', 'Position', [140, 130, 200, 22], 'Value', 250);
    
    uilabel(fig, 'Position', [20, 90, 100, 22], 'Text', 'Diagnóstico:');
    diagnosisField = uieditfield(fig, 'text', 'Position', [140, 90, 200, 22]);
    
    % Botón para confirmar la entrada de datos
    confirmButton = uibutton(fig, 'Position', [140, 40, 100, 22], 'Text', 'Confirmar', ...
        'ButtonPushedFcn', @(btn, event) confirmCallback());
    
    % Esperar hasta que se pulse el botón de confirmación
    uiwait(fig);
    
    % Función de callback para el botón de confirmación
    function confirmCallback()
        patientInfo.Name = nameField.Value;
        patientInfo.Age = ageField.Value;
        patientInfo.Gender = genderField.Value;
        patientInfo.Fs = fsField.Value;
        patientInfo.Diagnosis = diagnosisField.Value;
        
        % Cerrar la figura
        close(fig);
    end
end


function saveToHDF5(outputPath, ecgData, patientInfo)
    % Guardar los datos del ECG en el archivo HDF5
    h5create(outputPath, '/ECG', size(ecgData));
    h5write(outputPath, '/ECG', ecgData);
    
    % Guardar la información del paciente en el archivo HDF5
    fields = fieldnames(patientInfo);
    for i = 1:numel(fields)
        fieldName = fields{i};
        fieldValue = patientInfo.(fieldName);
        
        if ischar(fieldValue)
            % Para strings, primero eliminar cualquier tamaño de dimensión fijo
            h5create(outputPath, ['/', fieldName], [1], 'Datatype', 'string');
            h5write(outputPath, ['/', fieldName], string(fieldValue));
        else
            % Para valores numéricos
            h5create(outputPath, ['/', fieldName], [1], 'Datatype', class(fieldValue));
            h5write(outputPath, ['/', fieldName], fieldValue);
        end
    end
end

