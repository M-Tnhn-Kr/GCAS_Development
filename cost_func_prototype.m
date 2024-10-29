% Örnek parametreler
altitude = 3000;               % İrtifa, feet cinsinden
mach = 1;                     % Başlangıç Mach sayısı
distance = 500;                  % Kat edilecek mesafe, nautical miles
fuel_price_per_unit = 10;         % Yakıt fiyatı, dolar/gallon
fuel_efficiency_coeff = 0.8;     % Yakıt harcama katsayısı

% Enerji maliyetini minimize eden optimal thrust'i fmincon ile bul
optimal_thrust_fmincon = optimize_thrust_for_distance(altitude, mach, distance, fuel_price_per_unit, fuel_efficiency_coeff);

% patternsearch ile optimize et
initial_thrust = 15000;
thrust_lower_bound = 3000;
thrust_upper_bound = 25000;
time_needed = distance / (mach * 661.47); % time_needed hesaplandı

% Enerji maliyeti fonksiyonu
energy_cost_function = @(thrust) compute_energy_cost(thrust, altitude, mach, time_needed, fuel_price_per_unit, fuel_efficiency_coeff);

% patternsearch ayarları
options = optimoptions('patternsearch', 'Display', 'iter');
optimal_thrust_patternsearch = patternsearch(energy_cost_function, initial_thrust, [], [], [], [], thrust_lower_bound, thrust_upper_bound, options);

% Thrust değerlerine göre enerji maliyetini grafikte göster
thrust_values = linspace(thrust_lower_bound, thrust_upper_bound, 100);
energy_costs = arrayfun(@(thrust) compute_energy_cost(thrust, altitude, mach, time_needed, fuel_price_per_unit, fuel_efficiency_coeff), thrust_values);

% Grafiği çiz
figure;
plot(thrust_values, energy_costs);
xlabel('Thrust (N)');
ylabel('Energy Cost ($)');
title('Thrust vs. Energy Cost');
grid on;

%%

function optimal_thrust = optimize_thrust_for_distance(altitude, mach, distance, fuel_price_per_unit, fuel_efficiency_coeff)
    % Belirli bir mesafeyi katetmek için enerji maliyetini minimize eden thrust değerini bulur.
    % Girdiler:
    %   altitude               - İrtifa (feet)
    %   mach                   - Başlangıç Mach sayısı
    %   distance               - Kat edilecek mesafe (nautical miles)
    %   fuel_price_per_unit    - Yakıt birim fiyatı (dolar/gallon)
    %   fuel_efficiency_coeff  - Yakıt harcama katsayısı
    % Çıktı:
    %   optimal_thrust         - Enerji maliyetini minimize eden thrust değeri (Newton)

    % Hız (velocity) Mach sayısına göre hesaplanır
    speed_of_sound = 661.47; % deniz seviyesinde Mach 1 hızı, knot cinsinden
    velocity = mach * speed_of_sound; % velocity, knot

    % Zaman hesaplanır (saat cinsinden)
    time_needed = distance / velocity; % Saat cinsinden uçuş süresi

    % Enerji maliyeti fonksiyonunu tanımla (thrust'a göre)
    energy_cost_function = @(thrust) compute_energy_cost(thrust, altitude, mach, time_needed, fuel_price_per_unit, fuel_efficiency_coeff);

    % Başlangıç thrust tahmini ve sınırlamaları
    initial_thrust = 15000; % Başlangıç tahmini
    thrust_lower_bound = 3000; % Minimum thrust değeri
    thrust_upper_bound = 25000; % Maksimum thrust değeri

    % Optimize et
    options = optimset('Display', 'iter');
    optimal_thrust = fmincon(energy_cost_function, initial_thrust, [], [], [], [], thrust_lower_bound, thrust_upper_bound, [], options);

    % Sonucu ekrana yazdır
    disp(['Optimal Thrust for ', num2str(distance), ' nautical miles at altitude ', ...
          num2str(altitude), ' feet: ', num2str(optimal_thrust), ' N']);
end

function energy_cost = compute_energy_cost(thrust, altitude, mach, distance, fuel_price_per_unit, fuel_efficiency_coeff)
    % İtme gücü (thrust), irtifa ve diğer parametrelerle enerji maliyetini hesaplar

    % Sürükleme fonksiyonu
    drag = @(mach, altitude) 1000 + 10 * mach^2 + 0.01 * altitude;

    % Yakıt akış hızını hesaplayan fonksiyon
    fuel_flow_rate = @(thrust, drag) fuel_efficiency_coeff * (thrust + drag) / 1000;

    % Hızın thrust'a bağlı olarak hesaplanması (örnek basit bir model)
    speed_of_sound = 661.47; % knot cinsinden deniz seviyesinde Mach 1 hızı
    velocity = mach * speed_of_sound * (thrust / 15000)^(1/3); % Thrust arttıkça hız da artacak (örnek model)

    % Görev süresinin hesaplanması
    time_needed = distance / velocity; % Saat cinsinden uçuş süresi

    % Yakıt tüketimini hesapla
    fuel_burn = 0;
    time_steps = linspace(0, time_needed, 100); % Uçuş süresini 100 adıma böl

    for t = 1:length(time_steps)
        current_drag = drag(mach, altitude); % Sürüklemeyi hesapla
        current_ff = fuel_flow_rate(thrust, current_drag); % Yakıt akış hızını hesapla

        % Yakıt tüketimi (yaklaşık integral)
        fuel_burn = fuel_burn + current_ff * (time_steps(2) - time_steps(1)); % Riemann toplamı
    end

    % Enerji maliyetini hesapla
    energy_cost = fuel_burn * fuel_price_per_unit;
end