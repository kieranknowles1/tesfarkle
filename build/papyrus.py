from dataclasses import dataclass
import subprocess

@dataclass
class CompilerSettings:
    compiler: str
    flagsfile: str
    imports: list[str]

def build_dir(settings: CompilerSettings, input: str, output: str):
    imports = ";".join(settings.imports + [input])
    subprocess.run([
        settings.compiler, input, "-all", f"-import={imports}", f"-flags={settings.flagsfile}",
        f"-output={output}"
    ], check=True)