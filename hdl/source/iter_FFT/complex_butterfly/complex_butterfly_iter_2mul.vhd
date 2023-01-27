LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY complex_butterfly_iter_2mul IS
  GENERIC (
    IWL1 : natural := 16;
    IWL2 : natural := 16;
    AWL  : natural := 17;
    OWL  : natural := 16;
    CONSTANT_SHIFT : natural := 0
  );
  PORT (
    clk          : IN std_logic;
    rst          : IN std_logic;
    strb_in      : IN std_logic; --valid in
    din1_re      : IN std_logic_vector(IWL1 - 1 DOWNTO 0); --  B component
    din1_im      : IN std_logic_vector(IWL1 - 1 DOWNTO 0);

    din2_re      : IN std_logic_vector(IWL2 - 1 DOWNTO 0); --  W component
    din2_im      : IN std_logic_vector(IWL2 - 1 DOWNTO 0);

    din3_re      : IN std_logic_vector(IWL1 - 1 DOWNTO 0); --  A component
    din3_im      : IN std_logic_vector(IWL1 - 1 DOWNTO 0);

    dout1_re      : OUT std_logic_vector(OWL - 1 DOWNTO 0);
    dout1_im      : OUT std_logic_vector(OWL - 1 DOWNTO 0);

    dout2_re      : OUT std_logic_vector(OWL - 1 DOWNTO 0);
    dout2_im      : OUT std_logic_vector(OWL - 1 DOWNTO 0);

    strb_out     : OUT std_logic --valid out
  );
END complex_butterfly_iter_2mul;

ARCHITECTURE rtl OF complex_butterfly_iter_2mul IS

  CONSTANT PROD_WL : natural := IWL1 + IWL2;

  SIGNAL MUL_1_out, MUL_2_out : std_logic_vector(AWL DOWNTO 0);

  SIGNAL MUL_1_din1_mux                                           : std_logic_vector(IWL1 - 1 DOWNTO 0);
  SIGNAL MUL_1_din2_mux                                           : std_logic_vector(IWL2 - 1 DOWNTO 0);
  SIGNAL MUL_2_din1_mux                                           : std_logic_vector(IWL1 - 1 DOWNTO 0);
  SIGNAL MUL_2_din2_mux                                           : std_logic_vector(IWL2 - 1 DOWNTO 0);

  SIGNAL ADD_din1_mux, ADD_din2_mux, SUB_din1_mux, SUB_din2_mux : std_logic_vector(AWL DOWNTO 0);
  SIGNAL add_out, sub_out                                       : std_logic_vector(OWL - 1 DOWNTO 0);

  SIGNAL pipe_cnt                                               : unsigned(1 DOWNTO 0); -- unsigned(1 DOWNTO 0);

  SIGNAL dout1_re_b                                             : std_logic_vector(OWL - 1 DOWNTO 0);
  SIGNAL dout2_re_b                                             : std_logic_vector(OWL - 1 DOWNTO 0);

  SIGNAL re_reg                                                 : std_logic_vector(OWL - 1 DOWNTO 0); 
  SIGNAL im_reg                                                 : std_logic_vector(OWL - 1 DOWNTO 0); 

  SIGNAL re1_reg                                                : std_logic_vector(OWL - 1 DOWNTO 0);
  SIGNAL re2_reg                                                : std_logic_vector(OWL - 1 DOWNTO 0);

  SIGNAL pre_sum_re_reg                                         : std_logic_vector(AWL downto 0);
  SIGNAL pre_sum_im_reg                                         : std_logic_vector(AWL downto 0);
  SIGNAL pre_sum_din3_re                                        : std_logic_vector(AWL downto 0);
  SIGNAL pre_sum_din3_im                                        : std_logic_vector(AWL downto 0);


  SIGNAL dout1_im_b                                             : std_logic_vector(OWL - 1 DOWNTO 0);
  SIGNAL dout2_im_b                                             : std_logic_vector(OWL - 1 DOWNTO 0);
  SIGNAL valid                                                  : std_logic;

