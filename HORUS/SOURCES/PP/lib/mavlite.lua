#include "includes/mavlite_inc.lua"

local utils = ...

local function clearTable(t)
  if type(t)=="table" then
    for i,v in pairs(t) do
      if type(v) == "table" then
        clearTable(v)
      end
      t[i] = nil
    end
  end
  t = nil
  collectgarbage()
  collectgarbage()
end  

---------------------------
-- circular buffer support
---------------------------
local cbuffer_lib = {}

cbuffer_lib.init = function(cbuf)
  clearTable(cbuf)
  cbuf.buffer = {}
  cbuf.head = 0
  cbuf.tail = 0
  cbuf.max = SPORT_BUFFER_SIZE
  cbuf.full = false
  collectgarbage()
  collectgarbage()
  end

cbuffer_lib.size = function(cbuf)
  if cbuf.full == false then
    if cbuf.head >= cbuf.tail then
      return cbuf.head - cbuf.tail
    else
      return cbuf.max + cbuf.head - cbuf.tail
    end
  end
  return cbuf.max
end

cbuffer_lib.available = function(cbuf)
  if cbuf.full == false then
    if cbuf.head >= cbuf.tail then
      return cbuf.max - cbuf.head + cbuf.tail
    else
      return cbuf.tail - cbuf.head
    end
  end
  return 0
end

cbuffer_lib.empty = function(cbuf)
  return cbuf.full == false and cbuf.head == cbuf.tail
end

cbuffer_lib.push = function(cbuf,value)
  -- set value
  cbuf.buffer[cbuf.head] = value
  -- advance pointer
  if cbuf.full == true then
    cbuf.tail = (cbuf.tail+1)%cbuf.max
  end
  cbuf.head = (cbuf.head+1)%cbuf.max
  cbuf.full = cbuf.head == cbuf.tail
  collectgarbage()
  collectgarbage()
end

cbuffer_lib.pop = function(cbuf)
  if cbuffer_lib.empty(cbuf) == false then
      -- get value
      local value = cbuf.buffer[cbuf.tail]
      cbuf.buffer[cbuf.tail] = nil
      -- retreat pointer
      cbuf.full = false
      cbuf.tail = (cbuf.tail + 1) % cbuf.max
      collectgarbage()
      collectgarbage()
      return value
  end
  return nil
end

cbuffer_lib.peek = function(cbuf)
  if cbuffer_lib.empty(cbuf) == false then
      -- get value
      return cbuf.buffer[cbuf.tail]
  end
  return nil
end

local sport_tx_buffer = {}

cbuffer_lib.init(sport_tx_buffer)

--[[
  Note: some code from François Perrad's lua-MessagePack
  
  This function packs a lua number into a 4 bytes
  single precision IEEE 754 floating point representation
--]]
local function pack_float(n)
    if n == 0.0 then return 0.0 end

    local sign = 0
    if n < 0.0 then
        sign = 0x80
        n = -n
    end

    local mant, expo = math.frexp(n)
    local dword = 0x00000000

    if mant ~= mant then
        dword = 0xFF880000
    elseif mant == math.huge or expo > 0x80 then
        if sign == 0 then
            dword = 0x7F800000
        else
            dword = 0xFF800000
        end
    elseif (mant == 0.0 and expo == 0) or expo < -0x7E then
        dword = bit32.replace(dword,sign,24,8)
    else
        expo = expo + 0x7E
        mant = (mant * 2.0 - 1.0) * math.ldexp(0.5, 24)
        -- match STM32 endianess       
        dword = bit32.replace(dword,sign + math.floor(expo / 0x2),0,8)
        dword = bit32.replace(dword,(expo % 0x2) * 0x80 + math.floor(mant / 0x10000),8,8)
        dword = bit32.replace(dword,math.floor(mant / 0x100) % 0x100,16,8)
        dword = bit32.replace(dword,mant % 0x100,24,8)
    end
    
    return dword
end

