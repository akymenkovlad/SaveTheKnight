//
//  Constants.swift
//  SaveTheKnight
//
//  Created by Valados on 17.01.2022.
//

import Foundation

let ArrowCategory: UInt32 =  0x1 << 1
let FloorCategory: UInt32 =  0x1 << 2
let PlayerCategory: UInt32 =  0x1 << 3
let WorldFrameCategory: UInt32 = 0x1 << 4
let CoinCategory: UInt32 = 0x1 << 5
let HeartCategory: UInt32 = 0x1 << 7
let EnemyCategory: UInt32 = 0x1 << 8
let GoldBonusCategory: UInt32 = 0x1 << 9
let InvulnerabilityBonusCategory: UInt32 = 0x1 << 10
let InvulnerablePlayerCategory: UInt32 = 0x1 << 11
let BonusCoinCategory: UInt32 = 0x1 << 12

let ScoreKey = "SAVEKNIGHT_HIGHSCORE"
let MuteKey = "SAVEKNIGHT_MUTED"
let CharacterKey = "CHARACTER_TEXTURE"
let EnemyKey = "ENEMY_TEXTURE"
let SoilKey = "SOIL_TEXTURE"
let BackgroundKey = "BACKGROUND_TEXTURE"
let ProjectileKey = "PROJECTILE_TEXTURE"
let ExtraProjectileKey = "EXTRA_PROJECTILE_TEXTURE"
let TexturesKey = "TEXTURES"
let FramesKey = "FRAMES_TEXTURES"
let EnemySoundKey = "ENEMY_SOUND"

let ArrowSpawnRate = 0.5
let EnemySpawnRate = 15.0

