% Obtener información del archivo
info = h5info('C:\Users\danam\Desktop\CHino_2Prueba.h5');

% Leer un dataset específico
data = h5read('C:\Users\danam\Desktop\CHino_2Prueba.h5', '/ECG');

% Mostrar los datos
disp(data);
