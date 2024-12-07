clc; clear; close all
%% .TIF DOSYASINI MATLABDA MATRİSE ÇEKMEK

% GeoTIFF dosyasını yükleyin ve veri türünü dönüştürün
[elevationData, R] = readgeoraster('n39_w107_1arc_v3.tif'); % 'dosya_yolu.tif' yerine dosyanızın adını koyun
elevationData = double(elevationData); % Veriyi double türüne dönüştürün

% Raster bilgilerini kullanarak enlem ve boylam değerlerini hesaplayın
[lat, lon] = latlonRasterToGrid(R, size(elevationData));

%% SEÇİLEN NOKTANIN İRTİFASI

% Enlem ve boylam değerlerini girin
latitude = 39.2; % Örnek enlem
longitude = -106.2; % Örnek boylam

latitude_ac = 39.3; % Örnek enlem
longitude_ac = -106.3; % Örnek boylam

% Yönelim Açısı (Heading Angle)
headingAngle = -45; % yönelim açısı

% Ok yönü için u ve v hesapla
u = 0.03 * cosd(headingAngle);
v = 0.03 * sind(headingAngle);

% Satır ve sütun indekslerini hesapla
[row, col] = geographicToDiscrete(R, latitude, longitude);

% Yüksekliği alma
altitude = elevationData(row, col);
disp(['İrtifa: ', num2str(altitude), ' metre']);

%% TABLO
% Yansıma sorununu düzeltmek için veriyi X eksenine göre ters çevirin
elevationData_graph = flipud(elevationData); % Yukarı-aşağı çevirmek için kullanılır

figure;
surf(lon, lat, elevationData_graph, 'EdgeColor', 'none'); % 3D yüzey grafiği
colormap(parula); % Renk haritası
colorbar; % Renk skalası ekleyin
title('Yükseklik Haritası');
xlabel('Boylam');
ylabel('Enlem');
view(2); % Yatay görünüm (2D)

hold on
plot3(longitude, latitude, altitude+10000, 'ro', 'MarkerSize', 15, 'LineWidth', 2); % nokta
plot3(longitude, latitude, altitude+10000, 'ro', 'MarkerSize', 1, 'LineWidth', 1); % nokta
quiver3(longitude_ac, latitude_ac, 10000, u, v, 0, 'k', 'LineWidth', 1.5, 'MaxHeadSize', 100); % Ok

%% FONKSİYONLARIN TANIMLARI
function [lat, lon] = latlonRasterToGrid(R, dataSize)
    % Koordinat sistemine göre enlem ve boylam değerlerini hesaplayın
    rows = dataSize(1);  % İlk boyutu (satır) al
    cols = dataSize(2);  % İkinci boyutu (sütun) al
    latLimits = R.LatitudeLimits; % Enlem limitleri
    lonLimits = R.LongitudeLimits; % Boylam limitleri
    [lon, lat] = meshgrid(linspace(lonLimits(1), lonLimits(2), cols), ...
                          linspace(latLimits(1), latLimits(2), rows));
end
