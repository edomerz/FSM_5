----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:27:10 11/11/2014 
-- Design Name: 
-- Module Name:    FSM_4 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM_4 is
	Port ( r_in			: in  STD_LOGIC;   --P41_i  LOC = "P41" #        : r_in in
		   c_in  		: in  STD_LOGIC;   --P42_i  LOC = "P42" #        : c_in in
           clk 			: in  STD_LOGIC;   --P01_i  LOC = "P1"  # J1-3   : GCK = XTAL 50M OUT
           reset  		: in  STD_LOGIC;   --P40_i  LOC = "40"  # J1-34  : input reset
					run_out 		: out STD_LOGIC;    	--P30_o  LOC = "P30" # J1-27  : LED5
					Sync_out  		: out STD_LOGIC;   		--P31_o  LOC = "P31" #        : LED4
					P0_out  		: out STD_LOGIC;   		--P32_o  LOC = "P32" #        : LED3
					P1_out    		: out STD_LOGIC;  		--P33_o  LOC = "P33" #        : LED2
					Erase_out		: out STD_LOGIC); 		--P34_o  LOC = "P34" #        : !!!!!!!!need to add in ucf!!!!!!!
end FSM_4;

architecture Behavioral of FSM_4 is
	type state_type is (wait_for_event, wait_for_R_rise, wait_for_R_fall, almost_sync, sync_state,
							  c_up,
									push0,
									both_up, 
										c_down, push1, 
										r_down,  erase, 
							  run_state, 
							  wait_for_0);
	signal current_s, next_s : state_type;
	signal run, sync, p0, p1, e : STD_LOGIC;

begin

Sync_out  <= sync; -- 1.3422s
P0_out    <= p0;
P1_out    <= p1;
run_out   <= run;
Erase_out <= e;

