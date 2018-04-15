import
  nimgame2 / [
    assets,
    nimgame,
    entity,
    graphic,
    input,
    scene,
    settings,
    textgraphic,
    tween,
    types,
  ],
  arena,
  ../data,
  ../character,
  ../gong,
  ../keybuffer


type
  TitleScene = ref object of Scene
    bg: Entity
    player: Character
    gong1P, gong2P, gongExit: Gong


var
  exitTimer = 1.5
  exitSwitch = false


proc getCharacters(): seq[Entity] =
  game.scene.findAll "character"


proc init*(scene: TitleScene) =
  init Scene scene

  # bg
  scene.bg = newEntity()
  scene.bg.graphic = gfxData["bg"]
  scene.bg.layer = -100
  scene.add scene.bg

  # title
  let title = newEntity()
  title.graphic = newTextGraphic(defaultFont)
  TextGraphic(title.graphic).setText GameTitle
  TextGraphic(title.graphic).color = Color(r: 191, g: 0, b: 0, a: 255)
  title.centrify HAlign.center, VAlign.top
  title.pos = (GameDim.w div 2, 32)
  scene.add title

  # info
  let info = newEntity()
  info.graphic = newTextGraphic(smallFont)
  TextGraphic(info.graphic).color = Color(r: 31, g: 31, b: 31, a: 255)
  TextGraphic(info.graphic).lines = [
    "Player 1 controls: 'X' and 'Z', Player 2 controls: '<' and '>'",
    "Hold - walk, Tap - block",
    "Double tap - hit",
    "Two-button combo - dodge"
  ]
  info.pos = (5.0, 5.0)
  scene.add info

  # game info
  let gameInfo = newEntity()
  gameInfo.graphic = newTextGraphic(smallFont)
  TextGraphic(gameInfo.graphic).setText GameInfo
  gameInfo.centrify HAlign.left, VAlign.bottom
  gameInfo.pos = (5.0, float GameDim.h - 5)
  scene.add gameInfo

  # player
  scene.player = newCharacter(gfxData["player"], player1=true)
  scene.player.getCharacters = getCharacters
  scene.player.pos = GameDim / 2
  scene.player.pos.x = 0.0
  scene.add scene.player

  # gongs
  let gongOffset = (-10.0, -10.0)
  scene.gong1P = newGong(gfxData["gong"], 0, proc() =
    ArenaScene(arenaScene).twoPlayers = false
    game.scene = arenaScene)
  scene.gong1P.pos = GameDim / (4, 3)
  scene.gong1P.pos += gongOffset
  scene.add scene.gong1P

  let title1P = newEntity()
  title1P.graphic = newTextGraphic defaultFont
  TextGraphic(title1P.graphic).setText "1P"
  TextGraphic(title1P.graphic).color = Color(r: 225, g: 127, b: 31, a: 255)
  title1P.centrify(HAlign.center, VAlign.bottom)
  title1P.pos = scene.gong1P.pos
  title1P.pos += (90.0, 30.0)
  scene.add title1P

  scene.gong2P = newGong(gfxData["gong"], 1, proc() =
    ArenaScene(arenaScene).twoPlayers = true
    game.scene = arenaScene)
  scene.gong2P.pos = GameDim / (2, 3)
  scene.gong2P.pos += gongOffset
  scene.add scene.gong2P

  let title2P = newEntity()
  title2P.graphic = newTextGraphic defaultFont
  TextGraphic(title2P.graphic).setText "2P"
  TextGraphic(title2P.graphic).color = Color(r: 225, g: 127, b: 31, a: 255)
  title2P.centrify(HAlign.center, VAlign.bottom)
  title2P.pos = scene.gong2P.pos
  title2P.pos += (90.0, 30.0)
  scene.add title2P

  scene.gongExit = newGong(gfxData["gong"], 2, proc() =
    exitSwitch = true)
  scene.gongExit.pos = GameDim / (8, 3)
  scene.gongExit.pos.x *= 6
  scene.gongExit.pos += gongOffset
  scene.add scene.gongExit

  let titleExit = newEntity()
  titleExit.graphic = newTextGraphic defaultFont
  TextGraphic(titleExit.graphic).setText "Exit"
  TextGraphic(titleExit.graphic).color = Color(r: 225, g: 127, b: 31, a: 255)
  titleExit.centrify(HAlign.center, VAlign.bottom)
  titleExit.pos = scene.gongExit.pos
  titleExit.pos += (90.0, 30.0)
  scene.add titleExit


proc free*(scene: TitleScene) =
  scene.player.pos = GameDim / (8, 2)
  scene.player.pos.x = 0.0


method show*(scene: TitleScene) =
  scene.player.pos.x = 0.0
  flush scene.player.keyBuffer
  scene.player.play("idle")
  scene.player.resetHitCollider()


proc newTitleScene*(): TitleScene =
  new result, free
  init result


method update*(scene: TitleScene, elapsed: float) =
  scene.updateScene elapsed
  if ScancodeF10.pressed:
    colliderOutline = not colliderOutline
  if ScancodeF11.pressed:
    showInfo = not showInfo
  if exitSwitch:
    exitTimer -= elapsed
    if exitTimer <= 0.0:
      gameRunning = false

