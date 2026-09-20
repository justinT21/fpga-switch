import interfaces::*;

module rgmii_phy_if (
    input rgmii_phy_i_t phy_i,
    input speed_t phy_speed_i,
    input rst_ni,
    input clk_i,
    input gmii_mac_tx_t mac_i,
    output logic mac_clk_en_o,
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
      .d_i({phy_i.rxd, phy_i.rx_ctl}),
      .clk_o(mac_o.rx_clk),
      .q1_o({mac_o.rxd[3:0], mac_o.rx_dv}),
      .q2_o({mac_o.rxd[7:4], rx_ctl_neg})
  );

  assign mac_o.rx_err = mac_o.rx_dv ^ rx_ctl_neg;

  // TX Logic
  logic [5:0] clk_div_cnt;
  logic tx_ctl_pos, tx_ctl_neg, tx_clk_pos, tx_clk_neg;
  logic [3:0] txd_pos, txd_neg;

  always_ff @(posedge clk_i or negedge rst_ni) begin : blockName
    if (!rst_ni) begin
      clk_div_cnt  <= '0;
      tx_clk_pos   <= 1'b0;
      tx_clk_neg   <= 1'b0;
      mac_clk_en_o <= 1'b0;
    end else begin
      clk_div_cnt  <= clk_div_cnt + 1;
      tx_clk_pos   <= tx_clk_neg;
      mac_clk_en_o <= 1'b0;
      unique case (phy_speed_i)
        M_10: begin
          if (clk_div_cnt == 6'd24) begin
            tx_clk_neg <= 1'b1;
          end else if (clk_div_cnt >= 6'd49) begin
            tx_clk_neg   <= 1'b0;
            mac_clk_en_o <= 1'b1;
            clk_div_cnt  <= '0;
          end
        end
        M_100: begin
          if (clk_div_cnt == 6'd2) begin
            tx_clk_pos <= 1'b1;
            tx_clk_neg <= 1'b1;
          end else if (clk_div_cnt >= 6'd4) begin
            tx_clk_neg   <= 1'b0;
            mac_clk_en_o <= 1'b1;
            clk_div_cnt  <= '0;
          end
        end
        M_1000: begin
          clk_div_cnt  <= '0;
          tx_clk_pos   <= 1'b1;
          tx_clk_neg   <= 1'b0;
          mac_clk_en_o <= 1'b1;
        end
      endcase
    end
  end

  assign tx_ctl_pos = (tx_clk_pos == 1'b1) ? mac_i.tx_en : mac_i.tx_en ^ mac_i.tx_err;
  assign tx_ctl_neg = (tx_clk_neg == 1'b1) ? mac_i.tx_en : mac_i.tx_en ^ mac_i.tx_err;

  assign txd_pos = (tx_clk_pos == 1'b1 || phy_speed_i != M_1000) ? mac_i.txd[3:0] : mac_i.txd[7:4];
  assign txd_neg = (tx_clk_neg == 1'b1 || phy_speed_i != M_1000) ? mac_i.txd[3:0] : mac_i.txd[7:4];

  oddr #(
      .WIDTH(1)
  ) oddr_clk (
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .d1_i(tx_clk_pos),
      .d2_i(tx_clk_neg),
      .q_o(phy_o.tx_clk)
  );

  oddr #(
      .WIDTH(5)
  ) oddr_data (
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .d1_i({txd_pos, tx_ctl_pos}),
      .d2_i({txd_neg, tx_ctl_neg}),
      .q_o({phy_o.txd, phy_o.tx_ctl})
  );
endmodule