--[[
  Note: some code from François Perrad's lua-MessagePack
  
  This function unpacks a 
  4 bytes single precision IEEE 754 floating point representation
  into a lua double
--]]
local function unpack_float(dword)
    if dword == 0 then return 0.0 end
     -- match STM32 endianess
    local b1 = bit32.extract(dword,0,8)
    local b2 = bit32.extract(dword,8,8)
    local b3 = bit32.extract(dword,16,8)
    local b4 = bit32.extract(dword,24,8)
    
    local sign = b1 > 0x7F
    local expo = (b1 % 0x80) * 0x2 + math.floor(b2 / 0x80)
    local mant = ((b2 % 0x80) * 0x100 + b3) * 0x100 + b4

    if sign then
        sign = -1
    else
        sign = 1
    end

    local n

    if mant == 0 and expo == 0 then
        n = sign * 0.0
    elseif expo == 0xFF then
        if mant == 0 then
            n = sign * math.huge
        else
            n = 0.0/0.0
        end
    else
        n = sign * math.ldexp(1.0 + mant / 0x800000, expo - 0x7F)
    end

    return n
end

local function get_sport_packet_byte(packet,offset)
  if offset < 2 then
    return bit32.extract(packet.data_id,8*offset,8)
  else
    return bit32.extract(packet.value,8*(offset-2),8)
  end
end

local function set_sport_packet_byte(packet,offset,value)
  if offset < 2 then
    packet.data_id = bit32.replace(packet.data_id,value,8*offset,8)
  else
    packet.value = bit32.replace(packet.value,value,8*(offset-2),8)
  end
end

local function update_checksum(msg,byte)
  msg.checksum = msg.checksum + byte -- 0-1FF
  msg.checksum = msg.checksum + bit32.lshift(msg.checksum,8)
  msg.checksum = bit32.band(msg.checksum,0xFF)
end

local function init_parse(msg,status)
  msg.checksum = 0
  msg.len = 0
  msg.msgid = 0

  status.current_rx_seq = 0
  status.payload_next_byte = 0
  status.parse_state = PARSE_STATE_IDLE
end

local function tx_parse(packet,offset,msg,status)
  if status.parse_state == PARSE_STATE_IDLE or status.parse_state == PARSE_STATE_ERROR then
    if offset == 0 then
      set_sport_packet_byte(packet, offset, 0x00)
      status.parse_state = PARSE_STATE_GOT_START
      update_checksum(msg, 0x00)
    else
      status.parse_state = PARSE_STATE_ERROR
    end  
  elseif status.parse_state == PARSE_STATE_GOT_START then
    set_sport_packet_byte(packet, offset, msg.len)
    status.parse_state = PARSE_STATE_GOT_LEN
    update_checksum(msg, msg.len);
  elseif status.parse_state == PARSE_STATE_GOT_LEN then
    set_sport_packet_byte(packet, offset, msg.msgid)
    status.parse_state = PARSE_STATE_GOT_MSGID
    update_checksum(msg, msg.msgid);
  elseif status.parse_state == PARSE_STATE_GOT_MSGID then
    set_sport_packet_byte(packet, offset, msg.payload[status.payload_next_byte])
    status.parse_state = PARSE_STATE_GOT_PAYLOAD
    update_checksum(msg, msg.payload[status.payload_next_byte])
    status.payload_next_byte=status.payload_next_byte + 1
  elseif status.parse_state == PARSE_STATE_GOT_SEQ then
    if status.payload_next_byte < msg.len then
      set_sport_packet_byte(packet, offset, msg.payload[status.payload_next_byte])
      status.parse_state = PARSE_STATE_GOT_PAYLOAD
      update_checksum(msg, msg.payload[status.payload_next_byte]);
      status.payload_next_byte=status.payload_next_byte + 1
    else
      set_sport_packet_byte(packet, offset, msg.checksum)
      status.parse_state = PARSE_STATE_MESSAGE_RECEIVED
    end
  elseif status.parse_state == PARSE_STATE_GOT_PAYLOAD then
    if offset == 0 then
      status.current_rx_seq = status.current_rx_seq + 1;
      set_sport_packet_byte(packet, offset, status.current_rx_seq)
      status.parse_state = PARSE_STATE_GOT_SEQ
      update_checksum(msg, status.current_rx_seq);
    else
      if status.payload_next_byte < msg.len then
        set_sport_packet_byte(packet, offset, msg.payload[status.payload_next_byte])
        update_checksum(msg, msg.payload[status.payload_next_byte]);
        status.payload_next_byte=status.payload_next_byte + 1
      else
        set_sport_packet_byte(packet, offset, msg.checksum)
        status.parse_state = PARSE_STATE_MESSAGE_RECEIVED
      end
    end
  elseif status.parse_state == PARSE_STATE_MESSAGE_RECEIVED then
  end
