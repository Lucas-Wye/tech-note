import os
import hashlib
import uuid

def calculate_file_hash(file_path):
    """计算文件的SHA-256哈希值"""
    sha256_hash = hashlib.sha256()
    with open(file_path, "rb") as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()

def rename_file_with_random_name(file_path):
    """将文件重命名为随机名称，保留扩展名"""
    file_dir, file_name = os.path.split(file_path)
    file_ext = os.path.splitext(file_name)[1]
    random_name = str(uuid.uuid4()) + file_ext
    new_file_path = os.path.join(file_dir, random_name)
    os.rename(file_path, new_file_path)
    return new_file_path

def process_folder(folder_path):
    """遍历文件夹中的所有文件，计算哈希值并重命名"""
    for root, dirs, files in os.walk(folder_path):
        for file_name in files:
            file_path = os.path.join(root, file_name)
            file_hash = calculate_file_hash(file_path)
            new_file_path = rename_file_with_random_name(file_path)
            print(f"File: {file_path}")
            print(f"SHA-256 Hash: {file_hash}")
            print(f"Renamed to: {new_file_path}")
            print("-" * 40)

if __name__ == "__main__":
    folder_path = input("请输入文件夹路径: ")
    if os.path.isdir(folder_path):
        process_folder(folder_path)
    else:
        print("指定的路径不是一个有效的文件夹。")
