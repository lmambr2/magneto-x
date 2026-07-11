import subprocess
import shutil
import glob
import os

CONFIG_PATH = "/home/pi/printer_data/config/printer.cfg"
BACKUP_PATH = "/home/pi/printer_data/config/printer.cfg.bak"

def get_serial_devices():
    devices = glob.glob('/dev/serial/by-id/*')
    return devices

def backup_config():
    # 备份printer.cfg为printer.cfg.bak
    shutil.copy2(CONFIG_PATH, BACKUP_PATH)

def update_config_file(devices):
    if not devices:
        return

    with open(CONFIG_PATH, 'r') as file:
        content = file.readlines()

    # 检查是否有[mcu]段落，如果有则更新，否则添加
    mcu_section_found = False
    for index, line in enumerate(content):
        if line.strip() == '[mcu]':
            mcu_section_found = True
            # 查找serial:行并更新
            while "serial:" not in content[index] and content[index].strip() != "":
                index += 1
            if "serial:" in content[index]:
                content[index] = "serial: {}\n".format(devices[0])
                break

    # 如果没有找到[mcu]段落，则添加
    if not mcu_section_found:
        content.append("\n[mcu]\n")
        content.append("serial: {}\n".format(devices[0]))

    with open(CONFIG_PATH, 'w') as file:
        file.writelines(content)

def main():
    if not os.path.exists(CONFIG_PATH):
        print("Error: Config file not found at", CONFIG_PATH)
        return

    devices = get_serial_devices()
    backup_config()
    update_config_file(devices)

if __name__ == '__main__':
    main()
