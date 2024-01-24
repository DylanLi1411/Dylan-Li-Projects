# Authors: Dylan Li and Alec Lempert

def int_to_unsigned_binary(value, num_bits):
    # Ensure the value fits within the specified number of bits
    value &= (1 << num_bits) - 1

    # Use format to convert to binary with a specified width
    binary_representation = format(value, f'0{num_bits}b')

    return binary_representation


def Convert2Bin(line, filewrite, line_num):
    name = line.split(' ')[0]   # separate the line from the instruction name here

    if name == "li":
        bin_instruction = LI(line, line_num)
    elif name in ("simals", "simahs", "simsls", "simshs", "slmals", "slmahs", "slmsls", "slmshs"):
        bin_instruction = R4(line, line_num)
    elif name in ("shrhi", "au", "cnth", "ahs", "or", "bcw", "maxws", "minws", "mlhu", "mlhss", "and", "invb", "rotw", "sfwu", "sfhs"):
        bin_instruction = R3(line, line_num)
    elif name == "nop":     # special case handling for nop
        bin_instruction = "1100000000000000000000000"
    else:
        print("Invalid Instruction at line " + str(line_num) + ".")
        exit()

    if line_num != 64:
        filewrite.write(bin_instruction + '\n')
    else:
        filewrite.write(bin_instruction)


# li rd 0-7 immed(unsigned integer)
def LI(line, line_num):
    format = line.split(' ')      #split into parts
    load_index = int(format[2].replace(',', ""))
    immed = int(format[3])
    rd = int((format[1].replace('$', "")).replace(',', ""))

    # Check for errors
    if load_index > 7 or load_index < 0:
        print("Invalid Instruction at line " + str(line_num) + ".")
        exit()
    if immed > (2**16 - 1) or immed < 0:
        print("Invalid Instruction at line " + str(line_num) + ".")
        exit()
    if rd > 31 or rd < 0:
        print("Invalid Instruction at line " + str(line_num) + ".")
        exit()

    # Convert to binary string
    load_index_b = int_to_unsigned_binary(load_index, 3)
    immed_b = int_to_unsigned_binary(immed, 16)
    rd_b = int_to_unsigned_binary(rd, 5)

    return '0' + load_index_b + immed_b + rd_b

# name rd rs1 rs2 rs3
def R4(line, line_num):
    format = line.split(' ')      #split into parts
    name = format[0]
    rd = int((format[1].replace('$', "")).replace(',', ""))
    rs1 = int((format[2].replace('$', "")).replace(',', ""))
    rs2 = int((format[3].replace('$', "")).replace(',', ""))
    rs3 = int(format[4].replace('$', ""))

    # Check for errors
    if rd > 31 or rd < 0:
        print("Invalid Instruction at line " + str(line_num) + ".")
        exit()
    if rs1 > 31 or rs1 < 0:
        print("Invalid Instruction at line " + str(line_num) + ".")
        exit()
    if rs2 > 31 or rs2 < 0:
        print("Invalid Instruction at line " + str(line_num) + ".")
        exit()
    if rs3 > 31 or rs3 < 0:
        print("Invalid Instruction at line " + str(line_num) + ".")
        exit()

    # Convert to binary string
    match name:
        case "simals": opcode_b = "000"
        case "simahs": opcode_b = "001"
        case "simsls": opcode_b = "010"
        case "simshs": opcode_b = "011"
        case "slmals": opcode_b = "100"
        case "slmahs": opcode_b = "101"
        case "slmsls": opcode_b = "110"
        case "slmshs": opcode_b = "111"
        case _: print("Invalid Instruction at line " + str(line_num) + "."); exit()
    rd_b = int_to_unsigned_binary(rd, 5)
    rs1_b = int_to_unsigned_binary(rs1, 5)
    rs2_b = int_to_unsigned_binary(rs2, 5)
    rs3_b = int_to_unsigned_binary(rs3, 5)

    return "10" + opcode_b + rs3_b + rs2_b + rs1_b + rd_b

# name rd rs1 rs2   or
# name rd rs1 immed/0
# does not include nop
def R3(line, line_num):
    format = line.split(' ')      #split into parts
    name = format[0]
    rd = int((format[1].replace('$', "")).replace(',', ""))
    rs1 = int((format[2].replace('$', "")).replace(',', ""))
    rs2 = int(format[3].replace('$', ""))

    # Check for errors
    if rd > 31 or rd < 0:
        print("Invalid Instruction at line " + str(line_num) + ".")
        exit()
    if rs1 > 31 or rs1 < 0:
        print("Invalid Instruction at line " + str(line_num) + ".")
        exit()
    if rs2 > 31 or rs2 < 0:
        print("Invalid Instruction at line " + str(line_num) + ".")
        exit()

    # Convert to binary string
    match name:
        case "shrhi": opcode_b = "0001"
        case "au": opcode_b = "0010"
        case "cnth": opcode_b = "0011"
        case "ahs": opcode_b = "0100"
        case "or": opcode_b = "0101"
        case "bcw": opcode_b = "0110"
        case "maxws": opcode_b = "0111"
        case "minws": opcode_b = "1000"
        case "mlhu": opcode_b = "1001"
        case "mlhss": opcode_b = "1010"
        case "and": opcode_b = "1011"
        case "invb": opcode_b = "1100"
        case "rotw": opcode_b = "1101"
        case "sfwu": opcode_b = "1110"
        case "sfhs": opcode_b = "1111"
        case _: print("Invalid Instruction at line " + str(line_num) + "."); exit()
    rd_b = int_to_unsigned_binary(rd, 5)
    rs1_b = int_to_unsigned_binary(rs1, 5)
    rs2_b = int_to_unsigned_binary(rs2, 5)

    return "110000" + opcode_b + rs2_b + rs1_b + rd_b


# Main
fileread = open('Assembly_Instructions.txt', 'r')
filewrite = open('Binary_Instructions.txt', 'w')
i = 1
for line in fileread:
    line = line.strip()         #remove the newline char
    Convert2Bin(line, filewrite, i)
    i = i + 1
fileread.close()
filewrite.close()