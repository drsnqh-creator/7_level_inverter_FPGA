library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
    port (
        clk     : in  std_logic; -- clock hệ thống (ví dụ 50MHz)
        button_in  : in  std_logic; -- tín hiệu từ nút nhấn
        button_out : out std_logic  -- tín hiệu đã sạch
    );
end debouncer;

architecture rtl of debouncer is
    -- Giả sử Clock 200MHz, 20ms = 4,000,000 chu kỳ clock
    constant delay_counter : integer := 400000;
    signal counter : integer := 0;
    signal button_state : std_logic := '1';
begin
    process(clk)
    begin
			if rising_edge(clk) then
				if button_in /= button_state then
                -- Nút nhấn thay đổi trạng thái, bắt đầu đếm
                if counter < delay_counter then
                    counter <= counter + 1;
                else
                    -- Đủ thời gian chờ, cập nhật trạng thái mới
                    button_state <= button_in;
                    counter <= 0;
                end if;
            else
                -- Tín hiệu ổn định, reset bộ đếm
                counter <= 0;
            end if;
			end if;
    end process;
    
    button_out <= button_state;
end rtl;