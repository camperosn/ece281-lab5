--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnL    :   in std_logic; -- reset-async
        btnU    :   in std_logic; -- reset-sync
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
    constant k_IO_WIDTH : natural := 4;
    constant k_clk_period : time := 10 ns;
    
    
    component sevenseg_decoder is
        port (
            i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
            o_seg_n : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component sevenseg_decoder;
    
    component controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
    end component controller_fsm;
    
        
    component TDM4 is
        generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
        Port ( i_clk		: in  STD_LOGIC;
               i_reset		: in  STD_LOGIC; -- asynchronous
               i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
        );
    end component TDM4;
    
    component clock_divider is
        generic ( constant k_DIV : natural := 2	); -- How many clk cycles until slow clock toggles
        -- Effectively, you divide the clk double this 
        -- number (e.g., k_DIV := 2 --> clock divider of 4)
        port ( 	i_clk    : in std_logic;
                i_reset  : in std_logic;		   -- asynchronous
                o_clk    : out std_logic		   -- divided (slow) clock
        );
    end component clock_divider;
    
    component ALU is
        Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
               i_B : in STD_LOGIC_VECTOR (7 downto 0);
               i_op : in STD_LOGIC_VECTOR (2 downto 0);
               o_result : out STD_LOGIC_VECTOR (7 downto 0);
               o_flags : out STD_LOGIC_VECTOR (3 downto 0));
    end component ALU;
    
    
    component twos_comp is
        port (
            i_bin: in std_logic_vector(7 downto 0);
            o_sign: out std_logic;
            o_hund: out std_logic_vector(3 downto 0);
            o_tens: out std_logic_vector(3 downto 0);
            o_ones: out std_logic_vector(3 downto 0)
        );
    end component twos_comp;
    
    component button_debounce is
        Port(	clk: in  STD_LOGIC;
                reset : in  STD_LOGIC;
                button: in STD_LOGIC;
                action: out STD_LOGIC);
    end component button_debounce;
    
    -- signals
    signal w_clk, w_action, w_sign_pre : std_logic := '0';
    signal w_A, w_B : std_logic_vector(7 downto 0);
    signal w_seg_mux : std_logic_vector(6 downto 0);
    signal w_o_result, w_ALU_mux : std_logic_vector(7 downto 0);
    signal w_o_flags, w_cycle, w_hund, w_tens, w_ones, w_sel, w_data, w_sign_post : std_logic_vector(3 downto 0);
    
begin
	-- PORT MAPS ----------------------------------------
    
    button_debounce_inst_0 : button_debounce
        port map (
            clk => clk,
            reset => btnU,
            button => btnC,
            action => w_action
        );
    
    controller_fsm_inst_0 : controller_fsm
        port map (
            i_reset => btnU,
            i_adv =>  w_action,
            o_cycle => w_cycle
        );

    clock_divider_inst_0 : clock_divider
        generic map (k_DIV => 200000)
        port map(
            i_clk => clk,
            i_reset => btnL,
            o_clk => w_clk
        );
        
        
     ALU_inst_0 : ALU
        port map (
            i_A => w_A,
            i_B => w_B,
            i_op => sw(2 downto 0),
            o_result => w_o_result,
            o_flags => w_o_flags
        );
    
    twos_comp_inst_0 : twos_comp
        port map (
            i_bin => w_ALU_mux,
            o_sign => w_sign_pre,
            o_hund => w_hund,
            o_tens => w_tens,
            o_ones => w_ones
        );  
        
        
     TDM4_inst_0 : TDM4
        generic map (k_WIDTH => k_IO_WIDTH)
        port map (
            i_clk => w_clk,
            i_reset => btnU,
            i_D3 => w_sign_post,
            i_D2 => w_hund,
            i_D1 => w_tens,
            i_D0 => w_ones,
            o_data => w_data,
            o_sel => w_sel
        );
        
    sevenseg_decoder_inst_0 : sevenseg_decoder
        port map (
            i_Hex => w_data,
            o_seg_n => w_seg_mux
        );
        
        

	-- CONCURRENT STATEMENTS ----------------------------
	
	
	
	
	-- Registers
	registers_proc : process(clk)
	begin
	   if rising_edge(clk) then
	       if btnU = '1' then
	           w_A <= "00000000";
	           w_B <= "00000000";
	       else
	           if w_action = '1' then
                   if w_cycle(1) = '1' then
                       w_A <= sw(7 downto 0);
                   end if;
                   if w_cycle(2) = '1' then
                       w_B <= sw(7 downto 0);
                   end if;
               end if;
           end if;
	    end if;
	end process registers_proc;
	
	-- Account for sign not matching TDM expectations
	w_sign_post <= "1111" when (w_sign_pre = '1') else
	               "0000";
	
	
	-- Multiplexer out of the ALU
    w_ALU_mux <= w_A when (w_cycle(1) = '1') else
                 w_B when (w_cycle(2) = '1') else
                 w_o_result when (w_cycle(3) = '1') else
                "00000000";
       
    -- Multiplexer out of o_sel and into 'an'
    an <= "1111" when (w_cycle(0) = '1') else
           w_sel;
           
    -- Multiplexer out of seven seg decoder
	seg <= "1111110" when (w_sel(3) = '1' AND w_sign_pre = '1') else
	       w_seg_mux;
	
	led(3 downto 0) <= w_cycle;
	led(15 downto 12) <= w_o_flags;
    led(14 downto 4) <= (others => '0');

	
	
end top_basys3_arch;
