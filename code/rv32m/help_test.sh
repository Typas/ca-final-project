#!/usr/bin/env sh

Jupiter_Location="${HOME}/Downloads/Jupiter_3.1/bin/jupiter"
Jupiter_Asm="mul_div_rem.s"
Jupiter_Args="--dump-code"
Jupiter_Text_File="mul_div_rem_text.txt"

Py_Script="mul_div_rem.py"

if [ "$#" -ne 3 ]; then
   echo "usage:"
   echo "./help_test.sh <number 1> <number 2>"
   echo ""
   echo "This would modify the py file and generate the Jupiter obj dump"
   echo "Assuming Jupiter Location"
fi

sed -i -r "s|(n = )-?[0-9]+|\1$1|" "${Py_Script}"
sed -i -r "s|(m = )-?[0-9]+|\1$2|" "${Py_Script}"

sed -i -r "s|(li.*t1, *)-?[0-9]*|\1$1|" "${Jupiter_Asm}"
sed -i -r "s|(li.*t2, *)-?[0-9]*|\1$2|" "${Jupiter_Asm}"

${Jupiter_Location} ${Jupiter_Args} ${Jupiter_Text_File} ${Jupiter_Asm}
python3 ${Py_Script}

# delete two trailing lines
sed -i '$d' ${Jupiter_Text_File}
sed -i '$d' ${Jupiter_Text_File}
# remove "0x"
sed -i -r 's|0x(.*)$|\1|' "${Jupiter_Text_File}"
