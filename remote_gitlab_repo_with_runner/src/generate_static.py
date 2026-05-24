#!/usr/bin/env python3
import qrcode
from PIL import Image, ImageDraw, ImageFont
import hashlib
import subprocess
import datetime

# Получаем информацию из коммита
commit_hash = subprocess.check_output(['git', 'rev-parse', 'HEAD']).decode().strip()[:8]
commit_message = subprocess.check_output(['git', 'log', '-1', '--pretty=%B']).decode().strip()

# Читаем данные из файла в репозитории (если есть)
try:
    with open('data.txt', 'r') as f:
        custom_data = f.read().strip()
except:
    custom_data = "No custom data"

# Генерируем QR-код с информацией о коммите
qr = qrcode.QRCode(version=1, box_size=10, border=5)
qr_data = f"Commit: {commit_hash}\nMessage: {commit_message}\nTime: {datetime.datetime.now()}"
qr.add_data(qr_data)
qr.make(fit=True)
qr_img = qr.make_image(fill_color="black", back_color="white")

# Создаем и сохраняем только QR-код
qr.make_image(fill_color="black", back_color="white").save('src/generated_image.png')

# Генерируем HTML страницу
with open('src/index.template.html', 'r') as f:
    html_template = f.read()

html_content = html_template.format(
    commit_hash=commit_hash,
    commit_message=commit_message,
    custom_data=custom_data,
    build_time=datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
)

with open('src/index.html', 'w') as f:
    f.write(html_content)

print("Static files generated successfully")