end

local function rx_parse(byte,offset,msg,status)
  if status.parse_state == PARSE_STATE_IDLE or status.parse_state == PARSE_STATE_ERROR then
    if offset == 0 and byte == 0x00 then
      init_parse(msg,status)
      status.parse_state = PARSE_STATE_GOT_START
      update_checksum(msg,byte)
    else
      status.parse_state = PARSE_STATE_ERROR
    end
  elseif status.parse_state == PARSE_STATE_GOT_START then
    if offset == 0 and byte == 0x00 then
      init_parse(msg, status)
      status.parse_state = PARSE_STATE_GOT_START
    else
      msg.len = byte
      status.parse_state = PARSE_STATE_GOT_LEN
    end
    update_checksum(msg, byte)
  elseif status.parse_state == PARSE_STATE_GOT_LEN then
    if offset == 0 and byte == 0x00 then
      init_parse(msg, status)
      status.parse_state = PARSE_STATE_GOT_START
    else
      msg.msgid = byte
      status.parse_state = PARSE_STATE_GOT_MSGID
    end
    update_checksum(msg, byte)
  elseif status.parse_state == PARSE_STATE_GOT_MSGID then
    if offset == 0 and byte == 0x00 then
      init_parse(msg, status)
      status.parse_state = PARSE_STATE_GOT_START
    else
      msg.payload[status.payload_next_byte] = byte
      status.payload_next_byte=status.payload_next_byte + 1
      status.parse_state = PARSE_STATE_GOT_PAYLOAD
    end
    update_checksum(msg, byte)
  elseif status.parse_state == PARSE_STATE_GOT_SEQ then
    if offset == 0 and byte == 0x00 then
      init_parse(msg, status)
      status.parse_state = PARSE_STATE_GOT_START
      update_checksum(msg, byte)
    else
      if status.payload_next_byte < msg.len then
        msg.payload[status.payload_next_byte] = byte;
        status.payload_next_byte=status.payload_next_byte + 1
        status.parse_state = PARSE_STATE_GOT_PAYLOAD
        update_checksum(msg, byte);
      else
        if msg.checksum == byte then
          status.parse_state = PARSE_STATE_MESSAGE_RECEIVED
        else
          status.parse_state = PARSE_STATE_ERROR
        end
      end
    end
  elseif status.parse_state == PARSE_STATE_GOT_PAYLOAD then
    if offset == 0 then
      if byte == 0x00 then
        init_parse(msg, status)
        status.parse_state = PARSE_STATE_GOT_START
      else
        if bit32.band(byte,0x3F) ~= status.current_rx_seq + 1 then
          status.parse_state = PARSE_STATE_ERROR
        else
          status.current_rx_seq = bit32.band(byte,0x3F)
          status.parse_state = PARSE_STATE_GOT_SEQ
        end
      end
      update_checksum(msg, byte)
    else
      if status.payload_next_byte < msg.len then
        msg.payload[status.payload_next_byte] = byte;
        status.payload_next_byte=status.payload_next_byte + 1
        update_checksum(msg, byte);
      else
        if msg.checksum == byte then
          status.parse_state = PARSE_STATE_MESSAGE_RECEIVED
        else
          status.parse_state = PARSE_STATE_ERROR
        end
      end
    end
  elseif status.parse_state == PARSE_STATE_MESSAGE_RECEIVED then
    if offset == 0 and byte == 0x00 then
      init_parse(msg, status)
      status.parse_state = PARSE_STATE_GOT_START
      update_checksum(msg, byte)
    end
  end
end