BEGIN

  pipe_proc : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      pipe_cnt <= (OTHERS => '0');
    ELSIF rising_edge(clk) THEN
      IF strb_in = '1' THEN
        pipe_cnt <= (OTHERS               => '0');
      ELSIF pipe_cnt /= (pipe_cnt'RANGE => '1') THEN -- (pipe_cnt'RANGE => '1')
        pipe_cnt <= pipe_cnt + 1;
      END IF;
    END IF;
  END PROCESS;

  valid_proc : PROCESS (clk, rst)
    BEGIN
      IF rst = '1' THEN
        valid    <= '0';
      ELSIF falling_edge(clk) THEN
      IF (pipe_cnt(0) AND pipe_cnt(1)) = '1' THEN 
          valid <= '1';
        ELSE
          valid <= '0';
        END IF;
      END IF;
    END PROCESS;

  MUL_1_din1_mux <= din1_re;
  MUL_2_din1_mux <= din1_im;

  MUL_1_din2_mux <= din2_re WHEN (pipe_cnt(0) = '0') ELSE din2_im;
  MUL_2_din2_mux <= din2_im WHEN (pipe_cnt(0) = '0') ELSE din2_re;

  mult_with_shift : IF (CONSTANT_SHIFT = 1) GENERATE
    mul_proc_1 : PROCESS (MUL_1_din1_mux, MUL_1_din2_mux) -- first mult
    VARIABLE G_mul : signed(PROD_WL - 1 DOWNTO 0);
    BEGIN
      G_mul := signed(MUL_1_din1_mux) * signed(MUL_1_din2_mux);
      MUL_1_out <= std_logic_vector(G_mul(PROD_WL - 1) & G_mul(PROD_WL - 1 DOWNTO PROD_WL - AWL));
    END PROCESS mul_proc_1;

    mul_proc_2 : PROCESS (MUL_2_din1_mux, MUL_2_din2_mux)-- second mult
    VARIABLE G_mul : signed(PROD_WL - 1 DOWNTO 0);
    BEGIN
      G_mul := signed(MUL_2_din1_mux) * signed(MUL_2_din2_mux);
      MUL_2_out <= std_logic_vector(G_mul(PROD_WL - 1) & G_mul(PROD_WL - 1 DOWNTO PROD_WL - AWL));
    END PROCESS mul_proc_2;

    pre_sum_din3_re <= din3_re(OWL-1) & din3_re(OWL-1) & din3_re;
    pre_sum_din3_im <= din3_im(OWL-1) & din3_im(OWL-1) & din3_im;
  END GENERATE;
  mult_without_shift : IF (CONSTANT_SHIFT = 0) GENERATE
    mul_proc_1 : PROCESS (MUL_1_din1_mux, MUL_1_din2_mux)
    VARIABLE G_mul : signed(PROD_WL - 1 DOWNTO 0);
    BEGIN
      G_mul := signed(MUL_1_din1_mux) * signed(MUL_1_din2_mux);
      MUL_1_out <= std_logic_vector(G_mul(PROD_WL - 1 DOWNTO PROD_WL - 1 - AWL));
    END PROCESS mul_proc_1;

    mul_proc_2 : PROCESS (MUL_2_din1_mux, MUL_2_din2_mux)
    VARIABLE G_mul : signed(PROD_WL - 1 DOWNTO 0);
    BEGIN
      G_mul := signed(MUL_2_din1_mux) * signed(MUL_2_din2_mux);
      MUL_2_out <= std_logic_vector(G_mul(PROD_WL - 1 DOWNTO PROD_WL - 1 - AWL));
    END PROCESS mul_proc_2;

    pre_sum_din3_re <= din3_re(OWL-1) & din3_re & '0';
    pre_sum_din3_im <= din3_im(OWL-1) & din3_im & '0';
  END GENERATE;

  pre_sum_re_reg  <= re_reg (OWL-1) & re_reg  & '0';
  pre_sum_im_reg  <= im_reg (OWL-1) & im_reg  & '0';

  ADD_din2_mux <= pre_sum_re_reg WHEN pipe_cnt = "10" ELSE 
                  pre_sum_im_reg WHEN pipe_cnt = "11" ELSE MUL_1_out; 

  ADD_din1_mux <= pre_sum_din3_re WHEN pipe_cnt = "10" ELSE 
                  pre_sum_din3_im WHEN pipe_cnt = "11" ELSE MUL_2_out; 
  
  add_proc : PROCESS (ADD_din1_mux, ADD_din2_mux)
    VARIABLE add_v     : signed(AWL DOWNTO 0);
    VARIABLE add_v_dc  : signed(AWL DOWNTO AWL - OWL);
    VARIABLE add_v_sat : signed(OWL - 1 DOWNTO 0);
  BEGIN
    add_v    := signed(ADD_din1_mux) + signed(ADD_din2_mux);
    add_v_dc := add_v(AWL DOWNTO AWL - OWL) + ('0' & add_v(AWL - OWL - 1));
    IF add_v_dc(AWL) /= add_v_dc(AWL - 1) THEN
      add_v_sat(OWL - 1)          := add_v_dc(AWL);
      add_v_sat(OWL - 2 DOWNTO 0) := (OTHERS => add_v_dc(AWL - 1));
    ELSE
      add_v_sat := add_v_dc(AWL - 1 DOWNTO AWL - OWL);
    END IF;
    add_out <= std_logic_vector(add_v_sat);
  END PROCESS;

  SUB_din2_mux <= pre_sum_re_reg WHEN pipe_cnt = "10" ELSE 
                  pre_sum_im_reg WHEN pipe_cnt = "11" ELSE MUL_2_out;

  SUB_din1_mux <= pre_sum_din3_re WHEN pipe_cnt = "10" ELSE 
                  pre_sum_din3_im WHEN pipe_cnt = "11" ELSE MUL_1_out; 

  sub_proc : PROCESS (SUB_din1_mux, SUB_din2_mux)
    VARIABLE add_v     : signed(AWL DOWNTO 0);
    VARIABLE add_v_dc  : signed(AWL DOWNTO AWL - OWL);
    VARIABLE add_v_sat : signed(OWL - 1 DOWNTO 0);
  BEGIN
    add_v    := signed(SUB_din1_mux) - signed(SUB_din2_mux);
    add_v_dc := add_v(AWL DOWNTO AWL - OWL) + ('0' & add_v(AWL - OWL - 1));
    IF add_v_dc(AWL) /= add_v_dc(AWL - 1) THEN
      add_v_sat(OWL - 1)          := add_v_dc(AWL);
      add_v_sat(OWL - 2 DOWNTO 0) := (OTHERS => add_v_dc(AWL - 1));
    ELSE
      add_v_sat := add_v_dc(AWL - 1 DOWNTO AWL - OWL);
    END IF;
    sub_out <= std_logic_vector(add_v_sat);
  END PROCESS;

  pipe_reg_proc_re : PROCESS (clk)--, rst)
  BEGIN
    IF rising_edge(clk) THEN
      IF pipe_cnt = "00" THEN
        re_reg      <= sub_out;
      END IF;
    END IF;
  END PROCESS;

  pipe_reg_proc_img : PROCESS (clk)--, rst)
  BEGIN
    IF rising_edge(clk) THEN
      IF pipe_cnt = "01" THEN
        im_reg      <= add_out;
      END IF;
    END IF;
  END PROCESS;

  pipe_reg_proc_re_b : PROCESS (clk)--, rst)
  BEGIN
    IF rising_edge(clk) THEN
      IF pipe_cnt = "10" THEN
        re1_reg      <= add_out;
        re2_reg      <= sub_out;
      END IF;
    END IF;
  END PROCESS;

  

  reg_out_proc : PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      dout1_re_b      <= (OTHERS => '0');
      dout1_im_b      <= (OTHERS => '0');
      dout2_re_b      <= (OTHERS => '0');
      dout2_im_b      <= (OTHERS => '0');
    ELSIF rising_edge(clk) THEN
      IF (strb_in AND valid) = '1' THEN
        dout1_re_b    <= re1_reg;
        dout2_re_b    <= re2_reg;

        dout1_im_b      <= add_out;
        dout2_im_b      <= sub_out;
      END IF;
    END IF;
  END PROCESS;



  dout1_re <= dout1_re_b;
  dout1_im <= dout1_im_b;

  dout2_re <= dout2_re_b;
  dout2_im <= dout2_im_b;

  strb_out <= strb_in;

END rtl;