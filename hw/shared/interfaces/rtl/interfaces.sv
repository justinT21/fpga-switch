package interfaces;

  typedef struct packed {
    logic tx_clk;
    logic [3:0] txd;
    logic tx_ctl;
  } rgmii_phy_o_t;

  typedef struct packed {
    logic rx_clk;
    logic [3:0] rxd;
    logic rx_ctl;
  } rgmii_phy_i_t;

  typedef struct packed {
    logic rx_clk;
    logic [7:0] rxd;
    logic rx_dv;
    logic rx_err;
  } gmii_mac_rx_t;

  typedef struct packed {
    logic [7:0] txd;
    logic tx_en;
    logic tx_err;
  } gmii_mac_tx_t;

  typedef enum logic [2:0] {
    M_1000,
    M_100,
    M_10
  } speed_t;
endpackage
