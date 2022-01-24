//
//  Constants.swift
//  SaveTheKnight
//
//  Created by Valados on 17.01.2022.
//

import Foundation

let ArrowCategory: UInt32 =  0x1 << 1
let FloorCategory: UInt32 =  0x1 << 2
let KnightCategory: UInt32 =  0x1 << 3
let WorldFrameCategory: UInt32 = 0x1 << 4
let CoinCategory: UInt32 = 0x1 << 5
let BombCategory: UInt32 = 0x1 << 6
let HeartCategory: UInt32 = 0x1 << 7
let EnemyCategory: UInt32 = 0x1 << 8
let GoldBonusCategory: UInt32 = 0x1 << 9
let InvulnerabilityBonusCategory: UInt32 = 0x1 << 10
let InvulnerableKnightCategory: UInt32 = 0x1 << 11

let ScoreKey = "SAVEKNIGHT_HIGHSCORE"
let MuteKey = "SAVEKNIGHT_MUTED"
let CharacterKey = "CHARACTER_TEXTURE"
let TexturesKey = "TEXTURES"

let ArrowSpawnRate = 1.0
let BombSpawnRate = 15.0
let EnemySpawnRate = 15.0

