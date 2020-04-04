import os

input_dir = '/usr/local/airflow/input_files/'
output_dir = '/usr/local/airflow/output_files/'

def my_func(*op_args):
    for r, d, f in os.walk(input_dir):
        for item in f:
            print(item)
            if '.txt' in item:
                #print(item)
                #print(type(item))
                #files_in_dir.append(item)
                write_output_file(item)
            else:
                write_error_file(item)
    #print(op_args)
    #for item in op_args:
    #    print("file in dir: ", item)
    #    write_output_file(item)

def write_output_file(file_item):
    lines_count = 0
    with open(input_dir+file_item,'r') as fileItem:
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
        return output_dir + file_item_name + '_output' + file_item_ext

    return output_dir + file_item_name + '_error.txt'


