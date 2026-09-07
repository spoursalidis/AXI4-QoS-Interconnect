-- Author(s):
--   - Spyridon Poursalidis <s.poursalidis@gmail.com>
--
-- Description:
--
--	This module implements a 8-to-1 AXI4 multiplexer. 
--
--	Arbibration is decided based on the ARQOS/AWQOS signals of the AXI4 protocol, since they
--	are recommended to be used as priority indicators for the associated write or read requests,
--	where a higher value indicates a higher priority request.
--
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_qos_interconnect is
generic (
	AXI_ADDR_WIDTH  	: Integer := 32;
	AXI_DATA_WIDTH  	: Integer := 64;
	AXI_LEN_WIDTH		: Integer := 8;
	AXI_ID_WIDTH		: Integer := 6;
	AXI_USER_WIDTH		: Integer := 16;
	PIPELINE_STAGES		: Integer := 1;
	NUM_SLAVES			: Integer := 5
);
port (
	aclk				: in  std_logic;
	aresetn				: in  std_logic;

	-- AXI Channel 0
	s_axi_0_awid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_0_awqos		: in  std_logic_vector( 3 downto 0);
	s_axi_0_awaddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_0_awlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_0_awsize		: in  std_logic_vector( 2 downto 0);
	s_axi_0_awburst		: in  std_logic_vector( 1 downto 0);
	s_axi_0_awlock		: in  std_logic;
	s_axi_0_awcache		: in  std_logic_vector( 3 downto 0);
	s_axi_0_awprot		: in  std_logic_vector( 2 downto 0);
	s_axi_0_awuser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_0_awvalid		: in  std_logic;
	s_axi_0_awready		: out std_logic;
	s_axi_0_wdata		: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_0_wstrb		: in  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
	s_axi_0_wlast		: in  std_logic;
	s_axi_0_wvalid		: in  std_logic;
	s_axi_0_wready		: out std_logic;
	s_axi_0_bready		: in  std_logic;
	s_axi_0_bresp		: out std_logic_vector( 1 downto 0);
	s_axi_0_bvalid		: out std_logic;
	s_axi_0_arid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_0_arqos		: in  std_logic_vector( 3 downto 0);
	s_axi_0_araddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_0_arlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_0_arsize		: in  std_logic_vector( 2 downto 0);
	s_axi_0_arburst		: in  std_logic_vector( 1 downto 0);
	s_axi_0_arlock		: in  std_logic;
	s_axi_0_arcache		: in  std_logic_vector( 3 downto 0);
	s_axi_0_arprot		: in  std_logic_vector( 2 downto 0);
	s_axi_0_aruser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_0_arvalid		: in  std_logic;	
	s_axi_0_arready		: out std_logic;
	s_axi_0_rready		: in  std_logic;
	s_axi_0_rdata		: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_0_rresp		: out std_logic_vector( 1 downto 0);
	s_axi_0_rlast		: out std_logic;
	s_axi_0_rvalid		: out std_logic;

	-- AXI Channel 1
	s_axi_1_awid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_1_awqos		: in  std_logic_vector( 3 downto 0);
	s_axi_1_awaddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_1_awlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_1_awsize		: in  std_logic_vector( 2 downto 0);
	s_axi_1_awburst		: in  std_logic_vector( 1 downto 0);
	s_axi_1_awlock		: in  std_logic;
	s_axi_1_awcache		: in  std_logic_vector( 3 downto 0);
	s_axi_1_awprot		: in  std_logic_vector( 2 downto 0);
	s_axi_1_awuser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_1_awvalid		: in  std_logic;
	s_axi_1_awready		: out std_logic;
	s_axi_1_wdata		: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_1_wstrb		: in  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
	s_axi_1_wlast		: in  std_logic;
	s_axi_1_wvalid		: in  std_logic;
	s_axi_1_wready		: out std_logic;
	s_axi_1_bready		: in  std_logic;
	s_axi_1_bresp		: out std_logic_vector( 1 downto 0);
	s_axi_1_bvalid		: out std_logic;
	s_axi_1_arid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_1_arqos		: in  std_logic_vector( 3 downto 0);
	s_axi_1_araddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_1_arlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_1_arsize		: in  std_logic_vector( 2 downto 0);
	s_axi_1_arburst		: in  std_logic_vector( 1 downto 0);
	s_axi_1_arlock		: in  std_logic;
	s_axi_1_arcache		: in  std_logic_vector( 3 downto 0);
	s_axi_1_arprot		: in  std_logic_vector( 2 downto 0);
	s_axi_1_aruser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_1_arvalid		: in  std_logic;	
	s_axi_1_arready		: out std_logic;
	s_axi_1_rready		: in  std_logic;
	s_axi_1_rdata		: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_1_rresp		: out std_logic_vector( 1 downto 0);
	s_axi_1_rlast		: out std_logic;
	s_axi_1_rvalid		: out std_logic;

	-- AXI Channel 2
	s_axi_2_awid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_2_awqos		: in  std_logic_vector( 3 downto 0);
	s_axi_2_awaddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_2_awlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_2_awsize		: in  std_logic_vector( 2 downto 0);
	s_axi_2_awburst		: in  std_logic_vector( 1 downto 0);
	s_axi_2_awlock		: in  std_logic;
	s_axi_2_awcache		: in  std_logic_vector( 3 downto 0);
	s_axi_2_awprot		: in  std_logic_vector( 2 downto 0);
	s_axi_2_awuser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_2_awvalid		: in  std_logic;
	s_axi_2_awready		: out std_logic;
	s_axi_2_wdata		: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_2_wstrb		: in  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
	s_axi_2_wlast		: in  std_logic;
	s_axi_2_wvalid		: in  std_logic;
	s_axi_2_wready		: out std_logic;
	s_axi_2_bready		: in  std_logic;
	s_axi_2_bresp		: out std_logic_vector( 1 downto 0);
	s_axi_2_bvalid		: out std_logic;
	s_axi_2_arid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_2_arqos		: in  std_logic_vector( 3 downto 0);
	s_axi_2_araddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_2_arlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_2_arsize		: in  std_logic_vector( 2 downto 0);
	s_axi_2_arburst		: in  std_logic_vector( 1 downto 0);
	s_axi_2_arlock		: in  std_logic;
	s_axi_2_arcache		: in  std_logic_vector( 3 downto 0);
	s_axi_2_arprot		: in  std_logic_vector( 2 downto 0);
	s_axi_2_aruser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_2_arvalid		: in  std_logic;	
	s_axi_2_arready		: out std_logic;
	s_axi_2_rready		: in  std_logic;
	s_axi_2_rdata		: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_2_rresp		: out std_logic_vector( 1 downto 0);
	s_axi_2_rlast		: out std_logic;
	s_axi_2_rvalid		: out std_logic;

	-- AXI Channel 3
	s_axi_3_awid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_3_awqos		: in  std_logic_vector( 3 downto 0);
	s_axi_3_awaddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_3_awlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_3_awsize		: in  std_logic_vector( 2 downto 0);
	s_axi_3_awburst		: in  std_logic_vector( 1 downto 0);
	s_axi_3_awlock		: in  std_logic;
	s_axi_3_awcache		: in  std_logic_vector( 3 downto 0);
	s_axi_3_awprot		: in  std_logic_vector( 2 downto 0);
	s_axi_3_awuser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_3_awvalid		: in  std_logic;
	s_axi_3_awready		: out std_logic;
	s_axi_3_wdata		: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_3_wstrb		: in  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
	s_axi_3_wlast		: in  std_logic;
	s_axi_3_wvalid		: in  std_logic;
	s_axi_3_wready		: out std_logic;
	s_axi_3_bready		: in  std_logic;
	s_axi_3_bresp		: out std_logic_vector( 1 downto 0);
	s_axi_3_bvalid		: out std_logic;
	s_axi_3_arid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_3_arqos		: in  std_logic_vector( 3 downto 0);
	s_axi_3_araddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_3_arlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_3_arsize		: in  std_logic_vector( 2 downto 0);
	s_axi_3_arburst		: in  std_logic_vector( 1 downto 0);
	s_axi_3_arlock		: in  std_logic;
	s_axi_3_arcache		: in  std_logic_vector( 3 downto 0);
	s_axi_3_arprot		: in  std_logic_vector( 2 downto 0);
	s_axi_3_aruser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_3_arvalid		: in  std_logic;	
	s_axi_3_arready		: out std_logic;
	s_axi_3_rready		: in  std_logic;
	s_axi_3_rdata		: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_3_rresp		: out std_logic_vector( 1 downto 0);
	s_axi_3_rlast		: out std_logic;
	s_axi_3_rvalid		: out std_logic;

	-- AXI Channel 4
	s_axi_4_awid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_4_awqos		: in  std_logic_vector( 3 downto 0);
	s_axi_4_awaddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_4_awlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_4_awsize		: in  std_logic_vector( 2 downto 0);
	s_axi_4_awburst		: in  std_logic_vector( 1 downto 0);
	s_axi_4_awlock		: in  std_logic;
	s_axi_4_awcache		: in  std_logic_vector( 3 downto 0);
	s_axi_4_awprot		: in  std_logic_vector( 2 downto 0);
	s_axi_4_awuser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_4_awvalid		: in  std_logic;
	s_axi_4_awready		: out std_logic;
	s_axi_4_wdata		: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_4_wstrb		: in  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
	s_axi_4_wlast		: in  std_logic;
	s_axi_4_wvalid		: in  std_logic;
	s_axi_4_wready		: out std_logic;
	s_axi_4_bready		: in  std_logic;
	s_axi_4_bresp		: out std_logic_vector( 1 downto 0);
	s_axi_4_bvalid		: out std_logic;
	s_axi_4_arid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_4_arqos		: in  std_logic_vector( 3 downto 0);
	s_axi_4_araddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_4_arlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_4_arsize		: in  std_logic_vector( 2 downto 0);
	s_axi_4_arburst		: in  std_logic_vector( 1 downto 0);
	s_axi_4_arlock		: in  std_logic;
	s_axi_4_arcache		: in  std_logic_vector( 3 downto 0);
	s_axi_4_arprot		: in  std_logic_vector( 2 downto 0);
	s_axi_4_aruser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_4_arvalid		: in  std_logic;	
	s_axi_4_arready		: out std_logic;
	s_axi_4_rready		: in  std_logic;
	s_axi_4_rdata		: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_4_rresp		: out std_logic_vector( 1 downto 0);
	s_axi_4_rlast		: out std_logic;
	s_axi_4_rvalid		: out std_logic;

	-- AXI Channel 5
	s_axi_5_awid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_5_awqos		: in  std_logic_vector( 3 downto 0);
	s_axi_5_awaddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_5_awlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_5_awsize		: in  std_logic_vector( 2 downto 0);
	s_axi_5_awburst		: in  std_logic_vector( 1 downto 0);
	s_axi_5_awlock		: in  std_logic;
	s_axi_5_awcache		: in  std_logic_vector( 3 downto 0);
	s_axi_5_awprot		: in  std_logic_vector( 2 downto 0);
	s_axi_5_awuser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_5_awvalid		: in  std_logic;
	s_axi_5_awready		: out std_logic;
	s_axi_5_wdata		: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_5_wstrb		: in  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
	s_axi_5_wlast		: in  std_logic;
	s_axi_5_wvalid		: in  std_logic;
	s_axi_5_wready		: out std_logic;
	s_axi_5_bready		: in  std_logic;
	s_axi_5_bresp		: out std_logic_vector( 1 downto 0);
	s_axi_5_bvalid		: out std_logic;
	s_axi_5_arid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_5_arqos		: in  std_logic_vector( 3 downto 0);
	s_axi_5_araddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_5_arlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_5_arsize		: in  std_logic_vector( 2 downto 0);
	s_axi_5_arburst		: in  std_logic_vector( 1 downto 0);
	s_axi_5_arlock		: in  std_logic;
	s_axi_5_arcache		: in  std_logic_vector( 3 downto 0);
	s_axi_5_arprot		: in  std_logic_vector( 2 downto 0);
	s_axi_5_aruser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_5_arvalid		: in  std_logic;	
	s_axi_5_arready		: out std_logic;
	s_axi_5_rready		: in  std_logic;
	s_axi_5_rdata		: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_5_rresp		: out std_logic_vector( 1 downto 0);
	s_axi_5_rlast		: out std_logic;
	s_axi_5_rvalid		: out std_logic;

	-- AXI Channel 6
	s_axi_6_awid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_6_awqos		: in  std_logic_vector( 3 downto 0);
	s_axi_6_awaddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_6_awlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_6_awsize		: in  std_logic_vector( 2 downto 0);
	s_axi_6_awburst		: in  std_logic_vector( 1 downto 0);
	s_axi_6_awlock		: in  std_logic;
	s_axi_6_awcache		: in  std_logic_vector( 3 downto 0);
	s_axi_6_awprot		: in  std_logic_vector( 2 downto 0);
	s_axi_6_awuser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_6_awvalid		: in  std_logic;
	s_axi_6_awready		: out std_logic;
	s_axi_6_wdata		: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_6_wstrb		: in  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
	s_axi_6_wlast		: in  std_logic;
	s_axi_6_wvalid		: in  std_logic;
	s_axi_6_wready		: out std_logic;
	s_axi_6_bready		: in  std_logic;
	s_axi_6_bresp		: out std_logic_vector( 1 downto 0);
	s_axi_6_bvalid		: out std_logic;
	s_axi_6_arid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_6_arqos		: in  std_logic_vector( 3 downto 0);
	s_axi_6_araddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_6_arlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_6_arsize		: in  std_logic_vector( 2 downto 0);
	s_axi_6_arburst		: in  std_logic_vector( 1 downto 0);
	s_axi_6_arlock		: in  std_logic;
	s_axi_6_arcache		: in  std_logic_vector( 3 downto 0);
	s_axi_6_arprot		: in  std_logic_vector( 2 downto 0);
	s_axi_6_aruser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_6_arvalid		: in  std_logic;	
	s_axi_6_arready		: out std_logic;
	s_axi_6_rready		: in  std_logic;
	s_axi_6_rdata		: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_6_rresp		: out std_logic_vector( 1 downto 0);
	s_axi_6_rlast		: out std_logic;
	s_axi_6_rvalid		: out std_logic;

	-- AXI Channel 7
	s_axi_7_awid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_7_awqos		: in  std_logic_vector( 3 downto 0);
	s_axi_7_awaddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_7_awlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_7_awsize		: in  std_logic_vector( 2 downto 0);
	s_axi_7_awburst		: in  std_logic_vector( 1 downto 0);
	s_axi_7_awlock		: in  std_logic;
	s_axi_7_awcache		: in  std_logic_vector( 3 downto 0);
	s_axi_7_awprot		: in  std_logic_vector( 2 downto 0);
	s_axi_7_awuser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_7_awvalid		: in  std_logic;
	s_axi_7_awready		: out std_logic;
	s_axi_7_wdata		: in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_7_wstrb		: in  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
	s_axi_7_wlast		: in  std_logic;
	s_axi_7_wvalid		: in  std_logic;
	s_axi_7_wready		: out std_logic;
	s_axi_7_bready		: in  std_logic;
	s_axi_7_bresp		: out std_logic_vector( 1 downto 0);
	s_axi_7_bvalid		: out std_logic;
	s_axi_7_arid		: in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	s_axi_7_arqos		: in  std_logic_vector( 3 downto 0);
	s_axi_7_araddr		: in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	s_axi_7_arlen		: in  std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	s_axi_7_arsize		: in  std_logic_vector( 2 downto 0);
	s_axi_7_arburst		: in  std_logic_vector( 1 downto 0);
	s_axi_7_arlock		: in  std_logic;
	s_axi_7_arcache		: in  std_logic_vector( 3 downto 0);
	s_axi_7_arprot		: in  std_logic_vector( 2 downto 0);
	s_axi_7_aruser		: in  std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	s_axi_7_arvalid		: in  std_logic;	
	s_axi_7_arready		: out std_logic;
	s_axi_7_rready		: in  std_logic;
	s_axi_7_rdata		: out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	s_axi_7_rresp		: out std_logic_vector( 1 downto 0);
	s_axi_7_rlast		: out std_logic;
	s_axi_7_rvalid		: out std_logic;

	-- AXI4 Master I/F
	m_axi_awid			: OUT std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	m_axi_awqos        	: OUT std_logic_vector( 3 downto 0);
	m_axi_awaddr		: OUT std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	m_axi_awlen			: OUT std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	m_axi_awsize		: OUT std_logic_vector( 2 downto 0);
	m_axi_awburst		: OUT std_logic_vector( 1 downto 0);
	m_axi_awlock		: OUT std_logic;
	m_axi_awcache		: OUT std_logic_vector( 3 downto 0);
	m_axi_awprot		: OUT std_logic_vector( 2 downto 0);
	m_axi_awuser  		: OUT std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	m_axi_awvalid		: OUT std_logic;
	m_axi_awready		: IN  std_logic;
	m_axi_wdata			: OUT std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	m_axi_wstrb			: OUT std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
	m_axi_wlast			: OUT std_logic;
	m_axi_wvalid		: OUT std_logic;
	m_axi_wready		: IN  std_logic;
	m_axi_bready		: OUT std_logic;
	m_axi_bresp			: IN  std_logic_vector( 1 downto 0);
	m_axi_bvalid		: IN  std_logic;
	m_axi_arid			: OUT std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	m_axi_arqos			: OUT std_logic_vector( 3 downto 0);
	m_axi_araddr		: OUT std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	m_axi_arlen			: OUT std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	m_axi_arsize		: OUT std_logic_vector( 2 downto 0);
	m_axi_arburst		: OUT std_logic_vector( 1 downto 0);
	m_axi_arlock		: OUT std_logic;
	m_axi_arcache		: OUT std_logic_vector( 3 downto 0);
	m_axi_arprot		: OUT std_logic_vector( 2 downto 0);
	m_axi_aruser  		: OUT std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	m_axi_arvalid		: OUT std_logic;	
	m_axi_arready		: IN  std_logic;
	m_axi_rready		: OUT std_logic;
	m_axi_rdata			: IN  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	m_axi_rresp			: IN  std_logic_vector( 1 downto 0);
	m_axi_rlast			: IN  std_logic;
	m_axi_rvalid		: IN  std_logic
);
end axi_qos_interconnect;