local function msg_get_string(msg,offset)
  local name = ""
  for i=0, msg.len-(offset+1)
  do
    name = name .. string.char(msg.payload[i+offset])
  end
  collectgarbage()
  collectgarbage()
  return name
end

local function msg_set_string(msg,name,offset)
  for i = 1, math.min(16,#name) do
      local c = string.sub(name,i,i)
      msg.payload[offset + (i-1)] = string.byte(c) -- payload is zero based
  end 
  msg.len = msg.len + math.min(16,#name)
  collectgarbage()
  collectgarbage()
end

local function msg_get_float(msg,offset)
 local dword = 0x00000000
 
 dword = bit32.replace(dword,msg.payload[offset+0],24,8)
 dword = bit32.replace(dword,msg.payload[offset+1],16,8)
 dword = bit32.replace(dword,msg.payload[offset+2],8,8)
 dword = bit32.replace(dword,msg.payload[offset+3],0,8)
 
 return unpack_float(dword)
end

local function msg_set_float(msg,value,offset)
 local dword = pack_float(value)
 
 msg.payload[offset+0] = bit32.extract(dword,24,8)
 msg.payload[offset+1] = bit32.extract(dword,16,8)
 msg.payload[offset+2] = bit32.extract(dword,8,8)
 msg.payload[offset+3] = bit32.extract(dword,0,8)
 
 msg.len = msg.len + 4
end

local function msg_get_uint16(msg,offset)
 local uint16 = 0x0000
 
 uint16 = bit32.replace(uint16,msg.payload[offset+0],0,8)
 uint16 = bit32.replace(uint16,msg.payload[offset+1],8,8)
 
 return uint16
end

local function msg_set_uint16(msg,value,offset)
 msg.payload[offset+0] = bit32.extract(value,0,8)
 msg.payload[offset+1] = bit32.extract(value,8,8)
 
 msg.len = msg.len + 2
end

local function msg_get_uint8(msg,offset)
 return msg.payload[offset]
end

local function msg_set_uint8(msg,value,offset)
 msg.payload[offset+0] = bit32.extract(value,0,8)
 msg.len = msg.len + 1
end

local function bit8_pack(value,bit_value,bit_count,bit_offset)
  return bit32.extract(bit32.replace(value,bit_value,bit_offset,bit_count),0,8)
end

local function bit8_unpack(value,bit_count,bit_offset)
  return bit32.extract(bit32.extract(value,bit_offset,bit_count),0,8)
end

local function process_sport_rx_data(msg,status,callback,packet)
  for offset=0,5
  do
    local byte = get_sport_packet_byte(packet,offset)
    rx_parse(byte,offset,msg,status)
    if status.parse_state == PARSE_STATE_MESSAGE_RECEIVED then
      status.parse_state = PARSE_STATE_IDLE
      callback(msg)
      return
    end
  end
end

local function process_sport_tx_queue(utils)
  -- keep an active heartbeat by sending 1 empty frame
  -- this keeps the polling for SPORT_UPLINK_SENSOR_ID tight
  if cbuffer_lib.empty(sport_tx_buffer) == true then
    sportTelemetryPush(SPORT_UPLINK_SENSOR_ID, 0x0, 0x0, 0x0)
    return
  end
  -- queue is not empty, send up to 10 frames
  local count = 0
  while cbuffer_lib.empty(sport_tx_buffer) == false and count < 10
  do
    local packet = cbuffer_lib.peek(sport_tx_buffer)
    if sportTelemetryPush(SPORT_UPLINK_SENSOR_ID, SPORT_UPLINK_FRAME, packet.data_id, packet.value) then
      cbuffer_lib.pop(sport_tx_buffer)
    end
    count = count + 1
  end
end

local function msg_get_size(msg)
  return 1 + math.ceil((msg.len-2)/5)
end

local function msg_send_ready(msg)
  return cbuffer_lib.available(sport_tx_buffer) >= msg_get_size(msg)
end

local function msg_send(msg,utils)
  -- cannot send if last message still pending
  if cbuffer_lib.available(sport_tx_buffer) < msg_get_size(msg) then
    return false
  end
  
  local count = 0

  local status = {
    parse_state = PARSE_STATE_IDLE,
    current_rx_seq = 0,
    payload_next_byte = 0
  }

  while (count < 1 + math.ceil((MAVLITE_MAX_PAYLOAD_LEN-2)/5) and status.parse_state ~= PARSE_STATE_MESSAGE_RECEIVED)
  do
    -- no need to queue sensor_id and frame_id
    local packet = {
      data_id = 0x0000,
      value = 0x00000000
    }
    
    for i=0,5
    do
      tx_parse(packet,i, msg, status)
    end
    
    cbuffer_lib.push(sport_tx_buffer,packet)
#ifdef DEBUG_SPORT
    utils.pushMessage(7,string.format("%d - %02X:%02X:%04X:%08X",count+1,SPORT_UPLINK_SENSOR_ID,SPORT_UPLINK_FRAME,packet.data_id,packet.value),true)
    --print(string.format("%d - %02X:%02X:%04X:%08X",count+1,SPORT_UPLINK_SENSOR_ID,SPORT_UPLINK_FRAME,packet.data_id,packet.value))
#endif
    count=count+1
  end
  clearTable(status)
  status=nil
  
  collectgarbage()
  collectgarbage()
  
  return true
end

local function msg_send_test()
  -- cannot send if last message still pending
  if cbuffer_lib.empty(sport_tx_buffer) == false then
    return false
  end
  
  local packet1 = {
    data_id = 0x0000,
    value = 0x00000000
  }

  packet1.data_id = bit32.replace(packet1.data_id,0x00,8,8) -- seq
  packet1.data_id = bit32.replace(packet1.data_id,0x08,0,8) -- payload len
  packet1.value = bit32.replace(packet1.value,0xFF,24,8) -- msgid
  packet1.value = bit32.replace(packet1.value,0x00,16,8) -- pay[0]
  packet1.value = bit32.replace(packet1.value,0x00,8,8) -- pay[1]
  packet1.value = bit32.replace(packet1.value,0x00,0,8) -- pay[2]
  
  cbuffer_lib.push(sport_tx_buffer,packet1)
  
  
  local packet2 = {
    data_id = 0x0000,
    value = 0x00000000
  }
  
  packet2.data_id = bit32.replace(packet2.data_id,0x01,8,8) -- seq
  packet2.data_id = bit32.replace(packet2.data_id,0x00,0,8) -- pay[4]
  packet2.value = bit32.replace(packet2.value,string.byte("A"),24,8) -- pay[5]
  packet2.value = bit32.replace(packet2.value,string.byte("L"),16,8) -- pay[6]
  packet2.value = bit32.replace(packet2.value,string.byte("E"),8,8) -- pay[7]
  packet2.value = bit32.replace(packet2.value,string.byte("X"),0,8) -- pay[8]

  cbuffer_lib.push(sport_tx_buffer,packet2)

  local packet3 = {
    data_id = 0x0000,
    value = 0x00000000
  }
  
  packet3.data_id = bit32.replace(packet3.data_id,0x02,8,8) -- seq
  packet3.data_id = bit32.replace(packet3.data_id,0xFF,0,8) -- CRC
  packet3.value = 0x00000000

  cbuffer_lib.push(sport_tx_buffer,packet3)
  
  return true
end
local function clear_tx_queue()
  cbuffer_lib.init(sport_tx_buffer)
end

return {
  process_sport_rx_data=process_sport_rx_data,
  process_sport_tx_queue=process_sport_tx_queue,
  
  msg_send=msg_send,
  msg_send_ready=msg_send_ready,
  msg_send_test=msg_send_test,
  
  msg_get_string=msg_get_string,
  msg_get_float=msg_get_float,
  msg_get_uint16=msg_get_uint16,
  msg_get_uint8=msg_get_uint8,
  
  msg_set_string=msg_set_string,
  msg_set_float=msg_set_float,
  msg_set_uint16=msg_set_uint16,
  msg_set_uint8=msg_set_uint8,
  
  bit8_pack=bit8_pack,
  bit8_unpack=bit8_unpack,
  clear_tx_queue=clear_tx_queue
}