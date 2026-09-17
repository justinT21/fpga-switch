import interfaces::*;

module rgmii_phy_if (
    input rgmii_phy_i_t phy_i,
    input speed_t phy_speed_i,
    input rst_ni,
    input clk_i,
    input gmii_mac_tx_t mac_i,
    output gmii_mac_rx_t mac_o,
    output rgmii_phy_o_t phy_o
);
  // RX Logic
  logic rx_ctl_neg;

  ss_iddr #(
      .WIDTH(5)
  ) ss_iddr_inst (
      .ext_clk_i(phy_i.rx_clk),
      .rst_ni(rst_ni),
      .d_i({rxd, rx_ctl}),
      .clk_o(mac_o.rx_clk),
      .q1_o({mac_o.rxd[3:0], mac_o.rx_dv}),
      .q2_o({mac_o.rxd[7:4], rx_ctl_neg})
  );

  assign mac_o.rx_err = mac_o.rx_dv ^ rx_ctl_neg;

  // TX Logic

endmodule
