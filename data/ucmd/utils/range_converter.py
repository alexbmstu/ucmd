import re
import sys

def convert_text_file(input_filename, output_filename):
    try:
        with open(input_filename, 'r') as infile, open(output_filename, 'w') as outfile:
            for line_num, line in enumerate(infile):
                line = re.sub(r'([ \t\r]+)([;&)()])([ \t\r]+)', r'\2', line) # Удаляет пробелы вокруг ; & ( )
                line = replace_s_strings_with_binary(line)
                line = replace_h_strings_with_binary(line)
                line = re.sub(r'(\w+)\<(\d+):(\d+)\>(?:="(.+?)")?(?=[;&)])', lambda match: convert_range(match, line, line_num), line)
                line = re.sub(r'<(\d+)>', r'\1', line) # Удаляет <>
                line = re.sub(r'(&)', r' \1 ', line) # Удаляет <>
                line = re.sub(r'(;)', r'\1 ', line) # Удаляет <>
                outfile.write(line)
    except FileNotFoundError:
        print(f"Ошибка: Файл '{input_filename}' не найден.")
    except Exception as e:
        print(f"Произошла непредвиденная ошибка: {e}")

def replace_s_strings_with_binary(line):
    # Функция для замены содержимого s"" на двоичное представление
    def replace_match(match):
        # Получаем содержимое внутри s""
        content = match.group(1)
        # Преобразуем каждый символ содержимого в двоичное ASCII-значение
        binary_value = ''.join(format(ord(char), '08b') for char in content)
        return f'"{binary_value}"'  # Убираем символ 's'

    # Регулярное выражение для поиска конструкций s"..."
    pattern = re.compile(r's"([^"]*)"')
    # Заменяем все найденные конструкции с помощью функции replace_match
    result = pattern.sub(replace_match, line)
    return result

def replace_h_strings_with_binary(line):
    # Функция для замены содержимого Nh"..." на двоичное представление
    def replace_match(match):
        # Извлекаем количество двоичных цифр
        binary_length = int(match.group(1))
        # Получаем содержимое внутри h""
        hex_content = match.group(2)
        # Преобразуем шестнадцатеричное значение в двоичное представление
        binary_value = ''.join(f"{int(char, 16):04b}" for char in hex_content)
        # Обрезаем двоичное значение до указанной длины
        if binary_length < len(binary_value):
            binary_value = binary_value[-binary_length:]  # Оставляем младшие биты
        else:
            binary_value = binary_value.zfill(binary_length)  # Дополняем нулями, если длина меньше
        return f'"{binary_value}"'  # Возвращаем двоичное значение в кавычках

    # Регулярное выражение для поиска конструкций Nh"..."
    pattern = re.compile(r'(\d+)h"([0-9A-Fa-f]+)"')
    # Заменяем все найденные конструкции с помощью функции replace_match
    result = pattern.sub(replace_match, line)
    return result

    
def convert_range(match, line, line_num):
    name = match.group(1)
    start = int(match.group(2))
    end = int(match.group(3))
    if (start<end): 
        reverse = True
    else:
        reverse = False
    value = match.group(4)
    sep = ';' if line[match.end():match.end()+1] == ';' else '&'
    if value:
        if len(value) != start - end + 1:
            raise ValueError(f"Длина значения '{value}' не соответствует диапазону, строка {line_num+1}")
        if not(reverse):
            for i in range(start, end-1, -1):
                if (value[start - i] != "0" and  value[start - i] != "1"):
                    raise ValueError(f"Значение '{value}' не является бинарным, строка {line_num+1}")
            converted_parts = [f"{name}{i}={value[start - i]}" for i in range(start, end - 1, -1)]
        else:
            for i in range(start, end+1, +1):
                if (value[start + i] != "0" and  value[start + i] != "1"):
                    raise ValueError(f"Значение '{value}' не является бинарным, строка {line_num+1}")
            converted_parts = [f"{name}{i}={value[start + i]}" for i in range(start, end + 1, +1)]
        return sep.join(converted_parts)
    else:
        if not(reverse):
            converted_parts = [f"{name}{i}" for i in range(start, end - 1, -1)]
        else:
            converted_parts = [f"{name}{i}" for i in range(start, end + 1, +1)]
        return sep.join(converted_parts)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Использование: python3 range_converter.py <входной_файл> <выходной_файл>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    convert_text_file(input_file, output_file)

