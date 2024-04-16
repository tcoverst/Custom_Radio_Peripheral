library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_radio_v1_0_S00_AXI is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
        m_axis_tdata : out std_logic_vector(31 downto 0);
        m_axis_tvalid : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK	: in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	: in std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		S_AXI_AWVALID	: in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		S_AXI_AWREADY	: out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		S_AXI_WVALID	: in std_logic;
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		S_AXI_WREADY	: out std_logic;
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		S_AXI_BVALID	: out std_logic;
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		S_AXI_BREADY	: in std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		S_AXI_ARVALID	: in std_logic;
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	: out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		S_AXI_RVALID	: out std_logic;
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		S_AXI_RREADY	: in std_logic
	);
end full_radio_v1_0_S00_AXI;

architecture arch_imp of full_radio_v1_0_S00_AXI is

	-- AXI4LITE signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rdata	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;

	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 1;
	------------------------------------------------
	---- Signals for user logic register space example
	--------------------------------------------------
	---- Number of Slave Registers 4
	signal slv_reg0	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg1	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg2	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg3	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg_rden	: std_logic;
	signal slv_reg_wren	: std_logic;
	signal reg_data_out	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index	: integer;
	signal aw_en	: std_logic;

--COMPONENT dds_compiler_0
--  PORT (
--    aclk : IN STD_LOGIC;
--    aresetn : IN STD_LOGIC;
--    s_axis_phase_tvalid : IN STD_LOGIC;
--    s_axis_phase_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
--    m_axis_data_tvalid : OUT STD_LOGIC;
--    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
--  );
--    END COMPONENT;
    
    -- start 
  component dds_compiler_2
        PORT (
            aclk               : in std_logic;
            aresetn            : in std_logic;
            s_axis_phase_tvalid: in std_logic;
            s_axis_phase_tdata : in std_logic_vector(31 downto 0);
            m_axis_data_tvalid : out std_logic;
            m_axis_data_tdata  : out std_logic_vector(15 downto 0);
            m_axis_phase_tvalid: out std_logic;
            m_axis_phase_tdata : out std_logic_vector(31 downto 0)
        );
    end component;
    
  component dds_compiler_1
        PORT (
            aclk               : in std_logic;
            aresetn            : in std_logic;
            s_axis_phase_tvalid: in std_logic;
            s_axis_phase_tdata : in std_logic_vector(31 downto 0);
            m_axis_data_tvalid : out std_logic;
            m_axis_data_tdata  : out std_logic_vector(31 downto 0);
            m_axis_phase_tvalid: out std_logic;
            m_axis_phase_tdata : out std_logic_vector(31 downto 0)
        );
    end component;
    
    component cmpy_0
        PORT (
            aclk : in std_logic;
            s_axis_a_tvalid : in std_logic;
            s_axis_a_tdata : in std_logic_vector(31 downto 0);
            s_axis_b_tvalid : in std_logic;
            s_axis_b_tdata : in std_logic_vector(31 downto 0);
            m_axis_dout_tvalid : out std_logic;
            m_axis_dout_tdata : out std_logic_vector(31 downto 0)
        );
    end component;
    
    component fir_compiler_0
        PORT (
            aclk : in std_logic;
            s_axis_data_tvalid : in std_logic;
            s_axis_data_tdata : in std_logic_vector(15 downto 0);
            m_axis_data_tvalid : out std_logic;
            m_axis_data_tready : in std_logic;
            m_axis_data_tdata : out std_logic_vector(47 downto 0)
        );
    end component;
    
    component fir_compiler_1
        PORT (
            aclk : in std_logic;
            s_axis_data_tvalid : in std_logic;
            s_axis_data_tdata : in std_logic_vector(15 downto 0);
            m_axis_data_tvalid : out std_logic;
            s_axis_data_tready : out std_logic;
            m_axis_data_tdata : out std_logic_vector(47 downto 0)
        );
    end component;
    
    
   

    signal aresetn            : std_logic := '1';
    signal tune_prog            : std_logic := '0';
    
    signal s_axis_phase_tvalid : std_logic := '0';
    signal m_axis_data_tready_real : std_logic := '0';
    signal m_axis_data_tready_comp : std_logic := '0';
    signal s_axis_phase_tdata : std_logic_vector(31 downto 0) := (others => '0');
    
    signal s_axis_config_tvalid : std_logic := '0';
    signal s_axis_config_tdata : std_logic_vector(31 downto 0) := (others => '0');

    
    
    signal m_axis_data_tvalid_mult_f0 : std_logic := '0';
    signal s_axis_a_tvalid : std_logic := '0';
    signal s_axis_b_tvalid : std_logic := '0';
    signal m_axis_data_tdata_mult_f0 : std_logic_vector(31 downto 0) := (others => '0');
    signal m_axis_data_tdata_mult_f0_32 : std_logic_vector(31 downto 0) := (others => '0');
    
    signal m_axis_data_tvalid_ant_mult : std_logic := '0';
    signal m_axis_data_tdata_ant_mult : std_logic_vector(15 downto 0) := (others => '0');
    
    signal m_axis_data_tvalid_tun_mult : std_logic := '0';
    signal m_axis_data_tdata_tun_mult : std_logic_vector(31 downto 0) := (others => '0');
    
    signal m_axis_data_tvalid_f0_f1_real : std_logic := '0';
    signal m_axis_data_tdata_f0_f1_real : std_logic_vector(47 downto 0) := (others => '0');
    
    signal m_axis_data_tvalid_f1_dac_real : std_logic := '0';
    signal m_axis_data_tdata_f1_dac_real : std_logic_vector(47 downto 0) := (others => '0');
    
    signal m_axis_data_tvalid_f0_f1_comp : std_logic := '0';
    signal m_axis_data_tdata_f0_f1_comp : std_logic_vector(47 downto 0) := (others => '0');
    
    signal m_axis_data_tvalid_f1_dac_comp : std_logic := '0';
    signal m_axis_data_tdata_f1_dac_comp : std_logic_vector(47 downto 0) := (others => '0');
    
    signal m_axis_phase_tvalid_ant : std_logic := '0';
    signal m_axis_phase_tvalid_tun : std_logic := '0';
    signal m_axis_phase_tdata_ant : std_logic_vector(31 downto 0) := (others => '0');
    signal m_axis_phase_tdata_tun : std_logic_vector(31 downto 0) := (others => '0');

    signal end_of_simulation  : boolean := false;
    signal counter : std_logic_vector(31 downto 0) := (others => '0');  -- 32-bit counter

    
    
    --end

