
local current_packet_index = 0
local packet_array_empty = true
local packet_array = {}
local packet_array_size = 0
local tx_packet_count = 0
local rx_packet_count = 0
local pending_message = nil
local sensor_flip_flop = true

local function clear_table(t)
  if type(t)=="table" then
    for i,v in pairs(t) do
      if type(v) == "table" then
        clear_table(v)
      end
      t[i] = nil
    end
  end
  t = nil
  collectgarbage()
  collectgarbage()
end  

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
  msg.checksum = msg.checksum + bit32.rshift(msg.checksum,8)
  msg.checksum = bit32.band(msg.checksum,0xFF)
end

local function init_parse(msg,status)
  msg.checksum = 0
  msg.len = 0
  msg.msgid = 0

  status.current_rx_seq = 0
  status.payload_next_byte = 0
  status.parse_state = 0
end

local function tx_parse(packet,offset,msg,status)
  if status.parse_state == 0 or status.parse_state == 1 then
    if offset == 0 then
      set_sport_packet_byte(packet, offset, 0x00)
      status.parse_state = 2
      update_checksum(msg, 0x00)
    else
      status.parse_state = 1
    end  
  elseif status.parse_state == 2 then
    set_sport_packet_byte(packet, offset, msg.len)
    status.parse_state = 3
    update_checksum(msg, msg.len);
  elseif status.parse_state == 3 then
    set_sport_packet_byte(packet, offset, msg.msgid)
    status.parse_state = 5
    update_checksum(msg, msg.msgid);
  elseif status.parse_state == 5 then
    set_sport_packet_byte(packet, offset, msg.payload[status.payload_next_byte])
    status.parse_state = 6
    update_checksum(msg, msg.payload[status.payload_next_byte])
    status.payload_next_byte=status.payload_next_byte + 1
  elseif status.parse_state == 4 then
    if status.payload_next_byte < msg.len then
      set_sport_packet_byte(packet, offset, msg.payload[status.payload_next_byte])
      status.parse_state = 6
      update_checksum(msg, msg.payload[status.payload_next_byte]);
      status.payload_next_byte=status.payload_next_byte + 1
    else
      set_sport_packet_byte(packet, offset, msg.checksum)
      status.parse_state = 7
    end
  elseif status.parse_state == 6 then
    if offset == 0 then
      status.current_rx_seq = status.current_rx_seq + 1;
      set_sport_packet_byte(packet, offset, status.current_rx_seq)
      status.parse_state = 4
      update_checksum(msg, status.current_rx_seq);
    else
      if status.payload_next_byte < msg.len then
        set_sport_packet_byte(packet, offset, msg.payload[status.payload_next_byte])
        update_checksum(msg, msg.payload[status.payload_next_byte]);
        status.payload_next_byte=status.payload_next_byte + 1
      else
        set_sport_packet_byte(packet, offset, msg.checksum)
        status.parse_state = 7
      end
    end
  elseif status.parse_state == 7 then
  end
end

local function rx_parse(byte,offset,msg,status)
  if status.parse_state == 0 or status.parse_state == 1 then
    if offset == 0 and byte == 0x00 then
      init_parse(msg,status)
      status.parse_state = 2
      update_checksum(msg,byte)
    else
      status.parse_state = 1
    end
  elseif status.parse_state == 2 then
    if offset == 0 and byte == 0x00 then
      init_parse(msg, status)
      status.parse_state = 2
    else
      msg.len = byte
      status.parse_state = 3
    end
    update_checksum(msg, byte)
  elseif status.parse_state == 3 then
    if offset == 0 and byte == 0x00 then
      init_parse(msg, status)
      status.parse_state = 2
    else
      msg.msgid = byte
      status.parse_state = 5
    end
    update_checksum(msg, byte)
  elseif status.parse_state == 5 then
    if offset == 0 and byte == 0x00 then
      init_parse(msg, status)
      status.parse_state = 2
    else
      msg.payload[status.payload_next_byte] = byte
      status.payload_next_byte=status.payload_next_byte + 1
      status.parse_state = 6
    end
    update_checksum(msg, byte)
  elseif status.parse_state == 4 then
    if offset == 0 and byte == 0x00 then
      init_parse(msg, status)
      status.parse_state = 2
      update_checksum(msg, byte)
    else
      if status.payload_next_byte < msg.len then
        msg.payload[status.payload_next_byte] = byte;
        status.payload_next_byte=status.payload_next_byte + 1
        status.parse_state = 6
        update_checksum(msg, byte);
      else
        if msg.checksum == byte then
          status.parse_state = 7
        else
          status.parse_state = 1
        end
      end
    end
  elseif status.parse_state == 6 then
    if offset == 0 then
      if byte == 0x00 then
        init_parse(msg, status)
        status.parse_state = 2
      else
        if bit32.band(byte,0x3F) ~= status.current_rx_seq + 1 then
          status.parse_state = 1
        else
          status.current_rx_seq = bit32.band(byte,0x3F)
          status.parse_state = 4
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
          status.parse_state = 7
        else
          status.parse_state = 1
        end
      end
    end
  elseif status.parse_state == 7 then
    if offset == 0 and byte == 0x00 then
      init_parse(msg, status)
      status.parse_state = 2
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
 
 --print(string.format("set_float:%f ->%01X:%01X:%01X:%01X",value,msg.payload[offset+0],msg.payload[offset+1],msg.payload[offset+2],msg.payload[offset+3]))
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

