import subprocess
import re
import shutil
import os

# 执行shell命令并获取输出
def run_command(command):
    try:
        output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT).decode("utf-8")
        return output
    except subprocess.CalledProcessError as e:
        return e.output.decode("utf-8")

# 从输出中获取canbus_uuids
def extract_uuids(output):
    uuids = re.findall(r"canbus_uuid=(\w+)", output)
    return uuids

# 备份配置文件
def backup_config_file(filename):
    backup_filename = filename + ".backup"
    shutil.copy2(filename, backup_filename)

# 修改配置文件
def modify_config_file(filename, uuid):
    with open(filename, 'r') as file:
        lines = file.readlines()

    # 替换配置文件中的canbus_uuid
    for index, line in enumerate(lines):
        if "canbus_uuid:" in line:
            lines[index] = f"canbus_uuid: {uuid}\n"
            break

    # 写回到文件
    with open(filename, 'w') as file:
        file.writelines(lines)

# 主程序
def main():
    config_path = "/home/pi/printer_data/config/magneto_toolhead.cfg"
    
    # 检查文件是否存在
    if not os.path.exists(config_path):
        print(f"{config_path} not found!")
        return

    # 执行备份
    backup_config_file(config_path)

    command = "/home/pi/klippy-env/bin/python /home/pi/klipper/scripts/canbus_query.py can0"
    output = run_command(command)
    uuids = extract_uuids(output)

    # 判断uuids的数量并取适当的值
    if len(uuids) > 0:
        uuid_to_use = uuids[-1]
        modify_config_file(config_path, uuid_to_use)
    else:
        print("No canbus_uuid found!")

if __name__ == "__main__":
    main()
