import
  nimgame2 / [
    assets,
    nimgame,
    entity,
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
  ../gong


type
  TitleScene = ref object of Scene
    bg: Entity
    titleText: TextGraphic
    title: Entity
    player: Character
    gong1P, gong2P, gongExit: Gong


proc getCharacters(): seq[Entity] =
  game.scene.findAll "character"


proc init*(scene: TitleScene) =
  init Scene scene

  # bg
  scene.bg = newEntity()
  scene.bg.graphic = gfxData["bg_title"]
  scene.bg.layer = -100
  scene.add scene.bg

  # title
  scene.titleText = newTextGraphic defaultFont
  scene.titleText.setText GameTitle
  scene.title = newEntity()
  scene.title.graphic = scene.titleText
  scene.title.centrify HAlign.center, VAlign.top
  scene.title.pos = (GameDim.w div 2, 32)
  scene.add scene.title

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

  scene.gong2P = newGong(gfxData["gong"], 1, proc() =
    ArenaScene(arenaScene).twoPlayers = true
    game.scene = arenaScene)
  scene.gong2P.pos = GameDim / (2, 3)
  scene.gong2P.pos += gongOffset
  scene.add scene.gong2P

  scene.gongExit = newGong(gfxData["gong"], 2, proc() = echo "gong Exit")
  scene.gongExit.pos = GameDim / (8, 3)
  scene.gongExit.pos.x *= 6
  scene.gongExit.pos += gongOffset
  scene.add scene.gongExit


proc free*(scene: TitleScene) =
  scene.player.pos = GameDim / (8, 2)
  scene.player.pos.x = 0.0


method show*(scene: TitleScene) =
  scene.player.pos.x = 0.0


proc newTitleScene*(): TitleScene =
  new result, free
  init result


method update*(scene: TitleScene, elapsed: float) =
  scene.updateScene elapsed
  if ScancodeF10.pressed:
    colliderOutline = not colliderOutline
  if ScancodeF11.pressed:
    showInfo = not showInfo

