from flask import Flask, request
import serial
import serial.tools.list_ports

app = Flask(__name__)

def connect_to_serial():
    ports = serial.tools.list_ports.comports()
    for port in ports:
        # print(port.description)
        if "USB Serial" in port.description:
            try:
                return serial.Serial(port.device, 115200) 
            except Exception as e:
                print("Connect failed:")
    return None

serial_connection = connect_to_serial()
if serial_connection is None:
    print("No device found!")
else:
    print(f"Connectd {serial_connection.port}")

@app.route('/send_command', methods=['GET'])
def send_command():
    if not serial_connection:
        return "Serial port no connected", 400

    command = request.args.get('command')+"\n"

    if command:
        try:
            serial_connection.write(command.encode())
            return "Send success"
        except Exception as e:
            return "Send failed"
    else:
        return "Invalid command"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
