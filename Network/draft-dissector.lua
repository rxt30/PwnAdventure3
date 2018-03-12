PWN3 = Proto ("pwn3-gs", "Pwn Adventure 3 - Game server protocol")


-- FIELDS

local f = PWN3.fields

local opcodes = {
    [0x2a69] = "Fire",
    [0x6d61] = "Update mana"
}

f.opcode = ProtoField.uint16 ("pwn3.opcode", "Action", base.HEX, opcodes)

f.vx = ProtoField.uint32 ("pwn3.vx", "Vector X", base.DEC)
f.vy = ProtoField.uint32 ("pwn3.vy", "Vector Y", base.DEC)
f.vz = ProtoField.uint32 ("pwn3.vz", "Vector Z", base.DEC)

f.mana = ProtoField.uint32 ("pwn3.mana", "Mana", base.DEC)

f.str = ProtoField.string ("pwn3.str", "String")

f.unknown = ProtoField.uint8 ("pwn3.unknown", "Unknown", base.HEX)


-- Create vectors node

function addVectors (vectors, offset, tree)

    local branch

    branch = tree:add (vectors(offset, 12), "Vectors")

    branch:add_le (f.vx, vectors(offset, 4))
    branch:add_le (f.vy, vectors(offset + 4, 4))
    branch:add_le (f.vz, vectors(offset + 8, 4))

end



-- DISSECTOR

function PWN3.dissector (buffer, pinfo, tree)

    local subtree = tree:add (PWN3, buffer())

    local offset = 0

    while (offset < buffer:len()-1) do

        local opcode = buffer(offset, 2):uint()
        offset = offset + 2


        -- Fire
        if (opcode == 0x2a69) then

            local length = buffer(offset, 2):le_uint()
            local branch = subtree:add (buffer(offset-2, 16+length), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            -- String length
            offset = offset + 2

            branch:append_text (", Weapon: " .. buffer(offset, length):string())
            branch:add (f.str, buffer(offset, length))
            offset = offset + length

            addVectors (buffer, offset, branch)
            offset = offset + 12


        -- Update mana
        elseif (opcode == 0x6d61) then

            local branch = subtree:add (buffer(offset-2, 6), opcodes[opcode])

            branch:add (f.opcode, buffer(offset-2, 2))

            branch:append_text (", Mana: " .. buffer(offset, 4):le_uint())
            branch:add_le (f.mana, buffer(offset, 4))
            offset = offset + 4


        -- Not found
        else

            local branch = subtree:add (f.unknown, buffer(offset-2, 1))
            offset = offset - 1

        end
    end
end


tcp_table = DissectorTable.get ("tcp.port")
tcp_table:add (3000, PWN3)
tcp_table:add (3001, PWN3)
tcp_table:add (3002, PWN3)
tcp_table:add (3003, PWN3)
