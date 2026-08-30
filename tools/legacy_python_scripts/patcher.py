import os
import sys
import json
import shutil
import urllib.request
import subprocess
from pathlib import Path
from typing import Optional

def replace_trait_method(content: str, method_name: str, replacement: str) -> Optional[str]:
    content = content.replace("\r\n", "\n")
    lines = content.split("\n")
    
    start = -1
    for i, line in enumerate(lines):
        t = line.strip()
        if t.startswith("trait ") and f'"{method_name}"' in t:
            start = i
            break
            
    if start == -1:
        return None
        
    depth = 0
    end = -1
    for offset, line in enumerate(lines[start:]):
        t = line.strip()
        if t.startswith("trait "):
            if t.endswith(" end") or t == "end":
                continue
            depth += 1
        elif t.startswith("end ; trait"):
            depth = max(0, depth - 1)
            if depth == 0:
                end = start + offset
                break
                
    if end == -1:
        return None
        
    result = "\n".join(lines[:start])
    if result:
        result += "\n"
        
    result += replacement.rstrip() + "\n"
    
    tail = "\n".join(lines[end + 1:])
    if tail:
        result += tail
        
    if not result.endswith("\n"):
        result += "\n"
        
    return result

def clear_dir(path: Path):
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True, exist_ok=True)

def copy_dir(src: Path, dst: Path):
    if not src.exists():
        return
    dst.mkdir(parents=True, exist_ok=True)
    for item in src.iterdir():
        if item.is_dir():
            copy_dir(item, dst / item.name)
        else:
            shutil.copy2(item, dst / item.name)

def merge_patches(name: str):
    src = Path(f"pocket-patches/aqw/{name}")
    dst = Path(f"patches/{name}/bytecodes")
    if src.exists():
        if dst.exists():
            shutil.rmtree(dst)
        copy_dir(src, dst)

class Patcher:
    def __init__(self, name: str, source_url: str = None):
        self.name = name
        self.source_url = source_url

    def get_build_path(self) -> Path:
        return Path(f"patches/{self.name}/build")

    def get_bytecode_path(self) -> Path:
        return Path(f"patches/{self.name}/bytecodes")

    def get_build_rabcdasm_path(self) -> Path:
        return self.get_build_path() / f"{self.name}-0"

    def get_build_swf_path(self) -> Path:
        return self.get_build_path() / f"{self.name}.swf"
        
    def get_build_abc_path(self) -> Path:
        return self.get_build_path() / f"{self.name}-0.abc"

    def download(self):
        print(f"[{self.name}] Fetching download URL...")
        url = self.source_url
        if url is None:
            req = urllib.request.Request("https://game.aq.com/game/api/data/gameversion", headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req) as response:
                data = json.loads(response.read().decode())
                url = f"https://game.aq.com/game/gamefiles/{data['sFile']}"
                
        print(f"[{self.name}] Downloading {url}...")
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response, open(self.get_build_swf_path(), 'wb') as out_file:
            shutil.copyfileobj(response, out_file)
        print(f"[{self.name}] Downloaded successfully")

    def export_bytecode(self):
        print(f"[{self.name}] Running abcexport on {self.get_build_swf_path()}")
        subprocess.run(["abcexport", str(self.get_build_swf_path())], check=True)
        print(f"[{self.name}] Running rabcdasm on {self.get_build_abc_path()}")
        subprocess.run(["rabcdasm", str(self.get_build_abc_path())], check=True)

    def apply_method_to_file(self, build_dir: Path, class_file: str, method_name: str, replacement: str):
        if not build_dir.exists():
            return
        for item in build_dir.iterdir():
            if item.is_dir():
                self.apply_method_to_file(item, class_file, method_name, replacement)
            elif item.name == class_file:
                content = item.read_text(encoding='utf-8')
                new_content = replace_trait_method(content, method_name, replacement)
                if new_content:
                    print(f"[{self.name}] Applying method patch {method_name} to {item}")
                    item.write_text(new_content, encoding='utf-8')

    def apply_method_to_build(self, build_dir: Path, method_name: str, replacement: str):
        if not build_dir.exists():
            return
        for item in build_dir.iterdir():
            if item.is_dir():
                self.apply_method_to_build(item, method_name, replacement)
            elif item.suffix == ".asasm":
                content = item.read_text(encoding='utf-8')
                new_content = replace_trait_method(content, method_name, replacement)
                if new_content:
                    print(f"[{self.name}] Applying method patch {method_name} to {item}")
                    item.write_text(new_content, encoding='utf-8')

    def apply_methods(self, bytecode_dir: Path, build_dir: Path):
        if not bytecode_dir.exists():
            return
            
        target_class = None
        if bytecode_dir.name.endswith(".class.asasm"):
            target_class = bytecode_dir.name
            
        for item in bytecode_dir.iterdir():
            if item.is_dir():
                self.apply_methods(item, build_dir)
                continue
                
            if not item.name.endswith(".method.asasm"):
                continue
                
            method_name = item.name[:-13] # len(".method.asasm")
            replacement = item.read_text(encoding='utf-8')
            
            if target_class:
                self.apply_method_to_file(build_dir, target_class, method_name, replacement)
            else:
                self.apply_method_to_build(build_dir, method_name, replacement)

    def copy_files(self, source_dir: Path, target_dir: Path):
        if not source_dir.exists():
            return
            
        for item in source_dir.iterdir():
            if item.is_dir():
                self.copy_files(item, target_dir)
                continue
                
            if item.name.endswith(".copy.asasm"):
                dest_name = item.name.replace(".copy.asasm", ".asasm")
                dest = target_dir / dest_name
                print(f"[{self.name}] Copying patch {dest.name} to {dest}")
                shutil.copy2(item, dest)

    def start(self):
        main_asasm = self.get_build_rabcdasm_path() / f"{self.name}-0.main.asasm"
        print(f"[{self.name}] Assembling {main_asasm}")
        subprocess.run(["rabcasm", str(main_asasm)], check=True)
        
        main_abc = self.get_build_rabcdasm_path() / f"{self.name}-0.main.abc"
        print(f"[{self.name}] Replacing ABC in SWF")
        subprocess.run(["abcreplace", str(self.get_build_swf_path()), "0", str(main_abc)], check=True)
        
        output_swf = Path(f"loader/gamefiles/{self.name}.swf")
        output_swf.parent.mkdir(parents=True, exist_ok=True)
        if output_swf.exists():
            output_swf.unlink()
            
        print(f"[{self.name}] Moving SWF to {output_swf}")
        self.get_build_swf_path().rename(output_swf)

    def build(self):
        print(f"[{self.name}] Starting build")
        clear_dir(self.get_build_path())
        self.download()
        self.export_bytecode()
        
        self.apply_methods(self.get_bytecode_path(), self.get_build_rabcdasm_path())
        print(f"[{self.name}] Patches methods applied")
        
        self.copy_files(self.get_bytecode_path(), self.get_build_rabcdasm_path())
        print(f"[{self.name}] Patches copied")
        
        self.start()
        print(f"[{self.name}] Build complete")

def main():
    merge_patches("game")
    merge_patches("world-map")
    merge_patches("book-of-lore")
    merge_patches("character-select")
    
    Patcher("game").build()
    Patcher("world-map", "https://game.aq.com/game/gamefiles/news/Map-UI_r38.swf").build()
    Patcher("book-of-lore", "https://game.aq.com/game/gamefiles/news/spiderbook3.swf").build()
    Patcher("character-select", "https://game.aq.com/game/gamefiles/interface/CharSelect/charselect.swf").build()

if __name__ == "__main__":
    main()

