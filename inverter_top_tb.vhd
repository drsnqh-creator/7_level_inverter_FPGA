library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.inverter_pkg.all;

-- Entity của Testbench luôn rỗng, không có chân Port
entity inverter_top_tb is
end inverter_top_tb;

architecture sim of inverter_top_tb is

    -- 1. Khai báo Component PHẢI ĐỦ CÁC CỔNG như file TOP
    component inverter_top
        port(
            clk_50MHz   : in std_logic;
            reset       : in std_logic;
            pwm_chb_out : out pwm_output; -- Bổ sung chân này
				button_start   : in std_logic;
				button_stop : in std_logic
        );
    end component;

    signal t_clk_50MHz   : std_logic := '0';
    signal t_reset       : std_logic := '1'; -- Khởi đầu bật reset để xóa mạch
    signal t_pwm_chb_out : pwm_output;          -- Tạo dây ảo hứng ngõ ra
	 signal t_button_start : std_logic:= '1';
	 signal t_button_stop : std_logic := '1';
    -- Chu kỳ 20 ns tương ứng tần số 50 MHz
    constant CLK_PERIOD : time := 20 ns; 
    signal sim_end      : boolean := false;

begin

    -- 2. Kết nối đầy đủ các cổng vào UUT
    UUT : inverter_top
        port map (
            clk_50MHz   => t_clk_50MHz,
            reset       => t_reset,
            pwm_chb_out => t_pwm_chb_out,
				button_start => t_button_start,
				button_stop => t_button_stop
        );

    -- 3. Tạo xung nhịp 50MHz liên tục
    clk_process : process
    begin
        while not sim_end loop
            t_clk_50MHz <= '0';
            wait for CLK_PERIOD / 2;
            t_clk_50MHz <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- 4. Kịch bản kích thích chuẩn xác
    stim_process : process
    begin
        --t_reset <= '0';    -- 1. Giữ reset 0 cao trong 100 ns đầu để xóa mạch
		  --wait for 100 ns;
		  
		  
		  --t_button_start <= '0';
		  
		  --wait for 2 ms;
		  
		  t_button_start <= '0';
		  wait for 22 ms;
		  
		  --t_button_stop <= '0';
        
		  --t_reset <= '1';
        --t_button_start <= '1';    -- 2. CHÚ Ý: NHẢ RESET VỀ '1' ĐỂ MẠCH BẮT ĐẦU CHẠY!
        
        -- Cho mạch chạy trong 20 ms để tích lũy pha uốn lượn sóng Sin
        --wait for 2 ms;
        
        sim_end <= true;
        report "Mo phong hoan thanh an toan!";
        wait;
    end process;

end sim;