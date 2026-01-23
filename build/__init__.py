#!/usr/bin/env python3

from dataclasses import dataclass
from os.path import join

import papyrus, plugin

BUILD_DIR = "result"
GAME_DIR = "C:/Program Files (x86)/Steam/steamapps/common/Skyrim Special Edition"

@dataclass
class Settings:
    compiler: papyrus.CompilerSettings
    plugin: plugin.PluginSettings

def main(settings: Settings):
    papyrus.build_dir(settings.compiler)
    plugin.build_plugin(settings.plugin)

if __name__ == "__main__":
    main(Settings(
        compiler=papyrus.CompilerSettings(
            compiler=join(GAME_DIR, "Papyrus Compiler/PapyrusCompiler.exe"),
            flagsfile=join(GAME_DIR, "Data/Source/Scripts/TESV_Papyrus_Flags.flg"),
            imports=[join(GAME_DIR, "Data/Source/Scripts")],
            src_dir="Source/Scripts",
            dst_dir=join(BUILD_DIR, "Scripts"),
        ),
        plugin=plugin.PluginSettings(
            source="plugindata",
            destination=join(BUILD_DIR, "farkle.esp"),
        )
    ))