begin
	-- I/O Connections assignments

	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	S_AXI_BRESP	<= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	S_AXI_ARREADY	<= axi_arready;
	S_AXI_RDATA	<= axi_rdata;
	S_AXI_RRESP	<= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;
	-- Implement axi_awready generation
	-- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	-- de-asserted when reset is low.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awready <= '0';
	      aw_en <= '1';
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	        -- slave is ready to accept write address when
	        -- there is a valid write address and write data
	        -- on the write address and data bus. This design 
	        -- expects no outstanding transactions. 
	           axi_awready <= '1';
	           aw_en <= '0';
	        elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
	           aw_en <= '1';
	           axi_awready <= '0';
	      else
	        axi_awready <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	-- Implement axi_awaddr latching
	-- This process is used to latch the address when both 
	-- S_AXI_AWVALID and S_AXI_WVALID are valid. 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awaddr <= (others => '0');
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
	        -- Write Address latching
	        axi_awaddr <= S_AXI_AWADDR;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_wready generation
	-- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	-- de-asserted when reset is low. 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_wready <= '0';
	    else
	      if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
	          -- slave is ready to accept write data when 
	          -- there is a valid write address and write data
	          -- on the write address and data bus. This design 
	          -- expects no outstanding transactions.           
	          axi_wready <= '1';
	      else
	        axi_wready <= '0';
	      end if;
	    end if;
	  end if;
	end process; 

	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

	process (S_AXI_ACLK)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      slv_reg0 <= (others => '0');
	      slv_reg1 <= (others => '0');
	      slv_reg2 <= (others => '0');
	      slv_reg3 <= (others => '0');
	    else
	      loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	      if (slv_reg_wren = '1') then
	        case loc_addr is
	          when b"00" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 0
	                slv_reg0(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"01" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 1
	                slv_reg1(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"10" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 2
	                slv_reg2(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"11" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 3
	                slv_reg3(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when others =>
	            slv_reg0 <= slv_reg0;
	            slv_reg1 <= slv_reg1;
	            slv_reg2 <= slv_reg2;
	            slv_reg3 <= slv_reg3;
	        end case;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement write response logic generation
	-- The write response and response valid signals are asserted by the slave 
	-- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	-- This marks the acceptance of address and indicates the status of 
	-- write transaction.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_bvalid  <= '0';
	      axi_bresp   <= "00"; --need to work more on the responses
	    else
	      if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
	        axi_bvalid <= '1';
	        axi_bresp  <= "00"; 
	      elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
	        axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arready generation
	-- axi_arready is asserted for one S_AXI_ACLK clock cycle when
	-- S_AXI_ARVALID is asserted. axi_awready is 
	-- de-asserted when reset (active low) is asserted. 
	-- The read address is also latched when S_AXI_ARVALID is 
	-- asserted. axi_araddr is reset to zero on reset assertion.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_arready <= '0';
	      axi_araddr  <= (others => '1');
	    else
	      if (axi_arready = '0' and S_AXI_ARVALID = '1') then
	        -- indicates that the slave has acceped the valid read address
	        axi_arready <= '1';
	        -- Read Address latching 
	        axi_araddr  <= S_AXI_ARADDR;           
	      else
	        axi_arready <= '0';
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arvalid generation
	-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	-- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	-- data are available on the axi_rdata bus at this instance. The 
	-- assertion of axi_rvalid marks the validity of read data on the 
	-- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	-- is deasserted on reset (active low). axi_rresp and axi_rdata are 
	-- cleared to zero on reset (active low).  
	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then
	    if S_AXI_ARESETN = '0' then
	      axi_rvalid <= '0';
	      axi_rresp  <= "00";
	    else
	      if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
	        -- Valid read data is available at the read data bus
	        axi_rvalid <= '1';
	        axi_rresp  <= "00"; -- 'OKAY' response
	      elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
	        -- Read data is accepted by the master
	        axi_rvalid <= '0';
	      end if;            
	    end if;
	  end if;
	end process;

	-- Implement memory mapped register select and read logic generation
	-- Slave register read enable is asserted when valid address is available
	-- and the slave is ready to accept the read address.
	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

	process (slv_reg0, slv_reg1, slv_reg2, slv_reg3, axi_araddr, S_AXI_ARESETN, slv_reg_rden, aresetn, counter)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	begin
	    -- Address decoding for reading registers
	    loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	    case loc_addr is
	      when b"00" =>
	        reg_data_out <= slv_reg0;
	      when b"01" =>
	        reg_data_out <= slv_reg1;
	      when b"10" =>
	        reg_data_out <= slv_reg2;
	      when b"11" =>
	        reg_data_out <= counter;
	      when others =>
	        reg_data_out  <= (others => '0');
	    end case;
	end process; 

	-- Output register or memory read data
	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      axi_rdata  <= (others => '0');
	    else
	      if (slv_reg_rden = '1') then
	        -- When there is a valid read address (S_AXI_ARVALID) with 
	        -- acceptance of read address by the slave (axi_arready), 
	        -- output the read dada 
	        -- Read address mux
	        
	          axi_rdata <= reg_data_out;     -- register read data
	      end if;   
	    end if;
	    --m_axis_tdata <= m_axis_data_tdata_f1_dac_comp (45) & m_axis_data_tdata_f1_dac_comp (43 downto 30) & '0' & m_axis_data_tdata_f1_dac_real (45) & m_axis_data_tdata_f1_dac_real (43 downto 30) & '0'; -- Update dds_word
       -- m_axis_tvalid <= m_axis_data_tvalid_f1_dac_real;
	  end if;
	end process;


	-- Add user logic here

--your_name : dds_compiler_0
--  PORT MAP (
--    aclk => s_axi_aclk,
--    aresetn => '1',
--    s_axis_phase_tvalid => '1',
--    s_axis_phase_tdata => slv_reg0,
--    m_axis_data_tvalid => m_axis_data_tvalid_ant_mult,
--    m_axis_data_tdata => m_axis_data_tdata_ant_mult
--  );

antenna : dds_compiler_2
      port map (
        aclk => S_AXI_ACLK,
        aresetn => aresetn,
        s_axis_phase_tvalid => s_axis_phase_tvalid,
        s_axis_phase_tdata => slv_reg0,
        m_axis_data_tvalid => m_axis_data_tvalid_ant_mult,
        m_axis_data_tdata => m_axis_data_tdata_ant_mult,
        m_axis_phase_tvalid => m_axis_phase_tvalid_ant,
        m_axis_phase_tdata => m_axis_phase_tdata_ant
      );
      
tuner : dds_compiler_1
      port map (
        aclk => S_AXI_ACLK,
        aresetn => aresetn,
        s_axis_phase_tvalid => s_axis_config_tvalid,
        s_axis_phase_tdata => slv_reg1,
        m_axis_data_tvalid => m_axis_data_tvalid_tun_mult,
        m_axis_data_tdata => m_axis_data_tdata_tun_mult,
        m_axis_phase_tvalid => m_axis_phase_tvalid_tun,
        m_axis_phase_tdata => m_axis_phase_tdata_tun
      );
      
   m_axis_data_tdata_mult_f0_32 <= x"0000" & m_axis_data_tdata_ant_mult; 
   
   mult_0 : cmpy_0
      port map (
        aclk => S_AXI_ACLK,
        s_axis_a_tdata => m_axis_data_tdata_tun_mult, --std_logic_vector(signed(m_axis_data_tdata_tun_mult(15 downto 0)) * signed(m_axis_data_tdata_ant_mult)),
        s_axis_a_tvalid => m_axis_data_tvalid_tun_mult,
        s_axis_b_tdata => m_axis_data_tdata_mult_f0_32, --std_logic_vector(signed(m_axis_data_tdata_tun_mult(31 downto 16)) * signed(m_axis_data_tdata_ant_mult)),
        s_axis_b_tvalid => m_axis_data_tvalid_ant_mult,
        m_axis_dout_tdata => m_axis_data_tdata_mult_f0,
        m_axis_dout_tvalid => m_axis_data_tvalid_mult_f0
      );
        
      
    filt_real_0 : fir_compiler_0
      port map (
        aclk => S_AXI_ACLK,
        s_axis_data_tvalid => m_axis_data_tvalid_mult_f0,
        s_axis_data_tdata => m_axis_data_tdata_mult_f0 (15 downto 0),
        m_axis_data_tvalid => m_axis_data_tvalid_f0_f1_real,
        m_axis_data_tready => m_axis_data_tready_real,
        m_axis_data_tdata => m_axis_data_tdata_f0_f1_real
      );
      
    filt_real_1 : fir_compiler_1
      port map (
        aclk => S_AXI_ACLK,
        s_axis_data_tvalid => m_axis_data_tvalid_f0_f1_real,
        s_axis_data_tdata => m_axis_data_tdata_f0_f1_real (45 downto 30),
        m_axis_data_tvalid => m_axis_data_tvalid_f1_dac_real,
        s_axis_data_tready => m_axis_data_tready_real,
        m_axis_data_tdata => m_axis_data_tdata_f1_dac_real
      );
      
      
    filt_comp_0 : fir_compiler_0
      port map (
        aclk => S_AXI_ACLK,
        s_axis_data_tvalid => m_axis_data_tvalid_mult_f0,
        s_axis_data_tdata => m_axis_data_tdata_mult_f0 (31 downto 16),
        m_axis_data_tvalid => m_axis_data_tvalid_f0_f1_comp,
        m_axis_data_tready => m_axis_data_tready_comp,
        m_axis_data_tdata => m_axis_data_tdata_f0_f1_comp
      );
      
    filt_comp_1 : fir_compiler_1
      port map (
        aclk => S_AXI_ACLK,
        s_axis_data_tvalid => m_axis_data_tvalid_f0_f1_comp,
        s_axis_data_tdata => m_axis_data_tdata_f0_f1_comp (45 downto 30),
        m_axis_data_tvalid => m_axis_data_tvalid_f1_dac_comp,
        s_axis_data_tready => m_axis_data_tready_comp,
        m_axis_data_tdata => m_axis_data_tdata_f1_dac_comp
      );
     
     
    process(S_AXI_ACLK, S_AXI_ARESETN)
    begin
        if rising_edge(S_AXI_ACLK) then  -- Increment the counter on each rising edge of the clock
            counter <= std_logic_vector(unsigned(counter) + 1);
        end if;
    end process;

    --slv_reg3 <= std_logic_vector(counter);  -- Output the counter value
     --Process for updating dds_word
    process (S_AXI_ACLK, S_AXI_ARESETN)
    begin
        --if aresetn = '1' then
            --aresetn <= '0'; -- Assert asynchronous reset
        if rising_edge(S_AXI_ACLK) then
            --aresetn <= '1'; -- Release asynchronous reset
            s_axis_config_tvalid <= '1';
            s_axis_phase_tvalid <= '1';
           
            if m_axis_data_tvalid_f1_dac_real = '1' and m_axis_data_tvalid_f1_dac_comp = '1' then
                m_axis_tdata <= m_axis_data_tdata_f1_dac_comp (45) & m_axis_data_tdata_f1_dac_comp (43 downto 30) & '0' & m_axis_data_tdata_f1_dac_real (45) & m_axis_data_tdata_f1_dac_real (43 downto 30) & '0'; -- Update dds_word
            end if;
            m_axis_tvalid <= m_axis_data_tvalid_f1_dac_real;
            
        end if;
    end process;

	-- User logic ends
	aresetn <= not slv_reg2(0); 

end arch_imp;