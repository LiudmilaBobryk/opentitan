// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

typedef enum bit [2:0] {PktTypeSoF, PktTypeToken, PktTypeData, PktTypeHandshake} pkt_type_e;
typedef enum bit [7:0] {PidTypeOutToken=8'b11100001, PidTypeInToken=8'b01101001,
  PidTypeSofToken=8'b10100101, PidTypeSetupToken=8'b00101101, PidTypeData0=8'b11000011,
  PidData1=8'b01001011, PidTypeData2=8'b10000111, PidTypeMData=8'b00001111,
  PidTypeAck=8'b11010010, PidTypeNak=8'b01011010, PidTypeStall=8'b00011110,
  PidTypeNyet=8'b10010110} pid_type_e;

virtual class usb20_item extends uvm_sequence_item;
  pid_type_e m_pid_type;
  pkt_type_e m_pkt_type;

  `uvm_object_new
endclass

class token_pkt extends usb20_item;

  rand bit [6:0] address;
  rand bit [3:0] endpoint;
  bit [4:0] crc5;

  constraint endpoint_c{
    endpoint inside {[0:11]};
  }

  `uvm_object_utils_begin (token_pkt)
    `uvm_field_int(crc5,                     UVM_DEFAULT)
    `uvm_field_int(endpoint,                 UVM_DEFAULT)
    `uvm_field_int(address,                  UVM_DEFAULT)
    `uvm_field_enum(pid_type_e, m_pid_type,    UVM_DEFAULT)
  `uvm_object_utils_end

  `uvm_object_new

  function void post_randomize();
    crc5 = generate_crc5(address,endpoint);
  endfunction
  function bit [4:0] generate_crc5(bit [6:0] address,bit [3:0] endpoint);
    bit [4:0] crc;
    bit [4:0] crc_reg;
    bit [10:0] data;
    bit [4:0] polynomial = 5'b0_0101;
    bit       as1;
    bit [4:0] as2;
    data = {endpoint,address};
    crc_reg = 5'b1_1111;
    for (int i = 0; i <= 10; i++) begin
      as1 = data[i] ^ crc_reg[4];
      as2 = ({crc_reg[3:2], (as1^crc_reg[1]),crc_reg[0],as1});
      crc_reg = as2;
    end
    crc = ~{crc_reg[0],crc_reg[1],crc_reg[2],crc_reg[3],crc_reg[4]};
    return crc;
  endfunction
endclass

class data_pkt extends usb20_item;
  // TODO: Sequence item for data packet
  `uvm_object_utils_begin (data_pkt)
  `uvm_object_utils_end

  `uvm_object_new

endclass

class sof_pkt extends usb20_item;
  // TODO: Sequence item for sof packet
  `uvm_object_utils_begin (sof_pkt)
  `uvm_object_utils_end

  `uvm_object_new

endclass

class handshake_pkt extends usb20_item;
  // TODO: Sequence item for handshake packet

  `uvm_object_utils_begin (handshake_pkt)
  `uvm_object_utils_end

  `uvm_object_new
endclass
