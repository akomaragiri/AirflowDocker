import os

input_dir = os.environ['DBGAP_INPUT_FILES']
output_dir = os.environ['DBGAP_OUTPUT_FILES']

def process_files(*op_args):
    print('Version 0.2')
    print('The input directory is {dir}.'.format(dir=input_dir))
    for r, d, f in os.walk(input_dir):
        for item in f:
            print(item)
            if '.txt' in item:
                write_output_file(item)
            else:
                write_error_file(item)

def write_output_file(file_item):
    lines_count = 0
    with open(os.path.join(input_dir, file_item),'r') as fileItem:
        for line in fileItem:
            lines_count = lines_count + 1
    
    output_file_name = get_output_file_name(file_item, True)
    print(output_file_name)

    with open(output_file_name, 'w') as output_file:
        output_file.write("Total number of lines: {} ".format(lines_count))

def write_error_file(file_item):

    output_file_name = get_output_file_name(file_item, False)
    print(output_file_name)

    with open(output_file_name, 'w') as output_file:
        output_file.write("Invalid File format")


def get_output_file_name(file_item, is_txt):
    file_item_name = os.path.splitext(file_item)[0]
    file_item_ext = os.path.splitext(file_item)[1]
    
    if is_txt:
        return os.path.join(output_dir, file_item_name) + '_output' + file_item_ext

    return os.path.join(output_dir, file_item_name) + '_error.txt'
