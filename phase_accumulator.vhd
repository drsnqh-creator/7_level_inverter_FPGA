library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity phase_accumulator is
    port ( 
        clk        : in  std_logic;
        reset      : in  std_logic;
        m_val      : in  unsigned(31 downto 0); -- Nhận giá trị từ ADC biến trở
        addr_A_P   : out unsigned(9 downto 0);  -- Địa chỉ 8-bit sóng Sine gốc (P)
        addr_A_N   : out unsigned(9 downto 0)   -- Địa chỉ 8-bit sóng Sine ngược (N) lệch 180 độ
    );
end phase_accumulator;

architecture rtl of phase_accumulator is
    signal acc_master   : unsigned(31 downto 0) := (others => '0');
    -- Hằng số lệch pha 180 độ trong không gian pha 32-bit (2^31)
    constant OFFSET_180 : unsigned(31 downto 0) := x"80000000"; 
begin
    process(clk, reset)
        variable v_acc_N : unsigned(31 downto 0);
    begin
        if reset = '0' then 
            acc_master <= (others => '0');
            addr_A_P   <= (others => '0');
            addr_A_N   <= (others => '0');
        elsif rising_edge(clk) then
            -- 1. Cộng dồn pha Master liên tục tốc độ 200MHz
            acc_master <= acc_master + m_val;
            
            -- 2. Tính toán pha cho vế nghịch đảo (Tự động tràn nhị phân chuẩn 180 độ)
            v_acc_N := acc_master + OFFSET_180; 

            -- 3. Trích xuất đúng 8 bit cao nhất (MSB) từ bit 31 đến 24 cho hệ 256 mẫu
            addr_A_P <= acc_master(31 downto 22); -- Quét ROM gốc P
            addr_A_N <= v_acc_N(31 downto 22);    -- Quét ROM ngược N
            
        end if;
    end process; 
end rtl;