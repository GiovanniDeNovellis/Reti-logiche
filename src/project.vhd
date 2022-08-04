


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity datapath is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           r_righe_load: in STD_LOGIC;
           r_col_load: in STD_LOGIC;
           r_area_load: in STD_LOGIC;
           r_pixel_load: in STD_LOGIC;
           cont_incr: in STD_LOGIC;
           o_addr_sel: integer;
           max_min_load: in STD_LOGIC;
           delta_load: in STD_LOGIC;
           r_pixel_2_load: in STD_LOGIC;
           temp_sel: in STD_LOGIC;
           write_sel: in STD_LOGIC;
           max_min_area_reset: in STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           o_address: out STD_LOGIC_VECTOR (15 downto 0);
           end_calc: out STD_LOGIC;
           end_area: out STD_LOGIC);
           
end datapath;

architecture Behavioral of datapath is
           signal num_righe: STD_LOGIC_VECTOR(7 downto 0);
           signal num_col: STD_LOGIC_VECTOR(7 downto 0);
           signal area: STD_LOGIC_VECTOR(15 downto 0);
           signal curr_pixel: STD_LOGIC_VECTOR(7 downto 0);
           signal pixel_max: STD_LOGIC_VECTOR(7 downto 0);
           signal pixel_min: STD_LOGIC_VECTOR(7 downto 0);
           signal delta_value: STD_LOGIC_VECTOR(7 downto 0);
           signal shift_level: STD_LOGIC_VECTOR(3 downto 0);
           signal curr_pixel_2: STD_LOGIC_VECTOR(15 downto 0);
           signal temp_pixel: STD_LOGIC_VECTOR(15 downto 0);
           signal curr_address: STD_LOGIC_VECTOR(15 downto 0);
           signal floor: STD_LOGIC_VECTOR(3 downto 0);
           signal cont_area: STD_LOGIC_VECTOR(7 downto 0);
           begin 
                -- Registro righe
                process(i_clk, i_rst)
                begin 
                    if(i_rst = '1') then
                        num_righe <= "00000000";
                    elsif(rising_edge(i_clk)) then
                        if(r_righe_load = '1') then
                            num_righe <= i_data;
                        end if;
                    end if;
                end process;
                
                --Registro colonne
                process(i_clk, i_rst)
                begin 
                    if(i_rst = '1') then
                        num_col <= "00000000";
                    elsif(rising_edge(i_clk)) then
                        if(r_col_load = '1') then
                            num_col <= i_data;
                        end if;
                    end if;
                end process;
                
                --Registro area
                process(i_clk, i_rst, max_min_area_reset)
                begin 
                    if(i_rst = '1' or max_min_area_reset = '1' ) then
                        area <= "0000000000000000";
                        end_area <= '0';
                        cont_area <= "00000000";
                    elsif(rising_edge(i_clk)) then
                        if(r_area_load = '1') then
                            if(cont_area=num_righe) then
                                end_area <= '1';
                            else
                                area <= area + num_col;
                                cont_area <= cont_area + "00000001";                             
                            end if;
                        end if;
                    end if;
                end process;
                
                --Registro pixel
                process(i_clk, i_rst)
                begin 
                    if(i_rst = '1') then
                        curr_pixel <= "00000000";
                    elsif(rising_edge(i_clk)) then
                        if(r_pixel_load = '1') then
                            curr_pixel <= i_data;
                        end if;
                    end if;
                end process;
                
                --Secondo registro pixel
                process(i_clk, i_rst)
                begin 
                    if(i_rst = '1') then
                        curr_pixel_2 <= "0000000000000000";
                    elsif(rising_edge(i_clk)) then
                        if(r_pixel_2_load = '1') then
                            curr_pixel_2(7 downto 0) <= i_data;
                        end if;
                    end if;
                end process;
                
                --Registro valore massimo
                process(i_clk, i_rst, max_min_area_reset)
                begin 
                    if(i_rst = '1' or max_min_area_reset = '1') then
                        pixel_max <= "00000000";
                    elsif(rising_edge(i_clk)) then
                        if(max_min_load='1') then  
                            if(unsigned(curr_pixel) > unsigned(pixel_max)) then
                                pixel_max <= curr_pixel;
                                end if;
                            end if;
                    end if;
                end process;
                
                --Registro valore minimo
                process(i_clk, i_rst, max_min_area_reset)
                begin 
                    if(i_rst = '1' or max_min_area_reset = '1') then
                        pixel_min <= "11111111";
                    elsif(rising_edge(i_clk)) then
                        if(max_min_load='1') then
                            if(to_integer(unsigned(curr_pixel)) < to_integer(unsigned(pixel_min))) then
                                pixel_min <= curr_pixel;
                                end if;
                            end if;
                    end if;
                end process;
                
                --Calcolo delta value
                process(i_clk,i_rst)
                begin 
                    if(i_rst = '1') then
                        delta_value <= "00000000";
                    elsif(rising_edge(i_clk)) then
                        if(delta_load='1') then
                            delta_value <= pixel_max - pixel_min;
                            end if;
                    end if;
                end process;
                
                --Calcolo floor con controlli a soglia
                process(delta_value) 
                begin
                    if(delta_value < "00000001") then
                        floor <= "0000";
                    elsif(delta_value < "00000011") then
                        floor <= "0001";
                    elsif(delta_value < "00000111") then
                        floor <= "0010";
                    elsif(delta_value < "00001111") then
                        floor <= "0011";
                    elsif(delta_value < "00011111") then
                        floor <= "0100";
                    elsif(delta_value < "00111111") then
                        floor <= "0101";
                    elsif(delta_value < "01111111") then
                        floor <= "0110";
                    elsif(delta_value < "11111111") then
                        floor <= "0111";
                    else
                        floor <= "1000";
                    end if;
                end process;
                
                --Calcolo shift level
                process(floor)
                begin
                    shift_level <= "1000" - floor;
                end process;
                
                --Contatore indirizzo
                process(i_clk,i_rst)
                begin 
                    if(i_rst = '1') then
                        curr_address <= "0000000000000001";
                        end_calc <= '0';
                    elsif(rising_edge(i_clk)) then
                        if(cont_incr = '1') then
                            end_calc<='0';
                            curr_address <= curr_address + "0000000000000001";
                            if(unsigned(curr_address) >= unsigned(area + "0000000000000001")) then
                                end_calc <= '1';
                                curr_address <= "0000000000000001";
                                end if;
                            end if;
                        end if;
                    end process;
                    
                --Multiplexer per indirizzo in uscita
                with o_addr_sel select
                    o_address <= "0000000000000000" when 0,
                                 "0000000000000001" when 1,
                                 curr_address(15 downto 0)  when 2,
                                 curr_address + area when 3,
                                 "XXXXXXXXXXXXXXXX" when others;
                                 
                --Calcolo del temp pixel
                process(i_clk,i_rst)
                begin
                    if(i_rst='1') then
                        temp_pixel<="0000000000000000";
                    elsif(rising_edge(i_clk)) then
                        if(temp_sel='1') then
                            temp_pixel <= std_logic_vector(shift_left(unsigned(curr_pixel_2-pixel_min), to_integer(unsigned(shift_level))));
                            end if;
                    end if;
                end process;
                
                --Scrittura del nuovo pixel in memoria               
                process(i_clk,i_rst)
                begin
                    if(i_rst = '1') then
                        o_data <= "00000000";
                    elsif(rising_edge(i_clk)) then
                            if(write_sel='1') then
                                if(temp_pixel > "0000000011111111") then
                                    o_data <= "11111111";
                                else
                                    o_data <= temp_pixel(7 downto 0);
                                end if;
                        end if;
                    end if;
                end process;                                                   
                          
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity project_reti_logiche is
port (
    i_clk : in std_logic;
    i_rst : in std_logic;
    i_start : in std_logic;
    i_data : in std_logic_vector(7 downto 0);
    o_address : out std_logic_vector(15 downto 0);
    o_done : out std_logic;
    o_en : out std_logic;
    o_we : out std_logic;
    o_data : out std_logic_vector (7 downto 0));
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    component datapath is
        Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           r_righe_load: in STD_LOGIC;
           r_col_load: in STD_LOGIC;
           r_area_load: in STD_LOGIC;
           r_pixel_load: in STD_LOGIC;
           cont_incr: in STD_LOGIC;
           o_addr_sel: integer;
           max_min_load: in STD_LOGIC;
           delta_load: in STD_LOGIC;
           r_pixel_2_load: in STD_LOGIC;
           temp_sel: in STD_LOGIC;
           write_sel: in STD_LOGIC;
           max_min_area_reset: in STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           o_address: out STD_LOGIC_VECTOR (15 downto 0);
           end_calc: out STD_LOGIC;
           end_area: out STD_LOGIC);
    end component;
    signal r_righe_load: std_logic;
    signal r_col_load: std_logic;
    signal r_area_load: std_logic;
    signal r_pixel_load: std_logic;
    signal cont_incr: std_logic;
    signal o_addr_sel: integer;
    signal max_min_load: std_logic;
    signal delta_load: std_logic;
    signal r_pixel_2_load: std_logic;
    signal temp_sel: std_logic;
    signal write_sel: std_logic;
    signal end_calc: std_logic;
    signal end_area: std_logic;
    signal max_min_area_reset: std_logic;
    type state is (reset, leggo_colonne,wait_colonne, leggo_righe, wait_righe, calcolo_area,incr_addr, leggo_pixel,wait_pixel, valuto_max_min,
                    calcolo_delta_value,incr_addr_2, leggo_pixel_2, wait_pixel_2, calcolo_tmp, wait_tmp, scrivo_nuovo_pixel, fine_computazione);
    signal cur_state, next_state: state;
    begin
        DATAPATH0: datapath port map(
           i_clk,
           i_rst,
           i_data,
           r_righe_load,
           r_col_load,
           r_area_load,
           r_pixel_load,
           cont_incr,
           o_addr_sel,
           max_min_load,
           delta_load,
           r_pixel_2_load,
           temp_sel,
           write_sel,
           max_min_area_reset,
           o_data,
           o_address,
           end_calc,
           end_area
           );
           
           process(i_clk, i_rst)
           begin
                if(i_rst = '1') then
                    cur_state <= reset;
                elsif(rising_edge(i_clk)) then
                    cur_state <= next_state;
                end if; 
           end process;
           
           process(cur_state,i_start,end_area, end_calc)
           begin
                next_state <= cur_state;
                case cur_state is   
                    when reset =>
                        if(i_start= '1') then
                            next_state <= leggo_colonne;
                        else
                            next_state <= reset;
                        end if;
                    when leggo_colonne =>
                        next_state <= wait_colonne;
                    when wait_colonne =>
                        next_state <= leggo_righe;
                    when leggo_righe =>
                        next_state <= wait_righe;
                    when wait_righe =>
                        next_state <= calcolo_area;
                    when calcolo_area =>
                        if(end_area = '1') then
                            next_state <= incr_addr;
                        else
                            next_state <= calcolo_area;
                        end if;
                    when incr_addr =>
                        next_state <= leggo_pixel;
                    when leggo_pixel =>
                        if(end_calc = '1') then
                            next_state <= calcolo_delta_value;
                        else
                            next_state <= wait_pixel;
                        end if;
                    when wait_pixel =>
                        next_state <= valuto_max_min;
                    when valuto_max_min =>
                        next_state <= incr_addr;
                    when calcolo_delta_value =>
                        next_state <= incr_addr_2;
                    when incr_addr_2 =>
                        next_state <= leggo_pixel_2;
                    when leggo_pixel_2 =>
                        if(end_calc = '1') then
                            next_state <= fine_computazione;
                        else 
                            next_state <= wait_pixel_2;
                        end if;
                    when wait_pixel_2 =>
                        next_state <= calcolo_tmp;
                    when calcolo_tmp =>
                        next_state <= wait_tmp;
                    when wait_tmp =>
                        next_state <= scrivo_nuovo_pixel;
                    when scrivo_nuovo_pixel =>
                        next_state <= incr_addr_2;
                    when fine_computazione => 
                        if(i_start = '0') then
                            next_state <= reset;
                        else 
                            next_state <=  fine_computazione;
                        end if;
                end case;
           end process;
           
           process(cur_state)
           begin
                        o_done <= '0';
                        o_en <= '0';
                        o_we<='0';
                        r_righe_load<='0';
                        r_col_load<='0';
                        r_area_load<='0';
                        r_pixel_load<='0';
                        cont_incr<='0';
                        o_addr_sel<=0;
                        max_min_load<='0';
                        delta_load<='0';
                        r_pixel_2_load<='0';
                        temp_sel<='0';
                        write_sel<='0';
                        max_min_area_reset<='0';
                case cur_state is 
                    when reset=>
                        max_min_area_reset<='1';
                    when leggo_colonne=>
                        o_en<='1';
                        o_addr_sel<=0; 
                    when wait_colonne=> 
                        r_col_load <= '1';
                    when leggo_righe=>
                        o_en<='1';
                        o_addr_sel<=1; 
                    when wait_righe=>
                        r_righe_load <= '1';
                    when calcolo_area=>
                        r_area_load<='1';
                    when incr_addr=>    
                        cont_incr<='1';                  
                    when leggo_pixel=>
                        o_addr_sel<=2;
                        o_en<='1';
                    when wait_pixel=>
                        r_pixel_load<='1';
                    when valuto_max_min=>
                        max_min_load<='1';
                    when calcolo_delta_value=>
                        delta_load<='1';
                    when incr_addr_2=>
                        cont_incr<='1';
                    when leggo_pixel_2=>
                        o_addr_sel<=2;
                        o_en<='1';
                    when wait_pixel_2=>
                        r_pixel_2_load<='1';
                    when calcolo_tmp=>
                        temp_sel<='1';
                    when wait_tmp=>
                        write_sel<='1';
                    when scrivo_nuovo_pixel=>
                        o_addr_sel<=3;
                        o_en<='1';
                        o_we<='1';                    
                    when fine_computazione=>
                        o_done<='1';
                end case;
           end process;
end Behavioral;



