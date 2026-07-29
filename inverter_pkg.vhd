library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package inverter_pkg is
	type pwm_ideal_chb is record
		pwm_chb_P_1 : std_logic;
		pwm_chb_P_2 : std_logic;
		pwm_chb_N_1 : std_logic;
		pwm_chb_N_2 : std_logic;
	end record;	
		
	type pwm_ideal is array (0 to 2) of pwm_ideal_chb;
	
	type pwm_output_chb is record
		pwm_output_P_1 : std_logic;
		pwm_output_P_2 : std_logic;
		pwm_output_N_1 : std_logic;
		pwm_output_N_2 : std_logic;
	end record;
	type pwm_output is array (0 to 2) of pwm_output_chb;
	
	type triangle_array is array (0 to 2) of unsigned(11 downto 0);
end package;