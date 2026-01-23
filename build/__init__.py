#!/usr/bin/env python3

from dataclasses import dataclass
from os import path

import papyrus

@dataclass
class Settings:
    compiler: papyrus.CompilerSettings

def main(settings: Settings):
    papyrus.build_dir(settings.compiler, "Source/Scripts", "Scripts")

if __name__ == "__main__":
    GAME_DIR = "C:/Program Files (x86)/Steam/steamapps/common/Skyrim Special Edition"
    main(Settings(
        compiler=papyrus.CompilerSettings(
            compiler=path.join(GAME_DIR, "Papyrus Compiler/PapyrusCompiler.exe"),
            flagsfile=path.join(GAME_DIR, "Data/Source/Scripts/TESV_Papyrus_Flags.flg"),
            imports=[path.join(GAME_DIR, "Data/Source/Scripts")]
        )
    ))