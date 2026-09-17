% 1. Định nghĩa cấu hình
num_elements = 1024; % Số lượng phần tử
min_val = 390;        % Giá trị nhỏ nhất
max_val = 3517;      % Giá trị lớn nhất

% Tính toán biên độ (amplitude) và giá trị dịch offset (DC offset)
% Công thức dịch chuyển khoảng: S = Offset + Amplitude * sin(x)
amplitude = (max_val - min_val) / 2; % = 1950
offset = (max_val + min_val) / 2;    % = 2000

% 2. Tạo mảng góc từ 0 đến 360 độ (chia thành 1024 điểm)
% Lưu ý: Góc cuối cùng thường để là 360*(1 - 1/1024) để chu kỳ tuần hoàn mượt mà,
% nhưng ở đây linspace(0, 360) sẽ lấy chính xác từ điểm 0° đến đúng điểm 360°.
angles_deg = linspace(0, 360, num_elements);
angles_rad = deg2rad(angles_deg); % Chuyển sang radian

% 3. Tính giá trị sóng sin trong khoảng [50, 3950] và làm tròn thành số nguyên
sin_lut = round(offset + amplitude * sin(angles_rad));

% 4. Xuất ra Command Window với dấu phẩy phía sau mỗi số
for i = 1:num_elements
    if i < num_elements
        fprintf('%d, ', sin_lut(i));
    else
        fprintf('%d', sin_lut(i)); % Số cuối cùng không có dấu phẩy
    end
    
    % Xuống dòng sau mỗi 16 số cho dễ nhìn
    if mod(i, 16) == 0
        fprintf('\n');
    end
end
fprintf('\n'); % Xuống dòng khi kết thúc