architecture rtl of axi_qos_interconnect is

    signal grant_rd : std_logic_vector(3 downto 0); 
    signal grant_wr : std_logic_vector(3 downto 0); 

    -- FSM
    TYPE state_rd IS (RD_IDLE, RD_GRANT);
    SIGNAL rd_fsm_state : state_rd;

    TYPE state_wr IS (WR_IDLE, WR_GRANT);
    SIGNAL wr_fsm_state : state_wr;

	signal int_axi_awid			: std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	signal int_axi_awqos  		: std_logic_vector( 3 downto 0);
	signal int_axi_awaddr		: std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	signal int_axi_awlen		: std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	signal int_axi_awsize		: std_logic_vector( 2 downto 0);
	signal int_axi_awburst		: std_logic_vector( 1 downto 0);
	signal int_axi_awlock		: std_logic;
	signal int_axi_awcache		: std_logic_vector( 3 downto 0);
	signal int_axi_awprot		: std_logic_vector( 2 downto 0);
	signal int_axi_awuser 		: std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	signal int_axi_awvalid		: std_logic;
	signal int_axi_awready		: std_logic;
	signal int_axi_wdata		: std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	signal int_axi_wstrb		: std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
	signal int_axi_wlast		: std_logic;
	signal int_axi_wvalid		: std_logic;
	signal int_axi_wready		: std_logic;
	signal int_axi_bready		: std_logic;
	signal int_axi_bresp		: std_logic_vector( 1 downto 0);
	signal int_axi_bvalid		: std_logic;
	signal int_axi_arid			: std_logic_vector(AXI_ID_WIDTH-1 downto 0);
	signal int_axi_arqos		: std_logic_vector( 3 downto 0);
	signal int_axi_araddr		: std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
	signal int_axi_arlen		: std_logic_vector(AXI_LEN_WIDTH-1 downto 0);
	signal int_axi_arsize		: std_logic_vector( 2 downto 0);
	signal int_axi_arburst		: std_logic_vector( 1 downto 0);
	signal int_axi_arlock		: std_logic;
	signal int_axi_arcache		: std_logic_vector( 3 downto 0);
	signal int_axi_arprot		: std_logic_vector( 2 downto 0);
	signal int_axi_aruser 		: std_logic_vector(AXI_USER_WIDTH-1 downto 0);
	signal int_axi_arvalid		: std_logic;	
	signal int_axi_arready		: std_logic;
	signal int_axi_rready		: std_logic;
	signal int_axi_rdata		: std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	signal int_axi_rresp		: std_logic_vector( 1 downto 0);
	signal int_axi_rlast		: std_logic;
	signal int_axi_rvalid		: std_logic;

