library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.inverter_pkg.all;

entity inverter_top is
	port(
			clk_50MHz : in std_logic;
			reset : in std_logic;
			pwm_chb_out : out pwm_output;
			button_start : in std_logic;
			button_stop : in std_logic
			
		);
end inverter_top;

architecture rtl of inverter_top is
	-- 1. Khai báo Component PLL vừa tạo từ IP Catalog
		component clk_200mhz
			port (
				areset : in  std_logic := '0';
            inclk0 : in  std_logic := '0';
            c0     : out std_logic ;
            locked : out std_logic 
        );
		end component;

    -- 2. Khai báo các Signal trung gian
	signal clk_200MHz_wire : std_logic;
	signal pll_locked : std_logic;
	signal pll_areset_wire: std_logic;
	signal m_val_wire : unsigned(31 downto 0) := to_unsigned(1074, 32);
	signal triangle_wire : triangle_array;
	signal clk_logic : std_logic;
	signal addr_A_P_wire : unsigned(9 downto 0); 
	signal sine_A_P_wire : unsigned(11 downto 0);
	signal addr_A_N_wire : unsigned(9 downto 0); 
	signal sine_A_N_wire : unsigned(11 downto 0);
	signal pwm_chb_ideal_wire : pwm_ideal;
	signal pwm_output_wire : pwm_output;
	--nut nhan
	signal power_on_clean : std_logic;
	signal power_off_clean : std_logic;
	signal pwm_enable_wire : std_logic; --flag bat/tat xung
	
	--signal sync_wire : std_logic;
begin

   --3. Gọi cấu trúc (Instantiate) khối PLL
		u_pll : clk_200mhz
		port map (
			areset => pll_areset_wire,       -- Nối chân reset
         inclk0 => clk_50MHz,   -- Xung vào 50MHz
         c0     => clk_200MHz_wire,  -- Xung ra 200MHz đã được ép xung thành công!
         locked => pll_locked   -- Tín hiệu báo PLL đã khóa pha ổn định (1 = sẵn sàng)
        );
--clk_200MHz_wire <= clk_50MHz; -- Ép xung hệ thống tạm thời chạy bằng xung 50MHz của Testbench
	--pll_locked      <= '1';
	pll_areset_wire <= not reset;
   clk_logic <= clk_200MHz_wire and pll_locked;
	 
		triangle: entity work.triangle_wave
		port map(
			clk_in => clk_logic,
			reset => pwm_enable_wire,
			--sync_strobe => sync_wire,
			triangle => triangle_wire
				);
		
		phase_accumulator: entity work.phase_accumulator
		port map(
			clk => clk_logic,
			reset => pwm_enable_wire,
			m_val => m_val_wire,
			addr_A_P => addr_A_P_wire,
			addr_A_N => addr_A_N_wire
				);
			
		sine_rom: entity work.sine_ROM
		port map(
			clk => clk_logic,
			addr_A_P => addr_A_P_wire,
			addr_A_N => addr_A_N_wire,
			sine_val_A_P => sine_A_P_wire,
			sine_val_A_N => sine_A_N_wire
				);
		
		comparator: entity work.comparator
		port map(
			clk => clk_logic,
			triangle_in => triangle_wire,
			sine_A_P_in => sine_A_P_wire,
			sine_A_N_in => sine_A_N_wire,
			--sync_strobe => sync_wire,
			pwm_chb_out => pwm_chb_ideal_wire
				);
		dead_time: entity work.dead_time
		generic map(T_dead_time => 60) --gia su 1us = 1000ns, neu T_dead_time = 1000 thi 1000*5ns (1/200mhz) => 5000ns = 5us
		port map(
			clk => clk_logic,
			reset => pwm_enable_wire,
			pwm_chb_in => pwm_chb_ideal_wire,
			pwm_chb_out => pwm_output_wire
				);
		pwm_chb_out <= pwm_output_wire;
		
		--Debouncer cho cac nut nhan	
		POWER_ON : entity work.debouncer 
		port map(clk => clk_logic, button_in => button_start, button_out => power_on_clean);
		
		POWER_OFF : entity work.debouncer 
		port map(clk => clk_logic, button_in => button_stop, button_out => power_off_clean);
		--ERROR_TEST : debouncer port map(clk => CLK_50MHZ, btn_in => button_error, btn_out => button_error_test);
		--Van hanh he thong
		FSM : entity work.controller_FSM
		port map(
			clk => clk_logic,
			reset => reset,
			power_on => power_on_clean,
			power_off => power_off_clean,
			pwm_enable => pwm_enable_wire
					);
	
end rtl;