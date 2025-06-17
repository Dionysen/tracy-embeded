import requests
import os
import zipfile
import subprocess
import sys

project_root = os.path.abspath(
    os.path.join(os.path.dirname(__file__), ""))
sys.path.append(project_root)
external_dir = os.path.join(project_root, "dionysen/external")


def install_deps():
    print("Installing dependencies...")
    requirements_path = os.path.join(
        project_root, "scripts/python/requirements.txt")
    subprocess.check_call(
        [sys.executable, "-m", "pip", "install", "-i", "https://pypi.tuna.tsinghua.edu.cn/simple", "-r", requirements_path])


install_deps()


def download_file(name: str, url: str, save_path: str):
    if os.path.exists(save_path):
        print(f"{name} already exists at: {save_path}")
        return True

    try:
        # send GET request to get file
        response = requests.get(url, stream=True)
        response.raise_for_status()  # check if request is successful

        # ensure the directory of save path exists
        os.makedirs(os.path.dirname(save_path), exist_ok=True)

        # get file size
        total_size = int(response.headers.get('content-length', 0))
        block_size = 8192

        try:
            from tqdm import tqdm
            t = tqdm(total=total_size, unit='B', unit_scale=True)
        except ImportError:
            t = None

        with open(save_path, 'wb') as file:
            for data in response.iter_content(block_size):
                if not data:
                    break
                file.write(data)
                if t:
                    t.update(len(data))
        if t:
            t.close()
            if total_size != 0 and t.n != total_size:
                raise Exception("Download file size mismatch")

        print(f"{name} downloaded to: {save_path}")
        return True

    except requests.exceptions.RequestException as e:
        print(f"Download failed: {e}")
        return False


def unzip_file(zip_path: str, extract_path: str):
    print(f"Unzipping {zip_path} to {extract_path}...")
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extract_path)


def clear_file(file_path: str):
    print(f"Clearing file {file_path}...")
    if os.path.exists(file_path):
        os.remove(file_path)
        print(f"File {file_path} removed")


# Install external =====================================================

url_prefix = "https://gaid-data.obs.cn-north-4.myhuaweicloud.com/ide/dwg/lib/"

deps = ["stb_image",
        "spdlog",
        "imgui-docking",
        "entt",
        "mono",
        "msdf-atlas-gen",
        "imguizmo",
        "glm",
        "glfw"]


def install_external(name: str, url: str, save_path: str, extract_path: str):
    download_file(name, url, save_path)
    unzip_file(save_path, extract_path)
    clear_file(save_path)


if __name__ == "__main__":
    install_deps()

    if not os.path.exists(external_dir):
        os.makedirs(external_dir)

    for name in deps:
        save_path = os.path.join(external_dir, f"{name}.zip")
        url = url_prefix + name + ".zip"
        install_external(name, url, save_path, external_dir)