begin

	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
	-- Read Channel
	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
	int_axi_arid   	 <= s_axi_7_arid 	when (grant_rd = "1000") else 
						s_axi_6_arid 	when (grant_rd = "0111") else 
						s_axi_5_arid 	when (grant_rd = "0110") else 
						s_axi_4_arid 	when (grant_rd = "0101") else 
						s_axi_3_arid 	when (grant_rd = "0100") else 
						s_axi_2_arid 	when (grant_rd = "0011") else 
						s_axi_1_arid 	when (grant_rd = "0010") else 
						s_axi_0_arid	when (grant_rd = "0001") else 
						(others => '0');

	int_axi_arqos 	<= 	s_axi_7_arqos 	when (grant_rd = "1000") else 
						s_axi_6_arqos 	when (grant_rd = "0111") else 
						s_axi_5_arqos 	when (grant_rd = "0110") else	
						s_axi_4_arqos 	when (grant_rd = "0101") else 
						s_axi_3_arqos 	when (grant_rd = "0100") else 
						s_axi_2_arqos 	when (grant_rd = "0011") else 
						s_axi_1_arqos 	when (grant_rd = "0010") else 
						s_axi_0_arqos	when (grant_rd = "0001") else 
						(others => '0');

	int_axi_araddr 	 <= s_axi_7_araddr	when (grant_rd = "1000") else 
						s_axi_6_araddr	when (grant_rd = "0111") else 
						s_axi_5_araddr	when (grant_rd = "0110") else 
						s_axi_4_araddr	when (grant_rd = "0101") else 
						s_axi_3_araddr	when (grant_rd = "0100") else 
						s_axi_2_araddr	when (grant_rd = "0011") else 
						s_axi_1_araddr	when (grant_rd = "0010") else 
						s_axi_0_araddr	when (grant_rd = "0001") else 
						(others => '0');

	int_axi_arlen  	 <= s_axi_7_arlen	when (grant_rd = "1000") else 
						s_axi_6_arlen	when (grant_rd = "0111") else 
						s_axi_5_arlen	when (grant_rd = "0110") else 
						s_axi_4_arlen	when (grant_rd = "0101") else 
						s_axi_3_arlen	when (grant_rd = "0100") else 
						s_axi_2_arlen	when (grant_rd = "0011") else 
						s_axi_1_arlen	when (grant_rd = "0010") else 
						s_axi_0_arlen	when (grant_rd = "0001") else 
						(others => '0');

	int_axi_arsize 	 <= s_axi_7_arsize	when (grant_rd = "1000") else
						s_axi_6_arsize	when (grant_rd = "0111") else
						s_axi_5_arsize	when (grant_rd = "0110") else
						s_axi_4_arsize	when (grant_rd = "0101") else 
						s_axi_3_arsize	when (grant_rd = "0100") else 
						s_axi_2_arsize	when (grant_rd = "0011") else 
						s_axi_1_arsize	when (grant_rd = "0010") else 
						s_axi_0_arsize	when (grant_rd = "0001") else 
						(others => '0');

	int_axi_arburst	 <= s_axi_7_arburst	when (grant_rd = "1000") else 
						s_axi_6_arburst	when (grant_rd = "0111") else 
						s_axi_5_arburst	when (grant_rd = "0110") else 
						s_axi_4_arburst	when (grant_rd = "0101") else 
						s_axi_3_arburst	when (grant_rd = "0100") else 
						s_axi_2_arburst	when (grant_rd = "0011") else 
						s_axi_1_arburst	when (grant_rd = "0010") else 
						s_axi_0_arburst	when (grant_rd = "0001") else 
						(others => '0');

	int_axi_arlock 	 <= s_axi_7_arlock	when (grant_rd = "1000") else 
						s_axi_6_arlock	when (grant_rd = "0111") else 
						s_axi_5_arlock	when (grant_rd = "0110") else 
						s_axi_4_arlock	when (grant_rd = "0101") else 
						s_axi_3_arlock	when (grant_rd = "0100") else 
						s_axi_2_arlock	when (grant_rd = "0011") else 
						s_axi_1_arlock	when (grant_rd = "0010") else 
						s_axi_0_arlock	when (grant_rd = "0001") else 
						'0';

	int_axi_arcache	 <= s_axi_7_arcache	when (grant_rd = "1000") else 
						s_axi_6_arcache	when (grant_rd = "0111") else 
						s_axi_5_arcache	when (grant_rd = "0110") else 
						s_axi_4_arcache	when (grant_rd = "0101") else 
						s_axi_3_arcache	when (grant_rd = "0100") else 
						s_axi_2_arcache	when (grant_rd = "0011") else 
						s_axi_1_arcache	when (grant_rd = "0010") else 
						s_axi_0_arcache	when (grant_rd = "0001") else 
						(others => '0');

	int_axi_arprot 	 <= s_axi_7_arprot	when (grant_rd = "1000") else 
						s_axi_6_arprot	when (grant_rd = "0111") else 
						s_axi_5_arprot	when (grant_rd = "0110") else
						s_axi_4_arprot	when (grant_rd = "0101") else 
						s_axi_3_arprot	when (grant_rd = "0100") else 
						s_axi_2_arprot	when (grant_rd = "0011") else 
						s_axi_1_arprot	when (grant_rd = "0010") else 
						s_axi_0_arprot	when (grant_rd = "0001") else 
						(others => '0');

	int_axi_aruser 	 <= s_axi_7_aruser	when (grant_rd = "1000") else 
						s_axi_6_aruser	when (grant_rd = "0111") else 
						s_axi_5_aruser	when (grant_rd = "0110") else 
						s_axi_4_aruser	when (grant_rd = "0101") else 
						s_axi_3_aruser	when (grant_rd = "0100") else 
						s_axi_2_aruser	when (grant_rd = "0011") else 
						s_axi_1_aruser	when (grant_rd = "0010") else 
						s_axi_0_aruser	when (grant_rd = "0001") else 
						(others => '0');

	int_axi_arvalid	 <= s_axi_7_arvalid	when (grant_rd = "1000") else 
						s_axi_6_arvalid	when (grant_rd = "0111") else 
						s_axi_5_arvalid	when (grant_rd = "0110") else 
						s_axi_4_arvalid	when (grant_rd = "0101") else 
						s_axi_3_arvalid	when (grant_rd = "0100") else 
						s_axi_2_arvalid	when (grant_rd = "0011") else 
						s_axi_1_arvalid	when (grant_rd = "0010") else 
						s_axi_0_arvalid	when (grant_rd = "0001") else 
						'0';

	int_axi_rready 	 <= s_axi_7_rready	when (grant_rd = "1000") else 
						s_axi_6_rready	when (grant_rd = "0111") else 
						s_axi_5_rready	when (grant_rd = "0110") else 
						s_axi_4_rready	when (grant_rd = "0101") else 
						s_axi_3_rready	when (grant_rd = "0100") else 
						s_axi_2_rready	when (grant_rd = "0011") else 
						s_axi_1_rready	when (grant_rd = "0010") else 
						s_axi_0_rready	when (grant_rd = "0001") else 
						'0';

	s_axi_0_arready  <= int_axi_arready	when (grant_rd = "0001") else '0';
	s_axi_0_rlast    <= int_axi_rlast	when (grant_rd = "0001") else '0';
	s_axi_0_rvalid   <= int_axi_rvalid 	when (grant_rd = "0001") else '0';
	s_axi_0_rdata    <= int_axi_rdata;
	s_axi_0_rresp    <= int_axi_rresp;

	s_axi_1_arready  <= int_axi_arready	when (grant_rd = "0010") else '0';
	s_axi_1_rlast    <= int_axi_rlast	when (grant_rd = "0010") else '0';
	s_axi_1_rvalid   <= int_axi_rvalid	when (grant_rd = "0010") else '0';
	s_axi_1_rdata    <= int_axi_rdata;
	s_axi_1_rresp    <= int_axi_rresp;

	s_axi_2_arready  <= int_axi_arready	when (grant_rd = "0011") else '0';
	s_axi_2_rlast    <= int_axi_rlast	when (grant_rd = "0011") else '0';
	s_axi_2_rvalid   <= int_axi_rvalid 	when (grant_rd = "0011") else '0';
	s_axi_2_rdata    <= int_axi_rdata;
	s_axi_2_rresp    <= int_axi_rresp;

	s_axi_3_arready  <= int_axi_arready	when (grant_rd = "0100") else '0';
	s_axi_3_rlast    <= int_axi_rlast	when (grant_rd = "0100") else '0';
	s_axi_3_rvalid   <= int_axi_rvalid	when (grant_rd = "0100") else '0';
	s_axi_3_rdata    <= int_axi_rdata;
	s_axi_3_rresp    <= int_axi_rresp;

	s_axi_4_arready  <= int_axi_arready	when (grant_rd = "0101") else '0';
	s_axi_4_rlast    <= int_axi_rlast	when (grant_rd = "0101") else '0';
	s_axi_4_rvalid   <= int_axi_rvalid	when (grant_rd = "0101") else '0';
	s_axi_4_rdata    <= int_axi_rdata;
	s_axi_4_rresp    <= int_axi_rresp;

	s_axi_5_arready  <= int_axi_arready	when (grant_rd = "0110") else '0';
	s_axi_5_rlast    <= int_axi_rlast	when (grant_rd = "0110") else '0';
	s_axi_5_rvalid   <= int_axi_rvalid 	when (grant_rd = "0110") else '0';
	s_axi_5_rdata    <= int_axi_rdata;
	s_axi_5_rresp    <= int_axi_rresp;

	s_axi_6_arready  <= int_axi_arready	when (grant_rd = "0111") else '0';
	s_axi_6_rlast    <= int_axi_rlast	when (grant_rd = "0111") else '0';
	s_axi_6_rvalid   <= int_axi_rvalid	when (grant_rd = "0111") else '0';
	s_axi_6_rdata    <= int_axi_rdata;
	s_axi_6_rresp    <= int_axi_rresp;

	s_axi_7_arready  <= int_axi_arready	when (grant_rd = "1000") else '0';
	s_axi_7_rlast    <= int_axi_rlast	when (grant_rd = "1000") else '0';
	s_axi_7_rvalid   <= int_axi_rvalid	when (grant_rd = "1000") else '0';
	s_axi_7_rdata    <= int_axi_rdata;
	s_axi_7_rresp    <= int_axi_rresp;

	-----------------------------------------------------------------------
	-- Read FSM
	-----------------------------------------------------------------------
    process(aclk, aresetn)
		variable rd_max_qos 	: unsigned(3 downto 0) := (others => '0');
		variable rd_winner  	: integer range 0 to 7 := 0;
		variable rd_found		: std_logic := '0';
    begin
		if (aresetn = '0') then
			grant_rd       <= (others => '0');
			rd_fsm_state   <= RD_IDLE;

        elsif rising_edge(aclk) then

			case (rd_fsm_state) is

				when RD_IDLE => 

					rd_max_qos 		:= (others => '0');
					rd_winner  		:= 0;
					rd_found		:= '0';

					if (int_axi_arready = '1') then
																
						if (s_axi_0_arvalid = '1') then
							rd_max_qos := unsigned(s_axi_0_arqos);
							rd_winner  := 0;
							rd_found   := '1';
						end if;
						
						if (s_axi_1_arvalid = '1' and (rd_found = '0' or unsigned(s_axi_1_arqos) > rd_max_qos)) then
							rd_max_qos := unsigned(s_axi_1_arqos);
							rd_winner  := 1;
							rd_found   := '1';
						end if;

						if (s_axi_2_arvalid = '1' and (rd_found = '0' or unsigned(s_axi_2_arqos) > rd_max_qos))then
							rd_max_qos := unsigned(s_axi_2_arqos);
							rd_winner  := 2;
							rd_found   := '1';
						end if;

						if (s_axi_3_arvalid = '1' and (rd_found = '0' or unsigned(s_axi_3_arqos) > rd_max_qos)) then
							rd_max_qos := unsigned(s_axi_3_arqos);
							rd_winner  := 3;
							rd_found   := '1';
						end if;

						if (s_axi_4_arvalid = '1' and (rd_found = '0' or unsigned(s_axi_4_arqos) > rd_max_qos)) then
							rd_max_qos := unsigned(s_axi_4_arqos);
							rd_winner  := 4;
							rd_found   := '1';
						end if;

						if (s_axi_5_arvalid = '1' and (rd_found = '0' or unsigned(s_axi_5_arqos) > rd_max_qos)) then
							rd_max_qos := unsigned(s_axi_5_arqos);
							rd_winner  := 5;
							rd_found   := '1';
						end if;

						if (s_axi_6_arvalid = '1' and (rd_found = '0' or unsigned(s_axi_6_arqos) > rd_max_qos)) then
							rd_max_qos := unsigned(s_axi_6_arqos);
							rd_winner  := 6;
							rd_found   := '1';
						end if;

						if (s_axi_7_arvalid = '1' and (rd_found = '0' or unsigned(s_axi_7_arqos) > rd_max_qos)) then
							rd_max_qos := unsigned(s_axi_7_arqos);
							rd_winner  := 7;
							rd_found   := '1';
						end if;

						if (rd_found = '1') then
							grant_rd        <= std_logic_vector(to_unsigned(rd_winner + 1, grant_rd'length));
							rd_fsm_state    <= RD_GRANT;
						else
							grant_rd <= (others => '0');
						end if;

					else
						grant_rd <= (others => '0');
					end if;

				when RD_GRANT => 

					if (int_axi_rvalid = '1' and int_axi_rlast = '1') then
						rd_fsm_state <= RD_IDLE;
						grant_rd     <= (others => '0');
					end if;	

				when others => 
					grant_rd       <= (others => '0');
					rd_fsm_state   <= RD_IDLE;

			end case;
        end if;
    end process;

	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
	-- Write Channel
	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
	int_axi_awid	<= 	s_axi_7_awid when (grant_wr = "1000") else 
						s_axi_6_awid when (grant_wr = "0111") else 
						s_axi_5_awid when (grant_wr = "0110") else
						s_axi_4_awid when (grant_wr = "0101") else 
						s_axi_3_awid when (grant_wr = "0100") else 
						s_axi_2_awid when (grant_wr = "0011") else 
						s_axi_1_awid when (grant_wr = "0010") else 
						s_axi_0_awid when (grant_wr = "0001") else 
						(others => '0');

	int_axi_awqos	<= 	s_axi_7_awqos when (grant_wr = "1000") else 
						s_axi_6_awqos when (grant_wr = "0111") else 
						s_axi_5_awqos when (grant_wr = "0110") else
						s_axi_4_awqos when (grant_wr = "0101") else 
						s_axi_3_awqos when (grant_wr = "0100") else 
						s_axi_2_awqos when (grant_wr = "0011") else 
						s_axi_1_awqos when (grant_wr = "0010") else 
						s_axi_0_awqos when (grant_wr = "0001") else 
						(others => '0');

	int_axi_awaddr	<= 	s_axi_7_awaddr 	when (grant_wr = "1000") else 
						s_axi_6_awaddr 	when (grant_wr = "0111") else 
						s_axi_5_awaddr 	when (grant_wr = "0110") else 
						s_axi_4_awaddr 	when (grant_wr = "0101") else 
						s_axi_3_awaddr 	when (grant_wr = "0100") else 
						s_axi_2_awaddr 	when (grant_wr = "0011") else 
						s_axi_1_awaddr 	when (grant_wr = "0010") else 
						s_axi_0_awaddr	when (grant_wr = "0001") else 
						(others => '0');

	int_axi_awlen	<= 	s_axi_7_awlen when (grant_wr = "1000") else 
						s_axi_6_awlen when (grant_wr = "0111") else 
						s_axi_5_awlen when (grant_wr = "0110") else 
						s_axi_4_awlen when (grant_wr = "0101") else 
						s_axi_3_awlen when (grant_wr = "0100") else 
						s_axi_2_awlen when (grant_wr = "0011") else 
						s_axi_1_awlen when (grant_wr = "0010") else 
						s_axi_0_awlen when (grant_wr = "0001") else 
						(others => '0');

	int_axi_awsize	<= 	s_axi_7_awsize 	when (grant_wr = "1000") else 
						s_axi_6_awsize 	when (grant_wr = "0111") else 
						s_axi_5_awsize 	when (grant_wr = "0110") else 
						s_axi_4_awsize 	when (grant_wr = "0101") else 
						s_axi_3_awsize 	when (grant_wr = "0100") else 
						s_axi_2_awsize 	when (grant_wr = "0011") else 
						s_axi_1_awsize 	when (grant_wr = "0010") else 
						s_axi_0_awsize	when (grant_wr = "0001") else 
						(others => '0');

	int_axi_awburst	<= 	s_axi_7_awburst	when (grant_wr = "1000") else 
						s_axi_6_awburst	when (grant_wr = "0111") else 
						s_axi_5_awburst	when (grant_wr = "0110") else 
						s_axi_4_awburst	when (grant_wr = "0101") else 
						s_axi_3_awburst	when (grant_wr = "0100") else 
						s_axi_2_awburst	when (grant_wr = "0011") else 
						s_axi_1_awburst	when (grant_wr = "0010") else 
						s_axi_0_awburst	when (grant_wr = "0001") else 
						(others => '0');

	int_axi_awlock	<= 	s_axi_7_awlock when (grant_wr = "1000") else 
						s_axi_6_awlock when (grant_wr = "0111") else 
						s_axi_5_awlock when (grant_wr = "0110") else 
						s_axi_4_awlock when (grant_wr = "0101") else 
						s_axi_3_awlock when (grant_wr = "0100") else 
						s_axi_2_awlock when (grant_wr = "0011") else 
						s_axi_1_awlock when (grant_wr = "0010") else 
						s_axi_0_awlock when (grant_wr = "0001") else 
						'0';

	int_axi_awcache	<= 	s_axi_7_awcache when (grant_wr = "1000") else 
						s_axi_6_awcache when (grant_wr = "0111") else 
						s_axi_5_awcache when (grant_wr = "0110") else 
						s_axi_4_awcache when (grant_wr = "0101") else 
						s_axi_3_awcache when (grant_wr = "0100") else 
						s_axi_2_awcache when (grant_wr = "0011") else 
						s_axi_1_awcache when (grant_wr = "0010") else 
						s_axi_0_awcache when (grant_wr = "0001") else 
						(others => '0');

	int_axi_awprot	<= 	s_axi_7_awprot when (grant_wr = "1000") else 
						s_axi_6_awprot when (grant_wr = "0111") else 
						s_axi_5_awprot when (grant_wr = "0110") else 
						s_axi_4_awprot when (grant_wr = "0101") else 
						s_axi_3_awprot when (grant_wr = "0100") else 
						s_axi_2_awprot when (grant_wr = "0011") else 
						s_axi_1_awprot when (grant_wr = "0010") else 
						s_axi_0_awprot when (grant_wr = "0001") else 
						(others => '0');

	int_axi_awuser	<= 	s_axi_7_awuser when (grant_wr = "1000") else 
						s_axi_6_awuser when (grant_wr = "0111") else 
						s_axi_5_awuser when (grant_wr = "0110") else 
						s_axi_4_awuser when (grant_wr = "0101") else 
						s_axi_3_awuser when (grant_wr = "0100") else 
						s_axi_2_awuser when (grant_wr = "0011") else 
						s_axi_1_awuser when (grant_wr = "0010") else 
						s_axi_0_awuser when (grant_wr = "0001") else 
						(others => '0');

	int_axi_awvalid	<= 	s_axi_7_awvalid when (grant_wr = "1000") else 
						s_axi_6_awvalid when (grant_wr = "0111") else 
						s_axi_5_awvalid when (grant_wr = "0110") else 
						s_axi_4_awvalid when (grant_wr = "0101") else 
						s_axi_3_awvalid when (grant_wr = "0100") else 
						s_axi_2_awvalid when (grant_wr = "0011") else 
						s_axi_1_awvalid when (grant_wr = "0010") else 
						s_axi_0_awvalid when (grant_wr = "0001") else 
						'0';

	int_axi_wdata	<=	s_axi_7_wdata when (grant_wr = "1000") else 
						s_axi_6_wdata when (grant_wr = "0111") else 
						s_axi_5_wdata when (grant_wr = "0110") else 
						s_axi_4_wdata when (grant_wr = "0101") else 
						s_axi_3_wdata when (grant_wr = "0100") else 
						s_axi_2_wdata when (grant_wr = "0011") else 
						s_axi_1_wdata when (grant_wr = "0010") else 
						s_axi_0_wdata when (grant_wr = "0001") else 
						(others => '0');

	int_axi_wstrb	<=	s_axi_7_wstrb when (grant_wr = "1000") else 
						s_axi_6_wstrb when (grant_wr = "0111") else 
						s_axi_5_wstrb when (grant_wr = "0110") else
						s_axi_4_wstrb when (grant_wr = "0101") else 
						s_axi_3_wstrb when (grant_wr = "0100") else 
						s_axi_2_wstrb when (grant_wr = "0011") else 
						s_axi_1_wstrb when (grant_wr = "0010") else 
						s_axi_0_wstrb when (grant_wr = "0001") else 
						(others => '0');

	int_axi_wlast	<=	s_axi_7_wlast when (grant_wr = "1000") else 
						s_axi_6_wlast when (grant_wr = "0111") else 
						s_axi_5_wlast when (grant_wr = "0110") else 
						s_axi_4_wlast when (grant_wr = "0101") else 
						s_axi_3_wlast when (grant_wr = "0100") else 
						s_axi_2_wlast when (grant_wr = "0011") else 
						s_axi_1_wlast when (grant_wr = "0010") else 
						s_axi_0_wlast when (grant_wr = "0001") else 
						'0';

	int_axi_wvalid	<=	s_axi_7_wvalid when (grant_wr = "1000") else 
						s_axi_6_wvalid when (grant_wr = "0111") else 
						s_axi_5_wvalid when (grant_wr = "0110") else 
						s_axi_4_wvalid when (grant_wr = "0101") else 
						s_axi_3_wvalid when (grant_wr = "0100") else 
						s_axi_2_wvalid when (grant_wr = "0011") else 
						s_axi_1_wvalid when (grant_wr = "0010") else 
						s_axi_0_wvalid when (grant_wr = "0001") else 
						'0';

	int_axi_bready	<=	s_axi_7_bready when (grant_wr = "1000") else 
						s_axi_6_bready when (grant_wr = "0111") else 
						s_axi_5_bready when (grant_wr = "0110") else 
						s_axi_4_bready when (grant_wr = "0101") else 
						s_axi_3_bready when (grant_wr = "0100") else 
						s_axi_2_bready when (grant_wr = "0011") else 
						s_axi_1_bready when (grant_wr = "0010") else 
						s_axi_0_bready when (grant_wr = "0001") else 
						'0';

	s_axi_0_awready  <= int_axi_awready 	when (grant_wr = "0001") else '0';
	s_axi_0_wready   <= int_axi_wready  	when (grant_wr = "0001") else '0';
	s_axi_0_bvalid   <= int_axi_bvalid  	when (grant_wr = "0001") else '0';
	s_axi_0_bresp    <= int_axi_bresp;

	s_axi_1_awready  <= int_axi_awready 	when (grant_wr = "0010") else '0';
	s_axi_1_wready   <= int_axi_wready  	when (grant_wr = "0010") else '0';
	s_axi_1_bvalid   <= int_axi_bvalid  	when (grant_wr = "0010") else '0';
	s_axi_1_bresp    <= int_axi_bresp;

	s_axi_2_awready  <= int_axi_awready 	when (grant_wr = "0011") else '0';
	s_axi_2_wready   <= int_axi_wready  	when (grant_wr = "0011") else '0';
	s_axi_2_bvalid   <= int_axi_bvalid  	when (grant_wr = "0011") else '0';
	s_axi_2_bresp    <= int_axi_bresp;

	s_axi_3_awready  <= int_axi_awready 	when (grant_wr = "0100") else '0';
	s_axi_3_wready   <= int_axi_wready  	when (grant_wr = "0100") else '0';
	s_axi_3_bvalid   <= int_axi_bvalid  	when (grant_wr = "0100") else '0';
	s_axi_3_bresp    <= int_axi_bresp;

	s_axi_4_awready  <= int_axi_awready 	when (grant_wr = "0101") else '0';
	s_axi_4_wready   <= int_axi_wready  	when (grant_wr = "0101") else '0';
	s_axi_4_bvalid   <= int_axi_bvalid  	when (grant_wr = "0101") else '0';
	s_axi_4_bresp    <= int_axi_bresp;

	s_axi_5_awready  <= int_axi_awready 	when (grant_wr = "0110") else '0';
	s_axi_5_wready   <= int_axi_wready  	when (grant_wr = "0110") else '0';
	s_axi_5_bvalid   <= int_axi_bvalid  	when (grant_wr = "0110") else '0';
	s_axi_5_bresp    <= int_axi_bresp;

	s_axi_6_awready  <= int_axi_awready 	when (grant_wr = "0111") else '0';
	s_axi_6_wready   <= int_axi_wready  	when (grant_wr = "0111") else '0';
	s_axi_6_bvalid   <= int_axi_bvalid  	when (grant_wr = "0111") else '0';
	s_axi_6_bresp    <= int_axi_bresp;

	s_axi_7_awready  <= int_axi_awready 	when (grant_wr = "1000") else '0';
	s_axi_7_wready   <= int_axi_wready  	when (grant_wr = "1000") else '0';
	s_axi_7_bvalid   <= int_axi_bvalid  	when (grant_wr = "1000") else '0';
	s_axi_7_bresp    <= int_axi_bresp;


	-----------------------------------------------------------------------
	-- Write FSM
	-----------------------------------------------------------------------
    process(aclk, aresetn)
		variable wr_max_qos 	: unsigned(3 downto 0) := (others => '0');
		variable wr_winner  	: integer range 0 to 7 := 0;
		variable wr_found		: std_logic := '0';
    begin
		if (aresetn = '0') then
			grant_wr       <= (others => '0');
			wr_fsm_state   <= WR_IDLE;

        elsif rising_edge(aclk) then

			case (wr_fsm_state) is

				when WR_IDLE => 

					wr_max_qos 		:= (others => '0');
					wr_winner  		:= 0;
					wr_found		:= '0';

					if (int_axi_arready = '1') then
																
						if (s_axi_0_awvalid = '1') then
							wr_max_qos := unsigned(s_axi_0_awqos);
							wr_winner  := 0;
							wr_found   := '1';
						end if;
						
						if (s_axi_1_awvalid = '1' and (wr_found = '0' or unsigned(s_axi_1_awqos) > wr_max_qos)) then
							wr_max_qos := unsigned(s_axi_1_awqos);
							wr_winner  := 1;
							wr_found   := '1';
						end if;

						if (s_axi_2_awvalid = '1' and (wr_found = '0' or unsigned(s_axi_2_awqos) > wr_max_qos)) then
							wr_max_qos := unsigned(s_axi_2_awqos);
							wr_winner  := 2;
							wr_found   := '1';
						end if;

						if (s_axi_3_awvalid = '1' and (wr_found = '0' or unsigned(s_axi_3_awqos) > wr_max_qos)) then
							wr_max_qos := unsigned(s_axi_3_awqos);
							wr_winner  := 3;
							wr_found   := '1';
						end if;

						if (s_axi_4_awvalid = '1' and (wr_found = '0' or unsigned(s_axi_4_awqos) > wr_max_qos)) then
							wr_max_qos := unsigned(s_axi_4_awqos);
							wr_winner  := 4;
							wr_found   := '1';
						end if;

						if (s_axi_5_awvalid = '1' and (wr_found = '0' or unsigned(s_axi_5_awqos) > wr_max_qos)) then
							wr_max_qos := unsigned(s_axi_6_awqos);
							wr_winner  := 6;
							wr_found   := '1';
						end if;

						if (s_axi_6_awvalid = '1' and (wr_found = '0' or unsigned(s_axi_6_awqos) > wr_max_qos)) then
							wr_max_qos := unsigned(s_axi_6_awqos);
							wr_winner  := 6;
							wr_found   := '1';
						end if;

						if (s_axi_7_awvalid = '1' and (wr_found = '0' or unsigned(s_axi_7_awqos) > wr_max_qos)) then
							wr_max_qos := unsigned(s_axi_7_awqos);
							wr_winner  := 7;
							wr_found   := '1';
						end if;

						if (wr_found = '1') then
							grant_wr		<= std_logic_vector(to_unsigned(wr_winner + 1, grant_wr'length));
							wr_fsm_state	<= WR_GRANT;
						else
							grant_wr <= (others => '0');
						end if;
	
					else
						grant_wr <= (others => '0');
					end if;

				when WR_GRANT => 

					if (int_axi_bvalid = '1' and int_axi_bready = '1') then
						wr_fsm_state <= WR_IDLE;
						grant_wr     <= (others => '0');
					end if;

				when others => 
					grant_wr       <= (others => '0');
					wr_fsm_state   <= WR_IDLE;

			end case;
		end if;
    end process;

	pipeline: entity work.olo_axi_pl_stage
    generic map (
        AddrWidth_g	=> AXI_ADDR_WIDTH,
        DataWidth_g	=> AXI_DATA_WIDTH,
        IdWidth_g  	=> AXI_ID_WIDTH,
        LenWidth_g	=> AXI_LEN_WIDTH,
		UserWidth_g => AXI_USER_WIDTH,
        Stages_g   	=> PIPELINE_STAGES
    ) 
    port map (
        Clk        => aclk,
        Rst        => not(aresetn),

        S_AwId     => int_axi_awid,
        S_AwAddr   => int_axi_awaddr,
        S_AwValid  => int_axi_awvalid,
        S_AwReady  => int_axi_awready,
        S_AwLen    => int_axi_awlen,
        S_AwSize   => int_axi_awsize,
        S_AwBurst  => int_axi_awburst,
        S_AwLock   => int_axi_awlock,
        S_AwCache  => int_axi_awcache,
        S_AwProt   => int_axi_awprot,
        S_AwQos    => int_axi_awqos,
        S_AwUser   => int_axi_awuser,
        S_AwRegion => (others => '0'),
        S_WData    => int_axi_wdata,
        S_WStrb    => int_axi_wstrb,
        S_WValid   => int_axi_wvalid,
        S_WReady   => int_axi_wready,
        S_WLast    => int_axi_wlast,
        S_WUser    => (others => '0'),
        S_BId      => open,
        S_BResp    => int_axi_bresp,
        S_BValid   => int_axi_bvalid,
        S_BReady   => int_axi_bready,
        S_BUser    => open,
        S_ArId     => int_axi_arid,
        S_ArAddr   => int_axi_araddr,
        S_ArValid  => int_axi_arvalid,
        S_ArReady  => int_axi_arready,
        S_ArLen    => int_axi_arlen,
        S_ArSize   => int_axi_arsize,
        S_ArBurst  => int_axi_arburst,
        S_ArLock   => int_axi_arlock,
        S_ArCache  => int_axi_arcache,
        S_ArProt   => int_axi_arprot,
        S_ArQos    => int_axi_arqos,
        S_ArUser   => int_axi_aruser,
        S_ArRegion => (others => '0'),
        S_RId      => open,
        S_RData    => int_axi_rdata,
        S_RValid   => int_axi_rvalid,
        S_RReady   => int_axi_rready,
        S_RResp    => int_axi_rresp,
        S_RLast    => int_axi_rlast,
        S_RUser    => open,

        -- output interface
        M_AwId     => m_axi_awid,
        M_AwAddr   => m_axi_awaddr,
        M_AwValid  => m_axi_awvalid,
        M_AwReady  => m_axi_awready,
        M_AwLen    => m_axi_awlen,
        M_AwSize   => m_axi_awsize,
        M_AwBurst  => m_axi_awburst,
        M_AwLock   => m_axi_awlock,
        M_AwCache  => m_axi_awcache,
        M_AwProt   => m_axi_awprot,
        M_AwQos    => m_axi_awqos,
        M_AwUser   => m_axi_awuser,
        M_AwRegion => open,
        M_WData    => m_axi_wdata,
        M_WStrb    => m_axi_wstrb,
        M_WValid   => m_axi_wvalid,
        M_WReady   => m_axi_wready,
        M_WLast    => m_axi_wlast,
        M_WUser    => open,
        M_BId      => (others => '0'),
        M_BResp    => m_axi_bresp,
        M_BValid   => m_axi_bvalid,
        M_BReady   => m_axi_bready,
        M_BUser    => (others => '0'),
        M_ArId     => m_axi_arid,
        M_ArAddr   => m_axi_araddr,
        M_ArValid  => m_axi_arvalid,
        M_ArReady  => m_axi_arready,
        M_ArLen    => m_axi_arlen,
        M_ArSize   => m_axi_arsize,
        M_ArBurst  => m_axi_arburst,
        M_ArLock   => m_axi_arlock,
        M_ArCache  => m_axi_arcache,
        M_ArProt   => m_axi_arprot,
        M_ArQos    => m_axi_arqos,
        M_ArUser   => m_axi_aruser,
        M_ArRegion => open,
        M_RId      => (others => '0'),
        M_RData    => m_axi_rdata,
        M_RValid   => m_axi_rvalid,
        M_RReady   => m_axi_rready,
        M_RResp    => m_axi_rresp,
        M_RLast    => m_axi_rlast,
        M_RUser    => (others => '0')
    );

end rtl;