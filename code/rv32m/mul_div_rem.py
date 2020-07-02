import math

def rv32_div(n,m):
    return n//m;

def rv32_mul(n,m):
    return n*m;

def rv32_rem(n,m):
    return n%m;

def rv32_remu(n,m):
    return abs(n)%abs(m);

def rv32_divu(n,m):
    return abs(n)//abs(m);

def to_hex(num):
    return format(num if num >= 0 else (1 << 32) + num, '08x')

if __name__ == '__main__':
    # Modify your test pattern here
    n = 83
    m = -9

    with open('mul_div_rem_data.txt', 'w') as f_data:
        f_data.write('{:0>8x}\n'.format(10))

    with open('mul_div_rem_ans.txt', 'w') as f_ans:
        f_ans.write('{}\n'.format(to_hex(rv32_mul(n,m))))
        f_ans.write('{}\n'.format(to_hex(rv32_div(n,m))))
        f_ans.write('{}\n'.format(to_hex(rv32_divu(n,m))))
        f_ans.write('{}\n'.format(to_hex(rv32_rem(n,m))))
        f_ans.write('{}\n'.format(to_hex(rv32_remu(n,m))))
