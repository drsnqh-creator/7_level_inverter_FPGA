library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.inverter_pkg.all;

entity comparator is
    port(
        clk          : in std_logic;
        triangle_in  : in triangle_array;      -- Mảng 4 sóng tam giác (0 to 3)
        sine_A_P_in  : in unsigned(11 downto 0); -- Sóng Sin chính
        sine_A_N_in  : in unsigned(11 downto 0); -- Sóng Sin đảo dấu/đảo pha
        pwm_chb_out  : out pwm_ideal           -- Mảng 2 Cầu H (0 to 1)
    );
end comparator;

architecture rtl of comparator is
begin

    -- ===============================================================
    -- CẦU H 1 (Cell 1): 
    -- Leg A so sánh Sin_P với Tam giác 0 (0 deg)
    -- Leg B so sánh Sin_N với Tam giác 0 (0 deg) -> Tạo Unipolar 3 mức cho Cầu 1!
    -- ===============================================================
    process(clk)
    begin
        if rising_edge(clk) then
            -- [CẦU 1 - Leg A]: So sánh Sin_P với Triangle 0
            if (sine_A_P_in > triangle_in(0)) then
                pwm_chb_out(0).pwm_chb_P_1 <= '1'; -- Van trên Leg A
                pwm_chb_out(0).pwm_chb_P_2 <= '0'; -- Van dưới Leg A
            else
                pwm_chb_out(0).pwm_chb_P_1 <= '0';
                pwm_chb_out(0).pwm_chb_P_2 <= '1';
            end if;

            -- [CẦU 1 - Leg B]: So sánh Sin_N với Triangle 0 (Dùng Sin đảo)
            if (sine_A_N_in > triangle_in(0)) then
                pwm_chb_out(0).pwm_chb_N_1 <= '1'; -- Van trên Leg B
                pwm_chb_out(0).pwm_chb_N_2 <= '0'; -- Van dưới Leg B
            else
                pwm_chb_out(0).pwm_chb_N_1 <= '0';
                pwm_chb_out(0).pwm_chb_N_2 <= '1';
            end if;
        end if;
    end process;

    -- ===============================================================
    -- CẦU H 2 (Cell 2): 
    -- Leg A so sánh Sin_P với Tam giác 2 (90 deg)
    -- Leg B so sánh Sin_N với Tam giác 2 (90 deg) -> Tạo Unipolar 3 mức dời pha 90 deg!
    -- ===============================================================
    process(clk)
    begin
        if rising_edge(clk) then
            -- [CẦU 2 - Leg A]: So sánh Sin_P với Triangle 2 (L lệch 90 deg)
            if (sine_A_P_in > triangle_in(1)) then
                pwm_chb_out(1).pwm_chb_P_1 <= '1'; -- Van trên Leg A
                pwm_chb_out(1).pwm_chb_P_2 <= '0'; -- Van dưới Leg A
            else
                pwm_chb_out(1).pwm_chb_P_1 <= '0';
                pwm_chb_out(1).pwm_chb_P_2 <= '1';
            end if;

            -- [CẦU 2 - Leg B]: So sánh Sin_N với Triangle 2 (L lệch 90 deg)
            if (sine_A_N_in > triangle_in(1)) then
                pwm_chb_out(1).pwm_chb_N_1 <= '1'; -- Van trên Leg B
                pwm_chb_out(1).pwm_chb_N_2 <= '0'; -- Van dưới Leg B
            else
                pwm_chb_out(1).pwm_chb_N_1 <= '0';
                pwm_chb_out(1).pwm_chb_N_2 <= '1';
            end if;
        end if;
    end process;
	 
	 -- CẦU H 3 (Cell 3 - Phase 120 deg): Dùng triangle_in(2)
    -- ===============================================================
    process(clk)
    begin
        if rising_edge(clk) then
            if (sine_A_P_in > triangle_in(2)) then
                pwm_chb_out(2).pwm_chb_P_1 <= '1'; 
					 pwm_chb_out(2).pwm_chb_P_2 <= '0';
            else
                pwm_chb_out(2).pwm_chb_P_1 <= '0'; 
					 pwm_chb_out(2).pwm_chb_P_2 <= '1';
            end if;

            if (sine_A_N_in > triangle_in(2)) then
                pwm_chb_out(2).pwm_chb_N_1 <= '1'; 
					 pwm_chb_out(2).pwm_chb_N_2 <= '0';
            else
                pwm_chb_out(2).pwm_chb_N_1 <= '0'; 
					 pwm_chb_out(2).pwm_chb_N_2 <= '1';
            end if;
        end if;
    end process;


end rtl;