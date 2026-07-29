library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.inverter_pkg.all;

entity dead_time is
	generic(T_dead_time : integer);
	
	port (
		clk : in std_logic;
		reset : in std_logic;
		pwm_chb_in : in pwm_ideal;
		pwm_chb_out : out pwm_output
		);
end dead_time;

architecture rtl of dead_time is
	type delay_array is array (0 to 2) of integer range 0 to T_dead_time; 
	signal delay_P1, delay_P2, delay_N1, delay_N2 : delay_array := (others => 0);
	--signal flag1, flag2, flag3, flag4 : std_logic_vector(0 to 2) := (others => '0');
	signal pwm_reg : pwm_output := (others => ('0', '0', '0', '0'));
begin
	gene_dead_time: for i in 0 to 2 generate
	begin
		process(clk)
		begin
			if reset = '0' then
				delay_P1(i) <= 0;
            delay_P2(i) <= 0;
            delay_N1(i) <= 0;
            delay_N2(i) <= 0;
                
            pwm_reg(i).pwm_output_P_1 <= '0';
            pwm_reg(i).pwm_output_P_2 <= '0';
            pwm_reg(i).pwm_output_N_1 <= '0';
            pwm_reg(i).pwm_output_N_2 <= '0';
			elsif rising_edge(clk) then
				--dead time cho nhanh P MOSFET thu 1
				if pwm_chb_in(i).pwm_chb_P_1 = '1' then
					if delay_P1(i) < T_dead_time then
						delay_P1(i) <= delay_P1(i) + 1;
						pwm_reg(i).pwm_output_P_1 <= '0';
					else
						pwm_reg(i).pwm_output_P_1 <= '1';
					end if;
				else
					delay_P1(i) <= 0;
					pwm_reg(i).pwm_output_P_1 <= '0';
				end if;
				
				--dead time cho nhanh P MOSFET thu 2
				if pwm_chb_in(i).pwm_chb_P_2 = '1' then
					if delay_P2(i) < T_dead_time then
						delay_P2(i) <= delay_P2(i) + 1;
						pwm_reg(i).pwm_output_P_2 <= '0';
					else
						pwm_reg(i).pwm_output_P_2 <= '1';
					end if;
				else
					delay_P2(i) <= 0;
					pwm_reg(i).pwm_output_P_2 <= '0';
				end if;
				--dead time cho nhanh N MOSFET thu 1
				if pwm_chb_in(i).pwm_chb_N_1 = '1' then
					if delay_N1(i) < T_dead_time then
						delay_N1(i) <= delay_N1(i) + 1;
						pwm_reg(i).pwm_output_N_1 <= '0';
					else
						pwm_reg(i).pwm_output_N_1 <= '1';
					end if;
				else
					delay_N1(i) <= 0;
					pwm_reg(i).pwm_output_N_1 <= '0';
				end if;
				--dead time cho nhanh N MOSFET thu 2
				if pwm_chb_in(i).pwm_chb_N_2 = '1' then
					if delay_N2(i) < T_dead_time then
						delay_N2(i) <= delay_N2(i) + 1;
						pwm_reg(i).pwm_output_N_2 <= '0';
					else
						pwm_reg(i).pwm_output_N_2 <= '1';
					end if;
				else
					delay_N2(i) <= 0;
					pwm_reg(i).pwm_output_N_2 <= '0';
				end if;
			end if;
		end process;
	end generate;
	pwm_chb_out <= pwm_reg;
end rtl;