ff: process (clk, current_s, next_s, run, reset) begin
	if (reset='1') then 
		current_s <= wait_for_0;
	elsif (clk'event and clk = '1') then
		current_s <= next_s;
	end if;
end process ff;

logic: process (c_in, r_in, current_s) begin
	case current_s is 
											
				when wait_for_event => 
										sync <= '0'; 
										e <= '0'; 
										p0 <= '0';
										p1 <= '0';	
										run <= '0';	
					if (c_in='0' and r_in='0')  then 
						next_s <= wait_for_event;
					elsif (c_in='0' and r_in='1') then
						next_s <= run_state;
					elsif (c_in='1' and r_in='0') then
						next_s <= wait_for_R_rise ;
					elsif (c_in='1' and r_in='1') then
						next_s <= wait_for_0;
					end if;
					
				-- C up. wait for r_in rise 	
				when wait_for_R_rise => 
										sync <= '0'; 
										e <= '0'; 
										p0 <= '0'; 
										p1 <= '0';
										run <= '0';
					if (c_in='0' and r_in='0')  then 
						next_s <= wait_for_event;
					elsif (c_in='1' and r_in='1') then
						next_s <= wait_for_R_fall;
					elsif (c_in='1' and r_in='0') then
						next_s <= wait_for_R_rise;
					else 
						next_s <= wait_for_0;
					end if;
						
					-- r_in and c_in are up. wait for r_in fall	
				when wait_for_R_fall => 
										sync <= '0'; 
										e <= '0'; 
										p0 <= '0'; 
										p1 <= '0';
										run <= '0';
					if (c_in='0' and r_in='0')  then 
						next_s <= wait_for_event;
					elsif (c_in='1' and r_in='0') then
						next_s <= almost_sync;
					elsif (c_in='1' and r_in='1') then
						next_s <= wait_for_R_fall;
					else 
						next_s <= wait_for_0;
					end if;
					
				-- r_in fell c_in is up. wait for 00.
				when almost_sync => 
									sync <= '0'; 
									e <= '0'; 
									p0 <= '0'; 
									p1 <= '0';
									run <= '0';
					if (c_in='0' and r_in='0')  then 
						next_s <= sync_state;
					elsif (c_in='1' and r_in='0') then
						next_s <= almost_sync;
					else 
						next_s <= wait_for_0;
					end if;
					
				-- sync_state symbol received.
				when sync_state => 
								sync <= '1'; 
								e <= '0'; 
								p0 <= '0';
								p1 <= '0';
								run <= '0';
					if (c_in='0' and r_in='0')  then 
						next_s <= sync_state;
					elsif (c_in='0' and r_in='1') then
						next_s <= run_state;
					elsif (c_in='1' and r_in='0') then
						next_s <= c_up;
					else 
						next_s <= wait_for_0;
					end if;
					
				------------------------------------------------erase or
				------------------------------------------------push0 or
				------------------------------------------------push1
				
				when  c_up => 
								sync <= '0'; 
								e <= '0'; 
								p0 <= '0'; 
								p1 <= '0';
								run <= '0';
					if (c_in='0' and r_in='0')  then 
						next_s <= push0;
					elsif (c_in='1' and r_in='0') then
						next_s <= c_up;
					elsif (c_in='1' and r_in='1') then
						next_s <= both_up;					
					else 
						next_s <= wait_for_0;
					end if;
					
					-- r_in and c_in are up after sync symbol received.
				when both_up => 
								sync <= '0'; 
								e <= '0'; 
								p0 <= '0'; 
								p1 <= '0';
								run <= '0';
					if (c_in='0' and r_in='0')  then 
						next_s <= wait_for_event;
					elsif (c_in='1' and r_in='0') then
						next_s <= r_down;
					elsif (c_in='0' and r_in='1') then
						next_s <= c_down;
					else
						next_s <= both_up;
					end if;
					
					-- c_in is up, r_in fell. erase sync
				when r_down => 
								sync <= '0'; 
								e <= '0'; 
								p0 <= '0'; 
								p1 <= '0';
								run <= '0';
					if (c_in='0' and r_in='0')  then 
						next_s <= erase;
					elsif (c_in='1' and r_in='0') then
						next_s <= r_down;
					else 
						next_s <= wait_for_0;
					end if;	
					
										
				  -- erase symbol received.
				when erase => 
								sync <= '0'; 
								e <= '1'; 
								p0 <= '0'; 
								p1 <= '0';
								run <= '0'; -- erase CPLD reg 
					if (c_in='0' and r_in='0')  then 
						next_s <= erase;
					elsif (c_in='0' and r_in='1') then
						next_s <= run_state;
					elsif (c_in='1' and r_in='0') then
						next_s <= c_up;
					else 
						next_s <= wait_for_0;
					end if;
					
					-- r_in up . c_in fell.
				when c_down => 
								sync <= '0'; 
								e <= '0'; 
								p0 <= '0'; 
								p1 <= '0';
								run <= '0';
					if (c_in='0' and r_in='0') then
						next_s <= push1;
					elsif (c_in='0' and r_in='1') then
						next_s <= c_up;
					else
						next_s <= wait_for_0;
					end if;
					
				-- push0					
				when push0 => 
								sync <= '0'; 
								e <= '0'; 
								p0 <= '1'; 
								p1 <= '0';
								run <= '0'; --- push 0 onto nth cell in the 32b register
					if (c_in='0' and r_in='0') then
						next_s <= push0;-- return to sync_state
					elsif (c_in='0' and r_in='1') then
						next_s <= run_state;
					elsif (c_in='1' and r_in='0') then
						next_s <= c_up;
					else 
						next_s <= wait_for_0;
					end if;
					
				-- push1					
				when push1 => 
								sync <= '0'; 
								e <= '0'; 
								p0 <= '0'; 
								p1 <= '1';
								run <= '0'; --- push 1 onto register
					if (c_in='0' and r_in='0') then
						next_s <= push1;
					elsif (c_in='0' and r_in='1') then
						next_s <= run_state;
					elsif (c_in='1' and r_in='0') then
						next_s <= c_up;
					else
						next_s <= wait_for_0;
					end if;
				
				--run_state	
				when run_state => 
									sync <= '0'; 
									e <= '0'; 
									p0 <= '0'; 
									p1 <= '0'; 
									run <= '1';
						if (r_in='0' and c_in='0') then
							next_s <= wait_for_event;
						elsif (r_in='0' and c_in='1') then
							next_s <= wait_for_0;
						else
							next_s <= run_state;
						end if;
				--other.  wait for r_in=0 \ c_in=0
				when wait_for_0 => 
									sync <= '0'; 
									e <= '0'; 
									p0 <= '0'; 
									p1 <= '0'; 
									run <= '0';
					if (c_in='0' and r_in='0') then
						next_s <= wait_for_event;
					else
						next_s <= wait_for_0;
					end if;
				
			end case;
	end process logic;
end Behavioral;

