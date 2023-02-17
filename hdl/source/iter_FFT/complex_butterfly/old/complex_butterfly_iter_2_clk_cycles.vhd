LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY complex_butterfly_iter_2_clk_cycles IS
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
END complex_butterfly_iter_2_clk_cycles;

ARCHITECTURE rtl OF complex_butterfly_iter_2_clk_cycles IS

  CONSTANT PROD_WL : natural := IWL1 + IWL2;

  SIGNAL MUL_1_out, MUL_2_out, MUL_3_out, MUL_4_out               : std_logic_vector(AWL DOWNTO 0);

  SIGNAL MUL_1_out_b, MUL_2_out_b, MUL_3_out_b, MUL_4_out_b       : std_logic_vector(AWL DOWNTO 0);

  SIGNAL MUL_1_din1_mux                                           : std_logic_vector(IWL1 - 1 DOWNTO 0);
  SIGNAL MUL_1_din2_mux                                           : std_logic_vector(IWL2 - 1 DOWNTO 0);
  SIGNAL MUL_2_din1_mux                                           : std_logic_vector(IWL1 - 1 DOWNTO 0);
  SIGNAL MUL_2_din2_mux                                           : std_logic_vector(IWL2 - 1 DOWNTO 0);

  SIGNAL MUL_3_din1_mux                                           : std_logic_vector(IWL1 - 1 DOWNTO 0);
  SIGNAL MUL_3_din2_mux                                           : std_logic_vector(IWL2 - 1 DOWNTO 0);
  SIGNAL MUL_4_din1_mux                                           : std_logic_vector(IWL1 - 1 DOWNTO 0);
  SIGNAL MUL_4_din2_mux                                           : std_logic_vector(IWL2 - 1 DOWNTO 0);

  SIGNAL ADD_0_din1_mux, ADD_0_din2_mux                           : std_logic_vector(AWL DOWNTO 0);
  SIGNAL SUB_0_din1_mux, SUB_0_din2_mux                           : std_logic_vector(AWL DOWNTO 0);
  SIGNAL add_0_out, sub_0_out                                     : std_logic_vector(AWL DOWNTO 0);

  SIGNAL ADD_1_din1_mux, ADD_1_din2_mux                           : std_logic_vector(AWL DOWNTO 0);
  SIGNAL SUB_1_din1_mux, SUB_1_din2_mux                           : std_logic_vector(AWL DOWNTO 0);
  SIGNAL add_1_out, sub_1_out                                     : std_logic_vector(OWL - 1 DOWNTO 0);

  SIGNAL ADD_2_din1_mux, ADD_2_din2_mux                           : std_logic_vector(AWL DOWNTO 0);
  SIGNAL SUB_2_din1_mux, SUB_2_din2_mux                           : std_logic_vector(AWL DOWNTO 0);
  SIGNAL add_2_out, sub_2_out                                     : std_logic_vector(OWL - 1 DOWNTO 0);

  SIGNAL dout1_re_b                                               : std_logic_vector(OWL - 1 DOWNTO 0);
  SIGNAL dout2_re_b                                               : std_logic_vector(OWL - 1 DOWNTO 0);
  
  SIGNAL pre_sum_din3_re                                          : std_logic_vector(AWL downto 0);
  SIGNAL pre_sum_din3_im                                          : std_logic_vector(AWL downto 0);

  SIGNAL dout1_im_b                                             : std_logic_vector(OWL - 1 DOWNTO 0);
  SIGNAL dout2_im_b                                             : std_logic_vector(OWL - 1 DOWNTO 0);