local function process_sport_rx_data(msg, status, callback, packet)
  rx_packet_count = rx_packet_count + 1
  for offset=0,5
  do
    local byte = get_sport_packet_byte(packet,offset)
    rx_parse(byte,offset,msg,status)
    if status.parse_state == 7 then
      status.parse_state = 0
      callback(msg)
      return
    end
  end
end

local function msg_get_size(msg)
  return 1 + math.ceil((msg.len-2)/5)
end

local function msg_get_packet_array(msg)
  
  local count = 0
  local packet_array = {}
  
  local status = {
    parse_state = 0,
    current_rx_seq = 0,
    payload_next_byte = 0
  }
  
  while (count < 1 + math.ceil((31-2)/5) and status.parse_state ~= 7)
  do
    local packet = {
      data_id = 0x0000,
      value = 0x00000000
    }
    
    for i=0,5
    do
      tx_parse(packet, i, msg, status)
    end
    
    packet_array[count] = {packet.data_id, packet.value}
    count=count+1
  end
  return packet_array
end

-- packet array is zero based
local function queue_packet_array(pkts)
  if packet_array_empty then
    for i=0,#pkts
    do
      packet_array[i] = pkts[i]
    end
    packet_array_empty = false
    packet_array_size = #pkts
    return true
  end
  return false
end

local function queue_message(msg)
  if pending_message == nil then
    pending_message = msg
    return true
  end
  return false
end

local function queue_empty()
  return pending_message == nil
end

local function process_sport_tx_queue(utils, conf)
  local uplink_sensor = 0x0D
  if sportTelemetryPush() then
    if packet_array_empty then
      if pending_message == nil then
        -- send null frame while waiting
        sportTelemetryPush(uplink_sensor, 0x0, 0x0, 0x0)
        return
      else
        local pkts = msg_get_packet_array(pending_message)
        if queue_packet_array(pkts) then
          clear_table(pending_message)
          pending_message = nil
        else
          return
        end
      end
    end
    local success = sportTelemetryPush(uplink_sensor, 0x30, packet_array[current_packet_index][1], packet_array[current_packet_index][2]) 
    if conf.enableDebug == true then
      utils.pushMessage(success and 7 or 3, string.format("TX: %d - %04X:%08X pkts:%d, size:%d", current_packet_index, packet_array[current_packet_index][1], packet_array[current_packet_index][2], tx_packet_count, packet_array_size+1), true)
    end
    if success then
      tx_packet_count = tx_packet_count + 1
      
      -- if last packet is out
      if current_packet_index == packet_array_size then
        packet_array_empty = true
        current_packet_index = 0
        packet_array_size = 0
        return
      end
      
      current_packet_index = current_packet_index + 1
    else
      if conf.enableDebug == true then
        utils.pushMessage(3, string.format("TX: %d/%d - %04X:%08X", current_packet_index, packet_array_size, packet_array[current_packet_index][1], packet_array[current_packet_index][2]), true)
      end
    end
  end
end

local function clear_sport_tx_queue()
  clear_table(pending_message)
  pending_message = nil
  packet_array_empty = true
  current_packet_index = 0
  packet_array_size = 0
end

local function get_tx_packet_count()
  return tx_packet_count
end

local function get_rx_packet_count()
  return rx_packet_count
end

return {
  queue_empty=queue_empty,
  queue_message=queue_message,
  
  process_sport_rx_data=process_sport_rx_data,
  process_sport_tx_queue=process_sport_tx_queue,
  clear_sport_tx_queue=clear_sport_tx_queue,
  
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
  
  get_tx_packet_count=get_tx_packet_count,
  get_rx_packet_count=get_rx_packet_count,
}
