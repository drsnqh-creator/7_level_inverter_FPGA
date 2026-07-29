library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.inverter_pkg.all;

entity triangle_wave is
    port(
        clk_in   : in  std_logic;
        reset    : in  std_logic;
        triangle : out triangle_array -- Hãy đảm bảo triangle_array trong package khai báo (0 to 3)
    );
end triangle_wave;

architecture rtl of triangle_wave is
    -- 1. Mở rộng mảng flag và triangle_reg cho 4 sóng tam giác (0 to 3)
    signal flag         : std_logic_vector(0 to 2) := "111";
    signal triangle_reg : triangle_array := (others => (others => '0'));
    
    -- 2. Khai báo mảng khởi tạo giá trị ban đầu và hướng đi (FLAG) cho 4 sóng
    type init_array is array (0 to 2) of integer range 0 to 3907;
    
    -- Sóng 0: 0 deg (0)       | Sóng 1: 180 deg (3907)
    -- Sóng 2: 90 deg (1953)   | Sóng 3: 270 deg (1953)
    constant TRI_INIT_VAL  : init_array := (0, 1302, 2605);
    
    -- Flag = '1': Đang tăng (Đi LÊN) | Flag = '0': Đang giảm (Đi XUỐNG)
    constant FLAG_INIT_VAL : std_logic_vector(0 to 2) := "111"; 

begin

    -- 3. Nhân bản phần cứng cho cả 4 sóng tam giác (0 to 3)
    gen_4_triangles: for i in 0 to 2 generate
    begin 
        process(clk_in)
        begin
            if reset = '0' then
                -- Reset về đúng giá trị lệch pha ban đầu chuẩn PS-PWM Unipolar
                triangle_reg(i) <= to_unsigned(TRI_INIT_VAL(i), 12);
                flag(i)         <= FLAG_INIT_VAL(i);
                
            elsif rising_edge(clk_in) then
                if flag(i) = '1' then
                    if triangle_reg(i) >= 3907 then
                        flag(i)         <= '0';
                        triangle_reg(i) <= triangle_reg(i) - 1;
                    else 
                        triangle_reg(i) <= triangle_reg(i) + 1;
                    end if;
                else
                    if triangle_reg(i) <= 0 then
                        flag(i)         <= '1';
                        triangle_reg(i) <= triangle_reg(i) + 1;
                    else
                        triangle_reg(i) <= triangle_reg(i) - 1;
                    end if;
                end if;
            end if;
        end process;
    end generate gen_4_triangles;
    
    -- Gán ngõ ra 4 sóng tam giác
    triangle <= triangle_reg;

end rtl;