BEGIN

  MUL_1_din1_mux <= din1_re;
  MUL_1_din2_mux <= din2_re;

  MUL_2_din1_mux <= din1_im;
  MUL_2_din2_mux <= din2_im;

  MUL_3_din1_mux <= din1_re;
  MUL_3_din2_mux <= din2_im;

  MUL_4_din1_mux <= din1_im;
  MUL_4_din2_mux <= din2_re;


  mult_with_shift : IF (CONSTANT_SHIFT = 1) GENERATE
    mul_proc_1 : PROCESS (MUL_1_din1_mux, MUL_1_din2_mux) -- first mult
    VARIABLE G_mul : signed(PROD_WL - 1 DOWNTO 0);
    BEGIN
      G_mul := signed(MUL_1_din1_mux) * signed(MUL_1_din2_mux);
      MUL_1_out <= std_logic_vector(G_mul(PROD_WL - 1) & G_mul(PROD_WL - 1 DOWNTO PROD_WL - AWL));
    END PROCESS mul_proc_1;

    mul_proc_2 : PROCESS (MUL_2_din1_mux, MUL_2_din2_mux) -- second mult
    VARIABLE G_mul : signed(PROD_WL - 1 DOWNTO 0);
    BEGIN
      G_mul := signed(MUL_2_din1_mux) * signed(MUL_2_din2_mux);
      MUL_2_out <= std_logic_vector(G_mul(PROD_WL - 1) & G_mul(PROD_WL - 1 DOWNTO PROD_WL - AWL));
    END PROCESS mul_proc_2;

    mul_proc_3 : PROCESS (MUL_3_din1_mux, MUL_3_din2_mux) -- third mult
    VARIABLE G_mul : signed(PROD_WL - 1 DOWNTO 0);
    BEGIN
      G_mul := signed(MUL_3_din1_mux) * signed(MUL_3_din2_mux);
      MUL_3_out <= std_logic_vector(G_mul(PROD_WL - 1) & G_mul(PROD_WL - 1 DOWNTO PROD_WL - AWL));
    END PROCESS mul_proc_3;

    mul_proc_4 : PROCESS (MUL_4_din1_mux, MUL_4_din2_mux)-- fourth mult
    VARIABLE G_mul : signed(PROD_WL - 1 DOWNTO 0);
    BEGIN
      G_mul := signed(MUL_4_din1_mux) * signed(MUL_4_din2_mux);
      MUL_4_out <= std_logic_vector(G_mul(PROD_WL - 1) & G_mul(PROD_WL - 1 DOWNTO PROD_WL - AWL));
    END PROCESS mul_proc_4;


    pre_sum_din3_re <= din3_re(OWL-1) & din3_re(OWL-1) & din3_re;
    pre_sum_din3_im <= din3_im(OWL-1) & din3_im(OWL-1) & din3_im;
  END GENERATE;
  mult_without_shift : IF (CONSTANT_SHIFT = 0) GENERATE
    mul_proc_1 : PROCESS (MUL_1_din1_mux, MUL_1_din2_mux) -- first mult
    VARIABLE G_mul : signed(PROD_WL - 1 DOWNTO 0);
    BEGIN
      G_mul := signed(MUL_1_din1_mux) * signed(MUL_1_din2_mux);
      MUL_1_out <= std_logic_vector(G_mul(PROD_WL - 1 DOWNTO PROD_WL - 1 - AWL));
    END PROCESS mul_proc_1;

    mul_proc_2 : PROCESS (MUL_2_din1_mux, MUL_2_din2_mux) -- second mult
    VARIABLE G_mul : signed(PROD_WL - 1 DOWNTO 0);
    BEGIN
      G_mul := signed(MUL_2_din1_mux) * signed(MUL_2_din2_mux);
      MUL_2_out <= std_logic_vector(G_mul(PROD_WL - 1 DOWNTO PROD_WL - 1 - AWL));
    END PROCESS mul_proc_2;

    mul_proc_3 : PROCESS (MUL_3_din1_mux, MUL_3_din2_mux) -- first mult
    VARIABLE G_mul : signed(PROD_WL - 1 DOWNTO 0);
    BEGIN
      G_mul := signed(MUL_3_din1_mux) * signed(MUL_3_din2_mux);
      MUL_3_out <= std_logic_vector(G_mul(PROD_WL - 1 DOWNTO PROD_WL - 1 - AWL));
    END PROCESS mul_proc_3;

    mul_proc_4 : PROCESS (MUL_4_din1_mux, MUL_4_din2_mux) -- second mult
    VARIABLE G_mul : signed(PROD_WL - 1 DOWNTO 0);
    BEGIN
      G_mul := signed(MUL_4_din1_mux) * signed(MUL_4_din2_mux);
      MUL_4_out <= std_logic_vector(G_mul(PROD_WL - 1 DOWNTO PROD_WL - 1 - AWL));
    END PROCESS mul_proc_4;

    pre_sum_din3_re <= din3_re(OWL-1) & din3_re & '0';
    pre_sum_din3_im <= din3_im(OWL-1) & din3_im & '0';
  END GENERATE;

  ADD_0_din1_mux <= MUL_3_out_b; 
  ADD_0_din2_mux <= MUL_4_out_b; 

  add_proc_0 : PROCESS (ADD_0_din1_mux, ADD_0_din2_mux)
    VARIABLE add_v     : signed(AWL DOWNTO 0);
    VARIABLE add_v_dc  : signed(AWL DOWNTO AWL - OWL);
    VARIABLE add_v_sat : signed(AWL DOWNTO 0);
  BEGIN
    add_v    := signed(ADD_0_din1_mux) + signed(ADD_0_din2_mux);
    IF add_v(AWL) /= add_v(AWL - 1) THEN
      add_v_sat(AWL downto AWL-1) := (OTHERS => add_v_dc(AWL));
      add_v_sat(AWL - 1 DOWNTO 0) := (OTHERS => add_v_dc(AWL - 1));
    ELSE
      add_v_sat := add_v;
    END IF;
    add_0_out <= std_logic_vector(add_v_sat);
  END PROCESS;

  SUB_0_din1_mux <= MUL_1_out_b; 
  SUB_0_din2_mux <= MUL_2_out_b; 

  sub_proc_0 : PROCESS (SUB_0_din1_mux, SUB_0_din2_mux)
    VARIABLE add_v     : signed(AWL DOWNTO 0);
    VARIABLE add_v_dc  : signed(AWL DOWNTO AWL - OWL);
    VARIABLE add_v_sat : signed(AWL DOWNTO 0);
  BEGIN
    add_v    := signed(SUB_0_din1_mux) - signed(SUB_0_din2_mux);
    IF add_v(AWL) /= add_v(AWL - 1) THEN
      add_v_sat(AWL downto AWL-1) := (OTHERS => add_v_dc(AWL));
      add_v_sat(AWL - 1 DOWNTO 0) := (OTHERS => add_v_dc(AWL - 1));
    ELSE
      add_v_sat := add_v;
    END IF;
    sub_0_out <= std_logic_vector(add_v_sat);
  END PROCESS;

  ADD_1_din1_mux <= pre_sum_din3_re; 
  ADD_1_din2_mux <= sub_0_out; 
  
  add_proc_1 : PROCESS (ADD_1_din1_mux, ADD_1_din2_mux)
    VARIABLE add_v     : signed(AWL DOWNTO 0);
    VARIABLE add_v_dc  : signed(AWL DOWNTO AWL - OWL);
    VARIABLE add_v_sat : signed(OWL - 1 DOWNTO 0);
  BEGIN
    add_v    := signed(ADD_1_din1_mux) + signed(ADD_1_din2_mux);
    add_v_dc := add_v(AWL DOWNTO AWL - OWL) + ('0' & add_v(AWL - OWL - 1));
    IF add_v_dc(AWL) /= add_v_dc(AWL - 1) THEN
      add_v_sat(OWL - 1)          := add_v_dc(AWL);
      add_v_sat(OWL - 2 DOWNTO 0) := (OTHERS => add_v_dc(AWL - 1));
    ELSE
      add_v_sat := add_v_dc(AWL - 1 DOWNTO AWL - OWL);
    END IF;
    add_1_out <= std_logic_vector(add_v_sat);
  END PROCESS;

  ADD_2_din1_mux <= pre_sum_din3_im; 
  ADD_2_din2_mux <= add_0_out; 
  
  add_proc_2 : PROCESS (ADD_2_din1_mux, ADD_2_din2_mux)
    VARIABLE add_v     : signed(AWL DOWNTO 0);
    VARIABLE add_v_dc  : signed(AWL DOWNTO AWL - OWL);
    VARIABLE add_v_sat : signed(OWL - 1 DOWNTO 0);
  BEGIN
    add_v    := signed(ADD_2_din1_mux) + signed(ADD_2_din2_mux);
    add_v_dc := add_v(AWL DOWNTO AWL - OWL) + ('0' & add_v(AWL - OWL - 1));
    IF add_v_dc(AWL) /= add_v_dc(AWL - 1) THEN
      add_v_sat(OWL - 1)          := add_v_dc(AWL);
      add_v_sat(OWL - 2 DOWNTO 0) := (OTHERS => add_v_dc(AWL - 1));
    ELSE
      add_v_sat := add_v_dc(AWL - 1 DOWNTO AWL - OWL);
    END IF;
    add_2_out <= std_logic_vector(add_v_sat);
  END PROCESS;

  SUB_1_din1_mux <= pre_sum_din3_re;
  SUB_1_din2_mux <= sub_0_out; 

  sub_1_proc : PROCESS (SUB_1_din1_mux, SUB_1_din2_mux)
    VARIABLE add_v     : signed(AWL DOWNTO 0);
    VARIABLE add_v_dc  : signed(AWL DOWNTO AWL - OWL);
    VARIABLE add_v_sat : signed(OWL - 1 DOWNTO 0);
  BEGIN
    add_v    := signed(SUB_1_din1_mux) - signed(SUB_1_din2_mux);
    add_v_dc := add_v(AWL DOWNTO AWL - OWL) + ('0' & add_v(AWL - OWL - 1));
    IF add_v_dc(AWL) /= add_v_dc(AWL - 1) THEN
      add_v_sat(OWL - 1)          := add_v_dc(AWL);
      add_v_sat(OWL - 2 DOWNTO 0) := (OTHERS => add_v_dc(AWL - 1));
    ELSE
      add_v_sat := add_v_dc(AWL - 1 DOWNTO AWL - OWL);
    END IF;
    sub_1_out <= std_logic_vector(add_v_sat);
  END PROCESS;

  SUB_2_din1_mux <= pre_sum_din3_im; 
  SUB_2_din2_mux <= add_0_out; 

  sub_2_proc : PROCESS (SUB_2_din1_mux, SUB_2_din2_mux)
    VARIABLE add_v     : signed(AWL DOWNTO 0);
    VARIABLE add_v_dc  : signed(AWL DOWNTO AWL - OWL);
    VARIABLE add_v_sat : signed(OWL - 1 DOWNTO 0);
  BEGIN
    add_v    := signed(SUB_2_din1_mux) - signed(SUB_2_din2_mux);
    add_v_dc := add_v(AWL DOWNTO AWL - OWL) + ('0' & add_v(AWL - OWL - 1));
    IF add_v_dc(AWL) /= add_v_dc(AWL - 1) THEN
      add_v_sat(OWL - 1)          := add_v_dc(AWL);
      add_v_sat(OWL - 2 DOWNTO 0) := (OTHERS => add_v_dc(AWL - 1));
    ELSE
      add_v_sat := add_v_dc(AWL - 1 DOWNTO AWL - OWL);
    END IF;
    sub_2_out <= std_logic_vector(add_v_sat);
  END PROCESS;

  pipe_reg_proc_mul_b : PROCESS (clk)--, rst)
  BEGIN
    IF rising_edge(clk) THEN
      MUL_1_out_b <= MUL_1_out;
      MUL_2_out_b <= MUL_2_out; 
      MUL_3_out_b <= MUL_3_out; 
      MUL_4_out_b <= MUL_4_out;
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
      IF (strb_in) = '1' THEN
        dout1_re_b    <= add_1_out;
        dout2_re_b    <= sub_1_out;

        dout1_im_b    <= add_2_out;
        dout2_im_b    <= sub_2_out;
      END IF;
    END IF;
  END PROCESS;

  dout1_re <= dout1_re_b;
  dout1_im <= dout1_im_b;

  dout2_re <= dout2_re_b;
  dout2_im <= dout2_im_b;

  strb_out <= strb_in;

END rtl;