--------------------------------------------------------------------------------
--     This file is owned and controlled by Xilinx and must be used           --
--     solely for design, simulation, implementation and creation of          --
--     design files limited to Xilinx devices or technologies. Use            --
--     with non-Xilinx devices or technologies is expressly prohibited        --
--     and immediately terminates your license.                               --
--                                                                            --
--     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"          --
--     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR                --
--     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION        --
--     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION            --
--     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS              --
--     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,                --
--     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE       --
--     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY               --
--     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE                --
--     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR         --
--     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF        --
--     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS        --
--     FOR A PARTICULAR PURPOSE.                                              --
--                                                                            --
--     Xilinx products are not intended for use in life support               --
--     appliances, devices, or systems. Use in such applications are          --
--     expressly prohibited.                                                  --
--                                                                            --
--     (c) Copyright 1995-2009 Xilinx, Inc.                                   --
--     All rights reserved.                                                   --
--------------------------------------------------------------------------------
-- You must compile the wrapper file fp_div.vhd when simulating
-- the core, fp_div. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

-- The synthesis directives "translate_off/translate_on" specified
-- below are supported by Xilinx, Mentor Graphics and Synplicity
-- synthesis tools. Ensure they are correct for your synthesis tool(s).

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- synthesis translate_off
Library XilinxCoreLib;
-- synthesis translate_on
ENTITY fp_div IS
	port (
	a: IN std_logic_VECTOR(31 downto 0);
	b: IN std_logic_VECTOR(31 downto 0);
	result: OUT std_logic_VECTOR(31 downto 0));
END fp_div;

ARCHITECTURE fp_div_a OF fp_div IS
-- synthesis translate_off
component wrapped_fp_div
	port (
	a: IN std_logic_VECTOR(31 downto 0);
	b: IN std_logic_VECTOR(31 downto 0);
	result: OUT std_logic_VECTOR(31 downto 0));
end component;

-- Configuration specification 
	for all : wrapped_fp_div use entity XilinxCoreLib.floating_point_v5_0(behavioral)
		generic map(
			c_has_b_nd => 0,
			c_speed => 2,
			c_has_sclr => 0,
			c_has_a_rfd => 0,
			c_b_fraction_width => 24,
			c_has_operation_nd => 0,
			c_has_exception => 0,
			c_a_fraction_width => 24,
			c_has_flt_to_fix => 0,
			c_has_flt_to_flt => 0,
			c_has_fix_to_flt => 0,
			c_has_invalid_op => 0,
			c_latency => 0,
			c_has_divide_by_zero => 0,
			c_has_overflow => 0,
			c_xdevicefamily => "virtex5",
			c_mult_usage => 0,
			c_has_rdy => 0,
			c_result_fraction_width => 24,
			c_has_divide => 1,
			c_has_inexact => 0,
			c_has_underflow => 0,
			c_has_sqrt => 0,
			c_has_add => 0,
			c_has_status => 0,
			c_has_a_negate => 0,
			c_optimization => 1,
			c_has_a_nd => 0,
			c_has_aclr => 0,
			c_has_b_negate => 0,
			c_has_subtract => 0,
			c_compare_operation => 8,
			c_rate => 1,
			c_has_compare => 0,
			c_has_operation_rfd => 0,
			c_has_b_rfd => 0,
			c_result_width => 32,
			c_b_width => 32,
			c_status_early => 0,
			c_a_width => 32,
			c_has_cts => 0,
			c_has_ce => 0,
			c_has_multiply => 0);
-- synthesis translate_on
BEGIN
-- synthesis translate_off
U0 : wrapped_fp_div
		port map (
			a => a,
			b => b,
			result => result);
-- synthesis translate_on

END fp_div_a;

