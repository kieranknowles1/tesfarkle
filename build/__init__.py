#!/usr/bin/env python3

from dataclasses import dataclass
from argparse import ArgumentParser
from os.path import join

import papyrus, plugin

BUILD_DIR = "result"
DEV_DIR = "."
GAME_DIR = "C:/Program Files (x86)/Steam/steamapps/common/Skyrim Special Edition"

class Arguments(ArgumentParser):
    def __init__(self):
        ArgumentParser.__init__(self, prog="build", description="Build assets for Farkle")

        self.add_argument("-d", "--dev", action="store_true")
        args = self.parse_args()
        self.dev: bool = args.dev

@dataclass
class Settings:
    compiler: papyrus.CompilerSettings | None
    plugin: list[plugin.PluginSettings] | None

def main(args: Arguments, settings: Settings):
    if settings.compiler:
        papyrus.build_dir(settings.compiler)
    if settings.plugin:
        for pluginsrc in settings.plugin:
            plugin.build_plugin(pluginsrc)

if __name__ == "__main__":
    args = Arguments()
    result = BUILD_DIR if not args.dev else DEV_DIR

    # Always build scripts, .pex is safe to overwrite
    compiler = papyrus.CompilerSettings(
            compiler=join(GAME_DIR, "Papyrus Compiler/PapyrusCompiler.exe"),
            flagsfile=join(GAME_DIR, "Data/Source/Scripts/TESV_Papyrus_Flags.flg"),
            imports=[join(GAME_DIR, "Data/Source/Scripts")],
            src_dir="Source/Scripts",
            dst_dir=join(result, "Scripts"),
        )
    # Only build the ESP in release versions, devs must manually copy otherwise
    # to avoid risk of overwriting work
    esp = [
        plugin.PluginSettings(
            source="plugindata",
            destination=join(result, "farkle.esp"),
        ),
        plugin.PluginSettings(
            source="plugindata-bsheartland",
            destination=join(result, "farkle-bsheartland.esp"),
        ),
        ] if not args.dev else None

    main(args, Settings(compiler, esp))