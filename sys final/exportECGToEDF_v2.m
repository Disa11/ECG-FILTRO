function exportECGToEDF_v2(matFilePath)
    % Asegúrate de que biosig está en tu path de MATLAB
    addpath('path_to_biosig'); % Cambia 'path_to_biosig' por la ruta donde tienes biosig
    
    % Cargar los datos del archivo .mat
    data = load(matFilePath);
    
    % Obtener la señal de ECG y la información del paciente
    ecgData = data.val; % Ajusta esto según la estructura de tu .mat
    patientInfo = getPatientInfo();
    
    % Pedir al usuario seleccionar la carpeta de salida y el nombre del archivo
    outputPath = uigetdir('', 'Selecciona la carpeta de salida');
    [fileName, pathName] = uiputfile('*.edf', 'Guardar archivo como');
    
    % Comprobar si el usuario seleccionó un archivo
    if isequal(fileName, 0) || isequal(pathName, 0)
        disp('Usuario canceló la selección del archivo.');
        return;
    else
        fullOutputPath = fullfile(pathName, fileName);
    end
    
    % Datos de ECG
    signal = ecgData; % Ajusta esto según la estructura de tu .mat
    fs = patientInfo.Fs;
    
    % Tiempo en segundos
    t = (0:length(signal)-1) / fs;
    
    % Crear la estructura para guardar el archivo EDF
    hdr = struct();
    hdr.version = '0';
    hdr.patientID = patientInfo.Name;
    hdr.recordID = patientInfo.Diagnosis;
    hdr.startdate = datestr(now, 'dd-MMM-yyyy');
    hdr.starttime = datestr(now, 'HH:MM:SS');
    hdr.numRec = 1;
    hdr.duration = length(signal) / fs;
    hdr.numSignals = 1;
    hdr.label = {'ECG'};
    hdr.transducer = {''};
    hdr.physDimension = {'uV'};
    hdr.physMin = min(signal);
    hdr.physMax = max(signal);
    hdr.digMin = -32768;
    hdr.digMax = 32767;
    hdr.prefilter = {''};
    hdr.samplefrequency = fs;
    hdr.reserved = {''};
    hdr.nr = 1;

    % Escribir el archivo EDF
    writetoedf(fullOutputPath, hdr, signal');
end

function writetoedf(filename, hdr, signal)
    % Utiliza biosig para escribir el archivo EDF
    S = struct();
    S.Head = hdr;
    S.Data = signal;
    S = sopen(filename, 'w', S);
    S = swrite(S, signal);
    sclose(S);
end

function patientInfo = getPatientInfo()
    prompt = {'Nombre:', 'Edad:', 'Género:', 'Frecuencia de Muestreo (Hz):', 'Diagnóstico:'};
    dlgtitle = 'Datos del paciente';
    dims = [1 35];
    definput = {'', '', '', '250', ''};
    answer = inputdlg(prompt, dlgtitle, dims, definput);
    
    % Convertir la respuesta en una estructura
    patientInfo.Name = answer{1};
    patientInfo.Age = str2double(answer{2});
    patientInfo.Gender = answer{3};
    patientInfo.Fs = str2double(answer{4});
    patientInfo.Diagnosis = answer{5};
end

% Ejemplo de uso
matFilePath = 'path_to_your_mat_file.mat'; % Cambia esto por la ruta de tu archivo .mat
exportECGToEDF(matFilePath);
