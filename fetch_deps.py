import urllib.request
import zipfile
import os
import shutil

def download_and_extract(url, extract_to, subfolder=None):
    zip_path = "temp.zip"
    print(f"Downloading {url}...")
    headers = {"User-Agent": "Mozilla/5.0"}
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req) as response, open(zip_path, 'wb') as out_file:
        shutil.copyfileobj(response, out_file)
    print("Extracting...")
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        if subfolder:
            for member in zip_ref.namelist():
                if member.startswith(subfolder):
                    zip_ref.extract(member, extract_to)
        else:
            zip_ref.extractall(extract_to)
    os.remove(zip_path)

if __name__ == "__main__":
    libs_dir = "libs"
    os.makedirs(libs_dir, exist_ok=True)
    
    # imgui
    if not os.path.exists(f"{libs_dir}/imgui-1.86"):
        download_and_extract("https://github.com/ocornut/imgui/archive/refs/tags/v1.86.zip", libs_dir)

    # glm
    if not os.path.exists(f"{libs_dir}/glm-0.9.9.8"):
        download_and_extract("https://github.com/g-truc/glm/archive/refs/tags/0.9.9.8.zip", libs_dir)

    # glfw binary for win64
    if not os.path.exists(f"{libs_dir}/glfw-3.3.9.bin.WIN64"):
        download_and_extract("https://github.com/glfw/glfw/releases/download/3.3.9/glfw-3.3.9.bin.WIN64.zip", libs_dir)

    # glew binary for win64
    if not os.path.exists(f"{libs_dir}/glew-2.2.0"):
        download_and_extract("https://github.com/nigels-com/glew/releases/download/glew-2.2.0/glew-2.2.0-win32.zip", libs_dir)

    # stb_image
    os.makedirs(f"{libs_dir}/stb", exist_ok=True)
    stb_path = f"{libs_dir}/stb/stb_image.h"
    if not os.path.exists(stb_path):
        print("Downloading stb_image.h...")
        urllib.request.urlretrieve("https://raw.githubusercontent.com/nothings/stb/master/stb_image.h", stb_path)

    print("All dependencies downloaded.")
