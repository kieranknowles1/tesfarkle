from dataclasses import dataclass
import subprocess

@dataclass
class CompilerSettings:
    compiler: str
    flagsfile: str
    imports: list[str]
    src_dir: str
    dst_dir: str

def build_dir(settings: CompilerSettings):
    imports = ";".join(settings.imports + [settings.src_dir])
    subprocess.run([
        settings.compiler, settings.src_dir, "-all",
        f"-import={imports}", f"-flags={settings.flagsfile}",
        f"-output={settings.dst_dir}"
    ], check=True, stdout=subprocess.DEVNULL)