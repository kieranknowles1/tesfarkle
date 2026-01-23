from dataclasses import dataclass
import subprocess

@dataclass
class PluginSettings:
    source: str
    destination: str

def build_plugin(settings: PluginSettings):
    subprocess.run([
        "Spriggit.CLI.exe", "create-plugin",
        "--InputPath", settings.source,
        "--OutputPath", settings.destination
    ], check=True)