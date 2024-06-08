function exportECGToEDF(ecgData, patientInfo, outputPath, outputName)
    % Asegúrate de que biosig está en tu path de MATLAB
    addpath('path_to_biosig'); % Cambia 'path_to_biosig' por la ruta donde tienes biosig
    
    % Datos de ECG
    signal = ecgData.val; % Ajusta esto según la estructura de tu .mat
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
    fullOutputPath = fullfile(outputPath, [outputName, '.edf']);
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

% Ejemplo de uso
matFilePath = 'path_to_your_mat_file.mat'; % Cambia esto por la ruta de tu archivo .mat
outputPath = uigetdir; % Pide al usuario seleccionar la carpeta de salida
outputName = 'output_file_name'; % Cambia esto por el nombre de tu archivo de salida

% Cargar los datos y la información del paciente
load(matFilePath);
patientInfo = getPatientInfo();

% Exportar a EDF
exportECGToEDF(val, patientInfo, outputPath, outputName);
