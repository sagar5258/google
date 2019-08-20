`define TB_TOP slave_tb
`define RTL_TOP_PATH TB_TOP.S

// Instantiate and connect interfaces which we want to reuse at TOP TB
master_if m_abc_if(clk, rstn);
master_if m_xyz_if(clk, rstn);
  
// ---------------------------------------------------
// Approach 1 : Connect UVC I/F with RTL port directly
// ---------------------------------------------------
  // Direct connection of UVC I/F to RTL port connection
  `define CONNECT(inst_path, if_name, pre) \
    assign ``inst_path``.``pre``_valid = ``if_name``.valid; \
    assign ``inst_path``.``pre``_data  = ``if_name``.data; \
    assign ``if_name``.ready = ``inst_path``.``pre``_ready;

  `CONNECT(`RTL_TOP_PATH, m_abc_if, abc)
  `CONNECT(`RTL_TOP_PATH, m_xyz_if, xyz)

// ---------------------------------------------------
// Approach 2 : Connect UVC I/F with RTL port through local variables
// ---------------------------------------------------
  // Declare local variables
  bit [31:0] data[1:0];
  bit valid [1:0];
  bit ready [1:0];

  // Connection of I/F to local variables
  `define IF_CONNECT(if_name, idx) \
    assign `TB_TOP.valid[idx] = if_name`.valid; \
    assign `TB_TOP.data[idx] = if_name`.data; \
    assign ``if_name``.ready = `TB_TOP.ready[idx];

  // Connection of RTL port to local variables
  `define RTL_CONNECT(inst_path, pre, idx) \
    assign ``inst_path``.``pre``_valid = `TB_TOP.valid[idx]; \
    assign ``inst_path``.``pre``_data  = `TB_TOP.data[idx]; \
    assign `TB_TOP.ready[idx] = inst_path.pre`_ready;

  `IF_CONNECT(m_abc_if, 0);
  `IF_CONNECT(m_xyz_if, 1);
  `RTL_CONNECT(`RTL_TOP_PATH, abc, 0)
  `RTL_CONNECT(`RTL_TOP_PATH, xyz, 1)

