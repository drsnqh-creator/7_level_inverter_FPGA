library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_FSM is
	port (
		clk         : in  STD_LOGIC;
      reset       : in  STD_LOGIC;
      power_on   : in  STD_LOGIC; -- nút nhấn để bắt đầu xuất xung
		power_off : in std_logic; --nut nhan tat xung
		--error : in std_logic;
		--led_error : out std_logic;
      pwm_enable  : out STD_LOGIC  -- tín hiệu cho phép PWM hoạt động
		  
    );
end controller_FSM;

architecture rtl of controller_FSM is
    -- Định nghĩa 4 trạng thái tối giản
    type state_type is (idle, checking, fault, running);
    signal current_state, next_state : state_type;
	 --signal counter_checking : unsigned(27 downto 0) := (others => '0');
	 --constant checking_3s : unsigned(27 downto 0) := to_unsigned(150000000, 28);
	 --signal led_error_wire : std_logic := '0'; 
	 signal error : std_logic := '0';
begin
	process(clk)
    begin
        if rising_edge(clk) then
            if reset = '0' then -- Nếu ấn nút Reset (mức 0)
                current_state <= idle;
            else
                current_state <= next_state; -- Chuyển trạng thái theo nhịp clock
            end if;
        end if;
    end process;
    -- process 1: Logic chuyển đổi
    process(current_state, power_on, power_off, reset, clk)
    begin
        next_state <= current_state;
        case current_state is
            when idle =>
                pwm_enable <= '0'; -- không xuất xung
					 
                if power_on = '0' then --nut nhan chuyen sang muc 0
                    next_state <= checking; -- chuyển sang kiểm tra lỗi
                end if;
            when checking =>
						if error = '1' then 
							next_state <= fault;
							
						else
							next_state <= running;
						end if;
					--if error = '1' then
                    --next_state <= FAULT;
                   -- led_error <= '0';
                --end if;
				when fault =>
					pwm_enable <= '0';--tat xung
					if reset = '0' then
							next_state <= idle;
					end if;
            when running =>
               pwm_enable <= '1'; -- cho phép xuất xung
                -- giữ nguyen chạy cho đến khi nhấn nút off
					if power_off = '0' then
						next_state <= idle;
					end if;
					if error = '1' then
						next_state <= fault;
					end if;
                
            when others =>
                next_state <= idle;
        end case;
    end process;
end rtl;